import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'audio_service.dart';
import 'character_service.dart';
import 'icon_service.dart';


class PlaybackController with ChangeNotifier {
  
  final AudioService _audioService;

 
  bool _isPlaying = false;
  bool _isPaused = false;
  int _playbackIconIndex = 0;
  int? _playbackRowIndex;
  bool _cancelPlaybackSignal = false; 

  
  PlaybackController({required AudioService audioService}) : _audioService = audioService;

  
  bool get isPlaying => _isPlaying;
  bool get isPaused => _isPaused;
  int? get playbackRowIndex => _playbackRowIndex; 

  

  Future<void> playOrResume(BuildContext context) async {
   
    final characterController = context.read<CharacterController>();
    final iconController = context.read<IconController>();
    final int currentRow = characterController.currentRowIndex;

   
    List<IconModel> iconsToPlay = List.from(iconController.getIconsForRow(currentRow));
    if (iconsToPlay.isEmpty) {
      _showSnackbar(context, 'Nenhum ícone na linha atual para tocar.');
      _resetPlaybackState(); 
      return;
    }
    iconsToPlay.sort((a, b) => a.colIndex.compareTo(b.colIndex));

   
    if (_isPaused && _playbackRowIndex == currentRow) {
   
      _isPaused = false;
      _isPlaying = true; 
      _cancelPlaybackSignal = false; 
      notifyListeners();
      debugPrint("Playback resumed at index $_playbackIconIndex on row $_playbackRowIndex");
      _executePlaybackLoop(context, iconsToPlay); 
    } else {
    
      await stop(); 
      _playbackRowIndex = currentRow;
      _playbackIconIndex = 0;
      _isPlaying = true;
      _isPaused = false;
      _cancelPlaybackSignal = false;
      notifyListeners();
      debugPrint("Playback started on row $_playbackRowIndex");
      _executePlaybackLoop(context, iconsToPlay);
    }
  }

  Future<void> pause() async {
    if (!_isPlaying || _isPaused) return; 

    _isPaused = true;
    
    _cancelPlaybackSignal = true; 
    await _audioService.stopAudio(); 
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

  

  void _resetPlaybackState() {
    _isPlaying = false;
    _isPaused = false;
    _playbackIconIndex = 0;
    _playbackRowIndex = null;
    _cancelPlaybackSignal = false;
   
  }

   Future<void> _executePlaybackLoop(BuildContext context, List<IconModel> icons) async {
    final characterController = context.read<CharacterController>();

    const moveDelay = Duration(milliseconds: 150);
    
    const soundDurationEstimate = Duration(milliseconds: 400); 

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
      if (_cancelPlaybackSignal || !context.mounted) break; 

      _playIconSoundInternal(currentIcon.type); 
      await Future.delayed(soundDurationEstimate); 
      if (_cancelPlaybackSignal || !context.mounted) break; 

      _playbackIconIndex++;
    }

    if (context.mounted && _playbackIconIndex >= icons.length && !_isPaused) {
       debugPrint("Playback finished for row $_playbackRowIndex"); await stop();
    } else if (!context.mounted || (_cancelPlaybackSignal && !_isPaused)) {
       await stop();
    }
  }

 
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
       
        _audioService.playAudio(soundPath);
      } catch (e) {
        debugPrint("Erro ao tocar som '$soundPath' no PlaybackController: $e");
      }
    }
  }

  
  void _showSnackbar(BuildContext context, String message) {
     ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message), duration: const Duration(seconds: 2)),
     );
  }

  
  @override
  void dispose() {
    _cancelPlaybackSignal = true; 
    super.dispose();
  }
}

