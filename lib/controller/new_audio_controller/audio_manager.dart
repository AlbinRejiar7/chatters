import 'package:audio_waveforms/audio_waveforms.dart';
import 'package:chatter/services/local_chat.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../services/firebase_storage.dart';

// Audio player state management
class AudioState {
  final PlayerController playerController;
  RxString currentPosition = "00:00".obs;
  RxString audioMaxLength = "00:00".obs;
  RxBool isPlaying = false.obs;
  RxDouble downloadProgress = 0.0.obs;
  String? localAudioPath;

  AudioState(this.playerController);
}

class AudioManager extends GetxController {
  static AudioManager get instance => Get.find<AudioManager>();

  final Map<String, AudioState> audioStates = {};
  final Set<String> initializedAudioFiles = {};

  // Initialize audio state for a given firebaseAudioPath
  Future<void> initializeAudio(
      String firebaseAudioPath, bool isCurrentUser) async {
    debugPrint("Initializing audio for: $firebaseAudioPath");

    if (initializedAudioFiles.contains(firebaseAudioPath)) {
      debugPrint("Audio already initialized: $firebaseAudioPath");
      return;
    }

    initializedAudioFiles.add(firebaseAudioPath);

    final playerController = PlayerController();
    final audioState = AudioState(playerController);
    audioStates[firebaseAudioPath] = audioState;

    await _initializeAudio(firebaseAudioPath, isCurrentUser);
  }

  // Check if audio needs to be downloaded or use locally stored version
  Future<void> _initializeAudio(
      String firebaseAudioPath, bool isCurrentUser) async {
    if (!audioStates.containsKey(firebaseAudioPath)) return;

    final audioState = audioStates[firebaseAudioPath]!;

    // If current user owns the audio, use local path directly
    if (isCurrentUser) {
      audioState.localAudioPath = firebaseAudioPath;
    } else {
      audioState.localAudioPath =
          ChatStorageService.boxStorage.read(firebaseAudioPath);

      // If the audio is not saved locally, download it
      if (audioState.localAudioPath == null) {
        audioState.localAudioPath =
            await FirebaseStorageSerivce.downloadFirebaseAudio(
          firebaseAudioPath,
          (progress) => audioState.downloadProgress.value = progress,
        );

        // Save downloaded audio path
        if (audioState.localAudioPath?.isNotEmpty ?? false) {
          ChatStorageService.boxStorage
              .write(firebaseAudioPath, audioState.localAudioPath);
        }
      }
    }

    // Initialize player if local path is valid
    if (audioState.localAudioPath?.isNotEmpty ?? false) {
      await _initializePlayer(firebaseAudioPath);
    }
  }

  Future<void> _initializePlayer(String firebaseAudioPath) async {
    final audioState = audioStates[firebaseAudioPath]!;
    const style = PlayerWaveStyle();
    final samples = style.getSamplesForWidth(120.w); // Adjust waveform width

    try {
      await audioState.playerController.preparePlayer(
        path: audioState.localAudioPath!,
        noOfSamples: samples,
      );

      audioState.playerController.setFinishMode(finishMode: FinishMode.pause);

      audioState.playerController.onCurrentDurationChanged.listen((event) {
        debugPrint("$event");
        audioState.currentPosition.value = event == 0
            ? audioState.audioMaxLength.value
            : _formatDuration(event);
      });

      // Reset the player on completion
      audioState.playerController.onCompletion.listen((event) {
        audioState.isPlaying.value = false;
        audioState.playerController.seekTo(0);
      });

      int duration = await _getValidDuration(audioState.playerController);
      audioState.audioMaxLength.value = _formatDuration(duration);
      audioState.currentPosition.value = audioState.audioMaxLength.value;
    } catch (e) {
      debugPrint("Error initializing player: $e");
    }
  }

  // Play/Pause audio
  void playPause(String firebaseAudioPath) {
    if (!audioStates.containsKey(firebaseAudioPath)) return;

    final audioState = audioStates[firebaseAudioPath]!;

    if (!audioState.playerController.playerState.isPlaying) {
      _stopOtherPlayers(firebaseAudioPath);
      audioState.playerController.startPlayer();
      audioState.isPlaying.value = true;
    } else {
      audioState.playerController.pausePlayer();
      audioState.isPlaying.value = false;
    }
  }

  // Stop other playing audios when a new audio is played
  void _stopOtherPlayers(String currentPath) {
    audioStates.forEach((key, audioState) {
      if (key != currentPath && audioState.isPlaying.value) {
        audioState.playerController.pausePlayer();
        audioState.isPlaying.value = false;
      }
    });
  }

  @override
  void onClose() {
    for (var state in audioStates.values) {
      state.playerController.dispose();
    }
    super.onClose();
  }

  // Format duration to mm:ss
  String _formatDuration(int milliseconds) {
    int totalSeconds = milliseconds ~/ 1000;
    int minutes = totalSeconds ~/ 60;
    int seconds = totalSeconds % 60;
    return "${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}";
  }

  // Ensure valid duration retrieval, retrying if necessary
  Future<int> _getValidDuration(PlayerController playerController) async {
    int duration = await playerController.getDuration();
    if (duration <= 0) {
      debugPrint("Invalid duration received, retrying...");
      await Future.delayed(const Duration(milliseconds: 300));
      duration = await playerController.getDuration();
    }
    return duration;
  }
}
