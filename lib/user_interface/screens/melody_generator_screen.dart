// lib/user_interface/screens/melody_generator_screen.dart

import 'package:Mathnew/user_interface/screens/tanks_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import '../../services/character_service.dart';
import '../../services/melody_generator_service.dart';
import 'about_generator_screen.dart';
import 'generator_instructions_screen.dart';
import '../widgets/app_drawer_header.dart';

class MelodyGeneratorScreen extends StatefulWidget {
  const MelodyGeneratorScreen({super.key});

  @override
  State<MelodyGeneratorScreen> createState() => _MelodyGeneratorScreenState();
}

class _MelodyGeneratorScreenState extends State<MelodyGeneratorScreen> {
  final ItemScrollController _itemScrollController = ItemScrollController();
  final ItemPositionsListener _itemPositionsListener =
      ItemPositionsListener.create();
  int _previousTargetIndex = 0;
  GeneratorState? _previousState;

  AppBar _buildAppBar(
      BuildContext context, MelodyGeneratorController controller) {
    const backgroundColor = Color.fromRGBO(220, 247, 255, 1.0);
    const titleTextStyle = TextStyle(color: Colors.black87, fontSize: 20);
    const iconTheme = IconThemeData(color: Colors.blue, size: 30);

    switch (controller.state) {
      case GeneratorState.selectingIcons:
        final bool canConfirm = controller.selectedIcons.length >= 2;
        return AppBar(
          backgroundColor: backgroundColor,
          titleTextStyle: titleTextStyle,
          iconTheme: iconTheme,
          leading: Builder(
            builder: (context) => IconButton(
              icon: const Icon(Icons.menu),
              tooltip: "Abrir menu",
              onPressed: () => Scaffold.of(context).openDrawer(),
            ),
          ),
          title: const Text('Selecione 2 ou 3 sons'),
          centerTitle: true,
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 12.0),
              child: Center(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    textStyle: const TextStyle(fontWeight: FontWeight.bold),
                    backgroundColor: canConfirm ? Colors.blue : Colors.grey,
                    foregroundColor: Colors.white,
                  ),
                  onPressed: canConfirm ? controller.confirmIconSelection : null,
                  child: const Text('Confirmar'),
                ),
              ),
            ),
          ],
        );

      case GeneratorState.selectingMode:
        return AppBar(
          backgroundColor: backgroundColor,
          titleTextStyle: titleTextStyle,
          iconTheme: iconTheme,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            tooltip: "Voltar para seleção",
            onPressed: controller.reset,
          ),
          title: const Text('Escolha um modo de jogo'),
          centerTitle: true,
        );

      default:
        return AppBar(
          backgroundColor: backgroundColor,
          titleTextStyle: titleTextStyle,
          iconTheme: iconTheme,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            tooltip: "Voltar para seleção",
            onPressed: controller.reset,
          ),
          actions: [
            if (controller.isLevelsMode)
              Padding(
                padding: const EdgeInsets.only(right: 20.0),
                child: Center(
                  child: Text(
                    'Nível: ${controller.currentLevelIndex + 1}',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
                  ),
                ),
              ),
          ],
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<MelodyGeneratorController>();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_previousState != GeneratorState.gameWon &&
          controller.state == GeneratorState.gameWon &&
          mounted) {
        _showGameWonDialog(context);
      }
      _previousState = controller.state;
    });

    // A lógica de rolagem volta a ser a da versão de duas colunas
    final targetRowIndex = (controller.currentTargetMelodyIndex / 2).floor();
    if ((controller.state == GeneratorState.playingFreePlay || controller.state == GeneratorState.playingLevels) &&
        targetRowIndex != (_previousTargetIndex / 2).floor()) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && _itemScrollController.isAttached) {
          _itemScrollController.scrollTo(
            index: targetRowIndex,
            duration: const Duration(milliseconds: 500),
            curve: Curves.easeInOutCubic,
          );
          setState(() {
            _previousTargetIndex = controller.currentTargetMelodyIndex;
          });
        }
      });
    }

    return PopScope(
      canPop: controller.state == GeneratorState.selectingIcons,
      onPopInvoked: (bool didPop) {
        if (didPop) return;
        controller.reset();
      },
      child: Scaffold(
        drawer: _buildGameDrawer(context),
        appBar: _buildAppBar(context, controller),
        body: Container(
          width: double.infinity,
          height: double.infinity,
          color: const Color.fromRGBO(220, 247, 255, 1.0),
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            child: _buildScreenForState(context, controller),
          ),
        ),
      ),
    );
  }

  Widget _buildGameDrawer(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
         const AppDrawerHeader(),
          ListTile(
            leading: const Icon(Icons.home_filled, color: Colors.blue),
            title: const Text('Escolha o Jogo'),
            onTap: () {
              Navigator.of(context).popUntil((route) => route.isFirst);
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
                      builder: (_) => const GeneratorInstructionsScreen()));
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
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => const AboutGeneratorScreen()));
            },
          ),
        ],
      ),
    );
  }

  // <<< INÍCIO DA ALTERAÇÃO >>>
  // Esta função foi modificada para ser responsiva.
  void _showGameWonDialog(BuildContext context) {
    final controller = context.read<MelodyGeneratorController>();
    final bool wonLevels =
        controller.isLevelsMode || _previousState == GeneratorState.levelComplete;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          title: Center(
              child: Text(wonLevels ? 'Desafio Completo!' : 'Parabéns!')),
          // ALTERAÇÃO 1: Adicionado SingleChildScrollView
          // Garante que o conteúdo possa rolar se a tela for muito pequena.
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.star, color: Colors.amber, size: 80),
                const SizedBox(height: 16),
                Text(
                  wonLevels
                      ? 'Você completou todos os níveis!'
                      : 'Você completou todas as melodias!',
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 18),
                ),
              ],
            ),
          ),
          actionsAlignment: MainAxisAlignment.center,
          actions: <Widget>[
            ElevatedButton.icon(
              icon: const Icon(Icons.refresh),
              label: const Text('Jogar Novamente'),
              style: ElevatedButton.styleFrom(
                // ALTERAÇÃO 2: Removido 'minimumSize' e adicionado 'padding' flexível.
                // O botão agora pode encolher em telas menores.
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                textStyle: const TextStyle(fontSize: 16),
              ),
              onPressed: () {
                Navigator.of(dialogContext, rootNavigator: true).pop();
                Future.microtask(() {
                  controller.reset();
                });
              },
            ),
          ],
        );
      },
    );
  }
  // <<< FIM DA ALTERAÇÃO >>>

  Widget _buildScreenForState(
      BuildContext context, MelodyGeneratorController controller) {
    switch (controller.state) {
      case GeneratorState.selectingIcons:
        return _buildIconSelection(context, controller);
      case GeneratorState.selectingMode:
        return _buildModeSelection(context, controller);
      case GeneratorState.playingFreePlay:
      case GeneratorState.playingLevels:
      case GeneratorState.gameWon:
        return _buildGameScreen(context, controller);
      case GeneratorState.levelComplete:
        return _buildLevelCompleteScreen(context, controller);
    }
  }

  Widget _buildIconSelection(
      BuildContext context, MelodyGeneratorController controller) {
    final characterController = context.read<CharacterController>();
    final typeParts = characterController.selectedCharacterType.split('_');
    final gender = typeParts.isNotEmpty ? typeParts[0] : 'boy';
    final tone = typeParts.length > 1 ? typeParts[1] : 'light';

    return GridView.builder(
      key: const ValueKey('iconSelection'),
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
                    offset: const Offset(0, 2)),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Image.asset(_getIconImagePath(iconType, gender, tone)),
            ),
          ),
        );
      },
    );
  }

  Widget _buildModeSelection(
      BuildContext context, MelodyGeneratorController controller) {
    final bool canPlayLevels = controller.selectedIcons.length >= 3;

    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          child: Container(
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
            child: Column(
              key: const ValueKey('modeSelection'),
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton.icon(
                  icon: const Icon(Icons.emoji_events),
                  label: const Text('Desafio por Níveis', style: TextStyle(fontSize: 18)),
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(280, 55),
                    backgroundColor: canPlayLevels ? Colors.amber : Colors.grey,
                  ),
                  onPressed: canPlayLevels ? controller.startLevelsMode : null,
                ),
                if (!canPlayLevels)
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(
                      '(requer 3 sons selecionados)',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.black54),
                    ),
                  ),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  icon: const Icon(Icons.play_circle_fill),
                  label: const Text('Sem Repetição', style: TextStyle(fontSize: 18)),
                  style: ElevatedButton.styleFrom(minimumSize: const Size(280, 55)),
                  onPressed: () => controller.startFreePlayMode(false),
                ),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  icon: const Icon(Icons.replay_circle_filled),
                  label: const Text('Com Repetição', style: TextStyle(fontSize: 18)),
                  style: ElevatedButton.styleFrom(minimumSize: const Size(280, 55)),
                  onPressed: () => controller.startFreePlayMode(true),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildLevelCompleteScreen(
      BuildContext context, MelodyGeneratorController controller) {
    return Column(
      key: const ValueKey('levelComplete'),
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'Nível ${controller.currentLevelIndex + 1} Completo!',
          style: Theme.of(context)
              .textTheme
              .headlineMedium
              ?.copyWith(color: Colors.green.shade800),
        ),
        const SizedBox(height: 20),
        const Icon(Icons.check_circle, color: Colors.green, size: 100),
        const SizedBox(height: 40),
        ElevatedButton(
          onPressed: controller.proceedToNextLevel,
          style: ElevatedButton.styleFrom(minimumSize: const Size(250, 50)),
          child: Text('Ir para o Nível ${controller.currentLevelIndex + 2}',
              style: const TextStyle(fontSize: 18)),
        ),
      ],
    );
  }

  Widget _buildGameScreen(
      BuildContext context, MelodyGeneratorController controller) {
    final characterController = context.read<CharacterController>();
    final typeParts = characterController.selectedCharacterType.split('_');
    final gender = typeParts.isNotEmpty ? typeParts[0] : 'boy';
    final tone = typeParts.length > 1 ? typeParts[1] : 'light';

    return Padding(
      padding: const EdgeInsets.fromLTRB(8.0, 0, 8.0, 8.0),
      child: Column(
        key: const ValueKey('gameScreen'),
        children: [
          Expanded(
            child: _buildMelodyList(controller, gender, tone),
          ),
          const Divider(thickness: 1.5, height: 8),
          _buildInteractionArea(context, controller, gender, tone),
        ],
      ),
    );
  }

  Widget _buildInteractionArea(BuildContext context,
      MelodyGeneratorController controller, String gender, String tone) {
    return SingleChildScrollView(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildUserInputDisplay(controller, gender, tone),
          const SizedBox(height: 8),
          _buildIconInputPanel(controller, gender, tone),
        ],
      ),
    );
  }

  Widget _buildMelodyList(
      MelodyGeneratorController controller, String gender, String tone) {
    final melodies = controller.generatedMelodies;
    final rowCount = (melodies.length / 2).ceil();
    // Pega a largura da tela para passar para os itens filhos
    final screenWidth = MediaQuery.of(context).size.width;

    return ScrollablePositionedList.builder(
      itemCount: rowCount,
      itemScrollController: _itemScrollController,
      itemPositionsListener: _itemPositionsListener,
      itemBuilder: (context, rowIndex) {
        final int item1Index = rowIndex * 2;
        final int item2Index = item1Index + 1;

        final Widget item1 = _buildMelodyItemWidget(
          controller: controller,
          index: item1Index,
          gender: gender,
          tone: tone,
          screenWidth: screenWidth, // Passa a largura da tela
        );

        if (item2Index < melodies.length) {
          final Widget item2 = _buildMelodyItemWidget(
            controller: controller,
            index: item2Index,
            gender: gender,
            tone: tone,
            screenWidth: screenWidth, // Passa a largura da tela
          );
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: item1),
              const SizedBox(width: 8),
              Expanded(child: item2),
            ],
          );
        } else {
          return Row(
            children: [
              const Spacer(flex: 1),
              Expanded(flex: 2, child: item1),
              const Spacer(flex: 1),
            ],
          );
        }
      },
    );
  }

  Widget _buildMelodyItemWidget({
    required MelodyGeneratorController controller,
    required int index,
    required String gender,
    required String tone,
    required double screenWidth, // Novo parâmetro
  }) {
    // MUDANÇA AQUI: Calcula os tamanhos dinamicamente
    // Define um tamanho para o ícone da melodia, com limites mínimo e máximo
    final double iconSize = (screenWidth * 0.05).clamp(28.0, 40.0);
    // Define o tamanho para os ícones de status (check) e play
    final double leadingIconSize = (screenWidth * 0.04).clamp(24.0, 30.0);
    final double trailingIconSize = (screenWidth * 0.045).clamp(26.0, 32.0);
    // Reduz o espaçamento entre os ícones em telas menores
    final double iconSpacing = (screenWidth * 0.01).clamp(4.0, 8.0);

    final melody = controller.generatedMelodies[index];
    final isPlaying = controller.currentlyPlayingIndex == index;
    final isCompleted = controller.completedMelodies[index];
    final isCurrentTarget = controller.currentTargetMelodyIndex == index;
    final bool showHint = controller.isLevelsMode ? controller.currentLevel.hasHint : true;

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      color: isCurrentTarget ? Colors.yellow.shade100 : Colors.white,
      elevation: isCurrentTarget ? 4 : 2,
      child: ListTile(
        // MUDANÇA AQUI: Deixa o ListTile mais compacto
        visualDensity: VisualDensity.compact,
        contentPadding: const EdgeInsets.symmetric(horizontal: 6.0),

        leading: Icon(
          isCompleted ? Icons.check_circle : Icons.radio_button_unchecked,
          color: isCompleted ? Colors.green : Colors.grey,
          size: leadingIconSize, // Tamanho dinâmico
        ),
        title: Wrap(
          spacing: iconSpacing, // Espaçamento dinâmico
          runSpacing: 4.0,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            if (isCompleted)
              ...melody.map((iconType) =>
                  Image.asset(_getIconImagePath(iconType, gender, tone), height: iconSize)) // Tamanho dinâmico
            else ...[
              if (showHint)
                Image.asset(_getIconImagePath(melody.first, gender, tone), height: iconSize) // Tamanho dinâmico
              else
                _buildHiddenIcon(size: iconSize), // Tamanho dinâmico
              ...List.generate(melody.length - 1, (_) => _buildHiddenIcon(size: iconSize)), // Tamanho dinâmico
            ]
          ],
        ),
        trailing: IconButton(
          icon: Icon(
            isPlaying ? Icons.stop_circle_outlined : Icons.play_circle_outline,
            color: Colors.blue,
            size: trailingIconSize, // Tamanho dinâmico
          ),
          onPressed: () => controller.playMelody(index),
        ),
      ),
    );
  }

  Widget _buildHiddenIcon({required double size}) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
          color: Colors.grey.shade200,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey.shade400)),
      child: Icon(
        Icons.question_mark_rounded,
        color: Colors.grey.shade600,
        size: size * 0.6, // Ícone interno também é proporcional
      ),
    );
  }

  Widget _buildUserInputDisplay(
      MelodyGeneratorController controller, String gender, String tone) {
    Color feedbackColor;
    switch (controller.validationState) {
      case ValidationState.neutral:
        feedbackColor = Colors.blue.shade100;
        break;
      case ValidationState.correct:
        feedbackColor = Colors.green.shade200;
        break;
      case ValidationState.incorrect:
        feedbackColor = Colors.red.shade200;
        break;
    }
    const double iconHeight = 36.0;
    const double minContainerHeight = 48.0;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
      constraints: const BoxConstraints(minHeight: minContainerHeight),
      decoration: BoxDecoration(
          color: feedbackColor,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.grey.shade400)),
      child: Row(
        children: [
          Expanded(
            child: controller.currentUserInput.isEmpty
                ? Center(
                    child: Text(
                      "Toque nos sons abaixo...",
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 14),
                    ),
                  )
                : Wrap(
                    spacing: 6.0,
                    runSpacing: 4.0,
                    alignment: WrapAlignment.center,
                    children: controller.currentUserInput.map((iconType) {
                      return Image.asset(
                          _getIconImagePath(iconType, gender, tone),
                          height: iconHeight);
                    }).toList(),
                  ),
          ),
          if (controller.currentUserInput.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.backspace_outlined),
              onPressed: controller.clearUserInput,
              tooltip: "Limpar entrada",
            )
        ],
      ),
    );
  }

  Widget _buildIconInputPanel(
      MelodyGeneratorController controller, String gender, String tone) {
    final screenWidth = MediaQuery.of(context).size.width;
    
    final iconCount = controller.activeIconsForLevel.length;
    if (iconCount == 0) return const SizedBox.shrink();

    const double horizontalPadding = 40.0;
    const double minIconSize = 50.0;
    const double maxIconSize = 80.0;
    const double minSpacing = 12.0;
    final availableWidth = screenWidth - horizontalPadding;
    final idealSize =
        (availableWidth - ((iconCount - 1) * minSpacing)) / iconCount;
    final double iconSize = idealSize.clamp(minIconSize, maxIconSize);
    final double spacing = (iconSize * 0.15).clamp(8.0, 20.0);
    final double innerPadding = (iconSize * 0.12);

    return Padding(
      padding: const EdgeInsets.only(bottom: 4.0, top: 4.0),
      child: Wrap(
        alignment: WrapAlignment.center,
        spacing: spacing,
        runSpacing: spacing,
        children: controller.activeIconsForLevel.map((iconType) {
          return GestureDetector(
            onTap: () => controller.handleIconTap(iconType),
            child: Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              child: Container(
                padding: EdgeInsets.all(innerPadding),
                width: iconSize,
                height: iconSize,
                child: Image.asset(
                  _getIconImagePath(iconType, gender, tone),
                  fit: BoxFit.contain,
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  String _getIconImagePath(String iconType, String gender, String tone) {
    String basePath = 'assets/images/buttons/button_';
    String imagePath;
    switch (iconType) {
      case "BaterPalma":
        imagePath = '${basePath}bater_palma_${tone}_transp.png';
        break;
      case "EstalarDedo":
        imagePath = '${basePath}estalar_dedo_${tone}_transp.png';
        break;
      case "BaterPeito":
      case "BaterPe":
      case "BaterPerna":
      case "Gritar":
      case "Beijo":
      case "Assobiar":
      case "EstalarLingua1":
      case "EstalarLingua2":
        String snakeCaseType = iconType
            .replaceAllMapped(
                RegExp(r'[A-Z]'), (match) => '_${match.group(0)?.toLowerCase()}')
            .substring(1);
        imagePath = '$basePath${snakeCaseType}_${gender}_${tone}_transp.png';
        break;
      default:
        imagePath = 'assets/images/placeholder.png';
    }
    return imagePath;
  }
}