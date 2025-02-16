import 'dart:convert';

import 'package:audio_waveforms/audio_waveforms.dart';
import 'package:chatter/services/local_chat.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../services/firebase_storage.dart';

//audio states of the audio player
class AudioState {
  final PlayerController playerController;
  RxString currentPosition = "00:00".obs;
  RxString audioMaxLength = "00:00".obs;
  RxBool isPlaying = false.obs;
  RxDouble downloadProgress = 0.0.obs;
  List<double>? waveformData;
  String? localAudioPath;

  AudioState(this.playerController);
}

class AudioManager extends GetxController {
  static AudioManager get instance => Get.find<AudioManager>();

  final Map<String, AudioState> audioStates = {};
//to init the states of the audios
  Future<void> initializeAudio(String firebaseAudioPath) async {
    debugPrint("Initializing audio for: $firebaseAudioPath");

    if (audioStates.containsKey(firebaseAudioPath)) {
      debugPrint("Audio already initialized for: $firebaseAudioPath");
      return;
    }

    final playerController = PlayerController();
    final audioState = AudioState(playerController);
    audioStates[firebaseAudioPath] = audioState;

    await _initializeAudio(firebaseAudioPath);
  }

//to check if we need to download the audio or play from saved ones
  Future<void> _initializeAudio(String firebaseAudioPath) async {
    final audioState = audioStates[firebaseAudioPath]!;
    audioState.localAudioPath =
        ChatStorageService.boxStorage.read(firebaseAudioPath);

    if (audioState.localAudioPath == null) {
      audioState.localAudioPath =
          await FirebaseStorageSerivce.downloadFirebaseAudio(
        firebaseAudioPath,
        (progress) {
          audioState.downloadProgress.value = progress;
        },
      );

      if (audioState.localAudioPath != null) {
        ChatStorageService.boxStorage
            .write(firebaseAudioPath, audioState.localAudioPath);
      }
    }

    if (audioState.localAudioPath != null) {
      await _loadWaveformData(firebaseAudioPath);
      await _initializePlayer(firebaseAudioPath);
    }
  }

//load wave data from storage or create new one
  Future<void> _loadWaveformData(String firebaseAudioPath) async {
    final audioState = audioStates[firebaseAudioPath]!;
    const style = PlayerWaveStyle();
    final samples = style.getSamplesForWidth(127.w);
//to get the stored wave form
    String? waveformString =
        ChatStorageService.boxStorage.read("${firebaseAudioPath}_waveform");
//create a new wave from if there is no stored one
    if (waveformString == null) {
      debugPrint("CREATING NEW WAVEFORM...");
      audioState.waveformData =
          await audioState.playerController.extractWaveformData(
        path: audioState.localAudioPath!,
        noOfSamples: samples,
      );
      //add new wave form to storage
      ChatStorageService.boxStorage.write(
          "${firebaseAudioPath}_waveform", jsonEncode(audioState.waveformData));
    } else {
      debugPrint("FETCHING EXISTING WAVEFORM...");
      audioState.waveformData = List<double>.from(jsonDecode(waveformString));
    }
  }

//initialise the player controller with essential stuffs
  Future<void> _initializePlayer(String firebaseAudioPath) async {
    final audioState = audioStates[firebaseAudioPath]!;
    const style = PlayerWaveStyle();
    final samples = style.getSamplesForWidth(
        130); //to make the waves exaclty slideable with fitted width

    await audioState.playerController.preparePlayer(
      path: audioState.localAudioPath!,
      noOfSamples: samples,
    );

    audioState.playerController.setFinishMode(finishMode: FinishMode.pause);

    audioState.playerController.onCurrentDurationChanged.listen((event) {
      debugPrint("$event");
      audioState.currentPosition.value =
          event == 0 ? audioState.audioMaxLength.value : _formatDuration(event);
    });
//reset the player on compeletion
    audioState.playerController.onCompletion.listen((event) {
      audioState.isPlaying.value = false;
      audioState.playerController.seekTo(0);
    });

    int duration = await audioState.playerController.getDuration();
    if (duration <= 0) {
      debugPrint("Invalid duration received, retrying...");
      await Future.delayed(const Duration(milliseconds: 300));
      duration = await audioState.playerController.getDuration();
    }
    audioState.audioMaxLength.value = _formatDuration(duration);
    audioState.currentPosition.value = audioState.audioMaxLength.value;
  }

//to control the play/pause
  void playPause(String firebaseAudioPath) {
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

//to stop other players if any one of the new player is playing
  void _stopOtherPlayers(String currentPath) {
    for (var key in audioStates.keys) {
      if (key != currentPath && audioStates[key]!.isPlaying.value) {
        audioStates[key]!.playerController.pausePlayer();
        audioStates[key]!.isPlaying.value = false;
      }
    }
  }

  @override
  void onClose() {
    for (var state in audioStates.values) {
      state.playerController.dispose();
    }
    super.onClose();
  }

//format to 00:00 format
  String _formatDuration(int milliseconds) {
    int totalSeconds = milliseconds ~/ 1000;
    int minutes = totalSeconds ~/ 60;
    int seconds = totalSeconds % 60;
    return "${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}";
  }
}
