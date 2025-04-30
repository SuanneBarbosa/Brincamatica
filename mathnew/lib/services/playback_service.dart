import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'audio_service.dart';
import 'character_service.dart';
import 'icon_service.dart';


class PlaybackController with ChangeNotifier {
  // Dependências
  final AudioService _audioService;

  // Estado da Reprodução
  bool _isPlaying = false;
  bool _isPaused = false;
  int _playbackIconIndex = 0;
  int? _playbackRowIndex;
  bool _cancelPlaybackSignal = false; // Sinalizador para parar loops/delays

  // Construtor - Recebe o AudioService
  PlaybackController({required AudioService audioService}) : _audioService = audioService;

  // Getters para a UI
  bool get isPlaying => _isPlaying;
  bool get isPaused => _isPaused;
  int? get playbackRowIndex => _playbackRowIndex; // A UI pode querer saber qual linha está tocando

  // --- Métodos Públicos para Controle ---

  Future<void> playOrResume(BuildContext context) async {
    // Usa o context para ler os outros controllers no momento da chamada
    final characterController = context.read<CharacterController>();
    final iconController = context.read<IconController>();
    final int currentRow = characterController.currentRowIndex;

    // Obtém e ordena os ícones da linha atual
    List<IconModel> iconsToPlay = List.from(iconController.getIconsForRow(currentRow));
    if (iconsToPlay.isEmpty) {
      _showSnackbar(context, 'Nenhum ícone na linha atual para tocar.');
      _resetPlaybackState(); // Reseta se a linha estiver vazia
      return;
    }
    iconsToPlay.sort((a, b) => a.colIndex.compareTo(b.colIndex));

    // Lógica para iniciar ou retomar
    if (_isPaused && _playbackRowIndex == currentRow) {
      // Retoma da pausa na mesma linha
      _isPaused = false;
      _isPlaying = true; // A reprodução continua ativa
      _cancelPlaybackSignal = false; // Permite que o loop continue
      notifyListeners();
      debugPrint("Playback resumed at index $_playbackIconIndex on row $_playbackRowIndex");
      _executePlaybackLoop(context, iconsToPlay); // Passa o context
    } else {
      // Inicia uma nova reprodução (ou reinicia se estava em outra linha/parado)
      await stop(); // Garante que qualquer reprodução anterior seja parada
      _playbackRowIndex = currentRow;
      _playbackIconIndex = 0;
      _isPlaying = true;
      _isPaused = false;
      _cancelPlaybackSignal = false;
      notifyListeners();
      debugPrint("Playback started on row $_playbackRowIndex");
      _executePlaybackLoop(context, iconsToPlay); // Passa o context
    }
  }

  Future<void> pause() async {
    if (!_isPlaying || _isPaused) return; // Só pausa se estiver tocando ativamente

    _isPaused = true;
    // _isPlaying continua true, indicando que a sessão de playback está ativa (mas pausada)
    _cancelPlaybackSignal = true; // Sinaliza para interromper o loop/delay atual
    await _audioService.stopAudio(); // Para o som imediatamente
    notifyListeners();
    debugPrint("Playback paused at index $_playbackIconIndex on row $_playbackRowIndex");
  }

  Future<void> stop() async {
    if (!_isPlaying && !_isPaused) return; // Já está parado

    _cancelPlaybackSignal = true; // Sinal para interromper qualquer operação pendente
    await _audioService.stopAudio(); // Para o som
    _resetPlaybackState(); // Reseta todo o estado
    notifyListeners();
    debugPrint("Playback stopped.");
  }

  // --- Lógica Interna da Reprodução ---

  void _resetPlaybackState() {
    _isPlaying = false;
    _isPaused = false;
    _playbackIconIndex = 0;
    _playbackRowIndex = null;
    _cancelPlaybackSignal = false; // Reseta o sinal ao parar completamente
    // Não notificamos listeners aqui, pois stop() e playOrResume() já fazem isso
  }

   Future<void> _executePlaybackLoop(BuildContext context, List<IconModel> icons) async {
    final characterController = context.read<CharacterController>();

    const moveDelay = Duration(milliseconds: 150);
    // *** REMOVIDO: Cálculo baseado na velocidade ***
    const soundDurationEstimate = Duration(milliseconds: 400); // Duração fixa estimada

    while (_playbackIconIndex < icons.length && _isPlaying && !_isPaused && !_cancelPlaybackSignal) {
       if (!Provider.of<CharacterController>(context, listen: false).isLayoutInitialized) {
         debugPrint("Playback stopped: Layout not initialized."); await stop(); return;
       }
       if (_playbackRowIndex != characterController.currentRowIndex) {
           debugPrint("Playback stopped: Character row changed."); await stop(); return;
       }

      final currentIcon = icons[_playbackIconIndex];
      characterController.moveToColumn(currentIcon.colIndex);
      await Future.delayed(moveDelay);
      if (_cancelPlaybackSignal || !context.mounted) break; // Verifica se ainda está montado

      _playIconSoundInternal(currentIcon.type); // Toca o som
      await Future.delayed(soundDurationEstimate); // Espera duração fixa
      if (_cancelPlaybackSignal || !context.mounted) break; // Verifica se ainda está montado

      _playbackIconIndex++;
    }

    if (context.mounted && _playbackIconIndex >= icons.length && !_isPaused) {
       debugPrint("Playback finished for row $_playbackRowIndex"); await stop();
    } else if (!context.mounted || (_cancelPlaybackSignal && !_isPaused)) {
       await stop();
    }
  }

   // Função interna para tocar som (copiada de _MathiconState)
   void _playIconSoundInternal(String type) {
    String? soundPath;
    switch (type) {
      case "EstalarDedo": soundPath = 'assets/sounds/estalarDedos.mp3'; break;
      case "BaterPalma": soundPath = 'assets/sounds/baterPalma.mp3'; break;
      case "BaterPeito": soundPath = 'assets/sounds/baterPeito.mp3'; break;
      case "BaterPerna": soundPath = 'assets/sounds/baterPerna.mp3'; break;
      case "Assobiar": soundPath = 'assets/sounds/assobiar.mp3'; break;
      case "BaterPe": soundPath = 'assets/sounds/baterPes.mp3'; break;
    }
    if (soundPath != null) {
      try {
        // Usa a instância de _audioService injetada
        _audioService.playAudio(soundPath); // Usa a velocidade atual do player
      } catch (e) {
        debugPrint("Erro ao tocar som '$soundPath' no PlaybackController: $e");
      }
    }
  }

  // Helper interno para mostrar SnackBar
  void _showSnackbar(BuildContext context, String message) {
     ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message), duration: const Duration(seconds: 2)),
     );
  }

  // --- Limpeza ---
  @override
  void dispose() {
    _cancelPlaybackSignal = true; // Garante parada em caso de dispose inesperado
    // Não precisamos dar dispose no _audioService aqui, pois ele é gerenciado externamente
    super.dispose();
  }
}

