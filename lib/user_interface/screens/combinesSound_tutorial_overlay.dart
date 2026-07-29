import 'package:mathnew/user_interface/widgets/vlibras_widget.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/combinesSound_service.dart';
import '../../services/combinesSound_tutorial_service.dart';
import '../widgets/hole_clipper.dart';
import 'combinesSound_screen.dart';

class GeneratorTutorialOverlay extends StatefulWidget {
  const GeneratorTutorialOverlay({super.key});

  @override
  State<GeneratorTutorialOverlay> createState() =>
      _GeneratorTutorialOverlayState();
}

class _GeneratorTutorialOverlayState extends State<GeneratorTutorialOverlay> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final tutorialController = context.read<GeneratorTutorialController>();
      final gameController = context.read<MelodyGeneratorController>();
      tutorialController.start(context, gameController);
    });
  }

  bool _isStepInteractive(int stepIndex) {
    switch (stepIndex) {
      case 1:
      case 2:
      case 3:
      case 5:
      case 6:
      case 7:
      case 8:
        return true;
      default:
        return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final tutorial = context.watch<GeneratorTutorialController>();

    if (!tutorial.isTutorialActive) {
      return const MelodyGeneratorScreen();
    }

    final gameScreen = MelodyGeneratorScreen(
      iconKeys: tutorial.iconKeys,
      confirmSelectionButtonKey: tutorial.confirmSelectionButtonKey,
      modeSelectionChallengeKey: tutorial.modeSelectionChallengeKey,
      modeSelectionFreeNoRepeatKey: tutorial.modeSelectionFreeNoRepeatKey,
      modeSelectionFreeRepeatKey: tutorial.modeSelectionFreeRepeatKey,
      melodiesListKey: tutorial.melodiesListKey,
      userInputAreaKey: tutorial.userInputAreaKey,
      iconInputPanelKey: tutorial.iconInputPanelKey,
      buttonConfirmKey: tutorial.buttonConfirmKey,
    );

    return Stack(
      children: [
        IgnorePointer(
          ignoring: tutorial.isTutorialActive,
          child: ExcludeSemantics(
            excluding: tutorial.isTutorialActive,
            child: gameScreen,
          ),
        ),
        if (tutorial.isTutorialActive) _buildTutorialLayer(tutorial),
        if (tutorial.isTutorialActive)
          const Positioned(
            bottom: 0,
            right: 0,
            child: ExcludeSemantics(child: VLibrasWidget()),
          ),
      ],
    );
  }

  Widget _buildTutorialLayer(GeneratorTutorialController tutorial) {
    final bool isLastStep =
        tutorial.currentStepIndex == tutorial.totalSteps - 1;
    final bool isFirstStep = tutorial.currentStepIndex == 0;
    final bool isInteractive = _isStepInteractive(tutorial.currentStepIndex);

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
            if (!isInteractive)
              GestureDetector(
                onTap: () {},
                child: ClipPath(
                  clipper: HoleClipper(tutorial.highlightRect),
                  child: Container(
                    color: Colors.black.withOpacity(0.75),
                  ),
                ),
              ),
            if (isInteractive)
              IgnorePointer(
                child: ClipPath(
                  clipper: HoleClipper(tutorial.highlightRect),
                  child: Container(
                    color: Colors.black.withOpacity(0.75),
                  ),
                ),
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

  Widget _buildGuidanceBox(GeneratorTutorialController tutorial) {
    if (tutorial.guidanceText.isEmpty) return const SizedBox.shrink();

    final screenWidth = MediaQuery.of(context).size.width;
    final maxBoxWidth = screenWidth * 0.70;
    final double fontSize = (screenWidth * 0.025).clamp(16.0, 32.0);

    if (tutorial.guidanceAlignment == Alignment.center ||
        tutorial.highlightRect == null) {
      return Align(
        alignment: Alignment.centerLeft,
        child: Container(
          width: maxBoxWidth,
          padding: const EdgeInsets.all(24),
          margin: const EdgeInsets.only(left: 40),
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
      );
    }

    final rect = tutorial.highlightRect!;
    final screenHeight = MediaQuery.of(context).size.height;
    bool isBelow = tutorial.guidanceAlignment == Alignment.topCenter;
    double top = isBelow ? rect.bottom + 20 : rect.top - 130;

    if (top < 10) top = 10;
    if (top > screenHeight - 120) top = screenHeight - 120;

    return Positioned(
      top: top,
      left: 30,
      width: maxBoxWidth - 30,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 8)
          ],
        ),
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
    );
  }

  Widget _buildNextButton(GeneratorTutorialController tutorial) {
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

  Widget _buildFinishButton(GeneratorTutorialController tutorial) {
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

  Widget _buildSkipButton(GeneratorTutorialController tutorial) {
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
