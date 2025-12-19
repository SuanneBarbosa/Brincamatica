import 'package:Mathnew/user_interface/screens/tanks_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/character_service.dart';
import '../../services/sound_memory_service.dart';
import '../widgets/app_drawer_header.dart';
import 'about_sound_memory_screen.dart';
import 'instruction_sound_memory_screen.dart';

class SoundMemoryScreen extends StatefulWidget {
  const SoundMemoryScreen({super.key});

  @override
  State<SoundMemoryScreen> createState() => _SoundMemoryScreenState();
}

class _SoundMemoryScreenState extends State<SoundMemoryScreen> {
  SoundMemoryState? _previousState;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (context.read<SoundMemoryController>().gameState == SoundMemoryState.notStarted) {
         context.read<SoundMemoryController>().setupNewGame();
      }
    });
  }
  
  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return "$minutes:$seconds";
  }

   String _formatDurationForSemantics(Duration duration) {
    final int minutes = duration.inMinutes.remainder(60);
    final int seconds = duration.inSeconds.remainder(60);

    final List<String> parts = [];

    if (minutes > 0) {
      parts.add('$minutes ${minutes == 1 ? "minuto" : "minutos"}');
    }
    
    if (seconds > 0 || parts.isEmpty) {
      parts.add('$seconds ${seconds == 1 ? "segundo" : "segundos"}');
    }

    return parts.join(' e ');
  }

void _showGameOverDialog(BuildContext context) {
    final controller = context.read<SoundMemoryController>();
    final String tempoFinalVisual = _formatDuration(controller.elapsedTime);
    final String conteudo = 'Você terminou em $tempoFinalVisual.';
    final String tempoFinalFalado = _formatDurationForSemantics(controller.elapsedTime);
    final String conteudoFalado = 'Você terminou em $tempoFinalFalado.';
    const String titulo = 'Parabéns!';
    const String instrucaoAcessibilidade = 'Clique no botão Jogar Novamente abaixo para reiniciar.';
    final String fullSemanticLabel = '$titulo $conteudoFalado $instrucaoAcessibilidade';

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          contentPadding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
          content: SingleChildScrollView(
            child: Semantics(
              label: fullSemanticLabel,
              container: true,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const ExcludeSemantics(
                    child: Text(
                      titulo,
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const ExcludeSemantics(
                    child: Icon(Icons.celebration, color: Colors.amber, size: 80),
                  ),
                  const SizedBox(height: 16),
                  ExcludeSemantics(
                    child: Text(
                      conteudo, 
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 18),
                    ),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    icon: const Icon(Icons.refresh),
                    label: const Text('Jogar Novamente'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      textStyle: const TextStyle(fontSize: 16),
                    ),
                    onPressed: () {
                      Navigator.of(dialogContext, rootNavigator: true).pop();
                      Future.microtask(() {
                        controller.setupNewGame();
                      });
                    },
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }


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

  @override
  Widget build(BuildContext context) {
    final gameController = context.watch<SoundMemoryController>();
    final characterController = context.read<CharacterController>();
    final typeParts = characterController.selectedCharacterType.split('_');
    final gender = typeParts.isNotEmpty ? typeParts[0] : 'boy';
    final tone = typeParts.length > 1 ? typeParts[1] : 'light';

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_previousState != SoundMemoryState.gameOver &&
          gameController.gameState == SoundMemoryState.gameOver &&
          mounted) {
        _showGameOverDialog(context);
      }
      _previousState = gameController.gameState;
    });

    return PopScope(
      canPop: true,
      onPopInvoked: (didPop) {
        if (didPop) {
          gameController.resetGame();
        }
      },
      child: Scaffold(
        drawer: _buildGameDrawer(context),
        body: Container(
          color: const Color.fromRGBO(220, 247, 255, 1.0),
          padding: const EdgeInsets.all(10.0),
          child: Column(
            children: [
              _buildStatusArea(gameController),
              const SizedBox(height: 10),
             
              if (gameController.cards.isEmpty)
                const Expanded(child: Center(child: CircularProgressIndicator()))
              else
                Expanded(
                  child: _buildGameBoard(gameController, gender, tone),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Drawer _buildGameDrawer(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          const AppDrawerHeader(),
          ListTile(
            leading: const Icon(Icons.home_filled, color: Colors.blue),
            title: const Text('Escolha o Jogo'),
            onTap: () {
              context.read<SoundMemoryController>().resetGame();
              Navigator.of(context).popUntil((route) => route.isFirst);
            },
          ),
          
          const Divider(),
          ListTile(
            leading: const Icon(Icons.tune, color: Colors.blue),
            title: const Text('Nível de Dificuldade'),
            subtitle: Consumer<SoundMemoryController>(
              builder: (context, controller, child) {
                return Text(
                  controller.currentPairCountSetting == 6 
                  ? "Fácil" 
                  : "Difícil"
                );
              }
            ),
          ),
          Consumer<SoundMemoryController>(
            builder: (context, controller, child) {
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: SegmentedButton<int>(
                  segments: const [
                    ButtonSegment<int>(
                      value: 6,
                      label: Text('Fácil'),
                      icon: Icon(Icons.grid_view),
                    ),
                    ButtonSegment<int>(
                      value: 10,
                      label: Text('Difícil'),
                      icon: Icon(Icons.grid_on),
                    ),
                  ],
                  selected: {controller.currentPairCountSetting},
                  onSelectionChanged: (Set<int> newSelection) {
                    controller.setDifficulty(newSelection.first);
                  },
                ),
              );
            },
          ),

          const Divider(),
          ListTile(
            leading: const Icon(Icons.help_outline, color: Colors.blue),
            title: const Text('Instruções de Uso'),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(context, MaterialPageRoute(builder: (_) => const SoundMemoryInstructionsScreen()));
            },
          ),
            ListTile(
            leading: const Icon(Icons.handshake, color: Colors.blue),
            title: const Text('Agradecimentos'),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(context,
                  MaterialPageRoute(builder: (_) => const ThankYouScreen()));
            },
          ),
          ListTile(
            leading: const Icon(Icons.info_outline, color: Colors.blue),
            title: const Text('Sobre'),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(context, MaterialPageRoute(builder: (_) => const AboutSoundMemoryScreen()));
            },
          ),
        ],
      ),
    );
  }

  Widget _buildStatusArea(SoundMemoryController controller) {
 
    Widget statusContent;

   if (controller.gameState == SoundMemoryState.notStarted) {
      statusContent = Semantics( 
        label: 'Iniciar o jogo da Memória', 
        button: true, 
        child: ElevatedButton.icon(
          icon: const Icon(Icons.play_arrow),
          label: const Text('Iniciar'),
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          onPressed: controller.startGame,
        ),
      );
 }   else if (controller.gameState == SoundMemoryState.playing) {
      final String timeForSpeech = _formatDurationForSemantics(controller.elapsedTime);
      final String pairsForSpeech = 'Pares encontrados: ${controller.pairsFound} de ${controller.totalPairs}';
      final String fullSemanticsLabel = 'Tempo de jogo: $timeForSpeech. $pairsForSpeech';

    
      statusContent = Semantics(
        label: fullSemanticsLabel,
        liveRegion: false, 
        child: ExcludeSemantics( 
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.timer_outlined, color: Colors.blue, size: 35,),
              const SizedBox(width: 4),
              Text(
                _formatDuration(controller.elapsedTime),
              style: const TextStyle(
                      fontSize: 25,
                      fontWeight: FontWeight.w800,
                      color: Colors.blue)
              ),
              const SizedBox(width: 20),
              Text(
                'Pares: ${controller.pairsFound} / ${controller.totalPairs}',
                style: const TextStyle(
                      fontSize: 25,
                      fontWeight: FontWeight.w800,
                      color: Colors.blue)
              ),
            ],
          ),
        ),
      );
    } else { 
      statusContent = const Text(
        'Jogo da Memória',
        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.blueAccent),
      );
    }

    return SafeArea(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Builder(builder: (context) {
              return Semantics(
                label: 'Abrir menu do Jogo da Memória',
                button: true,
                child: IconButton(
                  icon: const Icon(Icons.menu, color: Colors.blue, size: 30),
                  tooltip: "Abrir menu",
                  onPressed: () => Scaffold.of(context).openDrawer(),
                ),
              );
            }),
           
            statusContent,
            const SizedBox(width: 48), 
          ],
        ),
      
    );
  }

  Widget _buildGameBoard(SoundMemoryController controller, String gender, String tone) {
    return LayoutBuilder(builder: (context, constraints) {
      final int crossAxisCount = controller.totalPairs == 10 ? 5 : 4;
      
      const mainAxisSpacing = 10.0;
      const crossAxisSpacing = 10.0;
      final itemWidth = (constraints.maxWidth - (crossAxisCount - 1) * crossAxisSpacing) / crossAxisCount;
      final int rowCount = (controller.cards.length / crossAxisCount).ceil();
      final itemHeight = (constraints.maxHeight - (rowCount -1 ) * mainAxisSpacing) / rowCount;
      
      final aspectRatio = itemWidth / itemHeight;

      return GridView.builder(
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: crossAxisCount,
          crossAxisSpacing: crossAxisSpacing,
          mainAxisSpacing: mainAxisSpacing,
          childAspectRatio: aspectRatio > 0 ? aspectRatio : 1.0,
        ),
        itemCount: controller.cards.length,
        itemBuilder: (context, index) {
          final card = controller.cards[index];
          return _buildCard(controller, card, index, gender, tone);
        },
      );
    });
  }

  Widget _buildCard(SoundMemoryController controller, SoundMemoryCard card, int index, String gender, String tone) {
    final bool isInteractable = controller.gameState == SoundMemoryState.playing && !card.isMatched && !card.isFlipped;
    String semanticsHint = isInteractable ? "Toque para virar a carta." : "";
    if (card.isMatched) semanticsHint = "Par já encontrado.";
    if (card.isFlipped && !card.isMatched) semanticsHint = "Carta virada, aguardando par.";

    return AnimatedOpacity(
      opacity: card.isMatched ? 0.0 : 1.0,
      duration: const Duration(milliseconds: 400),
      child: GestureDetector(
        onTap: () {
          if (isInteractable) {
            controller.flipCard(index);
          }
        },
        child: Semantics(
          label: "Carta ${index + 1}. ${card.isFlipped || card.isMatched ? controller.getSemanticsLabelFromType(card.type) : 'Verso da carta'}",
          hint: semanticsHint,
          button: isInteractable,
          hidden: card.isMatched,
          child: Card(
            elevation: 4,
            color: Colors.blue.shade300,
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              transitionBuilder: (Widget child, Animation<double> animation) {
                return ScaleTransition(scale: animation, child: child);
              },
              child: (card.isFlipped || card.isMatched)
                  ? Padding(
                      key: ValueKey('front_${card.id}'),
                      padding: const EdgeInsets.all(8.0),
                      child: Image.asset(_getIconImagePath(card.type, gender, tone)),
                    )
                  : Container(
                      key: ValueKey('back_${card.id}'),
                      alignment: Alignment.center,
                      padding: const EdgeInsets.all(8.0),
                      child: FittedBox(
                        fit: BoxFit.scaleDown, 
                        child: Text(
                          '${index + 1}',
                          style: const TextStyle(
                            fontSize: 40,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
            ),
          ),
        ),
      ),
    );
  }

}
