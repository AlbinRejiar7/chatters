// import 'dart:async';
// import 'dart:io';

// import 'package:chatter/controller/record_audio.dart';
// import 'package:flutter_sound/flutter_sound.dart';
// import 'package:get/get.dart';
// import 'package:just_audio/just_audio.dart';
// import 'package:path_provider/path_provider.dart';
// import 'package:permission_handler/permission_handler.dart';

// class AudioRecordingService {
//   final FlutterSoundRecorder _recorder = FlutterSoundRecorder();
//   final AudioPlayer _player = AudioPlayer();
//   String? _filePath;
//   StreamSubscription? _recordingSubscription;
//   Duration _recordingDuration = Duration.zero;

//   /// Getter for the recorder instance
//   FlutterSoundRecorder get recorder => _recorder;
//   String? get filePath => _filePath;

//   /// Getter for recording duration
//   Duration get recordingDuration => _recordingDuration;

//   /// Initializes the recorder and requests permissions
//   Future<void> initRecorder() async {
//     var status = await Permission.microphone.request();
//     if (status.isGranted) {
//       await _recorder.openRecorder();
//     } else {
//       throw Exception("Microphone permission not granted");
//     }
//   }

//   /// Starts recording audio with customizable parameters
//   Future<void> startRecording({
//     Codec codec = Codec.aacADTS,
//     int sampleRate = 16000,
//     int numChannels = 1,
//     int bitRate = 16000,
//     bool enableVoiceProcessing = false,
//   }) async {
//     var status = await Permission.microphone.status;
//     if (!status.isGranted) {
//       await Permission.microphone.request();
//       if (!await Permission.microphone.isGranted) {
//         throw Exception("Microphone permission not granted");
//       }
//     }

//     final directory = await getApplicationDocumentsDirectory();
//     _filePath = '${directory.path}/audio_record.aac';

//     await _recorder.startRecorder(
//       toFile: _filePath,
//       codec: codec,
//       sampleRate: sampleRate,
//       numChannels: numChannels,
//       bitRate: bitRate,
//       enableVoiceProcessing: enableVoiceProcessing,
//     );

//     // Set subscription duration before listening to onProgress
//     _recorder.setSubscriptionDuration(const Duration(milliseconds: 100));

//     // Ensure the stream is properly subscribed
//     _recordingSubscription?.cancel();
//     _recordingSubscription = _recorder.onProgress?.listen((event) {
//       _recordingDuration = event.duration;

//       Get.find<RecordAudioController>().recordingDuration.value =
//           _recordingDuration;
//       print("Recording duration: ${_recordingDuration.inSeconds} seconds");
//     });
//   }

//   /// Stops recording audio
//   Future<void> stopRecording() async {
//     var url = await _recorder.stopRecorder();

//     Get.find<RecordAudioController>().filePath.value = url ?? "";
//     _recordingSubscription?.cancel();
//   }

//   /// Plays the recorded audio if file exists
//   Future<void> playRecording() async {
//     if (_filePath != null && File(_filePath!).existsSync()) {
//       await _player.setFilePath(_filePath!);
//       await _player.play();
//     }
//   }

//   /// Stops audio playback
//   Future<void> stopPlayback() async {
//     await _player.stop();
//   }

//   /// Closes the recorder and player resources
//   Future<void> dispose() async {
//     await _recorder.closeRecorder();
//     await _player.dispose();
//     _recordingSubscription?.cancel();
//   }
// }
import 'dart:io';

import 'package:audio_waveforms/audio_waveforms.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';

import '../controller/record_audio.dart';

class AudioRecordingService {
  late final RecorderController _recorderController;
  String? _recordingPath;
  late Directory _appDirectory;
  bool _isRecording = false;
  bool _isRecordingCompleted = false;
  final Uuid _uuid = Uuid();

  AudioRecordingService() {
    _initialize();
  }

  Future<void> _initialize() async {
    _appDirectory = await getApplicationDocumentsDirectory();
    _initializeRecorderController();
  }

  void _initializeRecorderController() {
    _recorderController = RecorderController()
      ..androidEncoder = AndroidEncoder.aac
      ..androidOutputFormat = AndroidOutputFormat.mpeg4
      ..iosEncoder = IosEncoder.kAudioFormatMPEG4AAC
      ..sampleRate = 48000
      ..bitRate = 128000; // Increase bitrate to 128kbps for better quality
  }

  Future<void> startRecording() async {
    try {
      if (_isRecording) return;
      _recordingPath = "${_appDirectory.path}/recording_${_uuid.v4()}.m4a";
      await _recorderController.record(path: _recordingPath);
      _recorderController.onCurrentDuration.listen((duration) {
        Get.find<RecordAudioController>().recordingDuration.value = duration;
      });

      _isRecording = true;
    } catch (e) {
      debugPrint("Error starting recording: ${e.toString()}");
    }
  }

  Future<void> stopRecording() async {
    try {
      if (!_isRecording) return;
      _recordingPath = await _recorderController.stop(false);
      if (_recordingPath != null) {
        _isRecordingCompleted = true;
        debugPrint("Recording saved at: $_recordingPath");
        debugPrint("Recorded file size: ${File(_recordingPath!).lengthSync()}");
        Get.find<RecordAudioController>().filePath.value = _recordingPath ?? "";
        Get.find<RecordAudioController>().waveForms =
            _recorderController.waveData;
      }
    } catch (e) {
      debugPrint("Error stopping recording: ${e.toString()}");
    } finally {
      _isRecording = false;
    }
  }

  void refreshWave() {
    if (_isRecording) {
      _recorderController.refresh();
    }
  }

  void dispose() {
    _recorderController.dispose();
  }

  String? get recordingPath => _recordingPath;
  bool get isRecording => _isRecording;
  bool get isRecordingCompleted => _isRecordingCompleted;
  Duration get recordingDuration =>
      Duration(seconds: _recorderController.recordedDuration.inSeconds);
}
