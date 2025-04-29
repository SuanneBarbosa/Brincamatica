import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/character_service.dart';
import 'mathicons_screen.dart';

class CharacterSelectionScreen extends StatelessWidget {
  const CharacterSelectionScreen({super.key});

  // Lista dos tipos de personagens disponíveis
  final List<String> characterTypes = const [
    'boy_dark',
    'boy_light',
    'girl_dark',
    'girl_light',
  ];

  // Retorna o caminho da imagem para um tipo de personagem
  String _getCharacterImagePath(String type) {
    return 'assets/images/characters/character_$type.png';
  }

  // Retorna uma descrição semântica clara para cada opção de personagem
  String _getCharacterSemanticsLabel(String type) {
    // Determina gênero e tom de pele a partir do tipo
    String gender = type.contains('boy') ? 'Menino' : 'Menina';
    String tone = type.contains('dark') ? 'pele negra' : 'pele clara';
    // Cria a string descritiva, incluindo a instrução de ação
    return 'Personagem $gender, $tone. Toque para selecionar este personagem.';
  }

  // Retorna uma descrição semântica para o estado de erro da imagem
  String _getErrorSemanticsLabel(String type) {
    String gender = type.contains('boy') ? 'Menino' : 'Menina';
    String tone = type.contains('dark') ? 'pele negra' : 'pele clara';
    return 'Erro ao carregar imagem do personagem $gender, $tone.';
  }


  @override
  Widget build(BuildContext context) {
    // Obtém o controller do personagem via Provider
    final characterController = context.read<CharacterController>();

    // Constantes para espaçamento e largura máxima
    const double itemSpacing = 12.0;
    const double maxRowWidth = 600.0;

    return Scaffold(
      appBar: AppBar(
        // Envolve o título com Semantics para marcá-lo como cabeçalho
        title: Semantics(
          header: false, // Indica que é um cabeçalho de tela
          child: const Text('Escolha seu Personagem'),
        ),
        backgroundColor: Colors.blue,
        titleTextStyle: const TextStyle(color: Colors.white, fontSize: 20),
         iconTheme: const IconThemeData(color: Colors.white), // Garante ícone de voltar branco (se houver)
      ),
      body: Container(
        // Cor de fundo da tela
        color: const Color.fromRGBO(220, 247, 255, 1.0),
        // Centraliza o conteúdo principal
        child: Center(
          child: Padding(
            // Padding geral vertical e horizontal
            padding: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 10.0),
            // Centraliza a Row (útil se maxRowWidth for menor que a tela)
            child: Center(
              // Limita a largura máxima da Row de personagens
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: maxRowWidth),
                // Row para exibir os personagens lado a lado
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center, // Alinha verticalmente
                  mainAxisAlignment: MainAxisAlignment.center, // Centraliza horizontalmente
                  // Mapeia cada tipo de personagem para um widget de seleção
                  children: characterTypes.map((type) {
                    // Expanded para que cada item ocupe espaço igual na Row
                    return Expanded(
                      child: Padding(
                        // Espaçamento horizontal entre os cards
                        padding: const EdgeInsets.symmetric(horizontal: itemSpacing / 2),
                        // GestureDetector para tornar o card clicável
                        child: GestureDetector(
                          onTap: () {
                            // Define o personagem selecionado no controller
                            characterController.setSelectedCharacter(type);
                            // Navega para a tela principal, substituindo a atual
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(builder: (context) => const Mathicon()),
                            );
                          },
                          // --- SEMANTICS PARA O CARD/BOTÃO DE SELEÇÃO ---
                          child: Semantics(
                            label: _getCharacterSemanticsLabel(type), // Descrição clara da opção
                            button: true, // Indica que é um botão (interativo)
                            // ExcludeSemantics para evitar que o conteúdo interno (Card, Padding, Image)
                            // seja focado separadamente pela acessibilidade, pois o pai já descreve tudo.
                            child: ExcludeSemantics(
                              child: Card(
                                elevation: 4, // Sombra do card
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10)), // Bordas arredondadas
                                clipBehavior: Clip.antiAlias, // Corta conteúdo que excede as bordas
                                child: Padding(
                                  padding: const EdgeInsets.all(5.0), // Padding interno do card
                                  // AspectRatio para manter a proporção da imagem (90/120)
                                  child: AspectRatio(
                                    aspectRatio: 90 / 120,
                                    // Imagem do personagem
                                    child: Image.asset(
                                      _getCharacterImagePath(type),
                                      fit: BoxFit.contain, // Ajusta a imagem dentro do espaço
                                      // --- Tratamento de Erro da Imagem ---
                                      errorBuilder: (context, error, stackTrace) {
                                         // Log do erro para depuração
                                        print("Erro ao carregar imagem de seleção: ${_getCharacterImagePath(type)}\n$error");
                                        // Retorna um placeholder visual E SEMÂNTICO para o erro
                                        return Semantics(
                                          label: _getErrorSemanticsLabel(type), // Descreve qual imagem falhou
                                          image: true, // Indica que representa uma imagem (faltando)
                                          child: Container(
                                              color: Colors.grey.shade300, // Fundo cinza
                                              alignment: Alignment.center, // Centraliza o ícone
                                              // Ícone de erro (excluído da semântica pois o pai descreve)
                                              child: const ExcludeSemantics(
                                                child: Icon(Icons.error_outline, color: Colors.redAccent, size: 30),
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
                  }).toList(), // Converte o mapa para uma lista de widgets
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}