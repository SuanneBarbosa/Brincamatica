import 'package:Mathnew/user_interface/widgets/vlibras_widget.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/character_service.dart';
import '../../services/icon_service.dart';
import '../../services/playback_service.dart';
import '../../services/createMelody_tutorial_service.dart';
import '../widgets/hole_clipper.dart';
import 'createMelody_screen.dart';

class CreateMelodyTutorialOverlay extends StatefulWidget {
  const CreateMelodyTutorialOverlay({super.key});

  @override
  State<CreateMelodyTutorialOverlay> createState() =>
      _CreateMelodyTutorialOverlayState();
}

class _CreateMelodyTutorialOverlayState
    extends State<CreateMelodyTutorialOverlay> {
  
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final tutorialController = context.read<CreateMelodyTutorialController>();
      
      final charController = context.read<CharacterController>();
      final iconController = context.read<IconController>();
      final playbackController = context.read<PlaybackController>();

      tutorialController.start(
        context, 
        charController, 
        iconController, 
        playbackController
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final tutorial = context.watch<CreateMelodyTutorialController>();

    if (!tutorial.isTutorialActive) {
      return const Mathicon();
    }

    final gameScreen = Mathicon(
      characterKey: tutorial.characterKey,
      actionMenuKey: tutorial.actionMenuKey,
      playButtonKey: tutorial.playButtonKey,
      menuButtonKey: tutorial.menuButtonKey,
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
          bottom: 50, 
          right: 0,
          child: VLibrasWidget(),
        ),
      ],
    );
  }

  Widget _buildTutorialLayer(CreateMelodyTutorialController tutorial) {
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
            
            _buildGuidanceBox(tutorial),
            
            if (!isLastStep) _buildNextButton(tutorial),
            if (!isLastStep) _buildSkipButton(tutorial),
            if (isLastStep) _buildFinishButton(tutorial),
          ],
        ),
      ),
    );
  }

  Widget _buildGuidanceBox(CreateMelodyTutorialController tutorial) {
    if (tutorial.guidanceText.isEmpty) return const SizedBox.shrink();

    Widget guidanceContent = Semantics(
      liveRegion: true,
      child: Text(
        tutorial.guidanceText,
        style: const TextStyle(
            fontSize: 16,
            color: Colors.blueAccent,
            fontWeight: FontWeight.bold,
            decoration: TextDecoration.none),
        textAlign: TextAlign.center,
      ),
    );

    if (tutorial.guidanceAlignment == Alignment.center ||
        tutorial.highlightRect == null) {
      return Center(
        child: Container(
          padding: const EdgeInsets.all(24),
          margin: const EdgeInsets.symmetric(horizontal: 40),
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
          child: guidanceContent,
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
      right: 30,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 8)
          ],
        ),
        child: guidanceContent,
      ),
    );
  }

  Widget _buildNextButton(CreateMelodyTutorialController tutorial) {
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

  Widget _buildFinishButton(CreateMelodyTutorialController tutorial) {
    return Positioned(
      bottom: 20,
      right: 20,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.blueAccent,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        ),
        onPressed: tutorial.skipTutorial,
        child: const Text('Finalizar Tutorial'),
      ),
    );
  }

  Widget _buildSkipButton(CreateMelodyTutorialController tutorial) {
    return Positioned(
      bottom: 20,
      left: 20,
      child: TextButton(
        onPressed: tutorial.skipTutorial,
        child: const Text(
          'Pular Tutorial',
          style: TextStyle(
              color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}