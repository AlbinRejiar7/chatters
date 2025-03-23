// import 'dart:io';

// import 'package:audio_waveforms/audio_waveforms.dart';
// import 'package:chatter/constants/sounds.dart';
// import 'package:flutter/services.dart';
// import 'package:path_provider/path_provider.dart';

// class IncomingOutgoingService {
//   late final Directory _appDirectory;
//   bool _isInitialized = false;

//   IncomingOutgoingService() {
//     _init();
//   }

//   Future<void> _init() async {
//     _appDirectory = await getApplicationDocumentsDirectory();
//     _isInitialized = true;
//   }

//   Future<void> _playSound(String assetPath, String fileName) async {
//     try {
//       if (!_isInitialized) await _init(); // Ensure the directory is ready

//       File file = File('${_appDirectory.path}/$fileName');
//       if (!file.existsSync()) {
//         final audioFile = await rootBundle.load(assetPath);
//         await file.writeAsBytes(audioFile.buffer.asUint8List());
//       }

//       // Create a new player controller for each sound
//       final PlayerController playerController = PlayerController();

//       await playerController.preparePlayer(path: file.path);
//       await playerController.startPlayer();

//       // Dispose of the player when playback finishes
//       playerController.onCompletion.listen((_) {
//         playerController.dispose();
//       });
//     } catch (e) {
//       print("Error playing sound: $e");
//     }
//   }

//   Future<void> playIncomingSound() async {
//     await _playSound(incomingMessageSound, 'incomingMessageSound.mp3');
//   }

//   Future<void> playOutgoingSound() async {
//     await _playSound(sendMessageSound, 'sendMessageSound.mp3');
//   }
// }
