import 'package:mathnew/user_interface/widgets/vlibras_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'combinesSound_service.dart';
import 'orientation_service.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

class GeneratorTutorialController extends ChangeNotifier {
  int _currentStepIndex = -1;
  List<Function> _tutorialSteps = [];
  bool get isTutorialActive => _currentStepIndex < _tutorialSteps.length;
  int get currentStepIndex => _currentStepIndex;
  int get totalSteps => _tutorialSteps.length;

  bool _isInitialized = false;
  bool _shouldShowVLibrasStep = false;

  final Map<String, GlobalKey> iconKeys = {};
  final confirmSelectionButtonKey = GlobalKey();
  final modeSelectionChallengeKey = GlobalKey();
  final modeSelectionFreeNoRepeatKey = GlobalKey();
  final modeSelectionFreeRepeatKey = GlobalKey();
  final melodiesListKey = GlobalKey();
  final userInputAreaKey = GlobalKey();
  final iconInputPanelKey = GlobalKey();
  final buttonConfirmKey = GlobalKey();

  Rect? highlightRect;
  String guidanceText = '';
  Alignment guidanceAlignment = Alignment.center;

  late MelodyGeneratorController _gameController;
  final OrientationService _orientationService = OrientationService();

  GeneratorTutorialController() {
    final iconTypes = [
      "BaterPalma",
      "BaterPe",
      "BaterPeito",
      "BaterPerna",
      "Gritar",
      "Beijo",
      "Assobiar",
      "EstalarDedo",
      "EstalarLingua1",
      "EstalarLingua2"
    ];
    for (var type in iconTypes) {
      iconKeys[type] = GlobalKey();
    }
  }

  Future<void> start(
      BuildContext context, MelodyGeneratorController gameController) async {
    _gameController = gameController;
    bool alreadyShownAny =
        await _orientationService.hasShownAnyTutorialGlobal();
    _shouldShowVLibrasStep = kIsWeb || !alreadyShownAny;

    if (_shouldShowVLibrasStep && !kIsWeb) {
      await _orientationService.markAnyTutorialAsShownGlobal();
    }
    _buildTutorialSequence(context);
    _isInitialized = true;
    nextStep();
  }

  void _buildTutorialSequence(BuildContext context) {
    _tutorialSteps = [
      if (_shouldShowVLibrasStep) _stepVLibrasIntro,
      _stepWelcome,
      _stepSelectIconsIntro,
      _stepSelectIconsDemo,
      _stepConfirmSelection,
      _stepSelectMode,
      _stepEnterGame,
      _stepMelodiesList,
      _stepUserInputArea,
      _stepInputPanel,
      _stepConfirmAttempt,
      _stepWinCondition,
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

  void _stepSelectIconsIntro() {
    _calculateHighlight(iconKeys["BaterPalma"]!);
    guidanceText = 'Selecione os sons desejados tocando nos ícones.';
    guidanceAlignment = Alignment.topCenter;
    _announce(guidanceText);
    notifyListeners();
  }

  void _stepSelectIconsDemo() {
    guidanceText = 'Você pode selecionar 2 ou 3 sons.';
    guidanceAlignment = Alignment.topCenter;
    _announce(guidanceText);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!isTutorialActive) return;
      _gameController.selectedIcons
        ..clear()
        ..addAll(["BaterPalma", "BaterPe", "BaterPeito"]);
    });

    notifyListeners();
  }

  void _stepConfirmSelection() {
    _calculateHighlight(confirmSelectionButtonKey);
    guidanceText =
        'Após a seleção, toque no botão "Confirmar", no canto superior direito.';
    guidanceAlignment = Alignment.topCenter;
    _announce(guidanceText);
    notifyListeners();
  }

  void _stepSelectMode() {
    guidanceText = 'Após confirmar a seleção, escolha um modo de jogo.';
    guidanceAlignment = Alignment.bottomCenter;
    _announce(guidanceText);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!isTutorialActive) return;
      if (_gameController.state == GeneratorState.selectingIcons) {
        _gameController.confirmIconSelection();
      }
      if (_gameController.state == GeneratorState.selectingMode) {
        _calculateHighlight(modeSelectionFreeNoRepeatKey);
      }
    });

    notifyListeners();
  }

  void _stepEnterGame() {
    highlightRect = null;
    guidanceText = 'O objetivo é descobrir todas as combinações de sons.';
    guidanceAlignment = Alignment.center;
    _announce(guidanceText);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!isTutorialActive) return;
      if (_gameController.state == GeneratorState.selectingMode) {
        _gameController.startFreePlayMode(false);
      }
    });
    notifyListeners();
  }

  void _stepMelodiesList() {
    guidanceText =
        'As combinações encontradas podem ser reproduzidas no botão lateral.';
    guidanceAlignment = Alignment.topCenter;
    _announce(guidanceText);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!isTutorialActive) return;
      if (_gameController.state == GeneratorState.playingFreePlay ||
          _gameController.state == GeneratorState.playingLevels) {
        _calculateHighlight(melodiesListKey);
      }
    });
    notifyListeners();
  }

  void _stepUserInputArea() {
    _calculateHighlight(userInputAreaKey);
    guidanceText = 'A área abaixo mostra a sua combinação atual.';
    guidanceAlignment = Alignment.bottomCenter;
    _announce(guidanceText);
    notifyListeners();
  }

  void _stepInputPanel() {
    _calculateHighlight(iconInputPanelKey);
    guidanceText =
        'Use os botões na parte inferior para montar suas combinações.';
    guidanceAlignment = Alignment.bottomCenter;
    _announce(guidanceText);
    notifyListeners();
  }

  void _stepConfirmAttempt() {
    _calculateHighlight(buttonConfirmKey);
    guidanceText =
        'Toque no botão "Confirmar" quando completar todas as combinações.';
    guidanceAlignment = Alignment.bottomCenter;
    _announce(guidanceText);
    notifyListeners();
  }

  void _stepWinCondition() {
    highlightRect = null;
    guidanceText =
        'Se estiver faltando alguma combinação, você voltará ao jogo.';
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
    if (!_isInitialized) return;
    _currentStepIndex = _tutorialSteps.length;
    highlightRect = null;
    guidanceText = '';
    _orientationService.markGeneratorGameTutorialAsShown();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _gameController.reset();
    });

    _announce("Tutorial finalizado. Bom jogo!");
    notifyListeners();
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
    bool isIntroStep = _currentStepIndex <= (_shouldShowVLibrasStep ? 2 : 1);

    String messageToSpeak = message;
    VLibrasWidget.buscarTraducao(message);

    if (isTutorialActive && !isLastStep && !isIntroStep) {
      messageToSpeak += ". Toque em próximo para continuar";
    }

    SemanticsService.announce(messageToSpeak, TextDirection.ltr);
  }
}
