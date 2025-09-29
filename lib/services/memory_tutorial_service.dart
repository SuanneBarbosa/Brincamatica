import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'memory_game_service.dart';
import 'orientation_service.dart';

// Enum removido, usaremos uma lista de passos para mais flexibilidade

class MemoryTutorialController extends ChangeNotifier {
  // --- Estado do Tutorial ---
  int _currentStepIndex = -1; // Começa antes do primeiro passo
  List<Function> _tutorialSteps = []; // Lista de funções, cada uma representa um passo
  bool get isTutorialActive => _currentStepIndex < _tutorialSteps.length;

  // --- Chaves e Destaques ---
  final Map<String, GlobalKey> cardKeys = {}; // Um mapa de chaves para cada tipo de card
  final statusKey = GlobalKey();
  Rect? highlightRect;
  String guidanceText = '';
  Alignment guidanceAlignment = Alignment.center;
  bool canTapHighlightedItem = false; // Controla se o item destacado pode ser tocado

  // --- Referências Externas ---
  late GeniusGameController _gameController;
  final OrientationService _orientationService = OrientationService();
  
  // Construtor para inicializar as chaves dos cards
  MemoryTutorialController() {
    // Esses nomes devem corresponder EXATAMENTE aos nomes em 'availableIcons' no GeniusGameController
    final iconTypes = ["BaterPalma", "BaterPe", "BaterPeito", "BaterPerna", "Gritar", "Beijo"];
    for (var type in iconTypes) {
      cardKeys[type] = GlobalKey();
    }
  }

  void start(BuildContext context, GeniusGameController gameController) {
    _gameController = gameController;
    _buildTutorialSequence(); // Monta a sequência de passos
    nextStep(); // Inicia o primeiro passo
  }
  
  // Monta a sequência de passos do tutorial
  void _buildTutorialSequence() {
    _tutorialSteps = [
      _welcomeStep,
      _highlightStatusStep,
      _explainTimerStep,
      // Gera um passo de exploração para cada card
      ...cardKeys.keys.map((iconType) => () => _exploreCardStep(iconType)),
      _pressStartStep,
    ];
  }

  // Avança para o próximo passo da sequência
  void nextStep() {
    _currentStepIndex++;
    if (isTutorialActive) {
      _tutorialSteps[_currentStepIndex](); // Executa a função do passo atual
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
    guidanceText = 'Bem-vindo ao Jogo da Memória! Para continuar, toque no botão "Começar" no canto inferior direito, ou toque em "Pular Tutorial" no canto inferior esquerdo.';
    guidanceAlignment = Alignment.center;
    _announce(guidanceText);
    notifyListeners();
  }
  
  void _highlightStatusStep() {
    _calculateHighlight(statusKey);
    canTapHighlightedItem = false;
    guidanceText = 'No painel superior, aparecerão as instruções como "Observe a sequência" ou "Sua vez", além da sua pontuação. Toque na tela para continuar.';
    guidanceAlignment = Alignment.center;
    _announce(guidanceText);
    notifyListeners();
  }
  
  void _explainTimerStep() {
    _calculateHighlight(statusKey); // Mantém o destaque na barra de status
    canTapHighlightedItem = false;
    guidanceText = 'Quando for a sua vez, um timer de 10 segundos aparecerá neste painel superior. Se não responder a tempo, o jogo termina. Toque na tela para continuar.';
    guidanceAlignment = Alignment.center;
    _announce(guidanceText);
    notifyListeners();
  }

 void _exploreCardStep(String iconType) {
    _calculateHighlight(cardKeys[iconType]!);
    canTapHighlightedItem = true;
    
    String cardName = _getSemanticsLabelFromType(iconType);
    guidanceText = 'Agora toque no botão "$cardName" duas vezes para ouvir seu som. Quando estiver pronto, toque no botão "Próximo", no canto inferior direito da tela, para ouvir o próximo som.';
    guidanceAlignment = Alignment.topCenter;
    _announce(guidanceText);
    notifyListeners();
  }

   void playCardSound(String iconType) {
    _gameController.playCardSoundForTutorial(iconType);
  }

 void _pressStartStep() {
    _calculateHighlight(statusKey);
    canTapHighlightedItem = true;
    guidanceText = 'Você conheceu todos os sons! Agora, toque duas vezes no botão "Iniciar" para começar sua primeira partida.';
    guidanceAlignment = Alignment.center;
    _gameController.addListener(_onGameStarted);
    _announce(guidanceText);
    notifyListeners();
  }
  
  void _finishTutorial() {
    _currentStepIndex = _tutorialSteps.length; // Garante que isTutorialActive seja false
    highlightRect = null;
    guidanceText = '';
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
  
  // Função para anunciar ao TalkBack
  void _announce(String message) {
    SemanticsService.announce(message, TextDirection.ltr);
  }

  // Copiada para obter o nome para o anúncio
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