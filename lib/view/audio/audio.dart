// import 'package:chatter/services/recording.dart' show AudioRecordingService;
// import 'package:flutter/material.dart';

// class AudioRecorderScreen extends StatefulWidget {
//   const AudioRecorderScreen({super.key});

//   @override
//   _AudioRecorderScreenState createState() => _AudioRecorderScreenState();
// }

// class _AudioRecorderScreenState extends State<AudioRecorderScreen> {
//   final AudioRecordingService _audioService = AudioRecordingService();
//   bool _isRecording = false;
//   bool _isPlaying = false;

//   @override
//   void initState() {
//     super.initState();
//     _audioService.initRecorder();
//   }

//   @override
//   void dispose() {
//     _audioService.dispose();
//     super.dispose();
//   }

//   void _toggleRecording() async {
//     if (_isRecording) {
//       await _audioService.stopRecording();
//     } else {
//       await _audioService.startRecording();
//     }
//     setState(() => _isRecording = !_isRecording);
//   }

//   void _togglePlayback() async {
//     if (_isPlaying) {
//       await _audioService.stopPlayback();
//     } else {
//       await _audioService.playRecording();
//     }
//     setState(() => _isPlaying = !_isPlaying);
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: Text("Audio Recorder")),
//       body: Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             ElevatedButton(
//               onPressed: _toggleRecording,
//               child: Text(_isRecording ? "Stop Recording" : "Start Recording"),
//             ),
//             SizedBox(height: 20),
//             ElevatedButton(
//               onPressed: _togglePlayback,
//               child: Text(_isPlaying ? "Stop Playback" : "Play Recording"),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
