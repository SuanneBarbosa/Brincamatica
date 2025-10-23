import 'package:Mathnew/user_interface/screens/melody_generator_screen.dart';
import 'package:flutter/material.dart';
import 'character_selection_screen.dart';
import '../../services/orientation_service.dart';
import 'tutorial_overlay.dart';
import 'mathicons_screen.dart';
import 'memory_game_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // <<< ALTERAÇÃO: Obtendo a altura da tela para o espaçamento >>>
    final screenHeight = MediaQuery.of(context).size.height;
    // Calcula um espaçamento vertical responsivo
    final buttonSpacing = (screenHeight * 0.03).clamp(16.0, 24.0);

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
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        vertical: 24.0, horizontal: 16.0),
                    child: FocusTraversalGroup(
                      policy: OrderedTraversalPolicy(),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          FocusTraversalOrder(
                            order: const NumericFocusOrder(1),
                            child: _buildGameButton(
                              context: context,
                              label: 'Criar Melodia',
                              icon: Icons.music_note,
                              semanticsLabel: 'Criar Melodia',
                              semanticsHint:
                                  'Abre o jogo para criar melodias.',
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const Mathicon(),
                                  ),
                                );
                              },
                            ),
                          ),
                          SizedBox(height: buttonSpacing), // <<< ALTERAÇÃO: Espaçamento dinâmico
                          FocusTraversalOrder(
                            order: const NumericFocusOrder(2),
                            child: _buildGameButton(
                              context: context,
                              label: 'Jogo da Memória',
                              icon: Icons.memory,
                              semanticsLabel: 'Jogo da Memória',
                              semanticsHint:
                                  'Abre o jogo da memória. Caso seja a primeira vez, o tutorial será mostrado.',
                              onPressed: () async {
                                final orientationService =
                                    OrientationService();
                                final bool tutorialShown =
                                    await orientationService
                                        .hasShownMemoryGameTutorial();

                                if (context.mounted) {
                                  if (tutorialShown) {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            const MemoryGameScreen(),
                                      ),
                                    );
                                  } else {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            const TutorialOverlay(),
                                      ),
                                    );
                                  }
                                }
                              },
                            ),
                          ),
                          SizedBox(height: buttonSpacing), // <<< ALTERAÇÃO: Espaçamento dinâmico
                          FocusTraversalOrder(
                            order: const NumericFocusOrder(3),
                            child: _buildGameButton(
                              context: context,
                              label: 'Combina Som',
                              icon: Icons.compost,
                              semanticsLabel: 'Combina Som',
                              semanticsHint: 'Abre o jogo Combina Som.',
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        const MelodyGeneratorScreen(),
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildGameButton({
    required BuildContext context,
    required String label,
    required IconData icon,
    required VoidCallback onPressed,
    String? semanticsLabel,
    String? semanticsHint,
  }) {
    // <<< ALTERAÇÃO: Lógica para tamanhos dinâmicos >>>
    final mediaQuery = MediaQuery.of(context);
    final screenWidth = mediaQuery.size.width;
    final screenHeight = mediaQuery.size.height;

    // A largura do botão será 75% da largura da tela, mas no máximo 400px e no mínimo 280px.
    final buttonWidth = (screenWidth * 0.75).clamp(280.0, 400.0);
    
    // O padding vertical (que define a altura) será 2.5% da altura da tela, com limites.
    final verticalPadding = (screenHeight * 0.025).clamp(16.0, 24.0);
    
    // O tamanho do ícone será 8% da largura do botão, com limites.
    final iconSize = (buttonWidth * 0.08).clamp(28.0, 34.0);
    
    // O tamanho da fonte será 6% da largura do botão, com limites.
    final fontSize = (buttonWidth * 0.06).clamp(18.0, 24.0);

    return SizedBox(
      width: buttonWidth, // Usa a largura calculada
      child: Semantics(
        button: true,
        label: semanticsLabel ?? label,
        hint: semanticsHint ?? 'Toque para abrir $label.',
        child: ElevatedButton.icon(
          icon: Icon(icon, size: iconSize), // Usa o tamanho de ícone calculado
          label: Text(label),
          onPressed: onPressed,
          style: ElevatedButton.styleFrom(
            foregroundColor: Colors.white,
            backgroundColor: Colors.blueAccent,
            padding: EdgeInsets.symmetric(vertical: verticalPadding), // Usa o padding calculado
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            textStyle: TextStyle(
              fontSize: fontSize, // Usa o tamanho de fonte calculado
              fontWeight: FontWeight.bold,
            ),
            elevation: 5,
          ),
        ),
      ),
    );
  }
}