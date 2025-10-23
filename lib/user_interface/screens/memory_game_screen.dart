import 'package:Mathnew/services/memory_tutorial_service.dart';
import 'package:Mathnew/user_interface/screens/about_memory_game_screen.dart';
import 'package:Mathnew/user_interface/screens/instruction_memory_game_screen.dart';
import 'package:Mathnew/user_interface/widgets/app_drawer_header.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/character_service.dart';
import '../../services/memory_game_service.dart';
import 'score_history_screen.dart';
import 'tanks_screen.dart';

class MemoryGameScreen extends StatefulWidget {
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
        String snakeCaseType = iconType
            .replaceAllMapped(RegExp(r'[A-Z]'),
                (match) => '_${match.group(0)?.toLowerCase()}')
            .substring(1);
        imagePath = '$basePath${snakeCaseType}_${gender}_${tone}_transp.png';
        break;
      default:
        imagePath = 'assets/images/placeholder.png';
    }
    return imagePath;
  }

  String _getSemanticsLabelFromType(String type) {
    switch (type) {
      case "BaterPe":
        return "Bater Pé";
      case "BaterPalma":
        return "Bater Palma";
      case "BaterPerna":
        return "Bater Perna";
      case "BaterPeito":
        return "Bater Peito";
      case "Gritar":
        return "Gritar";
      case "Beijo":
        return "Mandar Beijo";
      default:
        return type;
    }
  }

  @override
  Widget build(BuildContext context) {
    final geniusController = context.watch<GeniusGameController>();
    final characterController = context.read<CharacterController>();
    final tutorialController = context.watch<MemoryTutorialController?>();

    final typeParts = characterController.selectedCharacterType.split('_');
    final gender = typeParts.isNotEmpty ? typeParts[0] : 'boy';
    final tone = typeParts.length > 1 ? typeParts[1] : 'light';

    final bool isExploringCardsTutorial =
        tutorialController?.isTutorialActive == true &&
            tutorialController?.activeCardTutorialType != null;
 

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
             const AppDrawerHeader(),
              ListTile(
                leading: const Icon(Icons.home_filled, color: Colors.blue),
                title: const Text('Escolha o Jogo'),
                onTap: () {
                  context.read<GeniusGameController>().resetGame();
                  Navigator.of(context).popUntil((route) => route.isFirst);
                },
              ),
              ListTile(
                leading: const Icon(Icons.history, color: Colors.blue),
                title: const Text('Histórico de Pontuação'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const ScoreHistoryScreen()));
                },
              ),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.help_outline, color: Colors.blue),
                title: const Text('Instruções de Uso'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) =>
                              const MemoryGameInstructionsScreen()));
                },
              ),
              ListTile(
                leading: const Icon(Icons.handshake, color: Colors.blue),
                title: const Text('Agradecimentos'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const ThankYouScreen()));
                },
              ),
              ListTile(
                leading: const Icon(Icons.info_outline, color: Colors.blue),
                title: const Text('Sobre'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const MemoryGameAboutScreen()));
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
              ExcludeSemantics(
                excluding: isExploringCardsTutorial,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Builder(builder: (context) {
                      return Semantics(
                        label: 'Abrir menu de navegação',
                        button: true,
                        child: IconButton(
                          icon: const Icon(Icons.menu,
                              color: Colors.blue, size: 30),
                          tooltip: "Abrir menu",
                          onPressed: () => Scaffold.of(context).openDrawer(),
                        ),
                      );
                    }),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Nível: ${geniusController.score + 1}',
                          style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.deepPurpleAccent[700]),
                        ),
                        const SizedBox(width: 24),
                        Text(
                          'Pontuação: ${geniusController.score}',
                          style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.teal.shade700),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              ExcludeSemantics(
                excluding: isExploringCardsTutorial,
                child: Container(
                  key: widget.statusBarKey,
                  child: _buildInGameStatus(geniusController),
                ),
              ),

              const SizedBox(height: 10),

              Expanded(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    const double crossAxisSpacing = 15;
                    const double mainAxisSpacing = 15;
                    const int crossAxisCount = 3;
                    final int itemCount =
                        geniusController.availableIcons.length;
                    final int rowCount = (itemCount / crossAxisCount).ceil();
                    final double itemWidth = (constraints.maxWidth -
                            (crossAxisCount - 1) * crossAxisSpacing) /
                        crossAxisCount;
                    final double itemHeight = (constraints.maxHeight -
                            (rowCount - 1) * mainAxisSpacing) /
                        rowCount;
                    if (itemHeight <= 0) {
                      return const SizedBox.shrink();
                    }
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
                        final isHighlighted =
                            geniusController.currentlyPlayingIcon == iconType;
                        final bool canTap = geniusController.gameState ==
                            GeniusGameState.waitingForInput;
                        final bool isTapped = _tappedIconIndex == index;

                        final bool isTutorialMode =
                            tutorialController?.isTutorialActive ?? false;
                        final String? activeCardType =
                            tutorialController?.activeCardTutorialType;

                        final bool shouldExcludeCard = isTutorialMode &&
                            activeCardType != null &&
                            activeCardType != iconType;

                        return ExcludeSemantics(
                          excluding: shouldExcludeCard,
                          child: GestureDetector(
                            key: widget.cardKeys?[iconType],
                            onTap: () {
                              if (widget.onCardTappedDuringTutorial != null &&
                                  isTutorialMode) {
                                widget.onCardTappedDuringTutorial!(iconType);
                              } else if (canTap) {
                                geniusController.handlePlayerInput(
                                    iconType, context);
                              }
                            },
                            onTapDown: canTap || isTutorialMode
                                ? (details) {
                                    setState(() {
                                      _tappedIconIndex = index;
                                    });
                                  }
                                : null,
                            onTapUp: canTap || isTutorialMode
                                ? (details) {
                                    setState(() {
                                      _tappedIconIndex = null;
                                    });
                                  }
                                : null,
                            onTapCancel: canTap || isTutorialMode
                                ? () {
                                    setState(() {
                                      _tappedIconIndex = null;
                                    });
                                  }
                                : null,
                            child: Semantics(
                              label: _getSemanticsLabelFromType(iconType),
                              hint: isTutorialMode
                                  ? 'Toque duas vezes para ouvir o som'
                                  : (canTap
                                      ? 'Toque duas vezes para jogar'
                                      : 'Aguarde sua vez'),
                              value: isHighlighted ? 'Mostrando' : '',
                              button: true,
                              enabled: canTap ||
                                  (isTutorialMode && !shouldExcludeCard),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 150),
                                transform: isTapped
                                    ? (Matrix4.identity()..scale(0.9))
                                    : Matrix4.identity(),
                                transformAlignment: FractionalOffset.center,
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: isHighlighted
                                      ? Colors.lightGreen.shade200
                                      : Colors.blue.withOpacity(0.8),
                                  borderRadius: BorderRadius.circular(15),
                                  border: isHighlighted
                                      ? Border.all(
                                          color: Colors.white, width: 4)
                                      : null,
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(
                                          isHighlighted ? 0.4 : 0.2),
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
    final screenWidth = MediaQuery.of(context).size.width;
    final textStyleSize = (screenWidth * 0.035).clamp(18.0, 24.0);
    final buttonTextStyleSize = (screenWidth * 0.03).clamp(16.0, 22.0);

    Widget leftSide;
    Widget rightSide = const SizedBox.shrink();
    bool isLive = false;
    Semantics rightSideSemantics = Semantics(child: rightSide);

    switch (controller.gameState) {
      case GeniusGameState.showingSequence:
        leftSide = Text(
    'Ouça a sequência...',
    semanticsLabel: 'Ouça a sequência.',
    style: TextStyle(fontSize: textStyleSize, fontWeight: FontWeight.w500, color: Colors.blue[900]),
  );
        isLive = false;
        break;
        
      case GeniusGameState.playerTurn:
        leftSide = Text(
          'Sua vez!',
          style: TextStyle(fontSize: textStyleSize, fontWeight: FontWeight.w500, color: Colors.blue[900]),
        );
        isLive = true;
        break;

      case GeniusGameState.waitingForInput:
        leftSide = Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.timer_outlined, color: Colors.blue.shade800, size: textStyleSize * 1.2),
            const SizedBox(width: 8),
            Text('${controller.countdown}', style: TextStyle(fontSize: textStyleSize * 1.1, fontWeight: FontWeight.bold)),
          ],
        );
        isLive = true;
        break;
      case GeniusGameState.levelComplete:
        leftSide = Text('Muito bem!', style: TextStyle(fontSize: textStyleSize, fontWeight: FontWeight.w500, color: Colors.blue[900]));
        isLive = true;
        break;
      case GeniusGameState.notStarted:
        leftSide = Text('Pronto para começar?', style: TextStyle(fontSize: textStyleSize, fontWeight: FontWeight.w500, color: Colors.blue[900]));
        rightSide = ElevatedButton(
          style: ElevatedButton.styleFrom(
            padding: EdgeInsets.symmetric(horizontal: (screenWidth * 0.04).clamp(16.0, 32.0), vertical: 8),
            textStyle: TextStyle(fontSize: buttonTextStyleSize, fontWeight: FontWeight.bold),
          ),
          onPressed: () => controller.startGame(context),
          child: const Text('Iniciar'),
        );
        rightSideSemantics = Semantics(
          label: 'Botão Iniciar Jogo',
          hint: 'Toque duas vezes para começar a partida',
          button: true,
          child: rightSide,
        );
        break;
      case GeniusGameState.gameOver:
        leftSide = Text('Fim de Jogo! Pontuação: ${controller.score}', style: TextStyle(fontSize: textStyleSize, fontWeight: FontWeight.w500, color: Colors.blue[900]));
        rightSide = ElevatedButton(
          style: ElevatedButton.styleFrom(
            padding: EdgeInsets.symmetric(horizontal: (screenWidth * 0.04).clamp(16.0, 32.0), vertical: 8),
            textStyle: TextStyle(fontSize: buttonTextStyleSize, fontWeight: FontWeight.bold),
          ),
          onPressed: () => controller.startGame(context),
          child: const Text('Jogar Novamente'),
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
