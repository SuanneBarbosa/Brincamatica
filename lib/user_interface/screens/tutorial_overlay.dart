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
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final tutorialController = context.read<MemoryTutorialController>();
      final gameController = context.read<GeniusGameController>();
      tutorialController.start(context, gameController);
    });
  }
  
  @override
  Widget build(BuildContext context) {
    final tutorial = context.watch<MemoryTutorialController>();

    if (!tutorial.isTutorialActive) {
      return const MemoryGameScreen();
    }

    final gameScreen = MemoryGameScreen(
      statusBarKey: tutorial.statusKey,
      cardKeys: tutorial.cardKeys,
      onCardTappedDuringTutorial: (iconType) {
        tutorial.playCardSound(iconType);
      },
    );

    final bool isExploringCards = tutorial.activeCardTutorialType != null;

    return Stack(
      children: [
        ExcludeSemantics(
          excluding: tutorial.isTutorialActive && !isExploringCards,
          child: gameScreen,
        ),
        _buildTutorialLayer(tutorial),
      ],
    );
  }

  Widget _buildTutorialLayer(MemoryTutorialController tutorial) {
    final bool isLastStep = tutorial.currentStepIndex == tutorial.totalSteps - 1;
    return Semantics(
      label: 'Camada do tutorial',
       scopesRoute: true, 
       explicitChildNodes: true, 
      child: Stack(
        children: [
          GestureDetector(
            onTap: () {},
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
          if (!isLastStep) _buildNextButton(tutorial),
          if (!isLastStep) _buildSkipButton(tutorial),
          if (isLastStep) _buildFinishButton(tutorial),
        ],
      ),
    );
  }
  
  Widget _buildGuidanceBox(MemoryTutorialController tutorial) {
    if (tutorial.guidanceAlignment == Alignment.center) {
      return Center(
        child: Container(
          padding: const EdgeInsets.all(24),
          margin: const EdgeInsets.symmetric(horizontal: 40),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(15),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 10, spreadRadius: 2,)],
          ),
          child: Text(
            tutorial.guidanceText,
            style: const TextStyle(fontSize: 16, color: Colors.blueAccent, fontWeight: FontWeight.bold, decoration: TextDecoration.none),
            textAlign: TextAlign.center,
          ),
        ),
      );
    }
  
    final rect = tutorial.highlightRect!;
    final screenHeight = MediaQuery.of(context).size.height;
    bool isBelow = tutorial.guidanceAlignment == Alignment.topCenter;
    
    double top = isBelow ? rect.bottom + 30 : rect.top - 120;
   
    if (top < 10) top = 10;
    if (top > screenHeight - 110) top = screenHeight - 110;
    
    return Positioned(
      top: top,
      left: 30,
      right: 30,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 8,)],
        ),
        child: Text(
          tutorial.guidanceText,
          style: const TextStyle(fontSize: 16, color: Colors.blueAccent, decoration: TextDecoration.none),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
 
  Widget _buildNextButton(MemoryTutorialController tutorial) {
    final bool isWelcomeStep = tutorial.currentStepIndex == 0;
    
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
  
  Widget _buildFinishButton(MemoryTutorialController tutorial) {
    return Positioned(
      bottom: 20,
      right: 20,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.blueAccent,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        ),
        onPressed: () => tutorial.skipTutorial(context),
        child: const Text('Finalizar Tutorial'),
      ),
    );
  }

  Widget _buildSkipButton(MemoryTutorialController tutorial) {
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