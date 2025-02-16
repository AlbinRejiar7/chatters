import 'dart:developer';

import 'package:chatter/services/recording.dart';
import 'package:get/get.dart';

class RecordAudioController extends GetxController {
  final AudioRecordingService _audioService = AudioRecordingService();
  var isRecording = false.obs;
  var isPlaying = false.obs;
  var recordingDuration = Duration.zero.obs;
  var filePath = ''.obs;
  @override
  void onInit() {
    super.onInit();
    _audioService.initRecorder();
  }

  @override
  void onClose() {
    _audioService.dispose();
    super.onClose();
  }

  Future toggleRecording() async {
    if (isRecording.value) {
      await _audioService.stopRecording();
      // filePath.value = _audioService.filePath ?? "";
    } else {
      await _audioService.startRecording();
    }
    isRecording.value = !isRecording.value;
  }

  void togglePlayback() async {
    if (isPlaying.value) {
      log("Recording duration: ${_audioService.recordingDuration.inSeconds} seconds");
      await _audioService.stopPlayback();
    } else {
      log("Recording duration: ${_audioService.recordingDuration.inSeconds} seconds");
      await _audioService.playRecording();
    }
    isPlaying.value = !isPlaying.value;
  }
}
