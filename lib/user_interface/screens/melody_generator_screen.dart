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
  GeneratorState? _previousState;
  
  final ItemScrollController _itemScrollController = ItemScrollController();
  final ItemPositionsListener _itemPositionsListener = ItemPositionsListener.create();
  int? _previousMostRecentIndex;

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
          title: const Text('Selecione 2 ou 3 sons',
              style: TextStyle(
                  fontSize: 25,
                  fontWeight: FontWeight.w800,
                  color: Colors.blue)),
          centerTitle: true,
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 12.0),
              child: Center(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 8),
                    textStyle: const TextStyle(fontWeight: FontWeight.bold),
                    backgroundColor: canConfirm ? Colors.blue : Colors.grey,
                    foregroundColor: Colors.white,
                  ),
                  onPressed:
                      canConfirm ? controller.confirmIconSelection : null,
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
          title: const Text('Escolha um modo de jogo',
              style: TextStyle(
                  fontSize: 25,
                  fontWeight: FontWeight.w800,
                  color: Colors.blue)),
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
      
      if (controller.mostRecentFoundIndex != null &&
          controller.mostRecentFoundIndex != _previousMostRecentIndex) {
        
        List<int> indicesToShow = [];
        for (int i = 0; i < controller.generatedMelodies.length; i++) {
          if (i == 0 || controller.completedMelodies[i]) {
            indicesToShow.add(i);
          }
        }
        
        final listPosition = indicesToShow.indexOf(controller.mostRecentFoundIndex!);
        if (listPosition != -1 && _itemScrollController.isAttached) {
          final targetRowIndex = (listPosition / 2).floor();
          _itemScrollController.scrollTo(
            index: targetRowIndex,
            duration: const Duration(milliseconds: 400),
            curve: Curves.easeInOut,
          );
        }

        if (mounted) {
          setState(() {
            _previousMostRecentIndex = controller.mostRecentFoundIndex;
          });
        }
      }
    });

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

  void _showGameWonDialog(BuildContext context) {
    final controller = context.read<MelodyGeneratorController>();
    final bool wonLevels = controller.isLevelsMode ||
        _previousState == GeneratorState.levelComplete;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          title: Center(
              child: Text(wonLevels ? 'Desafio Completo!' : 'Parabéns!')),
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
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
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
            padding:
                const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
            child: Column(
              key: const ValueKey('modeSelection'),
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton.icon(
                  icon: const Icon(Icons.emoji_events),
                  label: const Text('Desafio por Níveis',
                      style: TextStyle(fontSize: 18)),
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(280, 55),
                    backgroundColor: canPlayLevels ? Colors.amber : Colors.grey,
                  ),
                  onPressed: canPlayLevels ? controller.startLevelsMode : null,
                ),
                if (!canPlayLevels)
                  const Padding(
                    padding: EdgeInsets.only(top: 8.0),
                    child: Text(
                      '(requer 3 sons selecionados)',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.black54),
                    ),
                  ),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  icon: const Icon(Icons.play_circle_fill),
                  label:
                      const Text('Sem Repetição', style: TextStyle(fontSize: 18)),
                  style:
                      ElevatedButton.styleFrom(minimumSize: const Size(280, 55)),
                  onPressed: () => controller.startFreePlayMode(false),
                ),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  icon: const Icon(Icons.replay_circle_filled),
                  label:
                      const Text('Com Repetição', style: TextStyle(fontSize: 18)),
                  style:
                      ElevatedButton.styleFrom(minimumSize: const Size(280, 55)),
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
      padding: const EdgeInsets.fromLTRB(8.0, 8.0, 8.0, 8.0),
      child: Column(
        key: const ValueKey('gameScreen'),
        children: [
          Expanded(
            child: _buildFoundMelodiesList(controller, gender, tone),
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
          _buildUserInputDisplay(context, controller, gender, tone),
          const SizedBox(height: 8),
          _buildIconInputPanel(controller, gender, tone),
        ],
      ),
    );
  }

  Widget _buildFoundMelodiesList(
      MelodyGeneratorController controller, String gender, String tone) {
    
    if (controller.generatedMelodies.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    List<int> indicesToShow = [];
    for (int i = 0; i < controller.generatedMelodies.length; i++) {
      if (i == 0 || controller.completedMelodies[i]) {
        indicesToShow.add(i);
      }
    }
    
    if (indicesToShow.isEmpty) {
        return const Center(
          child: Text(
            "Carregando combinações...",
            style: TextStyle(fontSize: 18, color: Colors.grey),
          ),
        );
    }
    
    final rowCount = (indicesToShow.length / 2).ceil();
    
    return ScrollablePositionedList.builder(
      itemCount: rowCount,
      itemScrollController: _itemScrollController,
      itemPositionsListener: _itemPositionsListener,
      itemBuilder: (context, rowIndex) {
        final int item1ListIndex = rowIndex * 2;
        final int item2ListIndex = item1ListIndex + 1;

        final int originalIndex1 = indicesToShow[item1ListIndex];

        final Widget item1 = _buildMelodyItemWidget(
          controller: controller,
          originalIndex: originalIndex1,
          gender: gender,
          tone: tone,
        );

        if (item2ListIndex < indicesToShow.length) {
          final int originalIndex2 = indicesToShow[item2ListIndex];
          final Widget item2 = _buildMelodyItemWidget(
            controller: controller,
            originalIndex: originalIndex2,
            gender: gender,
            tone: tone,
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
              Expanded(child: item1),
              const Spacer(), 
            ],
          );
        }
      },
    );
  }

  Widget _buildMelodyItemWidget({
    required MelodyGeneratorController controller,
    required int originalIndex,
    required String gender,
    required String tone,
  }) {
    final melody = controller.generatedMelodies[originalIndex];
    final bool isCompleted = controller.completedMelodies[originalIndex];
    final bool showHint = controller.isLevelsMode ? controller.currentLevel.hasHint : true;
    
    final bool isMostRecent = controller.mostRecentFoundIndex == originalIndex;
    final screenWidth = MediaQuery.of(context).size.width;

    final double iconSize = (screenWidth * 0.05).clamp(28.0, 40.0);
    final double leadingIconSize = (screenWidth * 0.04).clamp(24.0, 30.0);
    final double trailingIconSize = (screenWidth * 0.045).clamp(26.0, 32.0);
    final double iconSpacing = (screenWidth * 0.01).clamp(4.0, 8.0);
    
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      color: isMostRecent ? Colors.yellow.shade100 : Colors.white,
      elevation: isMostRecent ? 4 : 2,
      child: ListTile(
        visualDensity: VisualDensity.compact,
        contentPadding: const EdgeInsets.symmetric(horizontal: 6.0),
        leading: Icon(
          isCompleted ? Icons.check_circle : Icons.radio_button_unchecked,
          color: isCompleted ? Colors.green : Colors.grey,
          size: leadingIconSize,
        ),
        title: Wrap(
          spacing: iconSpacing,
          runSpacing: 4.0,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            if (isCompleted)
              ...melody.map((iconType) => Image.asset(
                  _getIconImagePath(iconType, gender, tone),
                  height: iconSize))
            else ...[
              if (showHint)
                Image.asset(_getIconImagePath(melody.first, gender, tone), height: iconSize)
              else
                _buildHiddenIcon(size: iconSize),
              ...List.generate(melody.length - 1, (_) => _buildHiddenIcon(size: iconSize)),
            ]
          ],
        ),
        trailing: IconButton(
          icon: Icon(
            Icons.play_circle_outline,
            color: Colors.blue,
            size: trailingIconSize,
          ),
          onPressed: () => controller.playMelody(melody),
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
        size: size * 0.6,
      ),
    );
  }

  Widget _buildUserInputDisplay(BuildContext context,
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
    const double minContainerHeight = 52.0;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
              constraints: const BoxConstraints(minHeight: minContainerHeight),
              decoration: BoxDecoration(
                  color: feedbackColor,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.grey.shade400)),
              child: Row(
                children: [
                  Expanded(
                    child: controller.currentUserInput.isEmpty
                        ? const Center(
                            child: Text(
                              "Toque nos sons abaixo para formar as combinações.",
                              textAlign: TextAlign.center,
                              style: TextStyle(fontSize: 14),
                            ),
                          )
                        : Wrap(
                            spacing: 6.0,
                            runSpacing: 4.0,
                            alignment: WrapAlignment.center,
                            children:
                                controller.currentUserInput.map((iconType) {
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
            ),
          ),
          const SizedBox(width: 8),
          SizedBox(
            height: minContainerHeight,
            child: ElevatedButton(
              onPressed: () {
                if (controller.areAllCombinationsFound()) {
                  controller.finalizeRound();
                } else {
                  // <<< ALTERAÇÃO APLICADA AQUI >>>
                  showDialog(
                    context: context,
                    builder: (BuildContext dialogContext) {
                      return AlertDialog(
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15)),
                        title: const Center(child: Text("Atenção")),
                        content: const SingleChildScrollView(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.warning_amber_rounded,
                                  color: Colors.orange, size: 70),
                              SizedBox(height: 16),
                              Text(
                                "Faltam combinações para serem descobertas!",
                                textAlign: TextAlign.center,
                                style: TextStyle(fontSize: 17),
                              ),
                            ],
                          ),
                        ),
                        actionsAlignment: MainAxisAlignment.center,
                        actions: <Widget>[
                          ElevatedButton.icon(
                            icon: const Icon(Icons.arrow_back),
                            label: const Text("Voltar"),
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 24, vertical: 12),
                              textStyle: const TextStyle(fontSize: 16),
                            ),
                            onPressed: () {
                              Navigator.of(dialogContext).pop();
                            },
                          ),
                        ],
                      );
                    },
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10))),
              child: const Text("Confirmar"),
            ),
          ),
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
}