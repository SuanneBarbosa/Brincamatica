import 'package:Mathnew/user_interface/widgets/vlibras_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'orientation_service.dart';
import 'character_service.dart';
import 'icon_service.dart';
import 'playback_service.dart';

class CreateMelodyTutorialController extends ChangeNotifier {
  int _currentStepIndex = -1;
  List<Function> _tutorialSteps = [];
  bool get isTutorialActive => _currentStepIndex < _tutorialSteps.length;
  int get currentStepIndex => _currentStepIndex;
  int get totalSteps => _tutorialSteps.length;


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

  void start(
    BuildContext context, 
    CharacterController charController,
    IconController iconController,
    PlaybackController playbackController,
  ) {
    _characterController = charController;
    _iconController = iconController;
    _playbackController = playbackController;
    
    _buildTutorialSequence(context);
    nextStep();
  }

  void _buildTutorialSequence(BuildContext context) {
    _tutorialSteps = [
      _stepWelcome,
      _stepNext,
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


  void _stepWelcome() {
    highlightRect = null;
    guidanceText = 'Bem-vindo! Toque em "Começar" ou em "Pular Tutorial".';
    guidanceAlignment = Alignment.center;
    _announce(guidanceText);
    notifyListeners();
  }

  void _stepNext() {
    highlightRect = null;
    guidanceText = 'Para seguir o tutorial, toque em "Próximo" ou arraste para o lado.';
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
    guidanceText = 'Toque em um botão para adicionar um som na posição do beija-flor.';
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
    guidanceText = 'Tutorial finalizado! Toque em "Finalizar" para criar.';
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
        highlightRect = Rect.fromLTWH(
          position.dx, position.dy,
          renderBox.size.width, renderBox.size.height
        );
      } else {
        highlightRect = null;
      }
      notifyListeners();
    });
  }

  void _announce(String message) {
    bool isLastStep = _currentStepIndex >= _tutorialSteps.length - 1;
    bool isWelcomeStep = _currentStepIndex == 0;
    bool isNextStepInstruction = _currentStepIndex == 1;

    String messageToSpeak = message;
    VLibrasWidget.buscarTraducao(message); 
    
    if (isTutorialActive && !isLastStep && !isWelcomeStep && !isNextStepInstruction) {
      messageToSpeak += ". Toque em próximo para continuar";
    }

    SemanticsService.announce(messageToSpeak, TextDirection.ltr);
  }
}