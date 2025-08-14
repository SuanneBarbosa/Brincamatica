import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'services/character_service.dart';
import 'services/icon_service.dart';
import 'user_interface/screens/character_selection_screen.dart';
import 'services/saved_row_service.dart';
import 'services/audio_service.dart';
import 'services/playback_service.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  SystemChrome.setPreferredOrientations([
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]);

  final audioService = AudioService();

  runApp(Main(audioService: audioService));
}

class Main extends StatelessWidget {
  final AudioService audioService;

  const Main({super.key, required this.audioService});

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
      ],
      child: const MaterialApp(
        title: 'MathIcon',
        debugShowCheckedModeBanner: false,
        home: CharacterSelectionScreen(),
      ),
    );
  }
}
