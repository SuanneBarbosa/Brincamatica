// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import '../../services/combinesSound_service.dart';
// import '../../services/combinesSound_tutorial_service.dart';
// import '../widgets/hole_clipper.dart';
// import 'combinesSound_screen.dart';

// class GeneratorTutorialOverlay extends StatefulWidget {
//   const GeneratorTutorialOverlay({super.key});

//   @override
//   State<GeneratorTutorialOverlay> createState() =>
//       _GeneratorTutorialOverlayState();
// }

// class _GeneratorTutorialOverlayState extends State<GeneratorTutorialOverlay> {
//   @override
//   void initState() {
//     super.initState();
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       final tutorialController = context.read<GeneratorTutorialController>();
//       final gameController = context.read<MelodyGeneratorController>();
//       tutorialController.start(context, gameController);
//     });
//   }

//   bool _isStepInteractive(int stepIndex) {
//     switch (stepIndex) {
//       case 1:
//       case 2:
//       case 3:
//       case 5:
//       case 6:
//       case 7:
//       case 8:
//         return true;
//       default:
//         return false;
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     final tutorial = context.watch<GeneratorTutorialController>();

//     if (!tutorial.isTutorialActive) {
//       return const MelodyGeneratorScreen();
//     }

//     final gameScreen = MelodyGeneratorScreen(
//       iconKeys: tutorial.iconKeys,
//       confirmSelectionButtonKey: tutorial.confirmSelectionButtonKey,
//       modeSelectionChallengeKey: tutorial.modeSelectionChallengeKey,
//       modeSelectionFreeNoRepeatKey: tutorial.modeSelectionFreeNoRepeatKey,
//       modeSelectionFreeRepeatKey: tutorial.modeSelectionFreeRepeatKey,
//       melodiesListKey: tutorial.melodiesListKey,
//       userInputAreaKey: tutorial.userInputAreaKey,
//       iconInputPanelKey: tutorial.iconInputPanelKey,
//       buttonConfirmKey: tutorial.buttonConfirmKey,
//     );

//     return Stack(
//       children: [
//         IgnorePointer(
//           ignoring: tutorial.isTutorialActive,
//           child: ExcludeSemantics(
//             excluding: tutorial.isTutorialActive,
//             child: gameScreen,
//           ),
//         ),
//         if (tutorial.isTutorialActive) _buildTutorialLayer(tutorial),
//       ],
//     );
//   }

//   Widget _buildTutorialLayer(GeneratorTutorialController tutorial) {
//     final bool isLastStep = tutorial.currentStepIndex == tutorial.totalSteps - 1;
//     final bool isInteractive = _isStepInteractive(tutorial.currentStepIndex);

//     return Semantics(
//       label: 'Camada do tutorial',
//       scopesRoute: true,
//       explicitChildNodes: true,
//       child: Stack(
//         children: [
//           if (!isInteractive)
//             GestureDetector(
//               onTap: () {},
//               child: ClipPath(
//                 clipper: HoleClipper(tutorial.highlightRect),
//                 child: Container(
//                   color: Colors.black.withOpacity(0.75),
//                 ),
//               ),
//             ),
//           if (isInteractive)
//             IgnorePointer(
//               child: ClipPath(
//                 clipper: HoleClipper(tutorial.highlightRect),
//                 child: Container(
//                   color: Colors.black.withOpacity(0.75),
//                 ),
//               ),
//             ),
//           _buildGuidanceBox(tutorial),
//           if (!isLastStep) _buildNextButton(tutorial),
//           if (!isLastStep) _buildSkipButton(tutorial),
//           if (isLastStep) _buildFinishButton(tutorial),
//         ],
//       ),
//     );
//   }

//   Widget _buildGuidanceBox(GeneratorTutorialController tutorial) {
//     if (tutorial.guidanceText.isEmpty) return const SizedBox.shrink();

//     Widget guidanceContent = Semantics(
//       liveRegion: true,
//       child: Text(
//         tutorial.guidanceText,
//         style: const TextStyle(
//             fontSize: 16,
//             color: Colors.blueAccent,
//             fontWeight: FontWeight.bold,
//             decoration: TextDecoration.none),
//         textAlign: TextAlign.center,
//       ),
//     );

//     if (tutorial.guidanceAlignment == Alignment.center ||
//         tutorial.highlightRect == null) {
//       return Center(
//         child: Container(
//           padding: const EdgeInsets.all(24),
//           margin: const EdgeInsets.symmetric(horizontal: 40),
//           decoration: BoxDecoration(
//             color: Colors.white,
//             borderRadius: BorderRadius.circular(15),
//             boxShadow: [
//               BoxShadow(
//                   color: Colors.black.withOpacity(0.2),
//                   blurRadius: 10,
//                   spreadRadius: 2)
//             ],
//           ),
//           child: guidanceContent,
//         ),
//       );
//     }

//     final rect = tutorial.highlightRect!;
//     final screenHeight = MediaQuery.of(context).size.height;
//     bool isBelow = tutorial.guidanceAlignment == Alignment.topCenter;

//     double top = isBelow ? rect.bottom + 20 : rect.top - 130;

//     if (top < 10) top = 10;
//     if (top > screenHeight - 120) top = screenHeight - 120;

//     return Positioned(
//       top: top,
//       left: 30,
//       right: 30,
//       child: Container(
//         padding: const EdgeInsets.all(16),
//         decoration: BoxDecoration(
//           color: Colors.white,
//           borderRadius: BorderRadius.circular(10),
//           boxShadow: [
//             BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 8)
//           ],
//         ),
//         child: guidanceContent,
//       ),
//     );
//   }

//   Widget _buildNextButton(GeneratorTutorialController tutorial) {
//     final bool isWelcomeStep = tutorial.currentStepIndex == 0;

//     return Positioned(
//       bottom: 20,
//       right: 20,
//       child: ElevatedButton(
//         style: ElevatedButton.styleFrom(
//           padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
//         ),
//         onPressed: tutorial.nextStep,
//         child: Text(isWelcomeStep ? 'Começar' : 'Próximo'),
//       ),
//     );
//   }

//   Widget _buildFinishButton(GeneratorTutorialController tutorial) {
//     return Positioned(
//       bottom: 20,
//       right: 20,
//       child: ElevatedButton(
//         style: ElevatedButton.styleFrom(
//           backgroundColor: Colors.blueAccent,
//           foregroundColor: Colors.white,
//           padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
//         ),
//         onPressed: tutorial.skipTutorial,
//         child: const Text('Finalizar Tutorial'),
//       ),
//     );
//   }

//   Widget _buildSkipButton(GeneratorTutorialController tutorial) {
//     return Positioned(
//       bottom: 20,
//       left: 20,
//       child: TextButton(
//         onPressed: tutorial.skipTutorial,
//         child: const Text(
//           'Pular Tutorial',
//           style: TextStyle(
//               color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
//         ),
//       ),
//     );
//   }
// }

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
      ],
    );
  }

  Widget _buildTutorialLayer(GeneratorTutorialController tutorial) {
    final bool isLastStep = tutorial.currentStepIndex == tutorial.totalSteps - 1;
    final bool isFirstStep = tutorial.currentStepIndex == 0;
    final bool isInteractive = _isStepInteractive(tutorial.currentStepIndex);

    // >>> MODIFICAÇÃO AQUI: Envolvido com GestureDetector <<<
    return GestureDetector(
      onHorizontalDragEnd: (details) {
         bool isSwipeNext = details.primaryVelocity != null && details.primaryVelocity! < 0;
                
                // TRAVA DE SEGURANÇA: Só avança se não for o primeiro nem o último
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

  Widget _buildNextButton(GeneratorTutorialController tutorial) {
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

  Widget _buildFinishButton(GeneratorTutorialController tutorial) {
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

  Widget _buildSkipButton(GeneratorTutorialController tutorial) {
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