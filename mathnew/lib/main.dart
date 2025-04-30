import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'services/character_service.dart';
import 'services/icon_service.dart';
import 'user_interface/screens/character_selection_screen.dart';
import 'services/saved_row_service.dart';
import 'services/audio_service.dart'; // <<< IMPORTAR AudioService
import 'services/playback_service.dart'; // <<< IMPORTAR PlaybackController

void main() {
  // Garante que os bindings do Flutter estejam inicializados antes de mais nada
  WidgetsFlutterBinding.ensureInitialized();

  // Define as orientações preferidas para paisagem
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]);

  // Cria a instância ÚNICA do AudioService que será compartilhada
  final audioService = AudioService();

  // Inicia o aplicativo Flutter, passando a instância do AudioService
  runApp(Main(audioService: audioService));
}

class Main extends StatelessWidget {
  // Propriedade para receber a instância do AudioService
  final AudioService audioService;

  // Construtor que recebe o AudioService
  const Main({super.key, required this.audioService});

  @override
  Widget build(BuildContext context) {
    // MultiProvider para disponibilizar todos os serviços/controllers para a árvore de widgets
    return MultiProvider(
      providers: [
        // ChangeNotifierProvider para o CharacterController
        ChangeNotifierProvider(create: (_) => CharacterController()),

        // ChangeNotifierProvider para o IconController
        ChangeNotifierProvider(create: (_) => IconController()),

        // ChangeNotifierProvider para o SavedRowService (já existente)
        ChangeNotifierProvider(create: (_) => SavedRowService()),

        // *** ADICIONADO: Provider para o AudioService ***
        // Usamos Provider.value aqui porque já criamos a instância em main()
        // Isso garante que a mesma instância seja usada em todo o app.
        Provider<AudioService>.value(value: audioService),

        // *** ADICIONADO: ChangeNotifierProvider para o PlaybackController ***
        // Ele é criado aqui e recebe a instância do AudioService via construtor.
        // Como ele usa 'with ChangeNotifier', usamos ChangeNotifierProvider.
        ChangeNotifierProvider(
          create: (_) => PlaybackController(audioService: audioService),
        ),
      ],
      // O MaterialApp é o filho do MultiProvider, então todos os widgets dentro dele
      // terão acesso aos providers definidos acima usando Provider.of<T>(context) ou context.read<T>() / context.watch<T>()
      child: const MaterialApp(
        title: 'MathIcon', // Título do aplicativo
        debugShowCheckedModeBanner: false, // Opcional: remove o banner de debug
        // Tela inicial do aplicativo
        home: CharacterSelectionScreen(),
      ),
    );
  }
}