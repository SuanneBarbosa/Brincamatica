import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'memory_game_service.dart';
import 'orientation_service.dart';

class MemoryTutorialController extends ChangeNotifier {
  // --- Estado do Tutorial ---
  int _currentStepIndex = -1;
  List<Function> _tutorialSteps = [];
  bool get isTutorialActive => _currentStepIndex < _tutorialSteps.length;
  int get currentStepIndex => _currentStepIndex;
  int get totalSteps => _tutorialSteps.length;
  
  // <-- NOVA PROPRIEDADE para rastrear qual card está ativo no tutorial -->
  String? activeCardTutorialType;


  // --- Chaves e Destaques ---
  final Map<String, GlobalKey> cardKeys = {};
  final statusKey = GlobalKey();
  Rect? highlightRect;
  String guidanceText = '';
  Alignment guidanceAlignment = Alignment.center;
  bool canTapHighlightedItem = false;

  // --- Referências Externas ---
  late GeniusGameController _gameController;
  final OrientationService _orientationService = OrientationService();
  
  MemoryTutorialController() {
    final iconTypes = ["BaterPalma", "BaterPe", "BaterPeito", "BaterPerna", "Gritar", "Beijo"];
    for (var type in iconTypes) {
      cardKeys[type] = GlobalKey();
    }
  }

  void start(BuildContext context, GeniusGameController gameController) {
    _gameController = gameController;
    _buildTutorialSequence();
    nextStep();
  }
  
  void _buildTutorialSequence() {
    _tutorialSteps = [
      _welcomeStep,
      _highlightStatusStep,
      _explainTimerStep,
      ...cardKeys.keys.map((iconType) => () => _exploreCardStep(iconType)),
      _pressStartStep,
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

  // --- Funções de cada passo ---
  
  void _welcomeStep() {
    highlightRect = null;
    canTapHighlightedItem = false;
    activeCardTutorialType = null; // <-- Limpa o card ativo
    guidanceText = 'Bem-vindo ao Jogo da Memória! Para continuar, toque no botão "Começar" no canto inferior direito. Ou toque em "Pular Tutorial" no canto inferior esquerdo.';
    guidanceAlignment = Alignment.center;
    _announce(guidanceText);
    notifyListeners();
  }
  
  void _highlightStatusStep() {
    _calculateHighlight(statusKey);
    canTapHighlightedItem = false;
    activeCardTutorialType = null; // <-- Limpa o card ativo
    guidanceText = 'No painel superior, aparecerão as instruções como "Ouça a sequência." ou "Sua vez" e o botão Iniciar para começar o jogo. Toque no botão "Próximo", no canto inferior direito da tela para continuar.';
    guidanceAlignment = Alignment.center;
    _announce(guidanceText);
    notifyListeners();
  }
  
  void _explainTimerStep() {
    _calculateHighlight(statusKey);
    canTapHighlightedItem = false;
    activeCardTutorialType = null; // <-- Limpa o card ativo
    guidanceText = 'Quando for a sua vez, um timer aparecerá. Você terá 10 segundos para o primeiro toque da sequência. Para os toques seguintes na mesma rodada, o tempo será de 3 segundos. Se não responder a tempo, o jogo termina. Toque no botão "Próximo" para continuar.';
    guidanceAlignment = Alignment.center;
    _announce(guidanceText);
    notifyListeners();
  }

 void _exploreCardStep(String iconType) {
    _calculateHighlight(cardKeys[iconType]!);
    canTapHighlightedItem = true;
    activeCardTutorialType = iconType; // <-- Define o card ativo
    
    String cardName = _getSemanticsLabelFromType(iconType);
    guidanceText = 'Agora vá até o botão "$cardName" e toque duas vezes nele para ouvir seu som. Quando estiver pronto, toque no botão "Próximo" para ouvir o próximo som.';
    guidanceAlignment = Alignment.topCenter;
    _announce(guidanceText);
    notifyListeners();
  }

   void playCardSound(String iconType) {
    _gameController.playCardSoundForTutorial(iconType);
  }

  void _pressStartStep() {
    highlightRect = null; 
    canTapHighlightedItem = false;
    activeCardTutorialType = null; // <-- Limpa o card ativo
    
    guidanceText = 'Você conheceu todos os sons! Toque no botão "Finalizar Tutorial" para começar a jogar.';
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
    activeCardTutorialType = null; // <-- Limpa o card ativo
    _gameController.removeListener(_onGameStarted);
    _orientationService.markMemoryGameTutorialAsShown();
    _announce("Tutorial finalizado. Bom jogo!");
    notifyListeners();
  }

  // --- Lógica Auxiliar ---
  
  void _onGameStarted() {
    if (_gameController.gameState == GeniusGameState.showingSequence) {
      _finishTutorial();
    }
  }

  void _calculateHighlight(GlobalKey key) {
    final renderBox = key.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox != null) {
      final position = renderBox.localToGlobal(Offset.zero);
      highlightRect = Rect.fromLTWH(
        position.dx, position.dy,
        renderBox.size.width, renderBox.size.height
      );
    }
  }
  
  void _announce(String message) {
    SemanticsService.announce(message, TextDirection.ltr);
  }

  String _getSemanticsLabelFromType(String type) {
    switch (type) {
      case "BaterPe": return "Bater Pé";
      case "BaterPalma": return "Bater Palma";
      case "BaterPerna": return "Bater Perna";
      case "BaterPeito": return "Bater Peito";
      case "Gritar": return "Gritar";
      case "Beijo": return "Mandar Beijo";        
      default: return type;
    }
  }

  @override
  void dispose() {
    _gameController.removeListener(_onGameStarted);
    super.dispose();
  }
}