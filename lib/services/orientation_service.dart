import 'package:shared_preferences/shared_preferences.dart';

class OrientationService {
  
  static const String _orientationShownKey = 'orientation_shown';
  static const String _memoryGameTutorialShownKey = 'memory_game_tutorial_shown';
  static const String _generatorGameTutorialShownKey = 'generator_game_tutorial_shown';
  static const String _soundMemoryTutorialShownKey = 'sound_memory_tutorial_shown';
  static const String _createMelodyTutorialShownKey = 'create_melody_tutorial_shown';
  static const String _anyTutorialGlobalKey = 'any_tutorial_global_shown';

  Future<bool> hasShownOrientation() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_orientationShownKey) ?? false;
  }

  Future<void> markOrientationAsShown() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_orientationShownKey, true);
  }

  Future<bool> hasShownMemoryGameTutorial() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_memoryGameTutorialShownKey) ?? false;
  }

  Future<void> markMemoryGameTutorialAsShown() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_memoryGameTutorialShownKey, true);
  }

  Future<bool> hasShownGeneratorGameTutorial() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_generatorGameTutorialShownKey) ?? false;
  }

  Future<void> markGeneratorGameTutorialAsShown() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_generatorGameTutorialShownKey, true);
  }

  Future<bool> hasShownSoundMemoryTutorial() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_soundMemoryTutorialShownKey) ?? false;
  }
  
  Future<void> markSoundMemoryTutorialAsShown() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_soundMemoryTutorialShownKey, true);
  }

  Future<bool> hasShownCreateMelodyTutorial() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_createMelodyTutorialShownKey) ?? false;
  }

  Future<void> markCreateMelodyTutorialAsShown() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_createMelodyTutorialShownKey, true);
  }

    Future<bool> hasShownAnyTutorialGlobal() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_anyTutorialGlobalKey) ?? false;
  }

  Future<void> markAnyTutorialAsShownGlobal() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_anyTutorialGlobalKey, true);
  }
}