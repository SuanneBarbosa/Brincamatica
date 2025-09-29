// lib/services/melody_generator_service.dart

import 'dart:async';
import 'package:flutter/material.dart';
import 'audio_service.dart';

// Enum para controlar o estado da tela do jogo
enum GeneratorState {
  selectingIcons,
  selectingMode,
  displayingResults,
}

class MelodyGeneratorController extends ChangeNotifier {
  final AudioService _audioService;

  MelodyGeneratorController({required AudioService audioService})
      : _audioService = audioService;

  // --- Estado do Jogo ---
  GeneratorState _state = GeneratorState.selectingIcons;
  Set<String> _selectedIcons = {};
  bool _withRepetition = false;
  List<List<String>> _generatedMelodies = [];
  int? _currentlyPlayingIndex;

  // --- Getters Públicos ---
  GeneratorState get state => _state;
  Set<String> get selectedIcons => _selectedIcons;
  List<List<String>> get generatedMelodies => _generatedMelodies;
  int? get currentlyPlayingIndex => _currentlyPlayingIndex;

  // Ícones disponíveis para escolha
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

  void generateMelodies(bool withRepetition) {
    _withRepetition = withRepetition;
    _state = GeneratorState.displayingResults;
    final items = _selectedIcons.toList();
    
    if (_withRepetition) {
      _generatedMelodies = _generatePermutationsWithRepetition(items, items.length);
    } else {
      _generatedMelodies = _generatePermutationsWithoutRepetition(items);
    }
    notifyListeners();
  }

  Future<void> playMelody(int index) async {
    if (_currentlyPlayingIndex != null) return; // Evita tocar duas ao mesmo tempo

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