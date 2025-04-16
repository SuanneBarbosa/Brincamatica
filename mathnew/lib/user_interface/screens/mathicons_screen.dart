import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/character_service.dart';
import '../../services/icon_service.dart';
import '../widgets/joystick_button.dart';
import '../widgets/menu_button.dart';
import '../../services/audio_service.dart';
import 'package:flutter/services.dart';
import 'instruction_screen.dart';
import 'tanks_screen.dart';
import '../../services/saved_row_service.dart';
import 'saved_rows_screen.dart'; // Import the new screen
import '../../models/saved_row_models.dart'; //


class Mathicon extends StatefulWidget {
  const Mathicon({super.key});

  @override
  _MathiconState createState() => _MathiconState();
}

class _MathiconState extends State<Mathicon> {
  bool _showJoystick = false;
  final AudioService _audioService = AudioService();
  double _narrationSpeed = 1.0;
  final ScrollController _drawerScrollController = ScrollController();
  bool _showCount = false;

  @override
  void dispose() {
    _audioService.dispose();
    _drawerScrollController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  }

  Future<void> _narrateMovement(String directionSoundAsset) async {
    await _audioService.playAudio(directionSoundAsset, speed: _narrationSpeed);
  }

 
 void _handleIconAction({
    required BuildContext context,
    required String type,
    required String semanticsLabel,
  }) {
    final characterController = context.read<CharacterController>();
    final iconController = context.read<IconController>();

    final int targetRow = characterController.currentRowIndex;
    final int targetCol = characterController.currentColIndex; 
    final double currentIconSizeSetting = characterController.currentIconSizeSetting;

    IconModel? existingIcon = iconController.getIconAt(targetRow, targetCol);

    if (existingIcon != null) {
      
      print("Replacing icon at ($targetRow, $targetCol)");
      iconController.replaceIconAt(
        rowIndex: targetRow,
        colIndex: targetCol,
        newType: type,
        newSemanticsLabel: semanticsLabel,
        newSize: currentIconSizeSetting,
      );
      _playIconSound(type);
      
    } else {
     
      final int nextAvailableCol = iconController.getNextColumnIndex(targetRow); 

      
       if (iconController.getIconsForRow(targetRow).length >= iconController.maxCols) {
         ScaffoldMessenger.of(context).showSnackBar(
           SnackBar(
             content: Semantics(
               label: 'Alerta: Linha ${targetRow + 1} cheia.',
               child: Text("Não é possível adicionar mais ícones na linha ${targetRow + 1} (máximo ${iconController.maxCols})."),
             ),
             duration: const Duration(seconds: 2),
           ),
         );
         return;
       }

      int colToAddAt; 
      int nextCharacterCol; 

      
      if (targetCol < nextAvailableCol) {
          
          colToAddAt = targetCol;
          
          nextCharacterCol = targetCol + 1;
          print("Adding icon at specific empty slot: $targetCol");

      } else {
          
          colToAddAt = nextAvailableCol;
          
          nextCharacterCol = colToAddAt + 1;
          print("Adding icon sequentially at: $colToAddAt");
      }

      
      iconController.addIcon(
        rowIndex: targetRow,
        colIndex: colToAddAt, 
        type: type,
        semanticsLabel: semanticsLabel,
        size: currentIconSizeSetting,
      );
      _playIconSound(type);

      
      if (nextCharacterCol < characterController.maxCols) {
          characterController.moveToColumn(nextCharacterCol);
      } else {
          characterController.moveToColumn(characterController.maxCols - 1);
           debugPrint("Character moved to or remains in last column.");
      }
    }
  }

 
  void _playIconSound(String type) {
     String? soundPath;
      switch (type) {
        case "Assobiar": soundPath = 'assets/sounds/assobiar.mp3'; break;
        case "EstalarDedo": soundPath = 'assets/sounds/estalarDedos.mp3'; break;
        case "BaterPalma": soundPath = 'assets/sounds/baterPalma.mp3'; break;
        case "BaterPe": soundPath = 'assets/sounds/baterPes.mp3'; break;
        case "BaterPeito": soundPath = 'assets/sounds/baterPeito.mp3'; break;
        case "BaterPerna": soundPath = 'assets/sounds/baterPerna.mp3'; break;
      }
      if (soundPath != null) {
        try {
          _audioService.playAudio(soundPath, speed: _narrationSpeed);
        } catch (e) {
          debugPrint("Erro ao tocar som '$soundPath' em _playIconSound: $e");
        }
      }
  }



  Future<String?> _showSaveRowNameDialog(BuildContext context, int rowIndex) {
    final TextEditingController nameController = TextEditingController();
    return showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Salvar Linha ${rowIndex + 1}'),
          content: TextField(
            controller: nameController,
            autofocus: true,
            decoration: const InputDecoration(hintText: "Digite um nome para a linha"),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancelar'),
              onPressed: () => Navigator.of(context).pop(null),
            ),
            TextButton(
              child: const Text('Salvar'),
              onPressed: () => Navigator.of(context).pop(nameController.text),
            ),
          ],
        );
      },
    );
  }


  @override
  Widget build(BuildContext context) {
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
              colWidth: charController.colWidth 
              );
        });

        return Scaffold(
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
                          final characterController = context
                              .watch<CharacterController>(); 
                          final typeParts = characterController
                              .selectedCharacterType
                              .split('_');
                          final gender = typeParts[0]; 
                          final tone = typeParts[1];
                          return Stack(
                            children: iconController.allIcons.map((icon) {
                              String imagePath;
                              String basePath = 'assets/images/icons/icon_';

                              switch (icon.type) {
                                case "BaterPalma":
                                  imagePath =
                                      '${basePath}bater_palma_$tone.png';
                                  break;
                                case "EstalarDedo":
                                  imagePath =
                                      '${basePath}estalar_dedo_$tone.png';
                                  break;
                                case "Assobiar":
                                case "BaterPe":
                                case "BaterPeito":
                                case "BaterPerna":
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
                                  print(
                                      "AVISO: Ícone desconhecido: ${icon.type}");
                              }
                              return Positioned(
                                top: icon
                                    .position.dy, 
                                left: icon
                                    .position.dx, 
                                child: InkWell(
                                  onTap: () {
                                    showDialog(
                                      context: context,
                                      builder: (BuildContext context) {
                                        return AlertDialog(
                                          backgroundColor:
                                              Colors.white.withOpacity(0.8),
                                          title: Center(
                                            child: Semantics(
                                              child: const Text("Remover ícone",
                                                  style:
                                                      TextStyle(fontSize: 18)),
                                            ),
                                          ),
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
                                                    Navigator.of(context).pop(),
                                                style: ElevatedButton.styleFrom(
                                                    shape:
                                                        RoundedRectangleBorder(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        8.0))),
                                                child: const Text("Cancelar"),
                                              ),
                                            ),
                                            Semantics(
                                              label: 'Remover',
                                              button: true,
                                              child: ElevatedButton(
                                                onPressed: () {
                                                  iconController.removeIcon(
                                                      icon);
                                                  Navigator.of(context).pop();
                                                },
                                                style: ElevatedButton.styleFrom(
                                                    shape:
                                                        RoundedRectangleBorder(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        8.0))),
                                                child: const Text("Remover"),
                                              ),
                                            ),
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
                                      height: icon
                                          .size, 
                                      fit: BoxFit.contain,
                                      errorBuilder:
                                          (context, error, stackTrace) {
                                        print(
                                            "Erro ao carregar imagem do ícone: $imagePath\n$error");
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
                        },
                      ),
                      Consumer<CharacterController>(
                        builder: (context, controller, child) {
                          return Positioned(
                            top: controller.yPosition,
                            left: controller.xPosition,
                            child: GestureDetector(
                              onPanUpdate: (details) {
                                if (!controller.isLayoutInitialized ||
                                    controller.rowHeight <= 0 ||
                                    controller.colWidth <= 0) {
                                  return;
                                }
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
                                    'Personagem. Beija-Flor. Linha ${controller.currentRowIndex + 1}, Posição ${controller.currentColIndex + 1}. Arraste para mover.',
                                image: false,
                                child: Image.asset(
                                  controller.beijaFlorImagePath,
                                  height: controller.characterVisualHeight,
                                  width: controller.characterVisualWidth,
                                  fit: BoxFit.contain,
                                  errorBuilder: (context, error, stackTrace) {
                                    print(
                                        "Erro ao carregar Beija-Flor: ${controller.beijaFlorImagePath}\n$error");
                                    return Container(
                                        width: controller.characterVisualWidth,
                                        height:
                                            controller.characterVisualHeight,
                                        color: Colors.grey);
                                  },
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    
                      Positioned(
                        bottom: 10,
                        left: 10,
                        right: 10,
                        child: Consumer<CharacterController>(
                            builder: (context, characterController, child) {
                          final typeParts = characterController
                              .selectedCharacterType
                              .split('_');
                          final gender = typeParts[0];
                          final tone = typeParts[1];
                          String buttonBasePath =
                              'assets/images/buttons/button_';
                          return SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                MenuButton(
                                  iconPath:
                                      '${buttonBasePath}assobiar_${gender}_${tone}_transp.png',
                                  label: "Assobiar",
                                  tooltip: "Adicionar Assobiar",
                                  semanticsLabel: "Assobiar",
                                  onTap: () => _handleIconAction(
                                      context: context,
                                      type: "Assobiar",
                                      semanticsLabel: "Assobiar"),
                                ),
                                const SizedBox(width: 8),
                                MenuButton(
                                  iconPath:
                                      '${buttonBasePath}estalar_dedo_${tone}_transp.png', 
                                  label: "Estalar Dedo",
                                  tooltip: "Adicionar Estalar Dedo",
                                  semanticsLabel: "Estalar Dedo",
                                  onTap: () => _handleIconAction(
                                      context: context,
                                      type: "EstalarDedo",
                                      semanticsLabel: "Estalar Dedo"),
                                ),
                                const SizedBox(width: 8),
                                MenuButton(
                                  iconPath:
                                      '${buttonBasePath}bater_palma_${tone}_transp.png', 
                                  label: "Bater Palma",
                                  tooltip: "Adicionar Bater Palma",
                                  semanticsLabel: "Bater Palma",
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
                                  onTap: () => _handleIconAction(
                                      context: context,
                                      type: "BaterPerna",
                                      semanticsLabel: "Bater Perna"),
                                ),
                              ],
                            ),
                          );
                        } 
                            ),
                      ),
                      
                      if (_showJoystick)
                        Positioned(
                          bottom: 10,
                          right: 16, 
                          child: Consumer<CharacterController>(
                              builder: (context, controller, child) {
                            return Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                JoystickButton(
                                  icon: Icons.arrow_left,
                                  onPressed: () {
                                    controller.moveLeft();
                                    // _narrateMovement('assets/sounds/cima.mp3');
                                  },
                                  tooltip: "Mover para esquerda",
                                  semanticsLabel: "Mover para esquerda",
                                ),
                                const SizedBox(width: 1),
                                Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    JoystickButton(
                                      icon: Icons.arrow_drop_up,
                                      onPressed: () {
                                        controller.moveUp();
                                        // _narrateMovement('assets/sounds/cima.mp3');
                                      },
                                      tooltip: "Mover para cima",
                                      semanticsLabel: "Mover para cima",
                                    ),
                                    const SizedBox(height: 10),
                                    JoystickButton(
                                      icon: Icons.arrow_drop_down,
                                      onPressed: () {
                                        controller.moveDown();
                                        // _narrateMovement('assets/sounds/baixo.mp3');
                                      },
                                      tooltip: "Mover para baixo",
                                      semanticsLabel: "Mover para baixo",
                                    ),
                                  ],
                                ),
                                const SizedBox(width: 1),
                                JoystickButton(
                                  icon: Icons.arrow_right,
                                  onPressed: () {
                                    controller.moveRight();
                                    // _narrateMovement('assets/sounds/direita.mp3');
                                  },
                                  tooltip: "Mover para direita",
                                  semanticsLabel: "Mover para direita",
                                ),
                              ],
                            );
                          }),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          drawer: Drawer(
            child: ListView(
              children: [
                const DrawerHeader(
                  decoration: BoxDecoration(
                    color: Colors.blue,
                  ),
                  child: Stack(/* ... Existing Header Content ... */),
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
                    context.read<IconController>().clearIcons();
                    context.read<CharacterController>().resetPosition();
                  },
                ),
               
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
                  leading: const Icon(Icons.format_size, color: Colors.blue),
                  subtitle: Consumer<CharacterController>(
                      builder: (context, characterController, child) {
                    if (!characterController.isLayoutInitialized) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    return Semantics(
                      label:
                          'Ajustar tamanho. Atual: ${characterController.currentIconSizeSetting.toStringAsFixed(0)}. '
                          'Mínimo 30, Máximo permitido: ${characterController.maxAllowedIconSize.toStringAsFixed(0)}',
                      child: ExcludeSemantics(
                        child: Slider(
                          value: characterController.currentIconSizeSetting,
                          min: 30.0,
                          max: characterController.maxAllowedIconSize,
                          divisions: null,
                          label:
                              'Tamanho: ${characterController.currentIconSizeSetting.toStringAsFixed(0)}',
                          onChanged: (double value) {
                            characterController.setIconSizeSetting(value);
                          },
                        ),
                      ),
                    );
                  }),
                ),

                ListTile(
                  leading: const Icon(Icons.speed, color: Colors.blue),
                  subtitle: Semantics(
                    label:
                        'Ajustar a velocidade da narração. Velocidade atual: ${_narrationSpeed.toStringAsFixed(1)}x.',
                    child: ExcludeSemantics(
                      child: Slider(
                        value: _narrationSpeed,
                        min: 0.7,
                        max: 2.0,
                        divisions: 8,
                        label:
                            'Velocidade: ${_narrationSpeed.toStringAsFixed(1)}x',
                        onChanged: (double value) {
                          setState(() => _narrationSpeed = value);
                          _audioService.setSpeed(_narrationSpeed);
                        },
                      ),
                    ),
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
                        ? Container(
                            child: Text('$iconCount',
                                style: const TextStyle(
                                    fontSize: 16, color: Colors.blue)),
                          )
                        : null,
                    onTap: () => setState(() => _showCount = !_showCount),
                  );
                }),

                const Divider(), 

                ListTile(
                   leading: const Icon(Icons.save_alt, color: Colors.blue),
                   title: Semantics(
                     label: 'Salvar a linha onde o personagem está',
                     button: true,
                     child: const Text("Salvar Linha Atual"),
                   ),
                   onTap: () async {
                     Navigator.pop(context); // Close drawer first
                     final characterController = context.read<CharacterController>();
                     final iconController = context.read<IconController>();
                     final savedRowService = context.read<SavedRowService>();

                     final int currentRow = characterController.currentRowIndex;
                     final List<IconModel> iconsInCurrentRow = iconController.getIconsForRow(currentRow);

                     if (iconsInCurrentRow.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('A linha atual está vazia. Nada para salvar.'),
                            duration: Duration(seconds: 2),
                          ),
                        );
                        return;
                     }

                     // Prompt for name
                     final String? rowName = await _showSaveRowNameDialog(context, currentRow);

                     if (rowName != null) { // User didn't cancel
                        await savedRowService.saveRow(currentRow, iconsInCurrentRow, rowName);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Linha ${currentRow + 1} salva como "$rowName".'),
                            duration: Duration(seconds: 2),
                          ),
                        );
                     }
                   },
                 ),

                 // --- MANAGE SAVED ROWS ---
                 ListTile(
                   leading: const Icon(Icons.list_alt, color: Colors.blue),
                   title: Semantics(
                     label: 'Ver e aplicar linhas salvas',
                     button: true,
                     child: const Text("Linhas Salvas"),
                   ),
                   onTap: () {
                     Navigator.pop(context); // Close drawer
                     Navigator.push(
                       context,
                       MaterialPageRoute(builder: (context) => const SavedRowsScreen()),
                     );
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
              ],
            ),
          ),
        );
      },
    );
  }
}
