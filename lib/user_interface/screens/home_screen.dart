import 'package:mathnew/services/sheldon_tutorial_service.dart';
import 'package:mathnew/user_interface/screens/combinesSound_screen.dart';
import 'package:mathnew/user_interface/screens/createMelody_tutorial_overlay.dart';
import 'package:flutter/material.dart';
import 'character_selection_screen.dart';
import '../../services/orientation_service.dart';
import 'sheldon_tutorial_overlay.dart';
import 'createMelody_screen.dart';
import 'sheldon_screen.dart';
import 'combinesSound_tutorial_overlay.dart';
import 'sound_memory_screen.dart';
import 'sound_memory_tutorial_overlay.dart';
import '../../services/sound_memory_tutorial_service.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Semantics(
          namesRoute: true,
          header: true,
          child: const Text('Escolha o Jogo'),
        ),
        backgroundColor: Colors.blue,
        titleTextStyle: const TextStyle(color: Colors.white, fontSize: 20),
        actions: [
          FocusTraversalOrder(
            order: const NumericFocusOrder(99),
            child: Semantics(
              button: true,
              label: 'Trocar personagem',
              hint: 'Abre a tela para escolher ou alterar o personagem.',
              child: IconButton(
                tooltip: 'Trocar Personagem',
                icon: const Icon(Icons.person_search, color: Colors.white),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const CharacterSelectionScreen(),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
      body: Container(
        color: const Color.fromRGBO(220, 247, 255, 1.0),
        width: double.infinity,
        height: double.infinity,
        child: Center(
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
              child: FocusTraversalGroup(
                policy: OrderedTraversalPolicy(),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    FocusTraversalOrder(
                      order: const NumericFocusOrder(1),
                      child: _buildGameCard(
                        context: context,
                        label: 'Criar Melodia',
                        icon: Icons.music_note,
                        semanticsLabel: 'Jogo Criar Melodia',
                        onPressed: () async {
                          final orientationService = OrientationService();
                          final bool tutorialShown = await orientationService
                              .hasShownCreateMelodyTutorial();
                          if (context.mounted) {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => tutorialShown
                                    ? const Mathicon()
                                    : const CreateMelodyTutorialOverlay(),
                              ),
                            );
                          }
                        },
                      ),
                    ),
                    const SizedBox(width: 20),
                    FocusTraversalOrder(
                      order: const NumericFocusOrder(2),
                      child: _buildGameCard(
                        context: context,
                        label: 'Sheldon',
                        icon: Icons.memory,
                        semanticsLabel: 'Jogo Sheldon',
                        onPressed: () async {
                          final orientationService = OrientationService();
                          final bool tutorialShown = await orientationService
                              .hasShownMemoryGameTutorial();

                          if (context.mounted) {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => tutorialShown
                                    ? const MemoryGameScreen()
                                    : ChangeNotifierProvider(
                                        create: (_) =>
                                            MemoryTutorialController(),
                                        child: const TutorialOverlay(),
                                      ),
                              ),
                            );
                          }
                        },
                      ),
                    ),
                    const SizedBox(width: 20),
                    FocusTraversalOrder(
                      order: const NumericFocusOrder(3),
                      child: _buildGameCard(
                        context: context,
                        label: 'Combina Som',
                        icon: Icons.compost,
                        semanticsLabel: 'Jogo Combina Som',
                        onPressed: () async {
                          final orientationService = OrientationService();
                          final bool tutorialShown = await orientationService
                              .hasShownGeneratorGameTutorial();

                          if (context.mounted) {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => tutorialShown
                                    ? const MelodyGeneratorScreen()
                                    : const GeneratorTutorialOverlay(),
                              ),
                            );
                          }
                        },
                      ),
                    ),
                    const SizedBox(width: 20),
                    FocusTraversalOrder(
                      order: const NumericFocusOrder(4),
                      child: _buildGameCard(
                        context: context,
                        label: 'Jogo da Memória',
                        icon: Icons.style,
                        semanticsLabel: 'Jogo da Memória',
                        onPressed: () async {
                          final orientationService = OrientationService();
                          final bool tutorialShown = await orientationService
                              .hasShownSoundMemoryTutorial();

                          if (context.mounted) {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => tutorialShown
                                    ? const SoundMemoryScreen()
                                    : ChangeNotifierProvider(
                                        create: (_) =>
                                            SoundMemoryTutorialController(),
                                        child:
                                            const SoundMemoryTutorialOverlay(),
                                      ),
                              ),
                            );
                          }
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGameCard({
    required BuildContext context,
    required String label,
    required IconData icon,
    required VoidCallback onPressed,
    required String semanticsLabel,
  }) {
    return SizedBox(
      width: 150,
      height: 150,
      child: Semantics(
        label: semanticsLabel,
        hint: 'Toque para abrir o jogo $label',
        button: true,
        child: Card(
          elevation: 5,
          clipBehavior: Clip.antiAlias,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          child: InkWell(
            onTap: onPressed,
            child: Container(
              color: Colors.blueAccent,
              padding: const EdgeInsets.all(12.0),
              child: ExcludeSemantics(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Icon(icon, size: 50, color: Colors.white),
                    const SizedBox(height: 12),
                    Text(
                      label,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
