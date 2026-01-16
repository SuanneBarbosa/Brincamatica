import 'package:Mathnew/user_interface/widgets/vlibras_widget.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/sheldon_service.dart';
import '../../services/sheldon_tutorial_service.dart';
import '../widgets/hole_clipper.dart';
import 'sheldon_screen.dart';

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
    );

     final bool isGameScreenInteractive = tutorial.isTutorialActive && tutorial.canTapHighlightedItem;

    return Stack(
      children: [
        ExcludeSemantics(
          excluding: tutorial.isTutorialActive && !isGameScreenInteractive,
          child: gameScreen,
        ),
        _buildTutorialLayer(tutorial),
        if (tutorial.isTutorialActive)
        const Positioned(
          bottom: 0, 
          right: 0,
           child: ExcludeSemantics(
          child: VLibrasWidget(),
           ),
        ),
      ],
    );
  }

  Widget _buildTutorialLayer(MemoryTutorialController tutorial) {
    final bool isLastStep = tutorial.currentStepIndex == tutorial.totalSteps - 1;
    final bool isFirstStep = tutorial.currentStepIndex == 0;
    
    return GestureDetector(
      onHorizontalDragEnd: (details) {
       bool isSwipeNext = details.primaryVelocity != null && details.primaryVelocity! < 0;
                if (isSwipeNext && !isFirstStep && !isLastStep) {
                  tutorial.nextStep();
                }
      },
      child: Semantics(
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
      ),
    );
  }


Widget _buildGuidanceBox(MemoryTutorialController tutorial) {
  final screenWidth = MediaQuery.of(context).size.width;
  final double fontSize = (screenWidth * 0.025).clamp(16.0, 32.0);
  final maxBoxWidth = screenWidth * 0.70; 

    if (tutorial.guidanceAlignment == Alignment.center || tutorial.highlightRect == null) {
      return Align(
        alignment: Alignment.centerLeft,
        child: Container(
          width: maxBoxWidth,
          padding: const EdgeInsets.all(24),
          margin: const EdgeInsets.only(left: 40),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(15),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 10, spreadRadius: 2)],
          ),
          child: Text(
            tutorial.guidanceText,
            style: TextStyle(
              fontSize: fontSize, 
              color: Colors.blueAccent, 
              fontWeight: FontWeight.bold, 
              decoration: TextDecoration.none
            ),
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    final rect = tutorial.highlightRect!;
    final screenHeight = MediaQuery.of(context).size.height;
    final bool isBelow = tutorial.guidanceAlignment == Alignment.topCenter;
    double top = isBelow ? rect.bottom + 30 : rect.top - 120;

    if (top < 10) top = 10;
    if (top > screenHeight - 110) top = screenHeight - 110;

    return Positioned(
      top: top,
      left: 30,
      width: maxBoxWidth - 30, 
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 8)],
        ),
        child: Text(
          tutorial.guidanceText,
          style: TextStyle(
            fontSize: fontSize, 
            color: Colors.blueAccent, 
            decoration: TextDecoration.none
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
}


 Widget _buildNextButton(MemoryTutorialController tutorial) {
    final bool isWelcomeStep = tutorial.currentStepIndex == 0;
    final screenWidth = MediaQuery.of(context).size.width;
    final double btnFontSize = (screenWidth * 0.022).clamp(16.0, 28.0);
    final double padH = (screenWidth * 0.03).clamp(24.0, 50.0);
    final double padV = (screenWidth * 0.015).clamp(12.0, 24.0);

    return Positioned(
      bottom: 20,
      right: (screenWidth * 0.25) + 20, 
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          padding: EdgeInsets.symmetric(horizontal: padH, vertical: padV),
          textStyle: TextStyle(fontSize: btnFontSize, fontWeight: FontWeight.bold),
        ),
        onPressed: tutorial.nextStep,
        child: Text(isWelcomeStep ? 'Começar' : 'Próximo'),
      ),
    );
  }
  
  Widget _buildFinishButton(MemoryTutorialController tutorial) {
    final screenWidth = MediaQuery.of(context).size.width;
    final double btnFontSize = (screenWidth * 0.022).clamp(16.0, 28.0);
    final double padH = (screenWidth * 0.03).clamp(24.0, 50.0);
    final double padV = (screenWidth * 0.015).clamp(12.0, 24.0);

    return Positioned(
      bottom: 20,
      right: (screenWidth * 0.25) + 20, 
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.blueAccent,
          foregroundColor: Colors.white,
          padding: EdgeInsets.symmetric(horizontal: padH, vertical: padV),
          textStyle: TextStyle(fontSize: btnFontSize, fontWeight: FontWeight.bold),
        ),
        onPressed: () => tutorial.skipTutorial(context),
        child: const Text('Finalizar Tutorial'),
      ),
    );
  }

  Widget _buildSkipButton(MemoryTutorialController tutorial) {
    final screenWidth = MediaQuery.of(context).size.width;
    final double fontSize = (screenWidth * 0.022).clamp(16.0, 28.0);

    return Positioned(
      bottom: 20,
      left: 20,
      child: TextButton(
        onPressed: () => tutorial.skipTutorial(context),
        child: Text(
          'Pular Tutorial',
          style: TextStyle(
            color: Colors.blueAccent, 
            fontSize: fontSize, 
            fontWeight: FontWeight.bold
          ),
        ),
      ),
    );
  }
}
 
  