import 'package:shared_preferences/shared_preferences.dart';

class OrientationService {
  // Chave para a tela de orientação inicial
  static const String _orientationShownKey = 'orientation_shown';
  
  // NOVA CHAVE para o tutorial do jogo da memória
  static const String _memoryGameTutorialShownKey = 'memory_game_tutorial_shown';

  // --- Métodos da Orientação (sem alteração) ---
  Future<bool> hasShownOrientation() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_orientationShownKey) ?? false;
  }

  Future<void> markOrientationAsShown() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_orientationShownKey, true);
  }

  // --- NOVOS MÉTODOS para o Tutorial do Jogo da Memória ---

  // Verifica se o tutorial do jogo da memória já foi mostrado
  Future<bool> hasShownMemoryGameTutorial() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_memoryGameTutorialShownKey) ?? false;
  }

  // Marca o tutorial do jogo da memória como mostrado
  Future<void> markMemoryGameTutorialAsShown() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_memoryGameTutorialShownKey, true);
  }
}