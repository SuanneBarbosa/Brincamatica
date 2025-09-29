// lib/user_interface/screens/melody_generator_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/character_service.dart';
import '../../services/melody_generator_service.dart';

class MelodyGeneratorScreen extends StatelessWidget {
  const MelodyGeneratorScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<MelodyGeneratorController>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Gerador de Melodias'),
        backgroundColor: Colors.blue,
        titleTextStyle: const TextStyle(color: Colors.white, fontSize: 20),
        iconTheme: const IconThemeData(color: Colors.white),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            context.read<MelodyGeneratorController>().reset();
            Navigator.of(context).pop();
          },
        ),
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        color: const Color.fromRGBO(220, 247, 255, 1.0),
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          child: _buildScreenForState(context, controller),
        ),
      ),
    );
  }

  Widget _buildScreenForState(
      BuildContext context, MelodyGeneratorController controller) {
    switch (controller.state) {
      case GeneratorState.selectingIcons:
        return _buildIconSelection(context, controller);
      case GeneratorState.selectingMode:
        return _buildModeSelection(context, controller);
      case GeneratorState.displayingResults:
        return _buildResults(context, controller);
    }
  }

  // --- TELA 1: Seleção de Ícones (Permanece a mesma) ---
  Widget _buildIconSelection(BuildContext context, MelodyGeneratorController controller) {
    final characterController = context.read<CharacterController>();
    final typeParts = characterController.selectedCharacterType.split('_');
    final gender = typeParts.isNotEmpty ? typeParts[0] : 'boy';
    final tone = typeParts.length > 1 ? typeParts[1] : 'light';
    final bool canConfirm = controller.selectedIcons.length >= 2;

    return Column(
      key: const ValueKey('iconSelection'),
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            'Escolha 2 ou 3 sons para combinar',
            style: Theme.of(context).textTheme.headlineSmall,
            textAlign: TextAlign.center,
          ),
        ),
        Expanded(
          child: GridView.builder(
            padding: const EdgeInsets.all(12),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 5,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
            ),
            itemCount: controller.availableIcons.length,
            itemBuilder: (context, index) {
              final iconType = controller.availableIcons[index];
              final isSelected = controller.selectedIcons.contains(iconType);
              return GestureDetector(
                onTap: () => controller.toggleIconSelection(iconType),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    border: isSelected
                        ? Border.all(color: Colors.green.shade700, width: 4)
                        : Border.all(color: Colors.transparent, width: 4),
                    color: Colors.blue.withOpacity(0.8),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child:
                        Image.asset(_getIconImagePath(iconType, gender, tone)),
                  ),
                ),
              );
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: ElevatedButton.icon(
            icon: const Icon(Icons.check),
            label: const Text('Confirmar Seleção'),
            style: ElevatedButton.styleFrom(
              minimumSize: const Size(250, 50),
              textStyle: const TextStyle(fontSize: 18),
              backgroundColor: canConfirm ? Colors.green : Colors.grey,
            ),
            onPressed: canConfirm ? controller.confirmIconSelection : null,
          ),
        ),
      ],
    );
  }

  // --- TELA 2: Seleção de Modo (Permanece a mesma) ---
  Widget _buildModeSelection(BuildContext context, MelodyGeneratorController controller) {
    return Column(
      key: const ValueKey('modeSelection'),
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'Como você quer organizar os sons?',
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        const SizedBox(height: 30),
        ElevatedButton(
          style: ElevatedButton.styleFrom(minimumSize: const Size(300, 60)),
          onPressed: () => controller.generateMelodies(false),
          child: const Text('Sem Repetição', style: TextStyle(fontSize: 20)),
        ),
        const SizedBox(height: 20),
        ElevatedButton(
          style: ElevatedButton.styleFrom(minimumSize: const Size(300, 60)),
          onPressed: () => controller.generateMelodies(true),
          child: const Text('Com Repetição', style: TextStyle(fontSize: 20)),
        ),
      ],
    );
  }

  // --- TELA 3: Exibição dos Resultados (MODIFICADA) ---
  Widget _buildResults(BuildContext context, MelodyGeneratorController controller) {
    // Acessa o controller para saber se é com repetição ou não
    final melodyController = context.read<MelodyGeneratorController>();

    return Column(
      key: const ValueKey('results'),
      children: [
        Padding(
          padding: const EdgeInsets.all(12.0),
          child: Text(
            '${controller.generatedMelodies.length} melodias possíveis encontradas!',
            style: Theme.of(context).textTheme.titleLarge,
          ),
        ),
        Expanded(
          // ESCOLHE QUAL VISUALIZAÇÃO MOSTRAR
          child: melodyController.selectedIcons.length > 3 || melodyController.generatedMelodies.length > 6
              ? _buildResultsList(context, controller) // Se for muito complexo, usa lista
              : _PermutationTreeView(controller: controller), // Caso contrário, usa a árvore
        ),
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: ElevatedButton.icon(
            icon: const Icon(Icons.refresh),
            label: const Text('Começar de Novo'),
            style: ElevatedButton.styleFrom(
              minimumSize: const Size(250, 50),
              textStyle: const TextStyle(fontSize: 18),
              backgroundColor: Colors.redAccent,
              foregroundColor: Colors.white,
            ),
            onPressed: controller.reset,
          ),
        ),
      ],
    );
  }

  // --- VISUALIZAÇÃO EM LISTA (ANTIGA) ---
  Widget _buildResultsList(BuildContext context, MelodyGeneratorController controller) {
    final characterController = context.read<CharacterController>();
    final typeParts = characterController.selectedCharacterType.split('_');
    final gender = typeParts.isNotEmpty ? typeParts[0] : 'boy';
    final tone = typeParts.length > 1 ? typeParts[1] : 'light';

    return ListView.builder(
      itemCount: controller.generatedMelodies.length,
      itemBuilder: (context, index) {
        final melody = controller.generatedMelodies[index];
        final isPlaying = controller.currentlyPlayingIndex == index;
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          color: isPlaying ? Colors.yellow.shade200 : Colors.white,
          child: ListTile(
            leading: Text('${index + 1}.', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            title: Wrap(
              spacing: 8.0,
              runSpacing: 4.0,
              children: melody.map((iconType) {
                return Image.asset(
                  _getIconImagePath(iconType, gender, tone),
                  height: 30,
                );
              }).toList(),
            ),
            trailing: IconButton(
              icon: Icon(
                isPlaying ? Icons.stop_circle_outlined : Icons.play_circle_outline,
                color: Colors.blue,
                size: 32,
              ),
              onPressed: () => controller.playMelody(index),
            ),
          ),
        );
      },
    );
  }

  // Helper para obter o caminho da imagem do ícone
  String _getIconImagePath(String iconType, String gender, String tone) {
    String basePath = 'assets/images/buttons/button_';
    String imagePath;

    switch (iconType) {
      case "BaterPalma": imagePath = '${basePath}bater_palma_${tone}_transp.png'; break;
      case "EstalarDedo": imagePath = '${basePath}estalar_dedo_${tone}_transp.png'; break;
      case "BaterPeito":
      case "BaterPe":
      case "BaterPerna":
      case "Gritar":
      case "Beijo":
      case "Assobiar":
      case "EstalarLingua1":
      case "EstalarLingua2":
        String snakeCaseType = iconType.replaceAllMapped(RegExp(r'[A-Z]'), (match) => '_${match.group(0)?.toLowerCase()}').substring(1);
        imagePath = '$basePath${snakeCaseType}_${gender}_${tone}_transp.png';
        break;
      default: imagePath = 'assets/images/placeholder.png';
    }
    return imagePath;
  }
}

// =======================================================================
// ================ NOVOS WIDGETS PARA A ÁRVORE ==========================
// =======================================================================

// WIDGET PRINCIPAL QUE MONTA A ÁRVORE
class _PermutationTreeView extends StatelessWidget {
  final MelodyGeneratorController controller;
  
  const _PermutationTreeView({required this.controller});

  @override
  Widget build(BuildContext context) {
    final int n = controller.selectedIcons.length;

    // Se não for permutação de 2 ou 3, usa a lista como fallback
    if (n < 2 || n > 3) {
      return (const MelodyGeneratorScreen())._buildResultsList(context, controller);
    }
    
    // Constantes de layout
    const double nodeWidth = 120.0;
    const double nodeHeight = 50.0;
    const double levelGap = 60.0;
    const double leafNodeWidth = 150;

    return LayoutBuilder(
      builder: (context, constraints) {
        final double maxWidth = constraints.maxWidth;
        final List<Offset> leafPositions = [];
        final List<Offset> level1Positions = [];
        Offset rootPosition;

        List<Widget> nodes = [];

        // --- CÁLCULO DAS POSIÇÕES ---
        if (n == 2) {
          // Raiz
          rootPosition = Offset(maxWidth / 2, nodeHeight / 2);
          // Folhas
          leafPositions.add(Offset(maxWidth * 0.25, nodeHeight + levelGap));
          leafPositions.add(Offset(maxWidth * 0.75, nodeHeight + levelGap));
        } else { // n == 3
          // Raiz
          rootPosition = Offset(maxWidth / 2, nodeHeight / 2);
          // Nível 1
          level1Positions.add(Offset(maxWidth * 0.18, nodeHeight + levelGap));
          level1Positions.add(Offset(maxWidth * 0.50, nodeHeight + levelGap));
          level1Positions.add(Offset(maxWidth * 0.82, nodeHeight + levelGap));
          // Folhas (Nível 2)
          double leafY = nodeHeight * 2 + levelGap * 2;
          for (int i = 0; i < 6; i++) {
             leafPositions.add(Offset((maxWidth / 6) * (i + 0.5), leafY));
          }
        }
        
        // --- CRIAÇÃO DOS WIDGETS DE NÓS ---
        
        // Nó Raiz
        nodes.add(
          Positioned(
            top: rootPosition.dy - nodeHeight / 2,
            left: rootPosition.dx - nodeWidth / 2,
            child: _MelodyNode(
              melody: controller.selectedIcons.toList(),
              width: nodeWidth,
              height: nodeHeight,
            ),
          ),
        );

        // Nós do Nível 1 (apenas para n=3)
        if (n == 3) {
           for (int i = 0; i < 3; i++) {
             nodes.add(
              Positioned(
                top: level1Positions[i].dy - nodeHeight / 2,
                left: level1Positions[i].dx - nodeWidth / 2,
                child: _MelodyNode(
                  melody: controller.generatedMelodies[i*2], // Pega o primeiro de cada par
                  width: nodeWidth,
                  height: nodeHeight,
                ),
              ),
            );
           }
        }

        // Nós Folha (Resultados finais com botão de play)
        for (int i = 0; i < controller.generatedMelodies.length; i++) {
           nodes.add(
              Positioned(
                top: leafPositions[i].dy - nodeHeight / 2,
                left: leafPositions[i].dx - leafNodeWidth / 2,
                child: _MelodyNode(
                  melody: controller.generatedMelodies[i],
                  width: leafNodeWidth,
                  height: nodeHeight,
                  isLeaf: true,
                  onPlay: () => controller.playMelody(i),
                  isPlaying: controller.currentlyPlayingIndex == i,
                ),
              ),
            );
        }

        return SingleChildScrollView(
          child: SizedBox(
            height: n == 2 ? 300 : 450, // Altura do canvas
            width: maxWidth,
            child: Stack(
              children: [
                // Desenho das linhas de conexão
                CustomPaint(
                  size: Size(maxWidth, n == 2 ? 300 : 450),
                  painter: _TreePainter(
                    root: rootPosition,
                    level1: level1Positions,
                    leaves: leafPositions,
                    nodeHeight: nodeHeight,
                  ),
                ),
                ...nodes, // Adiciona os nós (ícones) sobre o desenho
              ],
            ),
          ),
        );
      },
    );
  }
}

// WIDGET PARA DESENHAR AS LINHAS DA ÁRVORE
class _TreePainter extends CustomPainter {
  final Offset root;
  final List<Offset> level1;
  final List<Offset> leaves;
  final double nodeHeight;

  _TreePainter({
    required this.root,
    required this.level1,
    required this.leaves,
    required this.nodeHeight,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.blue.shade700
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round;

    Offset rootBottom = root.translate(0, nodeHeight / 2);

    if (level1.isEmpty) { // Caso de 2 ícones
      for (final leaf in leaves) {
        canvas.drawLine(rootBottom, leaf.translate(0, -nodeHeight / 2), paint);
      }
    } else { // Caso de 3 ícones
      // Linhas da Raiz para o Nível 1
      for (final node in level1) {
        canvas.drawLine(rootBottom, node.translate(0, -nodeHeight/2), paint);
      }
      // Linhas do Nível 1 para as Folhas
      for (int i=0; i < level1.length; i++) {
        Offset l1Bottom = level1[i].translate(0, nodeHeight/2);
        canvas.drawLine(l1Bottom, leaves[i*2].translate(0, -nodeHeight/2), paint);
        canvas.drawLine(l1Bottom, leaves[i*2+1].translate(0, -nodeHeight/2), paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// WIDGET PARA EXIBIR UM NÓ DA ÁRVORE (um conjunto de ícones)
class _MelodyNode extends StatelessWidget {
  final List<String> melody;
  final double width;
  final double height;
  final bool isLeaf;
  final bool isPlaying;
  final VoidCallback? onPlay;

  const _MelodyNode({
    required this.melody,
    required this.width,
    required this.height,
    this.isLeaf = false,
    this.isPlaying = false,
    this.onPlay,
  });
  
  @override
  Widget build(BuildContext context) {
    final characterController = context.read<CharacterController>();
    final typeParts = characterController.selectedCharacterType.split('_');
    final gender = typeParts.isNotEmpty ? typeParts[0] : 'boy';
    final tone = typeParts.length > 1 ? typeParts[1] : 'light';

    return Container(
      width: width,
      height: height,
      padding: const EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
        color: isPlaying ? Colors.yellow.shade200 : Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.blue.shade400, width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 3,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          ...melody.map((iconType) {
            return Expanded(
              child: Padding(
                padding: const EdgeInsets.all(4.0),
                child: Image.asset(
                  (const MelodyGeneratorScreen())._getIconImagePath(iconType, gender, tone),
                  fit: BoxFit.contain,
                ),
              ),
            );
          }).toList(),
          if (isLeaf)
            IconButton(
              padding: EdgeInsets.zero,
              icon: Icon(
                isPlaying ? Icons.stop : Icons.play_arrow,
                color: Colors.blue,
              ),
              onPressed: onPlay,
            ),
        ],
      ),
    );
  }
}