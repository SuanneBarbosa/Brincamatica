import 'package:just_audio/just_audio.dart';

class AudioService {
  final AudioPlayer _mainPlayer = AudioPlayer(); 
  final AudioPlayer _feedbackPlayer = AudioPlayer();

  Future<void> playAudio(String assetPath) async {
    try {
      await _mainPlayer.setAsset(assetPath);
      await _mainPlayer.play();
    } catch (e) {
      print("Erro ao tocar áudio principal: $e");
    }
  }
  
  Future<void> playFeedbackAudio(String assetPath) async {
    try {
      await _feedbackPlayer.setAsset(assetPath);
      await _feedbackPlayer.play();
    } catch (e) {
      print("Erro ao tocar áudio de feedback: $e");
    }
  }

  Future<void> stopAudio() async {
    try {
      await _mainPlayer.stop();
    } catch (e) {
      print("Erro ao parar áudio: $e");
    }
  }

  void dispose() {
    _mainPlayer.dispose(); 
    _feedbackPlayer.dispose(); 
  }
}