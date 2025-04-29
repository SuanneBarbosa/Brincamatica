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
import '../widgets/joystick_button.dart'; // Certifique-se que este import está presente
// Import IconModel se ainda não estiver importado corretamente


class Mathicon extends StatefulWidget {
  const Mathicon({super.key});

  @override
  _MathiconState createState() => _MathiconState();
}

class _MathiconState extends State<Mathicon> {
  final AudioService _audioService = AudioService();
  double _narrationSpeed = 1.0;
  final ScrollController _drawerScrollController = ScrollController();
  bool _showCount = false; // <<< REVERTIDO: Variável de estado original
  bool _showJoystick = false; // Joystick visível por padrão

  @override
  void initState() {
    super.initState();
    // Esconde as barras do sistema para imersão
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  }

  @override
  void dispose() {
    _audioService.dispose();
    _drawerScrollController.dispose();
    super.dispose();
  }

  // --- Action Handlers (Como no seu código original) ---

  void _handleIconAction({
    required BuildContext context,
    required String type,
    required String semanticsLabel,
  }) {
    final characterController = context.read<CharacterController>();
    final iconController = context.read<IconController>();

    final int targetRow = characterController.currentRowIndex;
    final int targetCol = characterController.currentColIndex;
    final double currentIconSizeSetting =
        characterController.currentIconSizeSetting;

    IconModel? existingIcon = iconController.getIconAt(targetRow, targetCol);

    if (existingIcon != null) {
      debugPrint("Replacing icon at ($targetRow, $targetCol)"); // Mantido do original
      iconController.replaceIconAt(
        rowIndex: targetRow,
        colIndex: targetCol,
        newType: type,
        newSemanticsLabel: semanticsLabel,
        newSize: currentIconSizeSetting,
      );
      _playIconSound(type);
    } else {
      // Lógica original para encontrar onde adicionar
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

       // Lógica original para coluna e próximo movimento
      int colToAddAt;
      int nextCharacterCol;

      if (targetCol < nextAvailableCol) {
          colToAddAt = targetCol;
          nextCharacterCol = targetCol + 1;
          // print("Adding icon at specific empty slot: $targetCol"); // Mantido do original
      } else {
          colToAddAt = nextAvailableCol;
          nextCharacterCol = colToAddAt + 1;
          // print("Adding icon sequentially at: $colToAddAt"); // Mantido do original
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
          // debugPrint("Character moved to or remains in last column."); // Mantido do original
      }
    }
  }

  void _playIconSound(String type) {
    String? soundPath;
    switch (type) {
      case "EstalarDedo": soundPath = 'assets/sounds/estalarDedos.mp3'; break;
      case "BaterPalma": soundPath = 'assets/sounds/baterPalma.mp3'; break;
      case "BaterPeito": soundPath = 'assets/sounds/baterPeito.mp3'; break;
      case "BaterPerna": soundPath = 'assets/sounds/baterPerna.mp3'; break;
      case "Assobiar": soundPath = 'assets/sounds/assobiar.mp3'; break;
      case "BaterPe": soundPath = 'assets/sounds/baterPes.mp3'; break;
    }
    if (soundPath != null) {
      try {
        _audioService.playAudio(soundPath, speed: _narrationSpeed);
      } catch (e) {
        debugPrint("Erro ao tocar som '$soundPath' em _playIconSound: $e");
      }
    }
  }

  // --- Build Method (Estrutura Principal como no seu original) ---
  @override
  Widget build(BuildContext context) {
    // LayoutBuilder na raiz como no original
    return LayoutBuilder(
      builder: (context, constraints) {
        final screenWidth = constraints.maxWidth;
        final screenHeight = constraints.maxHeight;

        // Callback para atualizar controllers como no original
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted) return;
          final charController = Provider.of<CharacterController>(context, listen: false);
          charController.setScreenSize(screenWidth, screenHeight);

          final iconController = Provider.of<IconController>(context, listen: false);
          iconController.updateLayoutParameters(
              horizontalPadding: charController.horizontalPadding,
              verticalPadding: charController.verticalPadding,
              rowHeight: charController.rowHeight,
              colWidth: charController.colWidth);
        });

        return Scaffold(
           // --- DRAWER (Como no seu original, incluindo Contador) ---
           drawer: Drawer(
              child: ListView(
               controller: _drawerScrollController, // Original tinha controller
               padding: EdgeInsets.zero, // Boa prática remover padding
               children: [
                // --- CABEÇALHO DO DRAWER (Como no original) ---
                DrawerHeader(
                  decoration: const BoxDecoration(color: Colors.blue,),
                  child: Stack(
                    children: [
                      Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Semantics( // Semantics no title original
                              child: const Text('Apoio', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white), textAlign: TextAlign.center,),
                            ),
                            const SizedBox(height: 1),
                            Semantics( // Semantics nos logos original
                              label: 'Logotipos dos apoiadores: IFSP, CNPQ e RUMO à Educação Matemática Inclusiva',
                              child: Container(
                                padding: const EdgeInsets.all(10.0),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(15),
                                  boxShadow: [ BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 8, offset: const Offset(2, 4)) ],
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center, crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Image.asset('assets/images/IFSP_Logo.png', height: 70, fit: BoxFit.contain), const SizedBox(width: 5),
                                    Image.asset('assets/images/CNPQ_Logo.png', height: 70, fit: BoxFit.contain), const SizedBox(width: 5),
                                    Image.asset('assets/images/RUMO_Logo.png', height: 70, fit: BoxFit.contain),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Positioned( // Botão fechar original
                        bottom: 100, left: 230,
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
                // --- OPÇÕES DO MENU (Como no original) ---
                 SwitchListTile( // Switch Joystick original
                  title: Semantics(label: 'Botões de controle de movimentos', child: const Text("Joystick"),),
                  value: _showJoystick,
                  onChanged: (bool value) => setState(() => _showJoystick = value),
                  secondary: Icon(_showJoystick ? Icons.gamepad : Icons.gamepad_outlined, color: Colors.blue,),
                 ),
                 ListTile( // Limpar Tela original
                  title: Semantics(label: 'Remover todos os ícones da tela', button: true, child: const Text("Limpar Tela"),),
                  leading: const Icon(Icons.delete, color: Colors.blue),
                  onTap: () { Navigator.pop(context); context.read<IconController>().clearIcons(); context.read<CharacterController>().resetPosition(); },
                 ),
                 ListTile( // Tamanho Ícone original
                  leading: const Icon(Icons.format_size, color: Colors.blue),
                  subtitle: Consumer<CharacterController>(
                     builder: (context, characterController, child) {
                       if (!characterController.isLayoutInitialized) { return const Center(child: CircularProgressIndicator()); }
                       return Semantics(
                         label: 'Ajustar tamanho. Atual: ${characterController.currentIconSizeSetting.toStringAsFixed(0)}. Mínimo 30, Máximo permitido: ${characterController.maxAllowedIconSize.toStringAsFixed(0)}. Alterar o tamanho limpará a tela.',
                         child: ExcludeSemantics(
                           child: Slider(
                             value: characterController.currentIconSizeSetting, min: 30.0, max: characterController.maxAllowedIconSize.clamp(30.0, double.infinity),
                             divisions: null, // Original
                             label: 'Tamanho: ${characterController.currentIconSizeSetting.toStringAsFixed(0)}', // Original
                             onChanged: (double value) { // Original
                               final iconController = context.read<IconController>();
                               characterController.setIconSizeSetting(value); iconController.clearIcons(); characterController.resetPosition();
                               iconController.updateLayoutParameters(
                                 horizontalPadding: characterController.horizontalPadding, verticalPadding: characterController.verticalPadding,
                                 rowHeight: characterController.rowHeight, colWidth: characterController.colWidth,
                               );
                             },
                           ),
                         ),
                       );
                     }
                  ),
                ),
                 // <<< CONTADOR DE ÍCONES ORIGINAL >>>
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
                    trailing: _showCount // Usa a variável de estado
                        ? Text('$iconCount', style: const TextStyle(fontSize: 16, color: Colors.blue))
                        : null,
                    onTap: () => setState(() => _showCount = !_showCount), // Usa setState
                  );
                 }),
               const Divider(),
               ListTile( // Salvar Linha Atual original (sem pedir nome)
                  leading: const Icon(Icons.save_alt, color: Colors.blue),
                  title: Semantics(label: 'Salvar a linha onde o Beija-Flor está posicionado', button: true, child: const Text("Salvar Linha Atual"),),
                  onTap: () async {
                    Navigator.pop(context);
                    final characterController = context.read<CharacterController>(); final iconController = context.read<IconController>();
                    final savedRowService = context.read<SavedRowService>(); final int currentRow = characterController.currentRowIndex;
                    final List<IconModel> iconsInCurrentRow = iconController.getIconsForRow(currentRow);
                    if (iconsInCurrentRow.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('A linha atual está vazia. Nada para salvar.'), duration: Duration(seconds: 2)),); return;
                    }
                    await savedRowService.saveRow(currentRow, iconsInCurrentRow, ""); // Salva com nome padrão
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Linha ${currentRow + 1} salva com sucesso.'), duration: const Duration(seconds: 2)),);
                  },
               ),
               ListTile( // Linhas Salvas original
                  leading: const Icon(Icons.list_alt, color: Colors.blue),
                  title: Semantics(label: 'Ver e aplicar linhas salvas', button: true, child: const Text("Linhas Salvas"),),
                  onTap: () { Navigator.pop(context); Navigator.push(context, MaterialPageRoute(builder: (context) => const SavedRowsScreen())); },
               ),
               const Divider(),
               ListTile( // Instruções original
                  leading: const Icon(Icons.help_outline, color: Colors.blue),
                  title: Semantics(label: 'Abrir a página de instruções de uso', child: const Text("Instruções de Uso"),),
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const InstructionsScreen())),
               ),
               ListTile( // Agradecimentos original
                  leading: const Icon(Icons.handshake, color: Colors.blue),
                  title: Semantics(label: 'Abrir a página de agradecimentos', child: const Text("Agradecimentos"),),
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const ThankYouScreen())),
               ),
             ],
           ),
        ),
        // --- CORPO PRINCIPAL (Stack Layout Original) ---
        body: Container(
          width: screenWidth,
          height: screenHeight,
          color: const Color.fromRGBO(220, 247, 255, 1.0),
          // Stack principal para sobrepor elementos
          child: Column(
             crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // --- Botão do Menu Superior (Como no original) ---
              Builder( // Builder original para acesso ao Scaffold
                  builder: (context) {
                    return Semantics(
                      label: 'Abrir menu de navegação',
                      button: true,
                      child: IconButton(
                        icon: const Icon(Icons.menu, color: Colors.blue),
                        tooltip: "Abrir menu",
                        onPressed: () => Scaffold.of(context).openDrawer(),
                        // Sem padding/splashRadius no original
                      ),
                    );
                  },
                ),
                
 Expanded(
      child: Stack(
        children: [
           Consumer<IconController>(
                 builder: (context, iconController, child) {
                  final characterController = context.watch<CharacterController>();
 if (!characterController.isLayoutInitialized) {
      return const SizedBox.shrink(); // Ou um placeholder
    }

                  final typeParts = characterController.selectedCharacterType.split('_');
                  final gender = typeParts.isNotEmpty ? typeParts[0] : 'boy';
                  final tone = typeParts.length > 1 ? typeParts[1] : 'light';
                  return Stack(
                    children: iconController.allIcons.map((icon) {
                      String imagePath;
                      String basePath = 'assets/images/icons/icon_';
                      switch (icon.type) {
                         case "BaterPalma": imagePath = '${basePath}bater_palma_$tone.png'; break;
                         case "EstalarDedo": imagePath = '${basePath}estalar_dedo_$tone.png'; break;
                         case "BaterPeito": case "Assobiar": case "BaterPe": case "BaterPerna":
                          String snakeCaseType = icon.type.replaceAllMapped(RegExp(r'[A-Z]'), (match) => '_${match.group(0)?.toLowerCase()}').substring(1);
                          imagePath = '$basePath${snakeCaseType}_${gender}_$tone.png';
                          break;
                         default: imagePath = 'assets/images/placeholder.png'; //print("AVISO: Ícone desconhecido: ${icon.type}"); // Original não tinha print
                      }
                      return Positioned(
                        key: ValueKey('icon_${icon.rowIndex}_${icon.colIndex}_${icon.type}'), // Adicionar chave é boa prática
                        top: icon.position.dy, left: icon.position.dx,
                        child: InkWell(
                          onTap: () {
                             // Diálogo de remover original
                             showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return AlertDialog(
                                    backgroundColor: Colors.white.withOpacity(0.8),
                                    title: Center(child: Semantics(child: const Text("Remover ícone", style: TextStyle(fontSize: 18)))),
                                    content: const Text("Deseja remover o ícone?", textAlign: TextAlign.center, style: TextStyle(fontSize: 16)),
                                    actionsAlignment: MainAxisAlignment.center,
                                    actions: [
                                      Semantics(label: 'Cancelar', button: true, child: ElevatedButton(onPressed: () => Navigator.of(context).pop(), style: ElevatedButton.styleFrom(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0))), child: const Text("Cancelar"))),
                                      Semantics(label: 'Remover', button: true, child: ElevatedButton(onPressed: () { iconController.removeIcon(icon); Navigator.of(context).pop(); }, style: ElevatedButton.styleFrom(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0))), child: const Text("Remover"))),
                                    ],
                                  );
                                },
                              );
                          },
                          child: Semantics(
                            button: false, label: icon.semanticsLabel,
                            child: Image.asset(
                              imagePath, height: icon.size, fit: BoxFit.contain,
                              errorBuilder: (context, error, stackTrace) {
                                // print("Erro img ícone: $imagePath\n$error"); // Original não tinha print
                                return Container(width: icon.size, height: icon.size, color: Colors.red.withOpacity(0.5), child: const Icon(Icons.error));
                              },
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  );
                 }
               ),

              // --- DESENHO DO PERSONAGEM (Como no original) ---
              Consumer<CharacterController>(
                 builder: (context, controller, child) {
                  if (!controller.isLayoutInitialized) { return const SizedBox.shrink(); } // Boa prática
                  return Positioned(
                    top: controller.yPosition, left: controller.xPosition,
                    child: GestureDetector(
                      onPanUpdate: (details) { // Lógica de PanUpdate original
                         if (!controller.isLayoutInitialized || controller.rowHeight <= 0 || controller.colWidth <= 0) return;
                         final double dragX = details.globalPosition.dx; final double dragY = details.globalPosition.dy;
                         final double relativeX = dragX - controller.horizontalPadding; final double relativeY = dragY - controller.verticalPadding;
                         int targetCol = (relativeX / controller.colWidth).floor(); int targetRow = (relativeY / controller.rowHeight).floor();
                         controller.moveToGridCell(targetRow, targetCol);
                      },
                      child: Semantics( // Semantics original
                        label: 'Personagem. Beija-Flor. Linha ${controller.currentRowIndex + 1}, Posição ${controller.currentColIndex + 1}. Arraste para mover.',
                        image: false,
                        child: Image.asset(
                          controller.beijaFlorImagePath, height: controller.characterVisualHeight, width: controller.characterVisualWidth, fit: BoxFit.contain,
                          errorBuilder: (context, error, stackTrace) { // Error builder original
                            // print("Erro img Beija-Flor: ${controller.beijaFlorImagePath}\n$error"); // Original não tinha print
                            return Container(width: controller.characterVisualWidth, height: controller.characterVisualHeight, color: Colors.grey);
                          },
                        ),
                      ),
                    ),
                  );
                }
              ),
        ],
      ),
    ),
              // --- DESENHO DOS ÍCONES (Como no original) ---
            

              // --- *** BARRA DE CONTROLES INFERIOR (NOVO LAYOUT APLICADO) *** ---
            
                _buildBottomControlsRow(context),
             
              // --- *** FIM DA SEÇÃO MODIFICADA *** ---

            ], // Fim dos filhos da Stack principal
          ),
        ),
      );
     },
    );
  } // Fim do método build

 // --- Métodos Helper para a Barra Inferior (Adicionados/Mantidos) ---

 // Método que organiza a linha inferior inteira (joystick esq, ações, joystick dir)
 Widget _buildBottomControlsRow(BuildContext context) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 0.0, top: 0.0, left: 10.0, right: 10.0),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(
          width: 50,
          child: _showJoystick ? _buildLeftJoystick(context) : null,
        ),
        Expanded(
          child: Align(
            alignment: Alignment.center, // Centraliza horizontalmente
            child: _buildActionMenuBar(context),
          ),
        ),
        SizedBox(
          width: 50,
          child: _showJoystick ? _buildRightJoystick(context) : null,
        ),
      ],
    ),
  );
}


 // Método para construir a barra de MenuButton central
  Widget _buildActionMenuBar(BuildContext context) {
    // Exatamente como na versão anterior que você gostou
    return Consumer<CharacterController>(
      builder: (context, characterController, child) {
        final screenWidth = MediaQuery.of(context).size.width;
        const double minBtnIconSize = 40.0; const double maxBtnIconSize = 60.0;
        final double targetBtnIconSize = (screenWidth * 0.070).clamp(minBtnIconSize, maxBtnIconSize);
        final typeParts = characterController.selectedCharacterType.split('_');
        final gender = typeParts.isNotEmpty ? typeParts[0] : 'boy';
        final tone = typeParts.length > 1 ? typeParts[1] : 'light';
        String buttonBasePath = 'assets/images/buttons/button_';

        return SingleChildScrollView(
          scrollDirection: Axis.horizontal, physics: const BouncingScrollPhysics(),
          child: Center(
            child: Row(
              mainAxisSize: MainAxisSize.min, mainAxisAlignment: MainAxisAlignment.center,
              children: [
                 MenuButton(iconPath: '${buttonBasePath}assobiar_${gender}_${tone}_transp.png', label: "Assobiar", tooltip: "Adicionar Assobiar", semanticsLabel: "Assobiar", iconSize: targetBtnIconSize, onTap: () => _handleIconAction(context: context, type: "Assobiar", semanticsLabel: "Assobiar"),), const SizedBox(width: 8),
                 MenuButton(iconPath: '${buttonBasePath}estalar_dedo_${tone}_transp.png', label: "Estalar Dedo", tooltip: "Adicionar Estalar Dedo", semanticsLabel: "Estalar Dedo", iconSize: targetBtnIconSize, onTap: () => _handleIconAction(context: context, type: "EstalarDedo", semanticsLabel: "Estalar Dedo"),), const SizedBox(width: 8),
                 MenuButton(iconPath: '${buttonBasePath}bater_palma_${tone}_transp.png', label: "Bater Palma", tooltip: "Adicionar Bater Palma", semanticsLabel: "Bater Palma", iconSize: targetBtnIconSize, onTap: () => _handleIconAction(context: context, type: "BaterPalma", semanticsLabel: "Bater Palma"),), const SizedBox(width: 8),
                 MenuButton(iconPath: '${buttonBasePath}bater_pe_${gender}_${tone}_transp.png', label: "Bater Pé", tooltip: "Adicionar Bater Pé", semanticsLabel: "Bater Pé", iconSize: targetBtnIconSize, onTap: () => _handleIconAction(context: context, type: "BaterPe", semanticsLabel: "Bater Pé"),), const SizedBox(width: 8),
                 MenuButton(iconPath:'${buttonBasePath}bater_peito_${gender}_${tone}_transp.png', label: "Bater Peito", tooltip: "Adicionar Bater Peito", semanticsLabel: "Bater Peito", iconSize: targetBtnIconSize, onTap: () => _handleIconAction(context: context, type: "BaterPeito", semanticsLabel: "Bater Peito"),), const SizedBox(width: 8),
                 MenuButton(iconPath:'${buttonBasePath}bater_perna_${gender}_${tone}_transp.png', label: "Bater Perna", tooltip: "Adicionar Bater Perna", semanticsLabel: "Bater Perna", iconSize: targetBtnIconSize, onTap: () => _handleIconAction(context: context, type: "BaterPerna", semanticsLabel: "Bater Perna"),),
              ],
            ),
          ),
        );
      }
   );
  }

 // Método para construir o grupo esquerdo do Joystick
  Widget _buildLeftJoystick(BuildContext context) {
    // Exatamente como na versão anterior que você gostou
    return Consumer<CharacterController>(
      builder: (context, controller, child) {
        return Column(
          mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            JoystickButton(icon: Icons.arrow_upward, onPressed: () => controller.moveUp(), tooltip: "Mover para cima", semanticsLabel: "Mover para cima",),
           
            JoystickButton(icon: Icons.arrow_back, onPressed: () => controller.moveLeft(), tooltip: "Mover para esquerda", semanticsLabel: "Mover para esquerda",),
          ],
        );
      }
    );
  }

 // Método para construir o grupo direito do Joystick
  Widget _buildRightJoystick(BuildContext context) {
    // Exatamente como na versão anterior que você gostou
    return Consumer<CharacterController>(
      builder: (context, controller, child) {
        return Column(
          mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.center,
          children: [
             JoystickButton(icon: Icons.arrow_downward, onPressed: () => controller.moveDown(), tooltip: "Mover para baixo", semanticsLabel: "Mover para baixo",),
            
             JoystickButton(icon: Icons.arrow_forward, onPressed: () => controller.moveRight(), tooltip: "Mover para direita", semanticsLabel: "Mover para direita",),
          ],
        );
      }
    );
  }

} 