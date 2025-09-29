import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/memory_game_service.dart';
import '../../services/memory_tutorial_service.dart';
import '../widgets/hole_clipper.dart';
import 'memory_game_screen.dart';

class TutorialOverlay extends StatefulWidget {
  const TutorialOverlay({super.key});

  @override
  State<TutorialOverlay> createState() => _TutorialOverlayState();
}

class _TutorialOverlayState extends State<TutorialOverlay> {
  @override
  void initState() {
    super.initState();
    // Inicia o tutorial assim que a tela for construída
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final tutorialController = context.read<MemoryTutorialController>();
      final gameController = context.read<GeniusGameController>();
      tutorialController.start(context, gameController);
    });
  }
  
  @override
  Widget build(BuildContext context) {
    final tutorial = context.watch<MemoryTutorialController>();

   // ➜ Quando o tutorial NÃO está ativo, não passe callbacks do tutorial.
  if (!tutorial.isTutorialActive) {
    return const MemoryGameScreen(); // nova instância “limpa”
  }

  // ➜ Enquanto o tutorial está ativo, injete as chaves e o callback
  final gameScreen = MemoryGameScreen(
    statusBarKey: tutorial.statusKey,
    cardKeys: tutorial.cardKeys,
    onCardTappedDuringTutorial: (iconType) {
      tutorial.playCardSound(iconType);
    },
  );

    // Se o tutorial ESTÁ ativo, empilhamos o overlay por cima do jogo.
    return Stack(
      children: [
        gameScreen, // Camada 1: O jogo
        _buildTutorialLayer(tutorial), // Camada 2: O tutorial
      ],
    );
  }

  Widget _buildTutorialLayer(MemoryTutorialController tutorial) {
    return Stack(
      children: [
        GestureDetector(
          onTap: () {
            // Se o passo NÃO for interativo (o usuário não deve clicar no item destacado),
            // qualquer toque na área escura avançará para o próximo passo.
            if (!tutorial.canTapHighlightedItem) {
              tutorial.nextStep();
            }
          },
          child: ClipPath(
            clipper: HoleClipper(tutorial.highlightRect),
            child: Container(
              color: Colors.black.withOpacity(0.75),
            ),
          ),
        ),
        IgnorePointer(
          child: _buildGuidanceBox(tutorial),
        ),
        _buildNextButton(tutorial),
        _buildSkipButton(tutorial),
      ],
    );
  }

  Widget _buildGuidanceBox(MemoryTutorialController tutorial) {
    if (tutorial.highlightRect == null) {
      return Center(
        child: Container(
          padding: const EdgeInsets.all(24),
          margin: const EdgeInsets.symmetric(horizontal: 32),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(15),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 10,
                spreadRadius: 2,
              )
            ],
          ),
          child: Text(
            tutorial.guidanceText,
            // ====================== MODIFICAÇÃO DE ESTILO AQUI ======================
            style: const TextStyle(
              fontSize: 18, 
              color: Colors.blueAccent, // Cor do texto mudada para azul
              fontWeight: FontWeight.bold,
              decoration: TextDecoration.none, // Garante que não haja sublinhado
            ),
             textAlign: TextAlign.center,
        ),
      ),);
    }
    
    final rect = tutorial.highlightRect!;
    final screenHeight = MediaQuery.of(context).size.height;

    bool isBelow = tutorial.guidanceAlignment == Alignment.topCenter;
    double top = isBelow ? rect.bottom + 20 : rect.top - 120;

    if (top < 10) top = 10;
    if (top > screenHeight - 110) top = screenHeight - 110;
    
    return Positioned(
      top: top,
      left: 20,
      right: 20,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
           boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 8,
            )
          ],
        ),
        child: Text(
          tutorial.guidanceText,
          // ====================== MODIFICAÇÃO DE ESTILO AQUI ======================
          style: const TextStyle(
            fontSize: 16, 
            color: Colors.blueAccent, // Cor do texto mudada para azul
            decoration: TextDecoration.none, // Garante que não haja sublinhado
          ),
          // =====================================================================
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
  
  // ====================== MÉTODO CORRIGIDO ======================
  Widget _buildNextButton(MemoryTutorialController tutorial) {
    // Definimos explicitamente quais passos devem mostrar um botão
    bool isWelcomeStep = tutorial.guidanceText.contains('Bem-vindo');
    bool isExploreStep = tutorial.guidanceText.contains("Toque duas vezes nele para ouvir o som");

    // Se não for nem o passo de boas-vindas, nem um passo de exploração, não mostra o botão.
    if (!isWelcomeStep && !isExploreStep) {
      return const SizedBox.shrink();
    }
    
    return Positioned(
      bottom: 20,
      right: 20,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        ),
        onPressed: tutorial.nextStep,
        child: Text(isWelcomeStep ? 'Começar' : 'Próximo'),
      ),
    );
  }
  // =============================================================

  Widget _buildSkipButton(MemoryTutorialController tutorial) {
    if (!tutorial.isTutorialActive) {
      return const SizedBox.shrink();
    }
    return Positioned(
      bottom: 20,
      left: 20,
      child: TextButton(
        onPressed: () => tutorial.skipTutorial(context),
        child: const Text(
          'Pular Tutorial',
          style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}