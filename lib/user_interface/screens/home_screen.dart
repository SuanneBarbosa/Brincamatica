import 'package:flutter/material.dart';
import 'character_selection_screen.dart';
import '../../services/orientation_service.dart';
import 'tutorial_overlay.dart';



class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Escolha o Jogo'),
        backgroundColor: Colors.blue,
        titleTextStyle: const TextStyle(color: Colors.white, fontSize: 20),
      ),
      body: Container(
        color: const Color.fromRGBO(220, 247, 255, 1.0),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildGameButton(
                context: context,
                label: 'Criar Melodia',
                icon: Icons.music_note,
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      // Passamos o modo de jogo para a tela de seleção de personagem
                      builder: (context) => const CharacterSelectionScreen(gameMode: GameMode.creation),
                    ),
                  );
                },
              ),
              const SizedBox(height: 40),
              _buildGameButton(
                context: context,
                label: 'Jogo da Memória',
                icon: Icons.memory,
                onPressed: () async {
                  final orientationService = OrientationService();
                  final bool tutorialShown = await orientationService.hasShownMemoryGameTutorial();

                  if (context.mounted) {
                    if (tutorialShown) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const CharacterSelectionScreen(gameMode: GameMode.genius),
                        ),
                      );
                    } else {
                      // Chama a nova tela de overlay
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const TutorialOverlay(),
                        ),
                      );
                    }
                  }
                },
              ),
               const SizedBox(height: 30), // <-- NOVO ESPAÇAMENTO
              // BOTÃO PARA O NOVO JOGO
              _buildGameButton(
                context: context,
                label: 'Gerador de Melodias',
                icon: Icons.auto_awesome_motion, // Um ícone sugestivo
                onPressed: () {
                   Navigator.push(
                    context,
                    MaterialPageRoute(
                      // Passamos o novo modo de jogo
                      builder: (context) => const CharacterSelectionScreen(gameMode: GameMode.generator),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGameButton({
    required BuildContext context,
    required String label,
    required IconData icon,
    required VoidCallback onPressed,
  }) {
    return ElevatedButton.icon(
      icon: Icon(icon, size: 32),
      label: Text(label),
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        foregroundColor: Colors.white,
        backgroundColor: Colors.blueAccent,
        minimumSize: const Size(300, 80),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        textStyle: const TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
        ),
        elevation: 5,
      ),
    );
  }
}