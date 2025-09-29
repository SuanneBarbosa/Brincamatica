import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Importe para o SystemChrome
import 'package:provider/provider.dart';
import '../../services/character_service.dart';
import 'memory_game_screen.dart';
import 'mathicons_screen.dart';
import 'melody_generator_screen.dart';
// Removido 'package:flutter/foundation.dart' pois kIsWeb não é mais usado aqui

enum GameMode { creation, genius, generator}

class CharacterSelectionScreen extends StatefulWidget {
  final GameMode gameMode;
  const CharacterSelectionScreen({super.key, required this.gameMode});

  @override
  State<CharacterSelectionScreen> createState() => _CharacterSelectionScreenState();
}

class _CharacterSelectionScreenState extends State<CharacterSelectionScreen> {
  final List<String> characterTypes = const [
    'boy_dark',
    'boy_light',
    'girl_dark',
    'girl_light',
  ];

  
  String _getCharacterImagePath(String type) {
    return 'assets/images/characters/character_$type.png';
  }

  String _getCharacterSemanticsLabel(String type) {
    String gender = type.contains('boy') ? 'Menino' : 'Menina';
    String tone = type.contains('dark') ? 'pele negra' : 'pele clara';
    return 'Personagem $gender, $tone. Toque para selecionar este personagem.';
  }

  String _getErrorSemanticsLabel(String type) {
    String gender = type.contains('boy') ? 'Menino' : 'Menina';
    String tone = type.contains('dark') ? 'pele negra' : 'pele clara';
    return 'Erro ao carregar imagem do personagem $gender, $tone.';
  }

  @override
  Widget build(BuildContext context) {
    final characterController = context.read<CharacterController>();

    const double itemSpacing = 12.0;
    const double maxRowWidth = 600.0;

    return Scaffold(
      appBar: AppBar(
        title: Semantics(
          header: false,
          child: const Text('Escolha Seu Personagem'),
        ),
        backgroundColor: Colors.blue,
        titleTextStyle: const TextStyle(color: Colors.white, fontSize: 20),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Container(
        color: const Color.fromRGBO(220, 247, 255, 1.0),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 10.0),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: maxRowWidth),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: characterTypes.map((type) {
                    return Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: itemSpacing / 2),
                        child: GestureDetector(
                          onTap: () {
                            characterController.setSelectedCharacter(type);

                          if (widget.gameMode == GameMode.creation) {
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(builder: (context) => const Mathicon()),
                              );
                            } else if (widget.gameMode == GameMode.genius) {
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(builder: (context) => const MemoryGameScreen()),
                              );
                            } else { // Novo caso para o Gerador de Melodias
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(builder: (context) => const MelodyGeneratorScreen()),
                              );
                            }
                          },
                          child: Semantics(
                            label: _getCharacterSemanticsLabel(type),
                            button: true,
                            child: ExcludeSemantics(
                              child: Card(
                                elevation: 4,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10)),
                                clipBehavior: Clip.antiAlias,
                                child: Padding(
                                  padding: const EdgeInsets.all(5.0),
                                  child: AspectRatio(
                                    aspectRatio: 90 / 120,
                                    child: Image.asset(
                                      _getCharacterImagePath(type),
                                      fit: BoxFit.contain,
                                      errorBuilder: (context, error, stackTrace) {
                                        print("Erro ao carregar imagem de seleção: ${_getCharacterImagePath(type)}\n$error");
                                        return Semantics(
                                          label: _getErrorSemanticsLabel(type),
                                          image: true,
                                          child: Container(
                                              color: Colors.grey.shade300,
                                              alignment: Alignment.center,
                                              child: const ExcludeSemantics(
                                                child: Icon(
                                                    Icons.error_outline,
                                                    color: Colors.redAccent,
                                                    size: 30),
                                              )),
                                        );
                                      },
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}