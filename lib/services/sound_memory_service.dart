import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'audio_service.dart';

class SoundMemoryCard {
  final int id;
  final String type;
  bool isFlipped;
  bool isMatched;

  SoundMemoryCard({
    required this.id,
    required this.type,
    this.isFlipped = false,
    this.isMatched = false,
  });
}

enum SoundMemoryState {
  notStarted,
  playing,
  gameOver,
}

class SoundMemoryController extends ChangeNotifier {
  final AudioService _audioService;
  final Random _random = Random();

  SoundMemoryController({required AudioService audioService}) : _audioService = audioService;

  final List<String> _availableIcons = [
    "BaterPalma", "BaterPe", "BaterPeito", "BaterPerna",
    "Gritar", "Beijo", "Assobiar", "EstalarDedo",
    "EstalarLingua1", "EstalarLingua2"
  ];

  SoundMemoryState _gameState = SoundMemoryState.notStarted;
  List<SoundMemoryCard> _cards = [];
  List<int> _flippedCardIndices = [];
  int _moves = 0;
  int _pairsFound = 0;
  int _totalPairs = 0;
  bool _isChecking = false;
  int _currentPairCountSetting = 6;
  Timer? _gameTimer;
  Duration _elapsedTime = Duration.zero;
  SoundMemoryState get gameState => _gameState;
  List<SoundMemoryCard> get cards => _cards;
  int get moves => _moves;
  int get pairsFound => _pairsFound;
  int get totalPairs => _totalPairs;
  Duration get elapsedTime => _elapsedTime;
  int get currentPairCountSetting => _currentPairCountSetting;

  
  void setDifficulty(int pairCount) {
    if (_currentPairCountSetting != pairCount) {
      _currentPairCountSetting = pairCount;
      setupNewGame(); 
    }
  }
  void setupNewGame({int? pairCount}) {
    if (pairCount != null) {
      _currentPairCountSetting = pairCount;
    }

    _gameState = SoundMemoryState.notStarted;
    _moves = 0;
    _pairsFound = 0;
    _totalPairs = _currentPairCountSetting; 
    _flippedCardIndices.clear();
    _cards.clear();
    _isChecking = false;
    _gameTimer?.cancel();
    _elapsedTime = Duration.zero;

    final countToTake = min(_currentPairCountSetting, _availableIcons.length);
    final List<String> selectedIcons = List.from(_availableIcons)..shuffle(_random);
    final List<String> gameIcons = selectedIcons.sublist(0, countToTake);

    int cardId = 0;
    for (var iconType in gameIcons) {
      _cards.add(SoundMemoryCard(id: cardId++, type: iconType));
      _cards.add(SoundMemoryCard(id: cardId++, type: iconType));
    }
    _cards.shuffle(_random);
    notifyListeners();
  }

  void startGame() {
    if (_gameState != SoundMemoryState.notStarted) return;

    _gameState = SoundMemoryState.playing;
    _elapsedTime = Duration.zero;
    _gameTimer?.cancel();
    _gameTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _elapsedTime += const Duration(seconds: 1);
      notifyListeners();
    });
    SemanticsService.announce("Jogo iniciado.", TextDirection.ltr);
    notifyListeners();
  }

  void resetGame() {
    setupNewGame();
  }

  void flipCard(int cardIndex) {
    if (_gameState != SoundMemoryState.playing || _cards[cardIndex].isMatched || _cards[cardIndex].isFlipped || _isChecking) {
      return;
    }

    _playIconSound(_cards[cardIndex].type);
    _cards[cardIndex].isFlipped = true;
    _flippedCardIndices.add(cardIndex);

    if (_flippedCardIndices.length == 1) {
      _moves++;
      notifyListeners();
    } else if (_flippedCardIndices.length == 2) {
      _moves++;
      _isChecking = true;
      notifyListeners();
      Future.delayed(const Duration(milliseconds: 500), () {
        _checkForMatch();
      });
    }
  }

  void _checkForMatch() {
    if (_flippedCardIndices.length < 2) {
      _isChecking = false;
      return;
    }
    final int index1 = _flippedCardIndices[0];
    final int index2 = _flippedCardIndices[1];
    final SoundMemoryCard card1 = _cards[index1];
    final SoundMemoryCard card2 = _cards[index2];

    if (card1.type == card2.type) {
      _handleMatch(index1, index2);
    } else {
      _handleMismatch(index1, index2);
    }
  }

  void _handleMatch(int index1, int index2) {
    _cards[index1].isMatched = true;
    _cards[index2].isMatched = true;
    _pairsFound++;
    _flippedCardIndices.clear();
    _audioService.playFeedbackAudio('assets/sounds/correto.mp3');
    SemanticsService.announce("Par encontrado!", TextDirection.ltr);

    if (_pairsFound == _totalPairs) {
      _gameOver();
    }
    _isChecking = false;
    notifyListeners();
  }

  void _handleMismatch(int index1, int index2) {
    _audioService.playFeedbackAudio('assets/sounds/errado.mp3');
    SemanticsService.announce("Par incorreto.", TextDirection.ltr);
    Future.delayed(const Duration(milliseconds: 1200), () {
      if (_cards.isNotEmpty && index1 < _cards.length && index2 < _cards.length) {
        _cards[index1].isFlipped = false;
        _cards[index2].isFlipped = false;
        _flippedCardIndices.clear();
        _isChecking = false;
        notifyListeners();
      }
    });
  }

  void _gameOver() {
    _gameState = SoundMemoryState.gameOver;
    _gameTimer?.cancel();
    Future.delayed(const Duration(milliseconds: 500), () {
      SemanticsService.announce("Parabéns! Você encontrou todos os pares.", TextDirection.ltr);
    });
    notifyListeners();
  }

  void _playIconSound(String type) {
    String? soundPath;
    switch (type) {
      case "EstalarDedo": soundPath = 'assets/sounds/estalarDedos.mp3'; break;
      case "BaterPalma": soundPath = 'assets/sounds/baterPalma.mp3'; break;
      case "BaterPeito": soundPath = 'assets/sounds/baterPeito.mp3'; break;
      case "BaterPerna": soundPath = 'assets/sounds/baterPerna.mp3'; break;
      case "Assobiar": soundPath = 'assets/sounds/assobiar.mp3'; break;
      case "BaterPe": soundPath = 'assets/sounds/baterPes.mp3'; break;
      case "Gritar": soundPath = 'assets/sounds/gritar.mp3'; break;
      case "Beijo": soundPath = 'assets/sounds/beijo.mp3'; break;
      case "EstalarLingua1": soundPath = 'assets/sounds/estalarLingua1.mp3'; break;
      case "EstalarLingua2": soundPath = 'assets/sounds/estalarLingua2.mp3'; break;
    }
    if (soundPath != null) {
      _audioService.playFeedbackAudio(soundPath);
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

  @override
  void dispose() {
    _gameTimer?.cancel();
    super.dispose();
  }
}