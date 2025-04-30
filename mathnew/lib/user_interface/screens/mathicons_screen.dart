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
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  }

  @override
  void dispose() {
    _drawerScrollController.dispose();
    context.read<PlaybackController>().stop();
    super.dispose();
  }

// Dentro da classe _MathiconState (arquivo mathicons_screen.dart)

  // --- NOVA FUNÇÃO HELPER PRIVADA PARA TOCAR SOM NA ADIÇÃO/REPLACE ---
  void _playFeedbackSound(BuildContext context, String type) {
    // Lê a instância do AudioService via Provider
    final audioService = context.read<AudioService>();
    // A velocidade será a que estiver configurada no AudioService (1.0x agora)

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
    }
    if (soundPath != null) {
      try {
        // Chama o método playAudio do serviço (sem o parâmetro speed)
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
    // Para playback se estiver ocorrendo
    await context.read<PlaybackController>().stop();

    final characterController = context.read<CharacterController>();
    final iconController = context.read<IconController>();
    final int targetRow = characterController.currentRowIndex;
    final int targetCol = characterController.currentColIndex;
    final double currentIconSizeSetting =
        characterController.currentIconSizeSetting;
    IconModel? existingIcon = iconController.getIconAt(targetRow, targetCol);

    if (existingIcon != null) {
      // --- Lógica de Substituição (Mantida) ---
      debugPrint("Replacing icon at ($targetRow, $targetCol)");
      iconController.replaceIconAt(
        rowIndex: targetRow,
        colIndex: targetCol,
        newType: type,
        newSemanticsLabel: semanticsLabel,
        newSize: currentIconSizeSetting,
      );
      _playFeedbackSound(context, type);
      // Ao substituir, o personagem geralmente não se move.
    } else {
      // --- Lógica de Adição (Com Movimento Corrigido) ---

      // Verifica se a linha está cheia
      //  if (iconController.getIconsForRow(targetRow).length >= iconController.maxCols) {
      //      ScaffoldMessenger.of(context).showSnackBar(/*...*/); return;
      //    }

      // Verifica se a linha ESTAVA vazia ANTES de adicionar
      bool wasRowEmpty = iconController.getIconsForRow(targetRow).isEmpty;

      // Lógica ORIGINAL para determinar onde adicionar e qual a próxima coluna
      final int nextAvailableCol = iconController.getNextColumnIndex(targetRow);
      int colToAddAt;
      int nextCharacterCol; // Para onde ir DEPOIS de adicionar

      if (targetCol < nextAvailableCol) {
        colToAddAt = targetCol;
        debugPrint("Adding icon at specific empty slot: $targetCol");
      } else {
        colToAddAt = nextAvailableCol;
        debugPrint("Adding icon sequentially at: $colToAddAt");
      }
      // Calcula a próxima posição teórica do personagem (coluna seguinte à adicionada)
      nextCharacterCol = colToAddAt + 1;

      // Adiciona o ícone na coluna calculada
      iconController.addIcon(
        rowIndex: targetRow,
        colIndex: colToAddAt, // Usa a coluna calculada
        type: type,
        semanticsLabel: semanticsLabel,
        size: currentIconSizeSetting,
      );
      _playFeedbackSound(context, type); // Toca som de feedback

      // *** LÓGICA DE MOVIMENTO AJUSTADA ***
      int targetMoveCol; // Coluna para onde o personagem DEVE ir

      if (wasRowEmpty) {
        // Se era o primeiro ícone, o personagem deve ir para a coluna 1 (seguinte à adicionada na 0)
        // A menos que o limite seja 1 coluna, nesse caso fica na 0.
        targetMoveCol = (characterController.maxCols > 1) ? 1 : 0;
        debugPrint(
            "First icon added. Moving character to column $targetMoveCol.");
      } else {
        // Se não era o primeiro, usa a próxima coluna calculada (nextCharacterCol)
        targetMoveCol = nextCharacterCol;
        debugPrint(
            "Icon added. Moving character to next column: $targetMoveCol");
      }

      // Aplica o movimento, garantindo que não ultrapasse o limite
      targetMoveCol = targetMoveCol.clamp(0, characterController.maxCols - 1);
      characterController.moveToColumn(targetMoveCol);
      // Não precisa mais do debug print aqui, já fizemos acima
    }
  }

  void _limparTelaEPararPlayback() async {
    // Para a reprodução usando o controller
    await context.read<PlaybackController>().stop();
    if (mounted) {
      context.read<IconController>().clearIcons();
      context.read<CharacterController>().resetPosition();
    }
  }

  void _ajustarTamanhoEPararPlayback(double value) async {
    // Para a reprodução usando o controller
    await context.read<PlaybackController>().stop();
    if (mounted) {
      final characterController = context.read<CharacterController>();
      final iconController = context.read<IconController>();
      characterController.setIconSizeSetting(value);
      iconController.clearIcons();
      characterController.resetPosition();
      // Atualiza o layout do IconController após mudança de tamanho
      iconController.updateLayoutParameters(
        horizontalPadding: characterController.horizontalPadding,
        verticalPadding: characterController.verticalPadding,
        rowHeight: characterController.rowHeight,
        colWidth: characterController.colWidth,
      );
    }
  }

  // --- Build Method (Estrutura Principal como no seu original) ---
  @override
  Widget build(BuildContext context) {
    final playbackController = context.watch<PlaybackController>();
    return LayoutBuilder(
      builder: (context, constraints) {
        final screenWidth = constraints.maxWidth;
        final screenHeight = constraints.maxHeight;

        // Callback para atualizar controllers como no original
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
          // --- DRAWER (Como no seu original, incluindo Contador) ---
          drawer: Drawer(
            child: ListView(
              controller: _drawerScrollController, // Original tinha controller
              padding: EdgeInsets.zero, // Boa prática remover padding
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
                              // Semantics no title original
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
                              // Semantics nos logos original
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
                        // Botão fechar original
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
                SwitchListTile(
                  // Switch Joystick original
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
                  // Limpar Tela original
                  title: Semantics(
                    label: 'Remover todos os ícones da tela',
                    button: true,
                    child: const Text("Limpar Tela"),
                  ),
                  leading: const Icon(Icons.delete, color: Colors.blue),
                  onTap: () {
                    Navigator.pop(context);
                    // context.read<IconController>().clearIcons();
                    // context.read<CharacterController>().resetPosition();
                    _limparTelaEPararPlayback();
                  },
                ),
                ListTile(
                  // Tamanho Ícone original
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
                          divisions: null, // Original
                          label:
                              'Tamanho: ${characterController.currentIconSizeSetting.toStringAsFixed(0)}', // Original
                          onChanged: (double value) {
                            // Original
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
                        ? Text('$iconCount',
                            style: const TextStyle(
                                fontSize: 16, color: Colors.blue))
                        : null,
                    onTap: () => setState(
                        () => _showCount = !_showCount), // Usa setState
                  );
                }),
                const Divider(),
                ListTile(
                  // Salvar Linha Atual original (sem pedir nome)
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
                    await savedRowService.saveRow(currentRow, iconsInCurrentRow,
                        ""); // Salva com nome padrão
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                          content: Text(
                              'Linha ${currentRow + 1} salva com sucesso.'),
                          duration: const Duration(seconds: 2)),
                    );
                  },
                ),
                ListTile(
                  // Linhas Salvas original
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
                  // Instruções original
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
                  // Agradecimentos original
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
                Builder(
                  // Builder original para acesso ao Scaffold
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
                        final characterController =
                            context.watch<CharacterController>();
                        if (!characterController.isLayoutInitialized) {
                          return const SizedBox.shrink(); // Ou um placeholder
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
                                imagePath =
                                    'assets/images/placeholder.png'; //print("AVISO: Ícone desconhecido: ${icon.type}"); // Original não tinha print
                            }
                            return Positioned(
                              key: ValueKey(
                                  'icon_${icon.rowIndex}_${icon.colIndex}_${icon.type}'), // Adicionar chave é boa prática
                              top: icon.position.dy, left: icon.position.dx,
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
                                      // print("Erro img ícone: $imagePath\n$error"); // Original não tinha print
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

                      // --- DESENHO DO PERSONAGEM (Como no original) ---
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
                              // Torna async
                              // <<< INTERROMPER PLAYBACK AO ARRASTAR >>>
                              if (context
                                      .read<PlaybackController>()
                                      .isPlaying ||
                                  context.read<PlaybackController>().isPaused) {
                                await context.read<PlaybackController>().stop();
                              }
                              // Lógica original do PanUpdate...
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
                              // Semantics original
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
                // --- DESENHO DOS ÍCONES (Como no original) ---

                // --- *** BARRA DE CONTROLES INFERIOR (NOVO LAYOUT APLICADO) *** ---

                _buildBottomControlsRow(context, playbackController),

                // --- *** FIM DA SEÇÃO MODIFICADA *** ---
              ], // Fim dos filhos da Stack principal
            ),
          ),
        );
      },
    );
  } // Fim do método build

  Widget _buildBottomControlsRow(
      BuildContext context, PlaybackController playbackController) {
    // Determina o texto e a ação do botão Play/Pause
    final bool isCurrentlyPlaying =
        playbackController.isPlaying && !playbackController.isPaused;
    final String buttonText = isCurrentlyPlaying ? "Pause" : "Play";
    final VoidCallback onPressedAction = isCurrentlyPlaying
        ? playbackController.pause // Ação para pausar
        : () => playbackController
            .playOrResume(context); // Ação para iniciar/retomar

    return Padding(
      // Padding ajustado para dar mais espaço vertical se necessário para o texto
      padding:
          const EdgeInsets.only(bottom: 2.0, top: 0.0, left: 15.0, right: 15.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center, // Alinha verticalmente
        children: [
          
          Semantics(
            label: isCurrentlyPlaying ? 'Pausar reprodução da linha atual' : 'Tocar a linha atual do personagem',
            button: true,
            child: ElevatedButton( // Usando ElevatedButton
              onPressed: onPressedAction,
              style: ElevatedButton.styleFrom(
                 backgroundColor: Colors.blueAccent, // Cor de fundo azul
                 foregroundColor: Colors.white, // Cor do texto branca
                 padding: const EdgeInsets.symmetric(horizontal: 1, vertical: 2), // Padding interno
                 textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold), // Estilo do texto
                 shape: RoundedRectangleBorder( // Bordas arredondadas
                   borderRadius: BorderRadius.circular(8.0),
                 ),
                 minimumSize: const Size(60, 36), // Define um tamanho mínimo (opcional)
              ),
              child: Text(buttonText), // Exibe o texto "Play" ou "Pause"
            ),
          ),

          // Barra de Ações Central (mantida)
          Expanded(
            child: Align(
              alignment: Alignment.center,
              child: _buildActionMenuBar(context),
            ),
          ),
          SizedBox(
            width: 50, // Largura ligeiramente aumentada para equilíbrio visual
            child: _showJoystick ? _buildLeftJoystick(context) : null,
          ),
          const SizedBox(width: 8),
          // Coluna Direita do Joystick (mantida)
          SizedBox(
            width: 50, // Largura ligeiramente aumentada para equilíbrio visual
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
            ],
          ),
        ),
      );
    });
  }

  // Método para construir o grupo esquerdo do Joystick
  Widget _buildLeftJoystick(BuildContext context) {
    // Exatamente como na versão anterior que você gostou
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

  // Método para construir o grupo direito do Joystick
  Widget _buildRightJoystick(BuildContext context) {
    // Exatamente como na versão anterior que você gostou
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
