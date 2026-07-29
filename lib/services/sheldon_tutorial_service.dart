import 'package:mathnew/user_interface/widgets/vlibras_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'sheldon_service.dart';
import 'orientation_service.dart';

class MemoryTutorialController extends ChangeNotifier {
  int _currentStepIndex = -1;
  List<Function> _tutorialSteps = [];
  bool get isTutorialActive => _currentStepIndex < _tutorialSteps.length;
  int get currentStepIndex => _currentStepIndex;
  int get totalSteps => _tutorialSteps.length;

  String? activeCardTutorialType;
  final statusKey = GlobalKey();
  final Map<String, GlobalKey> cardKeys = {};
  Rect? highlightRect;
  String guidanceText = '';
  Alignment guidanceAlignment = Alignment.center;
  bool canTapHighlightedItem = false;

  late GeniusGameController _gameController;
  final OrientationService _orientationService = OrientationService();
  bool _shouldShowVLibrasIntro = false;

  MemoryTutorialController() {
    final iconTypes = [
      "BaterPalma",
      "BaterPe",
      "BaterPeito",
      "BaterPerna",
      "Gritar",
      "Beijo"
    ];
    for (var type in iconTypes) {
      cardKeys[type] = GlobalKey();
    }
  }

  Future<void> start(
      BuildContext context, GeniusGameController gameController) async {
    _gameController = gameController;
    bool alreadyShownAnyGlobal =
        await _orientationService.hasShownAnyTutorialGlobal();
    _shouldShowVLibrasIntro = kIsWeb || !alreadyShownAnyGlobal;
    if (_shouldShowVLibrasIntro && !kIsWeb) {
      await _orientationService.markAnyTutorialAsShownGlobal();
    }

    _buildTutorialSequence();
    nextStep();
  }

  void _buildTutorialSequence() {
    _tutorialSteps = [
      if (_shouldShowVLibrasIntro) _stepVLibrasIntro,
      _stepWelcome,
      _stepStatusPanel,
      _stepTimerExplanation,
      _stepTimerSettings,
      _stepGameArea,
      _stepGameLogic,
      _stepPressStart,
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

  void skipTutorial(BuildContext context) {
    _finishTutorial();
  }

  void _stepVLibrasIntro() {
    highlightRect = null;
    canTapHighlightedItem = false;
    activeCardTutorialType = null;

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

  void _stepStatusPanel() {
    _calculateHighlight(statusKey);
    canTapHighlightedItem = false;
    activeCardTutorialType = null;
    guidanceText = 'O painel superior mostra instruções e o botão "Iniciar".';
    guidanceAlignment = Alignment.center;

    _announce(guidanceText);
    notifyListeners();
  }

  void _stepTimerExplanation() {
    _calculateHighlight(statusKey);
    canTapHighlightedItem = false;
    activeCardTutorialType = null;

    guidanceText =
        'Um temporizador aparecerá com 15 segundos para o primeiro toque e 10 segundos para os demais.';
    guidanceAlignment = Alignment.center;

    _announce(guidanceText);
    notifyListeners();
  }

  void _stepTimerSettings() {
    highlightRect = null;
    canTapHighlightedItem = false;
    activeCardTutorialType = null;

    guidanceText =
        'Você pode alterar o tempo no menu lateral, em "Configurar Tempo".';
    guidanceAlignment = Alignment.center;

    _announce(guidanceText);
    notifyListeners();
  }

  void _stepGameArea() {
    highlightRect = null;
    canTapHighlightedItem = false;
    activeCardTutorialType = null;

    guidanceText = 'A área central contém os botões de sons.';
    guidanceAlignment = Alignment.center;

    _announce(guidanceText);
    notifyListeners();
  }

  void _stepGameLogic() {
    highlightRect = null;
    canTapHighlightedItem = false;
    activeCardTutorialType = null;

    guidanceText =
        'Memorize e repita a sequência de sons que o jogo reproduzir.';
    guidanceAlignment = Alignment.center;

    _announce(guidanceText);
    notifyListeners();
  }

  void playCardSound(String iconType) {
    _gameController.playCardSoundForTutorial(iconType);
  }

  void _stepPressStart() {
    highlightRect = null;
    canTapHighlightedItem = false;
    activeCardTutorialType = null;

    guidanceText = 'Toque em "Finalizar Tutorial" para entrar no jogo.';
    guidanceAlignment = Alignment.center;

    notifyListeners();

    Future.delayed(const Duration(milliseconds: 150), () {
      if (isTutorialActive && _currentStepIndex == _tutorialSteps.length - 1) {
        _announce(guidanceText);
      }
    });
  }

  void _finishTutorial() {
    _currentStepIndex = _tutorialSteps.length;
    highlightRect = null;
    guidanceText = '';
    activeCardTutorialType = null;
    _gameController.removeListener(_onGameStarted);
    _orientationService.markMemoryGameTutorialAsShown();
    _announce("Tutorial finalizado. Bom jogo!");
    notifyListeners();
  }

  void _onGameStarted() {
    if (_gameController.gameState == GeniusGameState.showingSequence) {
      _finishTutorial();
    }
  }

  void _calculateHighlight(GlobalKey key) {
    Future.delayed(const Duration(milliseconds: 150), () {
      if (!isTutorialActive) return;

      final renderBox = key.currentContext?.findRenderObject() as RenderBox?;
      if (renderBox != null && renderBox.hasSize) {
        final position = renderBox.localToGlobal(Offset.zero);
        highlightRect = Rect.fromLTWH(position.dx, position.dy,
            renderBox.size.width, renderBox.size.height);
      } else {
        highlightRect = null;
      }
      notifyListeners();
    });
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

  @override
  void dispose() {
    _gameController.removeListener(_onGameStarted);
    super.dispose();
  }
}
