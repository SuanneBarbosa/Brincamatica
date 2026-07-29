import 'package:mathnew/user_interface/widgets/vlibras_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'orientation_service.dart';
import 'sound_memory_service.dart';

class SoundMemoryTutorialController extends ChangeNotifier {
  int _currentStepIndex = -1;
  List<Function> _tutorialSteps = [];
  bool get isTutorialActive => _currentStepIndex < _tutorialSteps.length;
  int get currentStepIndex => _currentStepIndex;
  int get totalSteps => _tutorialSteps.length;

  Rect? highlightRect;
  String guidanceText = '';
  Alignment guidanceAlignment = Alignment.center;

  // ignore: unused_field
  late SoundMemoryController _gameController;
  final OrientationService _orientationService = OrientationService();
  bool _shouldShowVLibrasIntro = false;
  Future<void> start(
      BuildContext context, SoundMemoryController gameController) async {
    _gameController = gameController;
    bool alreadyShownAnyGlobal =
        await _orientationService.hasShownAnyTutorialGlobal();
    _shouldShowVLibrasIntro = kIsWeb || !alreadyShownAnyGlobal;

    if (_shouldShowVLibrasIntro && !kIsWeb) {
      await _orientationService.markAnyTutorialAsShownGlobal();
    }

    _buildTutorialSequence(context);
    nextStep();
  }

  void _buildTutorialSequence(BuildContext context) {
    _tutorialSteps = [
      if (_shouldShowVLibrasIntro) _stepVLibrasIntro,
      _stepWelcome,
      _stepStartButton,
      _stepDifficulty,
      _stepMenuSettings,
      _stepGoal,
      _stepCardAction,
      _stepVisualAid,
      _stepAudioFeedback,
      _stepGameEnd,
      _stepEnd,
    ];
  }

  void nextStep() {
    _currentStepIndex++;
    if (isTutorialActive) {
      _tutorialSteps[_currentStepIndex]();
    } else {
      _finishTutorial();
    }
  }

  void skipTutorial() {
    _finishTutorial();
  }

  void _stepVLibrasIntro() {
    highlightRect = null;
    guidanceText =
        'Ative o VLibras no ícone à direita depois toque em "Começar" ou apenas em "Começar" para seguir sem a tradução.';
    guidanceAlignment = Alignment.center;
    _announce(guidanceText);
    notifyListeners();
  }

  void _stepWelcome() {
    highlightRect = null;
    final String btnLabel = _currentStepIndex == 0 ? 'Começar' : 'Próximo';
    guidanceText = 'Bem-vindo! Toque em "$btnLabel" ou em "Pular Tutorial".';
    guidanceAlignment = Alignment.center;
    _announce(guidanceText);
    notifyListeners();
  }

  void _stepStartButton() {
    highlightRect = null;
    guidanceText = 'Para começar a jogar toque em "Iniciar" na barra superior.';
    guidanceAlignment = Alignment.topCenter;
    _announce(guidanceText);
    notifyListeners();
  }

  void _stepDifficulty() {
    highlightRect = null;
    guidanceText = 'O jogo começa no modo Fácil, com 6 pares de cartas.';
    guidanceAlignment = Alignment.center;
    _announce(guidanceText);
    notifyListeners();
  }

  void _stepMenuSettings() {
    highlightRect = null;
    guidanceText =
        'Para jogar com 10 pares, mude a dificuldade no menu lateral.';
    guidanceAlignment = Alignment.center;
    _announce(guidanceText);
    notifyListeners();
  }

  void _stepGoal() {
    highlightRect = null;
    guidanceText = 'O objetivo é encontrar todos os pares de sons iguais.';
    guidanceAlignment = Alignment.center;
    _announce(guidanceText);
    notifyListeners();
  }

  void _stepCardAction() {
    highlightRect = null;
    guidanceText = 'Você deve tocar em uma carta para virar e ouvir o som.';
    guidanceAlignment = Alignment.center;
    _announce(guidanceText);
    notifyListeners();
  }

  void _stepVisualAid() {
    highlightRect = null;
    guidanceText = 'Cada carta tem um número para ajudar na memorização.';
    guidanceAlignment = Alignment.center;
    _announce(guidanceText);
    notifyListeners();
  }

  void _stepAudioFeedback() {
    highlightRect = null;
    guidanceText = 'O jogo emite sons diferentes quando você acerta ou erra.';
    guidanceAlignment = Alignment.center;
    _announce(guidanceText);
    notifyListeners();
  }

  void _stepGameEnd() {
    highlightRect = null;
    guidanceText = 'Encontre todos os pares para ver o seu tempo final.';
    guidanceAlignment = Alignment.center;
    _announce(guidanceText);
    notifyListeners();
  }

  void _stepEnd() {
    highlightRect = null;
    guidanceText = 'Toque em "Finalizar Tutorial" para entrar no jogo.';
    guidanceAlignment = Alignment.center;
    _announce(guidanceText);
    notifyListeners();
  }

  void _finishTutorial() {
    _currentStepIndex = _tutorialSteps.length;
    highlightRect = null;
    guidanceText = '';
    _orientationService.markSoundMemoryTutorialAsShown();
    _announce("Tutorial finalizado. Bom jogo!");
    notifyListeners();
  }

  void _announce(String message) {
    bool isLastStep = _currentStepIndex >= _tutorialSteps.length - 1;
    bool isInitialStep = _currentStepIndex == 0;
    bool isSecondaryStep = _currentStepIndex == 1;

    String messageToSpeak = message;
    VLibrasWidget.buscarTraducao(message);

    if (isTutorialActive && !isLastStep && !isInitialStep && !isSecondaryStep) {
      messageToSpeak += ". Toque em próximo para continuar";
    }

    SemanticsService.announce(messageToSpeak, TextDirection.ltr);
  }
}
