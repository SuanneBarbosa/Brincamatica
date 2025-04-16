import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/character_service.dart';
import 'mathicons_screen.dart';

class CharacterSelectionScreen extends StatelessWidget {
  const CharacterSelectionScreen({super.key});

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
    String tone = type.contains('dark') ? 'pele escura' : 'pele clara';
    return '$gender, $tone. Toque para selecionar.';
  }

  @override
  Widget build(BuildContext context) {
    final characterController = context.read<CharacterController>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Escolha seu Personagem'),
        backgroundColor: Colors.blue,
        titleTextStyle: const TextStyle(color: Colors.white, fontSize: 20),
      ),
      body: Container(
        color: const Color.fromRGBO(220, 247, 255, 1.0),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Wrap(
              spacing: 20.0,
              runSpacing: 20.0,
              alignment: WrapAlignment.center,
              children: characterTypes.map((type) {
                return GestureDetector(
                  onTap: () {
                    characterController.setSelectedCharacter(type);

                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => const Mathicon()),
                    );
                  },
                  child: Semantics(
                    label: _getCharacterSemanticsLabel(type),
                    button: true,
                    child: Card(
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Image.asset(
                          _getCharacterImagePath(type),
                          height: 120,
                          width: 90,
                          fit: BoxFit.contain,
                          errorBuilder: (context, error, stackTrace) {
                            print(
                                "Erro ao carregar imagem de seleção: ${_getCharacterImagePath(type)}\n$error");
                            return Container(
                                width: 90,
                                height: 120,
                                color: Colors.grey,
                                child: const Icon(Icons.error,
                                    color: Colors.red, size: 40));
                          },
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
    );
  }
}
