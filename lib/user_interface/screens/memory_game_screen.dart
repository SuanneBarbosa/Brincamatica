import 'package:Mathnew/services/memory_tutorial_service.dart';
import 'package:Mathnew/user_interface/screens/about_memory_game_screen.dart';
import 'package:Mathnew/user_interface/screens/instruction_memory_game_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/character_service.dart';
import '../../services/memory_game_service.dart';
import 'instruction_screen.dart';
import 'tanks_screen.dart';
import 'about_screen.dart';

class MemoryGameScreen extends StatefulWidget {
  // PARÂMETROS PARA O TUTORIAL
  final GlobalKey? statusBarKey;
  final Map<String, GlobalKey>? cardKeys;
  final Function(String)? onCardTappedDuringTutorial;

  const MemoryGameScreen({
    super.key,
    this.statusBarKey,
    this.cardKeys,
    this.onCardTappedDuringTutorial,
  });

  @override
  State<MemoryGameScreen> createState() => _GeniusGameScreenState();
}

class _GeniusGameScreenState extends State<MemoryGameScreen> {
  int? _tappedIconIndex;
  final FocusNode _statusFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Só foca se não estiver no modo tutorial
      if (widget.statusBarKey == null) {
        _statusFocusNode.requestFocus();
      }
    });
  }

  @override
  void dispose() {
    _statusFocusNode.dispose();
    super.dispose();
  }

 String _getIconImagePath(String iconType, String gender, String tone) {
    String basePath = 'assets/images/buttons/button_';
    String imagePath;

    switch (iconType) {
      case "BaterPalma":
        imagePath = '${basePath}bater_palma_${tone}_transp.png';
        break;
      case "BaterPeito":
      case "BaterPe":
      case "BaterPerna":
      case "Gritar":
      case "Beijo":
        String snakeCaseType = iconType.replaceAllMapped(RegExp(r'[A-Z]'),
                (match) => '_${match.group(0)?.toLowerCase()}').substring(1);
        imagePath = '$basePath${snakeCaseType}_${gender}_${tone}_transp.png';
        break;
      default:
        imagePath = 'assets/images/placeholder.png';
    }
    return imagePath;
  }

  String _getSemanticsLabelFromType(String type) {
    switch (type) {
      case "BaterPe": return "Bater Pé";
      case "BaterPalma": return "Bater Palma";
      case "BaterPerna": return "Bater Perna";
      case "BaterPeito": return "Bater Peito";
      case "Gritar": return "Gritar";
      case "Beijo": return "Mandar Beijo";        
      default: return type;
    }
  }

  @override
  Widget build(BuildContext context) {
    final geniusController = context.watch<GeniusGameController>();
    final characterController = context.read<CharacterController>();
    
    final typeParts = characterController.selectedCharacterType.split('_');
    final gender = typeParts.isNotEmpty ? typeParts[0] : 'boy';
    final tone = typeParts.length > 1 ? typeParts[1] : 'light';

    return PopScope(
      canPop: true, 
      onPopInvokedWithResult: (bool didPop, dynamic result) {
        if (didPop) {
          context.read<GeniusGameController>().resetGame();
        }
      },
      child: Scaffold(
        drawer: Drawer(
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              DrawerHeader(
                decoration: const BoxDecoration(
                  color: Colors.blue,
                ),
                 child: Stack(
                    children: [
                      Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Semantics(
                              child: const Text(
                                'Apoio',
                                style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white),
                                textAlign: TextAlign.center,
                              ),
                            ),
                            const SizedBox(height: 1),
                            Semantics(
                              label:
                                  'Logotipos dos apoiadores: IFSP, CNPQ e RUMO à Educação Matemática Inclusiva',
                              child: Container(
                                padding: const EdgeInsets.all(10.0),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(15),
                                  boxShadow: [
                                    BoxShadow(
                                        color: Colors.black.withOpacity(0.2),
                                        blurRadius: 8,
                                        offset: const Offset(2, 4))
                                  ],
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Image.asset('assets/images/IFSP_Logo.png',
                                        height: 70, fit: BoxFit.contain),
                                    const SizedBox(width: 5),
                                    Image.asset('assets/images/CNPQ_Logo.png',
                                        height: 70, fit: BoxFit.contain),
                                    const SizedBox(width: 5),
                                    Image.asset('assets/images/RUMO_Logo.png',
                                        height: 70, fit: BoxFit.contain),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Positioned(
                        bottom: 100,
                        left: 230,
                        child: Semantics(
                          label: 'Botão de Fechar menu',
                          child: IconButton(
                            icon: const Icon(Icons.close, color: Colors.white),
                            onPressed: () => Navigator.pop(context),
                          ),
                        ),
                      ),
                    ],
                  ),
              ),
              ListTile(
                leading: const Icon(Icons.home_filled, color: Colors.blue),
                title: const Text('Escolha o Jogo'),
                onTap: () {
                  context.read<GeniusGameController>().resetGame();
                  Navigator.of(context).popUntil((route) => route.isFirst);
                },
              ),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.help_outline, color: Colors.blue),
                title: const Text('Instruções de Uso'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const MemoryGameInstructionsScreen()));
                },
              ),
              ListTile(
                leading: const Icon(Icons.handshake, color: Colors.blue),
                title: const Text('Agradecimentos'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const ThankYouScreen()));
                },
              ),
              ListTile(
                leading: const Icon(Icons.info_outline, color: Colors.blue),
                title: const Text('Sobre'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const MemoryGameAboutScreen()));
                },
              ),
            ],
          ),
        ),
        body: Container(
          color: const Color.fromRGBO(220, 247, 255, 1.0),
          padding: const EdgeInsets.all(10.0),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Builder(
                    builder: (context) {
                      return Semantics(
                        label: 'Abrir menu de navegação',
                        button: true,
                        child: IconButton(
                          icon: const Icon(Icons.menu, color: Colors.blue, size: 30),
                          tooltip: "Abrir menu",
                          onPressed: () => Scaffold.of(context).openDrawer(),
                        ),
                      );
                    }
                  ),
                  Text(
                    'Nível: ${geniusController.score + 1}',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.blue.shade800),
                  ),
                ],
              ),
              
              Container(
                key: widget.statusBarKey,
                child: _buildInGameStatus(geniusController),
              ),

              const SizedBox(height: 10),
              
              Expanded(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    const double crossAxisSpacing = 15;
                    const double mainAxisSpacing = 15;
                    const int crossAxisCount = 3;
                    final int itemCount = geniusController.availableIcons.length;
                    final int rowCount = (itemCount / crossAxisCount).ceil();
                    final double itemWidth = (constraints.maxWidth - (crossAxisCount - 1) * crossAxisSpacing) / crossAxisCount;
                    final double itemHeight = (constraints.maxHeight - (rowCount - 1) * mainAxisSpacing) / rowCount;
                    if (itemHeight <= 0) { return const SizedBox.shrink(); }
                    final double aspectRatio = itemWidth / itemHeight;
  
                    return GridView.builder(
                      physics: const NeverScrollableScrollPhysics(), 
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: crossAxisCount,
                        mainAxisSpacing: mainAxisSpacing,
                        crossAxisSpacing: crossAxisSpacing,
                        childAspectRatio: aspectRatio,
                      ),
                      itemCount: itemCount,
                      itemBuilder: (context, index) {
                        final iconType = geniusController.availableIcons[index];
                        final isHighlighted = geniusController.currentlyPlayingIcon == iconType;
                        final bool canTap = geniusController.gameState == GeniusGameState.waitingForInput;
                        final bool isTapped = _tappedIconIndex == index;
                        final tutorialActive = context.watch<MemoryTutorialController?>()?.isTutorialActive ?? false;
final bool isTutorialMode = widget.onCardTappedDuringTutorial != null && tutorialActive;
                        return GestureDetector(
                          key: widget.cardKeys?[iconType],
                          
                          // LÓGICA DE TOQUE ATUALIZADA
                          onTap: () {
                            // O onTap é usado para a lógica principal do jogo ou do tutorial
                            if (isTutorialMode) {
                              widget.onCardTappedDuringTutorial!(iconType);
                            } else if (canTap) {
                              geniusController.handlePlayerInput(iconType);
                            }
                          },
                          onTapDown: canTap || isTutorialMode ? (details) {
                            setState(() { _tappedIconIndex = index; });
                          } : null,
                          onTapUp: canTap || isTutorialMode ? (details) {
                            setState(() { _tappedIconIndex = null; });
                          } : null,
                          onTapCancel: canTap || isTutorialMode ? () {
                            setState(() { _tappedIconIndex = null; });
                          } : null,
                          
                          child: Semantics(
                            label: _getSemanticsLabelFromType(iconType),
                            hint: isTutorialMode
                                ? 'Toque duas vezes para ouvir o som'
                                : (canTap ? 'Toque duas vezes para jogar' : 'Aguarde sua vez'),
                            value: isHighlighted ? 'Mostrando' : '',
                            button: true,
                            enabled: canTap || isTutorialMode,
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 150),
                              transform: isTapped ? (Matrix4.identity()..scale(0.9)) : Matrix4.identity(),
                              transformAlignment: FractionalOffset.center,
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: isHighlighted ? Colors.yellow.shade600 : Colors.blue.withOpacity(0.8),
                                borderRadius: BorderRadius.circular(15),
                                border: isHighlighted ? Border.all(color: Colors.white, width: 4) : null,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(isHighlighted ? 0.4 : 0.2),
                                    blurRadius: isHighlighted ? 8 : 4,
                                    offset: Offset(0, isHighlighted ? 4 : 2),
                                  ),
                                ],
                              ),
                              child: ExcludeSemantics(
                                child: Image.asset(
                                  _getIconImagePath(iconType, gender, tone),
                                  fit: BoxFit.contain,
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInGameStatus(GeniusGameController controller) {
    Widget leftSide;
    Widget rightSide = const SizedBox.shrink();
    bool isLive = false;
    Semantics rightSideSemantics = Semantics(child: rightSide);

    switch (controller.gameState) {
      case GeniusGameState.showingSequence:
        leftSide = Text('Observe a sequência...', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w500));
        isLive = true;
        break;
      case GeniusGameState.waitingForInput:
        leftSide = Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.timer_outlined, color: Colors.blue.shade800),
            const SizedBox(width: 8),
            Text('${controller.countdown}', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          ],
        );
        isLive = true;
        break;
      case GeniusGameState.levelComplete:
        leftSide = Text('Muito bem!', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w500));
        isLive = true;
        break;
      case GeniusGameState.notStarted:
        leftSide = const Text('Pronto para começar?', style: TextStyle(fontSize: 18));
        rightSide = ElevatedButton(
          child: const Text('Iniciar'),
          onPressed: () => controller.startGame(),
        );
        rightSideSemantics = Semantics(
          label: 'Botão Iniciar Jogo',
          hint: 'Toque duas vezes para começar a partida',
          button: true,
          child: rightSide,
        );
        break;
      case GeniusGameState.gameOver:
        leftSide = Text('Fim de Jogo! Pontuação: ${controller.score}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500));
        rightSide = ElevatedButton(
          child: const Text('Jogar Novamente'),
          onPressed: () => controller.startGame(),
        );
        rightSideSemantics = Semantics(
          label: 'Botão Jogar Novamente',
          hint: 'Toque duas vezes para iniciar uma nova partida',
          button: true,
          child: rightSide,
        );
        break;
    }

    return Semantics(
      liveRegion: isLive,
      child: Focus(
        focusNode: _statusFocusNode,
        child: Container(
          height: 60,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: Colors.blue.shade100.withOpacity(0.5),
            borderRadius: BorderRadius.circular(10)
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              leftSide,
              rightSideSemantics,
            ],
          ),
        ),
      ),
    );
  }
}