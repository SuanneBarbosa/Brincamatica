// services/audio_service.dart

import 'package:just_audio/just_audio.dart';

class AudioService {
  // <<< ALTERAÇÃO: Renomeado para mais clareza >>>
  final AudioPlayer _mainPlayer = AudioPlayer(); 
  
  // <<< NOVO: Um player separado para sons de feedback >>>
  final AudioPlayer _feedbackPlayer = AudioPlayer();

  // Este método continuará sendo usado para os sons dos ícones do jogo
  Future<void> playAudio(String assetPath) async {
    try {
      // Garante que o player não esteja tocando outra coisa antes de carregar o novo som
      if (_mainPlayer.playing) {
        await _mainPlayer.stop();
      }
      await _mainPlayer.setAsset(assetPath);
      await _mainPlayer.play();
    } catch (e) {
      print("Erro ao tocar áudio principal: $e");
    }
  }
  
  // <<< NOVO: Método para tocar sons de feedback (certo/errado) sem interromper os outros >>>
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
    _feedbackPlayer.dispose(); // <<< ALTERAÇÃO: Não se esqueça de liberar o novo player também!
  }
}