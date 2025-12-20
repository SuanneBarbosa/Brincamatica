import 'package:Mathnew/services/combinesSound_service.dart';
import 'package:Mathnew/services/createMelody_tutorial_service.dart';
import 'package:Mathnew/services/score_history_service.dart';
import 'package:Mathnew/services/sound_memory_tutorial_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart'; 
import 'package:provider/provider.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:io' show Platform;
import 'services/sheldon_service.dart';
import 'services/character_service.dart';
import 'services/icon_service.dart';
import 'services/saved_row_service.dart';
import 'services/audio_service.dart';
import 'services/playback_service.dart';
import 'services/orientation_service.dart';
import 'user_interface/screens/orientation_screen.dart';
import 'services/sheldon_tutorial_service.dart';
import 'services/combinesSound_tutorial_service.dart';
import 'user_interface/screens/character_selection_screen.dart';
import 'services/sound_memory_service.dart';



void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  bool isMobilePlatform() {
    if (kIsWeb) {
      return false; 
    }
    if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
      return false;
    }
    return true;
  }

  if (isMobilePlatform()) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
  }

  SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: [SystemUiOverlay.bottom]);

  final audioService = AudioService();
  
  
  bool orientationShown = true; 

 
  if (isMobilePlatform()) {
    final orientationService = OrientationService();
    orientationShown = await orientationService.hasShownOrientation();
  }

  runApp(Main(audioService: audioService, orientationShown: orientationShown));
}

class Main extends StatelessWidget {
  final AudioService audioService;
  final bool orientationShown;

  const Main({
    super.key, 
    required this.audioService, 
    required this.orientationShown,
  });

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => CharacterController()),
        ChangeNotifierProvider(create: (_) => IconController()),
        ChangeNotifierProvider(create: (_) => SavedRowService()),
        Provider<AudioService>.value(value: audioService),
        ChangeNotifierProvider(
          create: (_) => PlaybackController(audioService: audioService),
        ),
        ChangeNotifierProvider(
          create: (_) => GeniusGameController(audioService: audioService),
        ),
        ChangeNotifierProvider(
          create: (_) => MemoryTutorialController(),
        ),
        ChangeNotifierProvider(
          create: (_) => GeneratorTutorialController(),
        ),
        ChangeNotifierProvider(
          create: (_) => SoundMemoryController(audioService: audioService),
        ),
        ChangeNotifierProvider(
          create: (_) => MelodyGeneratorController(audioService: audioService),
        ),
        ChangeNotifierProvider(create: (_) => ScoreHistoryService()),
        ChangeNotifierProvider(
          create: (_) => SoundMemoryTutorialController(),
        ),
        ChangeNotifierProvider(
          create: (_) => CreateMelodyTutorialController(),
        ),
      ],
      child: MaterialApp(
        title: 'MathNew',
        debugShowCheckedModeBanner: false,
        locale: const Locale('pt', 'BR'), 
        supportedLocales: const [
          Locale('pt', 'BR'),
        ],
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        home: orientationShown ? const CharacterSelectionScreen(isInitialSelection: true)  : const OrientationScreen(),
      ),
    );
  }
}