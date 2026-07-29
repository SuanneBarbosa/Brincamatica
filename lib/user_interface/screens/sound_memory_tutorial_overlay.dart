import 'package:mathnew/user_interface/widgets/vlibras_widget.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/sound_memory_service.dart';
import '../../services/sound_memory_tutorial_service.dart';
import 'sound_memory_screen.dart';

class SoundMemoryTutorialOverlay extends StatefulWidget {
  const SoundMemoryTutorialOverlay({super.key});

  @override
  State<SoundMemoryTutorialOverlay> createState() =>
      _SoundMemoryTutorialOverlayState();
}

class _SoundMemoryTutorialOverlayState
    extends State<SoundMemoryTutorialOverlay> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final tutorialController = context.read<SoundMemoryTutorialController>();
      final gameController = context.read<SoundMemoryController>();
      tutorialController.start(context, gameController);
    });
  }

  @override
  Widget build(BuildContext context) {
    final tutorial = context.watch<SoundMemoryTutorialController>();
    if (!tutorial.isTutorialActive) {
      return const SoundMemoryScreen();
    }

    return Stack(
      children: [
        IgnorePointer(
          ignoring: tutorial.isTutorialActive,
          child: ExcludeSemantics(
            excluding: tutorial.isTutorialActive,
            child: const SoundMemoryScreen(),
          ),
        ),
        if (tutorial.isTutorialActive) _buildTutorialLayer(tutorial),
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

  Widget _buildTutorialLayer(SoundMemoryTutorialController tutorial) {
    final bool isLastStep =
        tutorial.currentStepIndex == tutorial.totalSteps - 1;
    final bool isFirstStep = tutorial.currentStepIndex == 0;

    return GestureDetector(
      onHorizontalDragEnd: (details) {
        bool isSwipeNext =
            details.primaryVelocity != null && details.primaryVelocity! < 0;
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
            Container(
              color: Colors.black.withOpacity(0.75),
            ),
            _buildGuidanceBox(tutorial),
            if (!isLastStep) _buildNextButton(tutorial),
            if (!isLastStep) _buildSkipButton(tutorial),
            if (isLastStep) _buildFinishButton(tutorial),
          ],
        ),
      ),
    );
  }

  Widget _buildGuidanceBox(SoundMemoryTutorialController tutorial) {
    if (tutorial.guidanceText.isEmpty) return const SizedBox.shrink();
    final screenWidth = MediaQuery.of(context).size.width;
    final double fontSize = (screenWidth * 0.025).clamp(16.0, 32.0);

    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        width: screenWidth * 0.70,
        padding: const EdgeInsets.all(24),
        margin: const EdgeInsets.only(left: 30),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 10,
                spreadRadius: 2)
          ],
        ),
        child: Semantics(
          liveRegion: true,
          child: Text(
            tutorial.guidanceText,
            style: TextStyle(
                fontSize: fontSize,
                color: Colors.blueAccent,
                fontWeight: FontWeight.bold,
                decoration: TextDecoration.none),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }

  Widget _buildNextButton(SoundMemoryTutorialController tutorial) {
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
          textStyle:
              TextStyle(fontSize: btnFontSize, fontWeight: FontWeight.bold),
        ),
        onPressed: tutorial.nextStep,
        child: Text(isWelcomeStep ? 'Começar' : 'Próximo'),
      ),
    );
  }

  Widget _buildFinishButton(SoundMemoryTutorialController tutorial) {
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
          textStyle:
              TextStyle(fontSize: btnFontSize, fontWeight: FontWeight.bold),
        ),
        onPressed: tutorial.skipTutorial,
        child: const Text('Finalizar Tutorial'),
      ),
    );
  }

  Widget _buildSkipButton(SoundMemoryTutorialController tutorial) {
    final screenWidth = MediaQuery.of(context).size.width;
    final double fontSize = (screenWidth * 0.022).clamp(16.0, 28.0);

    return Positioned(
      bottom: 20,
      left: 20,
      child: TextButton(
        onPressed: tutorial.skipTutorial,
        child: Text(
          'Pular Tutorial',
          style: TextStyle(
              color: Colors.blueAccent,
              fontSize: fontSize,
              fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
