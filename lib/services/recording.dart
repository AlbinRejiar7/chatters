import 'dart:async';
import 'dart:io';

import 'package:chatter/controller/record_audio.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:get/get.dart';
import 'package:just_audio/just_audio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

class AudioRecordingService {
  final FlutterSoundRecorder _recorder = FlutterSoundRecorder();
  final AudioPlayer _player = AudioPlayer();
  String? _filePath;
  StreamSubscription? _recordingSubscription;
  Duration _recordingDuration = Duration.zero;

  /// Getter for the recorder instance
  FlutterSoundRecorder get recorder => _recorder;
  String? get filePath => _filePath;

  /// Getter for recording duration
  Duration get recordingDuration => _recordingDuration;

  /// Initializes the recorder and requests permissions
  Future<void> initRecorder() async {
    var status = await Permission.microphone.request();
    if (status.isGranted) {
      await _recorder.openRecorder();
    } else {
      throw Exception("Microphone permission not granted");
    }
  }

  /// Starts recording audio with customizable parameters
  Future<void> startRecording({
    Codec codec = Codec.aacADTS,
    int sampleRate = 16000,
    int numChannels = 1,
    int bitRate = 16000,
    bool enableVoiceProcessing = false,
  }) async {
    var status = await Permission.microphone.status;
    if (!status.isGranted) {
      await Permission.microphone.request();
      if (!await Permission.microphone.isGranted) {
        throw Exception("Microphone permission not granted");
      }
    }

    final directory = await getApplicationDocumentsDirectory();
    _filePath = '${directory.path}/audio_record.aac';

    await _recorder.startRecorder(
      toFile: _filePath,
      codec: codec,
      sampleRate: sampleRate,
      numChannels: numChannels,
      bitRate: bitRate,
      enableVoiceProcessing: enableVoiceProcessing,
    );

    // Set subscription duration before listening to onProgress
    _recorder.setSubscriptionDuration(const Duration(milliseconds: 100));

    // Ensure the stream is properly subscribed
    _recordingSubscription?.cancel();
    _recordingSubscription = _recorder.onProgress?.listen((event) {
      _recordingDuration = event.duration;

      Get.find<RecordAudioController>().recordingDuration.value =
          _recordingDuration;
      print("Recording duration: ${_recordingDuration.inSeconds} seconds");
    });
  }

  /// Stops recording audio
  Future<void> stopRecording() async {
    var url = await _recorder.stopRecorder();

    Get.find<RecordAudioController>().filePath.value = url ?? "";
    _recordingSubscription?.cancel();
  }

  /// Plays the recorded audio if file exists
  Future<void> playRecording() async {
    if (_filePath != null && File(_filePath!).existsSync()) {
      await _player.setFilePath(_filePath!);
      await _player.play();
    }
  }

  /// Stops audio playback
  Future<void> stopPlayback() async {
    await _player.stop();
  }

  /// Closes the recorder and player resources
  Future<void> dispose() async {
    await _recorder.closeRecorder();
    await _player.dispose();
    _recordingSubscription?.cancel();
  }
}
