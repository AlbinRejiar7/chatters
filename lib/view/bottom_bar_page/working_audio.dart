// import 'package:flutter/material.dart';
// import 'package:social_media_recorder/audio_encoder_type.dart';
// import 'package:social_media_recorder/main.dart';
// import 'package:social_media_recorder/provider/sound_record_notifier.dart';
// import 'package:social_media_recorder/screen/social_media_recorder.dart';
// import 'package:social_media_recorder/widgets/lock_record.dart';
// import 'package:social_media_recorder/widgets/show_counter.dart';
// import 'package:social_media_recorder/widgets/show_mic_with_text.dart';
// import 'package:social_media_recorder/widgets/sound_recorder_when_locked_design.dart';
// class MyHomePage extends StatefulWidget {
//   const MyHomePage({Key? key}) : super(key: key);
//   @override
//   _MyHomePageState createState() => _MyHomePageState();
// }

// class _MyHomePageState extends State<MyHomePage> {
//   @override
//   void initState() {
//     super.initState();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Center(
//         child: Padding(
//           padding: const EdgeInsets.only(top: 140, left: 4, right: 4),
//           child: Align(
//             alignment: Alignment.centerRight,
//             child: SocialMediaRecorder(
//               // maxRecordTimeInSecond: 5,
//               startRecording: () {
//                 // function called when start recording
//               },
//               stopRecording: (_time) {
//                 // function called when stop recording, return the recording time
//               },
//               sendRequestFunction: (soundFile, _time) {
//                 //  print("the current path is ${soundFile.path}");
//               },
//               encode: AudioEncoderType.AAC,
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }