// lib/services/melody_generator_service.dart
import 'package:flutter/material.dart';
import 'package:collection/collection.dart'; // Adicione esta importação para comparar listas
import 'audio_service.dart';

// --- NOVO: Classe para modelar cada nível do jogo ---
class GameLevel {
  final int iconCount;
  final bool withRepetition;
  final bool hasHint; // Define se o primeiro ícone é mostrado ou se são todos '?'

  GameLevel({
    required this.iconCount,
    required this.withRepetition,
    this.hasHint = true,
  });
}

// --- ATUALIZADO: Adicionado 'playingLevels' e 'levelComplete' ---
enum GeneratorState {
  selectingIcons,
  selectingMode,
  playingFreePlay, // Renomeado de playingGame para clareza
  playingLevels,   // Novo estado para o modo de desafio
  levelComplete,   // Estado intermediário para mostrar feedback
  gameWon,
}

enum ValidationState {
  neutral,
  correct,
  incorrect,
}

class MelodyGeneratorController extends ChangeNotifier {
  final AudioService _audioService;

  MelodyGeneratorController({required AudioService audioService})
      : _audioService = audioService;

  // --- Definição dos Níveis do Jogo ---
  final List<GameLevel> _levels = [
    // Bloco 1: Sem Repetição
    GameLevel(iconCount: 2, withRepetition: false, hasHint: true),  // Nível 1: Dois ícones sem repetição com dica
    GameLevel(iconCount: 3, withRepetition: false, hasHint: true),  // Nível 2: Três ícones sem repetição com dica
    GameLevel(iconCount: 2, withRepetition: false, hasHint: false), // Nível 3: Dois ícones sem repetição sem dica
    GameLevel(iconCount: 3, withRepetition: false, hasHint: false), // Nível 4: Três ícones sem repetição sem dica

    // Bloco 2: Com Repetição
    GameLevel(iconCount: 2, withRepetition: true, hasHint: true),   // Nível 5: Dois ícones com repetição com dica
    GameLevel(iconCount: 3, withRepetition: true, hasHint: true),   // Nível 6: Três ícones com repetição com dica
    GameLevel(iconCount: 2, withRepetition: true, hasHint: false),  // Nível 7: Dois ícones com repetição sem dica
    GameLevel(iconCount: 3, withRepetition: true, hasHint: false),  // Nível 8: Três ícones com repetição sem dica
  ];

  // --- Estado do Jogo ---
  GeneratorState _state = GeneratorState.selectingIcons;
  Set<String> _selectedIcons = {};
  List<List<String>> _generatedMelodies = [];
  int? _currentlyPlayingIndex;

  // --- Variáveis para a Lógica do Jogo ---
  List<String> _currentUserInput = [];
  List<bool> _completedMelodies = [];
  int _currentTargetMelodyIndex = 0;
  ValidationState _validationState = ValidationState.neutral;
  
  // --- NOVAS Variáveis para o Modo de Níveis ---
  int _currentLevelIndex = 0;
  List<String> _activeIconsForCurrentLevel = [];

  // --- Getters Públicos ---
  GeneratorState get state => _state;
  Set<String> get selectedIcons => _selectedIcons;
  List<List<String>> get generatedMelodies => _generatedMelodies;
  int? get currentlyPlayingIndex => _currentlyPlayingIndex;
  List<String> get currentUserInput => _currentUserInput;
  List<bool> get completedMelodies => _completedMelodies;
  int get currentTargetMelodyIndex => _currentTargetMelodyIndex;
  ValidationState get validationState => _validationState;
  
  // Getters para o modo de níveis
  bool get isLevelsMode => _state == GeneratorState.playingLevels || _state == GeneratorState.levelComplete;
  int get currentLevelIndex => _currentLevelIndex;
  GameLevel get currentLevel => _levels[_currentLevelIndex];
  int get totalLevels => _levels.length;
  List<String> get activeIconsForLevel => _activeIconsForCurrentLevel;


  final List<String> availableIcons = [
    "BaterPalma", "BaterPe", "BaterPeito", "BaterPerna",
    "Gritar", "Beijo", "Assobiar", "EstalarDedo",
    "EstalarLingua1", "EstalarLingua2"
  ];

  // --- Ações do Usuário ---

  void toggleIconSelection(String iconType) {
    if (_selectedIcons.contains(iconType)) {
      _selectedIcons.remove(iconType);
    } else {
      if (_selectedIcons.length < 3) {
        _selectedIcons.add(iconType);
      }
    }
    notifyListeners();
  }

  void confirmIconSelection() {
    if (_selectedIcons.length >= 2) {
      _state = GeneratorState.selectingMode;
      notifyListeners();
    }
  }

  // --- Lógica de Início de Jogo ---

  void startFreePlayMode(bool withRepetition) {
    final items = _selectedIcons.toList();
    _activeIconsForCurrentLevel = items;
    
    if (withRepetition) {
      _generatedMelodies = _generatePermutationsWithRepetition(items, items.length);
    } else {
      _generatedMelodies = _generatePermutationsWithoutRepetition(items);
    }

    _generatedMelodies.sort((a, b) => a.join().compareTo(b.join()));
    _completedMelodies = List<bool>.generate(_generatedMelodies.length, (_) => false);
    _currentUserInput = [];
    _currentTargetMelodyIndex = 0;
    _validationState = ValidationState.neutral;

    _state = GeneratorState.playingFreePlay;
    notifyListeners();
  }

  void startLevelsMode() {
    _currentLevelIndex = 0;
    _setupCurrentLevel();
    _state = GeneratorState.playingLevels;
    notifyListeners();
  }

  // --- Ações do Jogo Interativo ---

  void handleIconTap(String iconType) {
    if (_validationState == ValidationState.incorrect || _state == GeneratorState.gameWon || _state == GeneratorState.levelComplete) return;

    _currentUserInput.add(iconType);
    _playIconSound(iconType);
    _validateInput();
    notifyListeners();
  }
  
  void clearUserInput() {
      _currentUserInput.clear();
      _validationState = ValidationState.neutral;
      notifyListeners();
  }
  
  void _validateInput() {
    if (_generatedMelodies.isEmpty) return;

    final int targetLength = _generatedMelodies.first.length;
    
    if (_currentUserInput.length != targetLength) {
      return; 
    }
    
    int? matchedIndex;
    for (int i = 0; i < _generatedMelodies.length; i++) {
        if (!_completedMelodies[i] &&
            const ListEquality().equals(_generatedMelodies[i], _currentUserInput)) {
            matchedIndex = i;
            break; 
        }
    }

    if (matchedIndex != null) {
      // --- RESPOSTA CORRETA ---
      _validationState = ValidationState.correct;
      // <<< ALTERAÇÃO AQUI: Tocar som de acerto usando o novo método de feedback >>>
      // Isso evita que o som do ícone seja cortado.
      _audioService.playFeedbackAudio('assets/sounds/correto.mp3');
      _completedMelodies[matchedIndex] = true;

      _currentTargetMelodyIndex = matchedIndex; 
      notifyListeners();

      Future.delayed(const Duration(milliseconds: 800), () {
        if(_state != GeneratorState.playingFreePlay && _state != GeneratorState.playingLevels) return;

        _currentUserInput.clear(); 
        _validationState = ValidationState.neutral;
        
        _findNextTarget(); 
        notifyListeners();
      });

    } else {
      // --- RESPOSTA INCORRETA ---
      _validationState = ValidationState.incorrect;
      // <<< ALTERAÇÃO AQUI: Tocar som de erro usando o novo método de feedback >>>
      // Isso evita que o som do ícone seja cortado.
      _audioService.playFeedbackAudio('assets/sounds/errado.mp3');
      notifyListeners();
      
      Future.delayed(const Duration(milliseconds: 800), () {
        if(_state != GeneratorState.playingFreePlay && _state != GeneratorState.playingLevels) return;

        _currentUserInput.clear();
        _validationState = ValidationState.neutral;
        notifyListeners();
      });
    }
  }

  void _findNextTarget() {
    int nextIndex = _completedMelodies.indexWhere((completed) => !completed);
    
    if (nextIndex != -1) {
      _currentTargetMelodyIndex = nextIndex;
    } else {
      // Todos foram completados
      if (isLevelsMode) {
        _advanceToNextLevel();
      } else {
        _state = GeneratorState.gameWon;
      }
    }
  }

  // --- NOVAS Funções para o Modo de Níveis ---

  void _setupCurrentLevel() {
    final level = _levels[_currentLevelIndex];
    final itemsForLevel = _selectedIcons.toList().sublist(0, level.iconCount);
    _activeIconsForCurrentLevel = itemsForLevel;

    if (level.withRepetition) {
      _generatedMelodies = _generatePermutationsWithRepetition(itemsForLevel, level.iconCount);
    } else {
      _generatedMelodies = _generatePermutationsWithoutRepetition(itemsForLevel);
    }
    
    _generatedMelodies.sort((a, b) => a.join().compareTo(b.join()));
    _completedMelodies = List<bool>.generate(_generatedMelodies.length, (_) => false);
    _currentUserInput = [];
    _currentTargetMelodyIndex = 0;
    _validationState = ValidationState.neutral;
  }

  void _advanceToNextLevel() {
    if (_currentLevelIndex < _levels.length - 1) {
      _state = GeneratorState.levelComplete;
    } else {
      _state = GeneratorState.gameWon;
    }
    notifyListeners();
  }

  void proceedToNextLevel() {
    _currentLevelIndex++;
    _setupCurrentLevel();
    _state = GeneratorState.playingLevels;
    notifyListeners();
  }


  Future<void> playMelody(int index) async {
    if (_currentlyPlayingIndex != null) return;

    final melody = _generatedMelodies[index];
    _currentlyPlayingIndex = index;
    notifyListeners();

    for (final iconType in melody) {
      await _playIconSound(iconType);
      await Future.delayed(const Duration(milliseconds: 600));
    }

    _currentlyPlayingIndex = null;
    notifyListeners();
  }

  void reset() {
    _state = GeneratorState.selectingIcons;
    _selectedIcons.clear();
    _generatedMelodies.clear();
    _currentlyPlayingIndex = null;
    _currentUserInput.clear();
    _completedMelodies.clear();
    _currentTargetMelodyIndex = 0;
    _validationState = ValidationState.neutral;
    _currentLevelIndex = 0;
    _activeIconsForCurrentLevel.clear();
    notifyListeners();
  }

  // --- Lógica de Geração (Combinatória) ---

  List<List<String>> _generatePermutationsWithoutRepetition(List<String> items) {
    List<List<String>> result = [];
    void permute(List<String> arr, int k) {
      if (k == arr.length) {
        result.add(List.from(arr));
        return;
      }
      for (int i = k; i < arr.length; i++) {
        String temp = arr[k];
        arr[k] = arr[i];
        arr[i] = temp;
        permute(arr, k + 1);
        temp = arr[k];
        arr[k] = arr[i];
        arr[i] = temp;
      }
    }
    permute(items, 0);
    return result;
  }

  List<List<String>> _generatePermutationsWithRepetition(List<String> items, int length) {
    List<List<String>> result = [];
    void generate(List<String> current) {
      if (current.length == length) {
        result.add(List.from(current));
        return;
      }
      for (int i = 0; i < items.length; i++) {
        current.add(items[i]);
        generate(current);
        current.removeLast();
      }
    }
    generate([]);
    return result;
  }

  // --- Funções Auxiliares ---
  
  Future<void> _playIconSound(String type) async {
    String? soundPath;
    switch (type) {
      case "EstalarDedo": soundPath = 'assets/sounds/estalarDedos.mp3'; break;
      case "BaterPalma": soundPath = 'assets/sounds/baterPalma.mp3'; break;
      case "BaterPeito": soundPath = 'assets/sounds/baterPeito.mp3'; break;
      case "BaterPerna": soundPath = 'assets/sounds/baterPerna.mp3'; break;
      case "Assobiar": soundPath = 'assets/sounds/assobiar.mp3'; break;
      case "BaterPe": soundPath = 'assets/sounds/baterPes.mp3'; break;
      case "Gritar": soundPath = 'assets/sounds/gritar.mp3'; break;
      case "EstalarLingua1": soundPath = 'assets/sounds/estalarLingua1.mp3'; break;
      case "EstalarLingua2": soundPath = 'assets/sounds/estalarLingua2.mp3'; break;
      case "Beijo": soundPath = 'assets/sounds/beijo.mp3'; break;
    }
    if (soundPath != null) {
      await _audioService.playAudio(soundPath);
    }
  }

  String getSemanticsLabelFromType(String type) {
    switch (type) {
      case "BaterPe": return "Bater Pé";
      case "BaterPalma": return "Bater Palma";
      case "BaterPerna": return "Bater Perna";
      case "BaterPeito": return "Bater Peito";
      case "Gritar": return "Gritar";
      case "Beijo": return "Mandar Beijo";
      case "Assobiar": return "Assobiar";
      case "EstalarDedo": return "Estalar Dedo";
      case "EstalarLingua1": return "Estalar Língua 1";
      case "EstalarLingua2": return "Estalar Língua 2";
      default: return type;
    }
  }
}