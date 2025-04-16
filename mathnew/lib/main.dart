import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'services/character_service.dart';
import 'services/icon_service.dart';
import 'user_interface/screens/character_selection_screen.dart';
import 'services/saved_row_service.dart'; 

void main() {
 WidgetsFlutterBinding.ensureInitialized();

  SystemChrome.setPreferredOrientations([
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]);


  runApp(const Main());
}

class Main extends StatelessWidget {
  const Main({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => CharacterController()),
        ChangeNotifierProvider(create: (_) => IconController()), 
        ChangeNotifierProvider(create: (_) => SavedRowService()),
      ],
      child: const MaterialApp(
        title: 'MathIcon',
        home:CharacterSelectionScreen(),
      ),
    );
  }
}
