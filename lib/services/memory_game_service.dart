import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart'; // <-- ADICIONE ESTE IMPORT
import 'package:provider/provider.dart';
import 'audio_service.dart';
import 'score_history_service.dart';


enum GeniusGameState {
  notStarted,
  showingSequence,
  playerTurn,
  waitingForInput,
  levelComplete,
  gameOver,
}

class GeniusGameController extends ChangeNotifier {
  final AudioService _audioService;
  final Random _random = Random();

  Timer? _inputTimer;
  Timer? _countdownTimer;

  GeniusGameController({required AudioService audioService}) : _audioService = audioService;

  final List<String> availableIcons = [
     "BaterPalma", "BaterPe",
    "BaterPeito", "BaterPerna", "Gritar", "Beijo"
  ];

  GeniusGameState _gameState = GeniusGameState.notStarted;
  List<String> _sequence = [];
  int _userInputIndex = 0;
  int _score = 0;
  String? _currentlyPlayingIcon;
  int _countdown = 10;

  GeniusGameState get gameState => _gameState;
  int get score => _score;
  String? get currentlyPlayingIcon => _currentlyPlayingIcon;
  int get countdown => _countdown;

  void startGame(BuildContext context) {
    _score = 0;
    _sequence = [];
    _gameState = GeniusGameState.showingSequence;
    notifyListeners();
    _nextLevel(context);
  }

  void resetGame() {
    _cancelTimers();
    _gameState = GeniusGameState.notStarted;
    _score = 0;
    _sequence = [];
    _userInputIndex = 0;
    notifyListeners();
  }

  void _nextLevel(BuildContext context) async {
    _userInputIndex = 0;
    _gameState = GeniusGameState.showingSequence;
    notifyListeners();
    _sequence.add(availableIcons[_random.nextInt(availableIcons.length)]);
    
    const double baseDuration = 800;
    const double minDuration = 250;
    const double speedIncreaseFactor = 25;
    
    final currentDuration = (baseDuration - (_score * speedIncreaseFactor)).clamp(minDuration, baseDuration);
    final showDuration = Duration(milliseconds: currentDuration.toInt());
    final gapDuration = Duration(milliseconds: (currentDuration * 0.25).toInt());

    await Future.delayed(const Duration(milliseconds: 1000));

    for (final iconType in _sequence) {
      if (_gameState != GeniusGameState.showingSequence) return;
      _currentlyPlayingIcon = iconType;
      notifyListeners();
      _playIconSound(iconType);
      await Future.delayed(showDuration);
      _currentlyPlayingIcon = null;
      notifyListeners();
      await Future.delayed(gapDuration);
    }

     // ====================== MUDANÇA AQUI ======================
    // 1. Mude para o estado intermediário "playerTurn"
    _gameState = GeniusGameState.playerTurn;
    notifyListeners();

    // 2. Aguarde um momento para que o jogador veja a mensagem "Sua vez!"
    //    Você pode ajustar a duração (ex: 1200 para 1.2 segundos).
    await Future.delayed(const Duration(milliseconds: 1500));

    // 3. Verifique se o jogo não foi interrompido durante a pausa
    if (_gameState != GeniusGameState.playerTurn) return;

    // 4. Agora, mude para o estado de espera e inicie o timer.
    _gameState = GeniusGameState.waitingForInput;
    notifyListeners();
    _startInputTimer(context: context, seconds: 10);
  }

  void handlePlayerInput(String iconType, BuildContext context) {
    if (_gameState != GeniusGameState.waitingForInput) return;
    
    _cancelTimers(); 
    _playIconSound(iconType);

    if (_sequence[_userInputIndex] == iconType) {
      _userInputIndex++;
      if (_userInputIndex == _sequence.length) {
        _score++;
        _gameState = GeniusGameState.levelComplete;
        notifyListeners();
        Future.delayed(const Duration(milliseconds: 1500), () => _nextLevel(context));
      } else {
         _startInputTimer(context: context, seconds: 3);
      }
    } else {
      _gameOver(context);
    }
  }

  void _gameOver(BuildContext context) {
    _cancelTimers();
    _gameState = GeniusGameState.gameOver;
    
    context.read<ScoreHistoryService>().addScoreEntry(_score, _score + 1);

    _audioService.playAudio('assets/sounds/error.mp3');

    // ====================== MUDANÇA AQUI ======================
    // Criamos a mensagem que será anunciada pelo leitor de tela.
    final String announcement = "Fim de Jogo! Você alcançou o nível ${_score + 1} e sua pontuação foi ${_score}. Toque no botão Jogar Novamente para iniciar um novo jogo.";
    
    // Usamos um pequeno atraso para garantir que o som de erro não
    // interrompa o anúncio do TalkBack.
    Future.delayed(const Duration(milliseconds: 200), () {
      SemanticsService.announce(announcement, TextDirection.ltr);
    });
    // ==========================================================

    notifyListeners();
  }

  void _startInputTimer({required BuildContext context, int seconds = 10}) {
    _cancelTimers();
    _countdown = seconds;
    notifyListeners();

    _inputTimer = Timer(Duration(seconds: seconds), () => _gameOver(context));

    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_countdown > 0) {
        _countdown--;
        notifyListeners();
      } else {
        timer.cancel();
      }
    });
  }

  void _cancelTimers() {
    _inputTimer?.cancel();
    _countdownTimer?.cancel();
  }

   void playCardSoundForTutorial(String type) {
    _playIconSound(type);
  }

  void _playIconSound(String type) {
    String? soundPath;
    switch (type) {
      case "BaterPalma": soundPath = 'assets/sounds/baterPalma.mp3'; break;
      case "BaterPeito": soundPath = 'assets/sounds/baterPeito.mp3'; break;
      case "BaterPerna": soundPath = 'assets/sounds/baterPerna.mp3'; break;
      case "BaterPe": soundPath = 'assets/sounds/baterPes.mp3'; break;
      case "Gritar": soundPath = 'assets/sounds/gritar.mp3'; break;
      case "Beijo": soundPath = 'assets/sounds/beijo.mp3'; break;
    }
    if (soundPath != null) {
      _audioService.playAudio(soundPath);
    }
  }

  @override
  void dispose() {
    _cancelTimers();
    super.dispose();
  }
}