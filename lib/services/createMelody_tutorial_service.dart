import 'package:mathnew/user_interface/widgets/vlibras_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'orientation_service.dart';
import 'character_service.dart';
import 'icon_service.dart';
import 'playback_service.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

class CreateMelodyTutorialController extends ChangeNotifier {
  int _currentStepIndex = -1;
  List<Function> _tutorialSteps = [];
  bool get isTutorialActive => _currentStepIndex < _tutorialSteps.length;
  int get currentStepIndex => _currentStepIndex;
  int get totalSteps => _tutorialSteps.length;
  bool _shouldShowVLibrasIntro = false;

  final characterKey = GlobalKey();
  final actionMenuKey = GlobalKey();
  final playButtonKey = GlobalKey();
  final menuButtonKey = GlobalKey();

  Rect? highlightRect;
  String guidanceText = '';
  Alignment guidanceAlignment = Alignment.center;

  late CharacterController _characterController;
  late IconController _iconController;
  late PlaybackController _playbackController;

  final OrientationService _orientationService = OrientationService();

  Future<void> start(
    BuildContext context,
    CharacterController charController,
    IconController iconController,
    PlaybackController playbackController,
  ) async {
    _characterController = charController;
    _iconController = iconController;
    _playbackController = playbackController;
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
      _stepCharacterIntro,
      _stepMovement,
      _stepActionMenu,
      _stepAddSound,
      _stepPlayButton,
      _stepMenuOptions,
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

  void _stepCharacterIntro() {
    _calculateHighlight(characterKey);
    guidanceText = 'O beija-flor indica a sua posição na tela.';
    guidanceAlignment = Alignment.center;
    _announce(guidanceText);
    notifyListeners();
  }

  void _stepMovement() {
    _calculateHighlight(characterKey);
    guidanceText = 'Mova o beija-flor pela tela para mudar a posição dele.';
    guidanceAlignment = Alignment.center;
    _announce(guidanceText);
    notifyListeners();
  }

  void _stepActionMenu() {
    _calculateHighlight(actionMenuKey);
    guidanceText = 'A barra inferior contém os botões de som disponíveis.';
    guidanceAlignment = Alignment.center;
    _announce(guidanceText);
    notifyListeners();
  }

  void _stepAddSound() {
    _calculateHighlight(actionMenuKey);
    guidanceText =
        'Toque em um botão para adicionar um som na posição do beija-flor.';
    guidanceAlignment = Alignment.center;
    _announce(guidanceText);
    notifyListeners();
  }

  void _stepPlayButton() {
    _calculateHighlight(playButtonKey);
    guidanceText = 'Toque no botão "Play", à esquerda, para ouvir sua criação.';
    guidanceAlignment = Alignment.center;
    _announce(guidanceText);
    notifyListeners();
  }

  void _stepMenuOptions() {
    _calculateHighlight(menuButtonKey);
    guidanceText = 'Use o menu para limpar a área, salvar e ativar o joystick.';
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
    _orientationService.markCreateMelodyTutorialAsShown();
    _playbackController.stop();
    _iconController.clearIcons();
    _characterController.resetPosition();

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
