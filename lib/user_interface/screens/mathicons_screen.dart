import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/character_service.dart';
import '../../services/icon_service.dart';
import '../widgets/menu_button.dart';
import '../../services/audio_service.dart';
import 'package:flutter/services.dart';
import 'instruction_screen.dart';
import 'tanks_screen.dart';
import '../../services/saved_row_service.dart';
import 'saved_rows_screen.dart';
import '../widgets/joystick_button.dart';
import '../../services/playback_service.dart';
import 'about_screen.dart';


class Mathicon extends StatefulWidget {
  const Mathicon({super.key});

  @override
  _MathiconState createState() => _MathiconState();
}

class _MathiconState extends State<Mathicon> {
  final ScrollController _drawerScrollController = ScrollController();
  bool _showCount = false;
  bool _showJoystick = false;

  @override
  void initState() {
    super.initState();
    
  }

  @override
  void dispose() {
    _drawerScrollController.dispose();
    //context.read<PlaybackController>().stop();
    super.dispose();
  }

  void _playFeedbackSound(BuildContext context, String type) {
    final audioService = context.read<AudioService>();

    String? soundPath;
    switch (type) {
      case "EstalarDedo":
        soundPath = 'assets/sounds/estalarDedos.mp3';
        break;
      case "BaterPalma":
        soundPath = 'assets/sounds/baterPalma.mp3';
        break;
      case "BaterPeito":
        soundPath = 'assets/sounds/baterPeito.mp3';
        break;
      case "BaterPerna":
        soundPath = 'assets/sounds/baterPerna.mp3';
        break;
      case "Assobiar":
        soundPath = 'assets/sounds/assobiar.mp3';
        break;
      case "BaterPe":
        soundPath = 'assets/sounds/baterPes.mp3';
        break;
      case "Gritar":
        soundPath = 'assets/sounds/gritar.mp3';
        break;
      case "EstalarLingua1":
        soundPath = 'assets/sounds/estalarLingua1.mp3';
        break;
      case "EstalarLingua2":
        soundPath = 'assets/sounds/estalarLingua2.mp3';
        break;
      case "Beijo":
        soundPath = 'assets/sounds/beijo.mp3';
        break;
    }
    if (soundPath != null) {
      try {
        audioService.playAudio(soundPath);
      } catch (e) {
        debugPrint("Erro ao tocar som de feedback '$soundPath': $e");
      }
    }
  }

  void _handleIconAction({
    required BuildContext context,
    required String type,
    required String semanticsLabel,
  }) async {
    await context.read<PlaybackController>().stop();

    final characterController = context.read<CharacterController>();
    final iconController = context.read<IconController>();
    final int targetRow = characterController.currentRowIndex;
    final int targetCol = characterController.currentColIndex;
    final double currentIconSizeSetting =
        characterController.currentIconSizeSetting;
    IconModel? existingIcon = iconController.getIconAt(targetRow, targetCol);

    if (existingIcon != null) {
      debugPrint("Replacing icon at ($targetRow, $targetCol)");
      iconController.replaceIconAt(
        rowIndex: targetRow,
        colIndex: targetCol,
        newType: type,
        newSemanticsLabel: semanticsLabel,
        newSize: currentIconSizeSetting,
      );
      _playFeedbackSound(context, type);
    } else {
      bool wasRowEmpty = iconController.getIconsForRow(targetRow).isEmpty;

      final int nextAvailableCol = iconController.getNextColumnIndex(targetRow);
      int colToAddAt;
      int nextCharacterCol;

      if (targetCol < nextAvailableCol) {
        colToAddAt = targetCol;
        debugPrint("Adding icon at specific empty slot: $targetCol");
      } else {
        colToAddAt = nextAvailableCol;
        debugPrint("Adding icon sequentially at: $colToAddAt");
      }

      nextCharacterCol = colToAddAt + 1;

      iconController.addIcon(
        rowIndex: targetRow,
        colIndex: colToAddAt,
        type: type,
        semanticsLabel: semanticsLabel,
        size: currentIconSizeSetting,
      );
      _playFeedbackSound(context, type);

      int targetMoveCol;

      if (wasRowEmpty) {
        targetMoveCol = (characterController.maxCols > 1) ? 1 : 0;
        debugPrint(
            "First icon added. Moving character to column $targetMoveCol.");
      } else {
        targetMoveCol = nextCharacterCol;
        debugPrint(
            "Icon added. Moving character to next column: $targetMoveCol");
      }

      targetMoveCol = targetMoveCol.clamp(0, characterController.maxCols - 1);
      characterController.moveToColumn(targetMoveCol);
    }
  }


  void _limparTelaEPararPlayback() async {
    await context.read<PlaybackController>().stop();
    if (mounted) {
      context.read<IconController>().clearIcons();
      context.read<CharacterController>().resetPosition();
    }
  }

  void _ajustarTamanhoEPararPlayback(double value) async {
    await context.read<PlaybackController>().stop();
    if (mounted) {
      final characterController = context.read<CharacterController>();
      final iconController = context.read<IconController>();
      characterController.setIconSizeSetting(value);
      iconController.clearIcons();
      characterController.resetPosition();

      iconController.updateLayoutParameters(
        horizontalPadding: characterController.horizontalPadding,
        verticalPadding: characterController.verticalPadding,
        rowHeight: characterController.rowHeight,
        colWidth: characterController.colWidth,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final playbackController = context.watch<PlaybackController>();
    return LayoutBuilder(
      builder: (context, constraints) {
        final screenWidth = constraints.maxWidth;
        final screenHeight = constraints.maxHeight;

        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted) return;
          final charController =
              Provider.of<CharacterController>(context, listen: false);
          charController.setScreenSize(screenWidth, screenHeight);

          final iconController =
              Provider.of<IconController>(context, listen: false);
          iconController.updateLayoutParameters(
              horizontalPadding: charController.horizontalPadding,
              verticalPadding: charController.verticalPadding,
              rowHeight: charController.rowHeight,
              colWidth: charController.colWidth);
        });

        return Scaffold(
          drawer: Drawer(
            child: ListView(
              controller: _drawerScrollController,
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
                  title: Semantics(
                    label: 'Voltar ao Menu para escolher um jogo',
                    button: true,
                    child: const Text("Escolha o jogo"),
                  ),
                  onTap: () {
                   context.read<PlaybackController>().stop();
                    Navigator.pop(context); 
                    Navigator.of(context).popUntil((route) => route.isFirst);
                  },
                ),
                const Divider(),
                SwitchListTile(
                  title: Semantics(
                    label: 'Botões de controle de movimentos',
                    child: const Text("Joystick"),
                  ),
                  value: _showJoystick,
                  onChanged: (bool value) =>
                      setState(() => _showJoystick = value),
                  secondary: Icon(
                    _showJoystick ? Icons.gamepad : Icons.gamepad_outlined,
                    color: Colors.blue,
                  ),
                ),
                ListTile(
                  title: Semantics(
                    label: 'Remover todos os ícones da tela',
                    button: true,
                    child: const Text("Limpar Tela"),
                  ),
                  leading: const Icon(Icons.delete, color: Colors.blue),
                  onTap: () {
                    Navigator.pop(context);
                    _limparTelaEPararPlayback();
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.format_size, color: Colors.blue),
                  subtitle: Consumer<CharacterController>(
                      builder: (context, characterController, child) {
                    if (!characterController.isLayoutInitialized) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    return Semantics(
                      label:
                          'Ajustar tamanho. Atual: ${characterController.currentIconSizeSetting.toStringAsFixed(0)}. Mínimo 30, Máximo permitido: ${characterController.maxAllowedIconSize.toStringAsFixed(0)}. Alterar o tamanho limpará a tela.',
                      child: ExcludeSemantics(
                        child: Slider(
                          value: characterController.currentIconSizeSetting,
                          min: 30.0,
                          max: characterController.maxAllowedIconSize
                              .clamp(30.0, double.infinity),
                          divisions: null,
                          label:
                              'Tamanho: ${characterController.currentIconSizeSetting.toStringAsFixed(0)}',
                          onChanged: (double value) {
                            final iconController =
                                context.read<IconController>();
                            characterController.setIconSizeSetting(value);
                            _ajustarTamanhoEPararPlayback(value);
                            iconController.clearIcons();
                            characterController.resetPosition();
                            iconController.updateLayoutParameters(
                              horizontalPadding:
                                  characterController.horizontalPadding,
                              verticalPadding:
                                  characterController.verticalPadding,
                              rowHeight: characterController.rowHeight,
                              colWidth: characterController.colWidth,
                            );
                          },
                        ),
                      ),
                    );
                  }),
                ),
                ListTile(
                  leading: const Icon(Icons.speed, color: Colors.blue),
                  // title: const Text("Velocidade da Animação"),
                  subtitle: Consumer<PlaybackController>(
                    builder: (context, controller, child) {
                      return Semantics(
                        label:
                            'Ajustar velocidade da animação. Velocidade atual: ${controller.speedMultiplier.toStringAsFixed(2)}x.',
                        child: ExcludeSemantics(
                          child: Slider(
                            value: controller.speedMultiplier,
                            min: 0.5,
                            max: 2.5,
                            //divisions: 8,
                            label:
                                '${controller.speedMultiplier.toStringAsFixed(2)}x',
                            onChanged: (double value) {
                              context
                                  .read<PlaybackController>()
                                  .setSpeed(value);
                            },
                          ),
                        ),
                      );
                    },
                  ),
                ),
                Consumer<IconController>(
                    builder: (context, iconController, child) {
                  final iconCount = iconController.allIcons.length;
                  return ListTile(
                    leading: const Icon(Icons.numbers, color: Colors.blue),
                    title: Semantics(
                      label: 'Quantidade de ícones na tela: $iconCount',
                      button: true,
                      child: const Text("Contador de ícones"),
                    ),
                    trailing: _showCount
                        ? Text('$iconCount',
                            style: const TextStyle(
                                fontSize: 16, color: Colors.blue))
                        : null,
                    onTap: () => setState(() => _showCount = !_showCount),
                  );
                }),
                const Divider(),
                ListTile(
                  leading: const Icon(Icons.save_alt, color: Colors.blue),
                  title: Semantics(
                    label: 'Salvar a linha onde o Beija-Flor está posicionado',
                    button: true,
                    child: const Text("Salvar Linha Atual"),
                  ),
                  onTap: () async {
                    Navigator.pop(context);
                    final characterController =
                        context.read<CharacterController>();
                    final iconController = context.read<IconController>();
                    final savedRowService = context.read<SavedRowService>();
                    final int currentRow = characterController.currentRowIndex;
                    final List<IconModel> iconsInCurrentRow =
                        iconController.getIconsForRow(currentRow);
                    if (iconsInCurrentRow.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text(
                                'A linha atual está vazia. Nada para salvar.'),
                            duration: Duration(seconds: 2)),
                      );
                      return;
                    }
                    await savedRowService.saveRow(
                        currentRow, iconsInCurrentRow, "");
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                          content: Text(
                              'Linha ${currentRow + 1} salva com sucesso.'),
                          duration: const Duration(seconds: 2)),
                    );
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.list_alt, color: Colors.blue),
                  title: Semantics(
                    label: 'Ver e aplicar linhas salvas',
                    button: true,
                    child: const Text("Linhas Salvas"),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const SavedRowsScreen()));
                  },
                ),
                const Divider(),
                ListTile(
                  leading: const Icon(Icons.help_outline, color: Colors.blue),
                  title: Semantics(
                    label: 'Abrir a página de instruções de uso',
                    child: const Text("Instruções de Uso"),
                  ),
                  onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const InstructionsScreen())),
                ),
                ListTile(
                  leading: const Icon(Icons.handshake, color: Colors.blue),
                  title: Semantics(
                    label: 'Abrir a página de agradecimentos',
                    child: const Text("Agradecimentos"),
                  ),
                  onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const ThankYouScreen())),
                ),
                ListTile(
                  leading: const Icon(Icons.info_outline, color: Colors.blue),
                  title: Semantics(
                    label: 'Abrir a página de informações sobre o aplicativo',
                    child: const Text("Sobre"),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const AboutScreen()),
                    );
                  },
                ),
              ],
            ),
          ),
          body: Container(
            width: screenWidth,
            height: screenHeight,
            color: const Color.fromRGBO(220, 247, 255, 1.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Builder(
                  builder: (context) {
                    return Semantics(
                      label: 'Abrir menu de navegação',
                      button: true,
                      child: IconButton(
                        icon: const Icon(Icons.menu, color: Colors.blue),
                        tooltip: "Abrir menu",
                        onPressed: () => Scaffold.of(context).openDrawer(),
                      ),
                    );
                  },
                ),
                Expanded(
                  child: Stack(
                    children: [
                      Consumer<IconController>(
                          builder: (context, iconController, child) {
                        final characterController =
                            context.watch<CharacterController>();
                        if (!characterController.isLayoutInitialized) {
                          return const SizedBox.shrink();
                        }

                        final typeParts = characterController
                            .selectedCharacterType
                            .split('_');
                        final gender =
                            typeParts.isNotEmpty ? typeParts[0] : 'boy';
                        final tone =
                            typeParts.length > 1 ? typeParts[1] : 'light';
                        return Stack(
                          children: iconController.allIcons.map((icon) {
                            String imagePath;
                            String basePath = 'assets/images/icons/icon_';
                            switch (icon.type) {
                              case "BaterPalma":
                                imagePath = '${basePath}bater_palma_$tone.png';
                                break;
                              case "EstalarDedo":
                                imagePath = '${basePath}estalar_dedo_$tone.png';
                                break;
                              case "BaterPeito":
                              case "Assobiar":
                              case "BaterPe":
                              case "BaterPerna":
                              case "Gritar":
                              case "EstalarLingua1":
                              case "EstalarLingua2":
                              case "Beijo":
                                String snakeCaseType = icon.type
                                    .replaceAllMapped(
                                        RegExp(r'[A-Z]'),
                                        (match) =>
                                            '_${match.group(0)?.toLowerCase()}')
                                    .substring(1);
                                imagePath =
                                    '$basePath${snakeCaseType}_${gender}_$tone.png';
                                break;
                              default:
                                imagePath = 'assets/images/placeholder.png';
                            }
                            return Positioned(
                              key: ValueKey(
                                  'icon_${icon.rowIndex}_${icon.colIndex}_${icon.type}'),
                              top: icon.position.dy,
                              left: icon.position.dx,
                              child: InkWell(
                                onTap: () async {
                                  await context
                                      .read<PlaybackController>()
                                      .stop();
                                  if (!context.mounted) return;
                                  showDialog(
                                    context: context,
                                    builder: (BuildContext context) {
                                      return AlertDialog(
                                        backgroundColor:
                                            Colors.white.withOpacity(0.8),
                                        title: Center(
                                            child: Semantics(
                                                child: const Text(
                                                    "Remover ícone",
                                                    style: TextStyle(
                                                        fontSize: 18)))),
                                        content: const Text(
                                            "Deseja remover o ícone?",
                                            textAlign: TextAlign.center,
                                            style: TextStyle(fontSize: 16)),
                                        actionsAlignment:
                                            MainAxisAlignment.center,
                                        actions: [
                                          Semantics(
                                              label: 'Cancelar',
                                              button: true,
                                              child: ElevatedButton(
                                                  onPressed: () =>
                                                      Navigator.of(context)
                                                          .pop(),
                                                  style: ElevatedButton.styleFrom(
                                                      shape:
                                                          RoundedRectangleBorder(
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          8.0))),
                                                  child:
                                                      const Text("Cancelar"))),
                                          Semantics(
                                              label: 'Remover',
                                              button: true,
                                              child: ElevatedButton(
                                                  onPressed: () {
                                                    iconController
                                                        .removeIcon(icon);
                                                    Navigator.of(context).pop();
                                                  },
                                                  style: ElevatedButton.styleFrom(
                                                      shape:
                                                          RoundedRectangleBorder(
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          8.0))),
                                                  child:
                                                      const Text("Remover"))),
                                        ],
                                      );
                                    },
                                  );
                                },
                                child: Semantics(
                                  button: false,
                                  label: icon.semanticsLabel,
                                  child: Image.asset(
                                    imagePath,
                                    height: icon.size,
                                    fit: BoxFit.contain,
                                    errorBuilder: (context, error, stackTrace) {
                                      return Container(
                                          width: icon.size,
                                          height: icon.size,
                                          color: Colors.red.withOpacity(0.5),
                                          child: const Icon(Icons.error));
                                    },
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        );
                      }),
                      Consumer<CharacterController>(
                          builder: (context, controller, child) {
                        if (!controller.isLayoutInitialized) {
                          return const SizedBox.shrink();
                        }
                        return Positioned(
                          top: controller.yPosition,
                          left: controller.xPosition,
                          child: GestureDetector(
                            onPanUpdate: (details) async {
                              if (context
                                      .read<PlaybackController>()
                                      .isPlaying ||
                                  context.read<PlaybackController>().isPaused) {
                                await context.read<PlaybackController>().stop();
                              }

                              if (!controller.isLayoutInitialized ||
                                  controller.rowHeight <= 0 ||
                                  controller.colWidth <= 0) return;
                              final double dragX = details.globalPosition.dx;
                              final double dragY = details.globalPosition.dy;
                              final double relativeX =
                                  dragX - controller.horizontalPadding;
                              final double relativeY =
                                  dragY - controller.verticalPadding;
                              int targetCol =
                                  (relativeX / controller.colWidth).floor();
                              int targetRow =
                                  (relativeY / controller.rowHeight).floor();
                              controller.moveToGridCell(targetRow, targetCol);
                            },
                            child: Semantics(
                              label:
                                  'Personagem. Beija-Flor. Linha ${controller.currentRowIndex + 1}, Posição ${controller.currentColIndex + 1}. Use o Joystick para mover.',
                              image: false,
                              child: Image.asset(
                                controller.beijaFlorImagePath,
                                height: controller.characterVisualHeight,
                                width: controller.characterVisualWidth,
                                fit: BoxFit.contain,
                                errorBuilder: (context, error, stackTrace) {
                                  return Container(
                                      width: controller.characterVisualWidth,
                                      height: controller.characterVisualHeight,
                                      color: Colors.grey);
                                },
                              ),
                            ),
                          ),
                        );
                      }),
                    ],
                  ),
                ),
                _buildBottomControlsRow(context, playbackController),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildBottomControlsRow(
      BuildContext context, PlaybackController playbackController) {
    final bool isCurrentlyPlaying =
        playbackController.isPlaying && !playbackController.isPaused;
    final String buttonText = isCurrentlyPlaying ? "Pause" : "Play";
    final VoidCallback onPressedAction = isCurrentlyPlaying
        ? playbackController.pause
        : () => playbackController.playOrResume(context);

    return Padding(
      padding:
          const EdgeInsets.only(bottom: 2.0, top: 0.0, left: 15.0, right: 15.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Semantics(
            label: isCurrentlyPlaying
                ? 'Pausar reprodução da linha atual'
                : 'Tocar a linha atual do personagem',
            button: true,
            child: ElevatedButton(
              onPressed: onPressedAction,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blueAccent,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 1, vertical: 2),
                textStyle:
                    const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
                minimumSize: const Size(60, 36),
              ),
              child: Text(buttonText),
            ),
          ),
          Expanded(
            child: Align(
              alignment: Alignment.center,
              child: _buildActionMenuBar(context),
            ),
          ),
          SizedBox(
            width: 50,
            child: _showJoystick ? _buildLeftJoystick(context) : null,
          ),
          const SizedBox(width: 8),
          SizedBox(
            width: 50,
            child: _showJoystick ? _buildRightJoystick(context) : null,
          ),
        ],
      ),
    );
  }

  Widget _buildActionMenuBar(BuildContext context) {
    return Consumer<CharacterController>(
        builder: (context, characterController, child) {
      final screenWidth = MediaQuery.of(context).size.width;
      const double minBtnIconSize = 40.0;
      const double maxBtnIconSize = 60.0;
      final double targetBtnIconSize =
          (screenWidth * 0.070).clamp(minBtnIconSize, maxBtnIconSize);
      final typeParts = characterController.selectedCharacterType.split('_');
      final gender = typeParts.isNotEmpty ? typeParts[0] : 'boy';
      final tone = typeParts.length > 1 ? typeParts[1] : 'light';
      String buttonBasePath = 'assets/images/buttons/button_';

      return SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        child: Center(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              MenuButton(
                iconPath:
                    '${buttonBasePath}assobiar_${gender}_${tone}_transp.png',
                label: "Assobiar",
                tooltip: "Adicionar Assobiar",
                semanticsLabel: "Assobiar",
                iconSize: targetBtnIconSize,
                onTap: () => _handleIconAction(
                    context: context,
                    type: "Assobiar",
                    semanticsLabel: "Assobiar"),
              ),
              const SizedBox(width: 8),
              MenuButton(
                iconPath: '${buttonBasePath}estalar_dedo_${tone}_transp.png',
                label: "Estalar Dedo",
                tooltip: "Adicionar Estalar Dedo",
                semanticsLabel: "Estalar Dedo",
                iconSize: targetBtnIconSize,
                onTap: () => _handleIconAction(
                    context: context,
                    type: "EstalarDedo",
                    semanticsLabel: "Estalar Dedo"),
              ),
              const SizedBox(width: 8),
              MenuButton(
                iconPath: '${buttonBasePath}bater_palma_${tone}_transp.png',
                label: "Bater Palma",
                tooltip: "Adicionar Bater Palma",
                semanticsLabel: "Bater Palma",
                iconSize: targetBtnIconSize,
                onTap: () => _handleIconAction(
                    context: context,
                    type: "BaterPalma",
                    semanticsLabel: "Bater Palma"),
              ),
              const SizedBox(width: 8),
              MenuButton(
                iconPath:
                    '${buttonBasePath}bater_pe_${gender}_${tone}_transp.png',
                label: "Bater Pé",
                tooltip: "Adicionar Bater Pé",
                semanticsLabel: "Bater Pé",
                iconSize: targetBtnIconSize,
                onTap: () => _handleIconAction(
                    context: context,
                    type: "BaterPe",
                    semanticsLabel: "Bater Pé"),
              ),
              const SizedBox(width: 8),
              MenuButton(
                iconPath:
                    '${buttonBasePath}bater_peito_${gender}_${tone}_transp.png',
                label: "Bater Peito",
                tooltip: "Adicionar Bater Peito",
                semanticsLabel: "Bater Peito",
                iconSize: targetBtnIconSize,
                onTap: () => _handleIconAction(
                    context: context,
                    type: "BaterPeito",
                    semanticsLabel: "Bater Peito"),
              ),
              const SizedBox(width: 8),
              MenuButton(
                iconPath:
                    '${buttonBasePath}bater_perna_${gender}_${tone}_transp.png',
                label: "Bater Perna",
                tooltip: "Adicionar Bater Perna",
                semanticsLabel: "Bater Perna",
                iconSize: targetBtnIconSize,
                onTap: () => _handleIconAction(
                    context: context,
                    type: "BaterPerna",
                    semanticsLabel: "Bater Perna"),
              ),
              const SizedBox(width: 8),
              MenuButton(
                iconPath:
                    '${buttonBasePath}gritar_${gender}_${tone}_transp.png',
                label: "Gritar",
                tooltip: "Adicionar Gritar",
                semanticsLabel: "Gritar",
                iconSize: targetBtnIconSize,
                onTap: () => _handleIconAction(
                    context: context, type: "Gritar", semanticsLabel: "Gritar"),
              ),
              MenuButton(
                iconPath:
                    '${buttonBasePath}estalar_lingua1_${gender}_${tone}_transp.png',
                label: "Estalar Língua 1",
                tooltip: "Adicionar Estalar Língua 1",
                semanticsLabel: "Estalar Língua 1",
                iconSize: targetBtnIconSize,
                onTap: () => _handleIconAction(
                    context: context,
                    type: "EstalarLingua1",
                    semanticsLabel: "Estalar Língua 1"),
              ),
              MenuButton(
                iconPath:
                    '${buttonBasePath}estalar_lingua2_${gender}_${tone}_transp.png',
                label: "Estalar Língua 2",
                tooltip: "Adicionar Estalar Língua 2",
                semanticsLabel: "Estalar Língua 2",
                iconSize: targetBtnIconSize,
                onTap: () => _handleIconAction(
                    context: context,
                    type: "EstalarLingua2",
                    semanticsLabel: "Estalar Língua 2"),
              ),
              MenuButton(
                iconPath: '${buttonBasePath}beijo_${gender}_${tone}_transp.png',
                label: "Mandar Beijo",
                tooltip: "Adicionar Mandar Beijo",
                semanticsLabel: "Mandar Beijo",
                iconSize: targetBtnIconSize,
                onTap: () => _handleIconAction(
                    context: context,
                    type: "Beijo",
                    semanticsLabel: "Mandar Beijo"),
              ),
            ],
          ),
        ),
      );
    });
  }

  Widget _buildLeftJoystick(BuildContext context) {
    return Consumer<CharacterController>(builder: (context, controller, child) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          JoystickButton(
            icon: Icons.arrow_upward,
            onPressed: () => controller.moveUp(),
            tooltip: "Mover para cima",
            semanticsLabel: "Mover para cima",
          ),
          JoystickButton(
            icon: Icons.arrow_back,
            onPressed: () => controller.moveLeft(),
            tooltip: "Mover para esquerda",
            semanticsLabel: "Mover para esquerda",
          ),
        ],
      );
    });
  }

  Widget _buildRightJoystick(BuildContext context) {
    return Consumer<CharacterController>(builder: (context, controller, child) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          JoystickButton(
            icon: Icons.arrow_downward,
            onPressed: () => controller.moveDown(),
            tooltip: "Mover para baixo",
            semanticsLabel: "Mover para baixo",
          ),
          JoystickButton(
            icon: Icons.arrow_forward,
            onPressed: () => controller.moveRight(),
            tooltip: "Mover para direita",
            semanticsLabel: "Mover para direita",
          ),
        ],
      );
    });
  }
}
