import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/character_service.dart';
import 'home_screen.dart';

class CharacterSelectionScreen extends StatefulWidget {
  final bool isInitialSelection;

  const CharacterSelectionScreen({
    super.key, 
    this.isInitialSelection = false,
  });

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
    String tone = type.contains('dark') ? 'Pele Negra' : 'Pele Branca';
    return 'Personagem $gender, $tone. Toque para selecionar este personagem.';
  }

  String _getErrorSemanticsLabel(String type) {
    String gender = type.contains('boy') ? 'Menino' : 'Menina';
    String tone = type.contains('dark') ? 'Pele Negra' : 'Pele Branca';
    return 'Erro ao carregar imagem do personagem $gender, $tone.';
  }

  @override
  Widget build(BuildContext context) {
    final characterController = context.read<CharacterController>();

    const double itemSpacing = 12.0;
    const double maxRowWidth = 600.0;
    final String appBarTitle = widget.isInitialSelection
        ? 'Personagem'
        : 'Escolha Seu Personagem';

    return Scaffold(
      appBar: AppBar(
        title: Semantics(
          header: false,
          child: Text(appBarTitle), 
        ),
        automaticallyImplyLeading: !widget.isInitialSelection,
        backgroundColor: Colors.blue,
        titleTextStyle: const TextStyle(color: Colors.white, fontSize: 20),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Container(
        color: const Color.fromRGBO(220, 247, 255, 1.0),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 10.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (widget.isInitialSelection)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 30.0, left: 16.0, right: 16.0),
                    child: Semantics(
                      header: true,
                      child: Text(
                        'Escolha um personagem para começar!',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w500,
                          color: Colors.blue.shade800,
                        ),
                      ),
                    ),
                  ),

                Center(
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
                                if (widget.isInitialSelection) {
                                  Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(builder: (context) => const HomeScreen()),
                                  );
                                } else {
                                  Navigator.pop(context);
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
              ],
            ),
          ),
        ),
      ),
    );
  }
}