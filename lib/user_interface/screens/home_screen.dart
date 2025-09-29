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
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            // ⬇️ TROCA: Column -> Wrap para alinhar na HORIZONTAL
            child: Wrap(
              alignment: WrapAlignment.center,
              spacing: 24,     // espaço horizontal entre botões
              runSpacing: 24,  // espaço vertical quando quebrar linha
              children: [
                _buildGameButton(
                  context: context,
                  label: 'Criar Melodia',
                  icon: Icons.music_note,
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const CharacterSelectionScreen(gameMode: GameMode.creation),
                      ),
                    );
                  },
                ),
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
                _buildGameButton(
                  context: context,
                  label: 'Gerador de Melodias',
                  icon: Icons.auto_awesome_motion,
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const CharacterSelectionScreen(gameMode: GameMode.generator),
                      ),
                    );
                  },
                ),
              ],
            ),
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
    // ⬇️ Mantém aparência e dá uma largura “fixa” para alinhar bonito no Wrap
    return ConstrainedBox(
      constraints: const BoxConstraints(
        minWidth: 260, // largura mínima do botão (ajuste se quiser)
        maxWidth: 300, // trava um pouco para todos ficarem parecidos
        minHeight: 80,
      ),
      child: ElevatedButton.icon(
        icon: Icon(icon, size: 32),
        label: Text(label),
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          foregroundColor: Colors.white,
          backgroundColor: Colors.blueAccent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
          elevation: 5,
        ),
      ),
    );
  }
}
