import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
// NOVOS IMPORTS PARA VERIFICAÇÃO DE PLATAFORMA
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:io' show Platform;

// Seus imports existentes
import 'services/memory_game_service.dart';
import 'user_interface/screens/home_screen.dart'; 
import 'services/character_service.dart';
import 'services/icon_service.dart';
import 'services/saved_row_service.dart';
import 'services/audio_service.dart';
import 'services/playback_service.dart';
import 'services/orientation_service.dart';
import 'user_interface/screens/orientation_screen.dart';
import 'services/memory_tutorial_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Função para verificar se a plataforma é mobile
  bool isMobilePlatform() {
    if (kIsWeb) {
      return false; // Não é mobile se for web
    }
    // Verifica se é um SO de desktop
    if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
      return false;
    }
    // Assume que o resto (Android, iOS, Fuchsia) é mobile
    return true;
  }

  // A orientação da tela só deve ser forçada em plataformas móveis
  if (isMobilePlatform()) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
  }

  SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: [SystemUiOverlay.bottom]);

  final audioService = AudioService();
  
  // ====================== MUDANÇA AQUI ======================
  bool orientationShown = true; // Assume por padrão que a tela não precisa ser mostrada

  // Só verifica e mostra a tela de orientação se for uma plataforma móvel
  if (isMobilePlatform()) {
    final orientationService = OrientationService();
    orientationShown = await orientationService.hasShownOrientation();
  }
  // ==========================================================

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
      ],
      child: MaterialApp(
        title: 'MathIcon',
        debugShowCheckedModeBanner: false,
        home: orientationShown ? const HomeScreen() : const OrientationScreen(),
      ),
    );
  }
}