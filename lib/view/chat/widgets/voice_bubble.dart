import 'package:audio_waveforms/audio_waveforms.dart';
import 'package:chatter/constants/colors.dart';
import 'package:chatter/controller/new_audio_controller/audio_manager.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:visibility_detector/visibility_detector.dart';

class AudioBubble extends StatelessWidget {
  final String firebaseAudioPath;
  final bool isBlackColor;
  final List<double> waveData;
  final bool isCurrentUser;
  const AudioBubble(
      {super.key,
      required this.firebaseAudioPath,
      required this.isBlackColor,
      required this.waveData,
      required this.isCurrentUser});
  @override
  Widget build(BuildContext context) {
    final AudioManager audioManager = Get.find<AudioManager>();

    audioManager.initializeAudio(firebaseAudioPath, isCurrentUser);

    return VisibilityDetector(
      key: Key(firebaseAudioPath),
      onVisibilityChanged: (visibilityInfo) {},
      child: Obx(() {
        final audioState = audioManager.audioStates[firebaseAudioPath];

        if (audioState == null) {
          return const SizedBox(
            width: 40,
            height: 40,
            child: CircularProgressIndicator(strokeWidth: 1.8),
          );
        }

        return SizedBox(
          height: 40,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              (audioState.localAudioPath == null)
                  ? Text(
                      "${audioState.downloadProgress.value.toInt()}%",
                      style: TextStyle(
                          color: isBlackColor
                              ? AppColors.darkColor
                              : AppColors.whiteColor),
                    )
                  : IconButton(
                      onPressed: () =>
                          audioManager.playPause(firebaseAudioPath),
                      icon: Icon(
                        audioState.isPlaying.value
                            ? Icons.pause_circle_outline
                            : Icons.play_circle_outline,
                      ),
                      color: isBlackColor ? AppColors.darkColor : Colors.white,
                    ),
              AudioFileWaveforms(
                padding: EdgeInsets.symmetric(vertical: 7.h),
                waveformData: waveData,
                waveformType: WaveformType.long,
                playerWaveStyle: PlayerWaveStyle(
                  seekLineColor:
                      isBlackColor ? Colors.blue.shade200 : Colors.white54,
                  waveCap: StrokeCap.square,
                  fixedWaveColor:
                      isBlackColor ? Colors.blue.shade200 : Colors.white54,
                  liveWaveColor:
                      isBlackColor ? AppColors.primaryColor : Colors.white,
                  waveThickness: 2,
                  spacing: 6,
                ),
                playerController: audioState.playerController,
                size: const Size(150, 50),
              ),
              Text(
                audioState.currentPosition.value,
                style: TextStyle(
                    color: isBlackColor
                        ? AppColors.darkColor
                        : AppColors.whiteColor),
              ),
            ],
          ),
        );
      }),
    );
  }
}

// class AudioBubble extends StatefulWidget {
//   final String firebaseAudioPath;

//   const AudioBubble({super.key, required this.firebaseAudioPath});
//   @override
//   State<AudioBubble> createState() => _AudioBubbleState();
// }

// class _AudioBubbleState extends State<AudioBubble> {
//   late PlayerController playerController;
//   String currentPosition = "00:00";
//   String audioMaxLength = "00:00";
//   bool isPlaying = false;
//   double downloadProgress = 0.0;
//   String? localAudioPath;
//   List<double>? waveformData;
//   @override
//   void initState() {
//     super.initState();
//     playerController = PlayerController();
//     _initializeAudio();
//   }

//   Future<void> _initializeAudio() async {
//     localAudioPath = storage.read(widget.firebaseAudioPath);

//     if (localAudioPath == null) {
//       localAudioPath = await SendAudioService.downloadFirebaseAudio(
//         widget.firebaseAudioPath,
//         (progress) {
//           downloadProgress = progress;
//           if (mounted) setState(() {});
//         },
//       );
//       if (localAudioPath != null) {
//         storage.write(widget.firebaseAudioPath, localAudioPath);
//       }
//     }

//     if (localAudioPath != null) {
//       // Extract waveform before initializing player
//       await _loadWaveformData();
//       await initializePlayer();
//     }
//   }

//   Future<void> _loadWaveformData() async {
//     const style = PlayerWaveStyle();
//     final samples = style.getSamplesForWidth(130.w);

//     String? waveformString =
//         storage.read("${widget.firebaseAudioPath}_waveform");

//     if (waveformString == null) {
//       log("CREATING NEW WAVEFORM..............");
//       waveformData = await playerController.extractWaveformData(
//         path: localAudioPath!,
//         noOfSamples: samples,
//       );
//       storage.write(
//           "${widget.firebaseAudioPath}_waveform", jsonEncode(waveformData));
//     } else {
//       log("FETCHING ALREADY THERE WAVEFORM..............");
//       waveformData = List<double>.from(jsonDecode(waveformString));
//     }

//     if (mounted) setState(() {});
//   }

//   Future<void> initializePlayer() async {
//     const style = PlayerWaveStyle();
//     final samples = style.getSamplesForWidth(130.w);

//     await playerController.preparePlayer(
//       path: localAudioPath!,
//       noOfSamples: samples,
//     );
//     String? waveformString =
//         storage.read("${widget.firebaseAudioPath}_waveform");

//     if (waveformString == null) {
//       log("CREATING NEW WAVEFORM..............");
//       waveformData = await playerController.extractWaveformData(
//         path: localAudioPath!,
//         noOfSamples: samples,
//       );
//       storage.write(
//           "${widget.firebaseAudioPath}_waveform", jsonEncode(waveformData));
//     }

//     if (waveformString != null) {
//       log("FETCHING ALREADY THERE  WAVEFORM..............");
//       // Decode the stored waveform data
//       waveformData = List<double>.from(jsonDecode(waveformString));
//     }

//     playerController.setFinishMode(finishMode: FinishMode.pause);

//     playerController.onCurrentDurationChanged.listen((event) async {
//       if (!mounted) return;
//       currentPosition = formatDuration(event);
//       if (event == 0) {
//         currentPosition = audioMaxLength;
//       }
//       if (mounted) setState(() {});
//     });

//     playerController.onCompletion.listen((event) {
//       if (!mounted) return;
//       if (mounted) {
//         setState(() {
//           playerController.seekTo(0);
//           isPlaying = false;
//         });
//       }
//     });

//     int duration = await playerController.getDuration();
//     if (mounted) {
//       setState(() {
//         audioMaxLength = formatDuration(duration);
//         currentPosition = audioMaxLength;
//       });
//     }
//   }

//   void playPause() {
//     if (!playerController.playerState.isPlaying) {
//       playerController.startPlayer();
//       if (mounted) {
//         setState(() {
//           isPlaying = true;
//         });
//       }
//     } else {
//       playerController.pausePlayer();
//       if (mounted) {
//         setState(() {
//           isPlaying = false;
//         });
//       }
//     }
//   }

//   String convertToPercentage(double progress) {
//     return "${progress.toInt()}%";
//   }

//   String formatDuration(int milliseconds) {
//     int totalSeconds = milliseconds ~/ 1000;
//     int minutes = totalSeconds ~/ 60;
//     int seconds = totalSeconds % 60;
//     return "${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}";
//   }

//   @override
//   void dispose() {
//     playerController.onCurrentDurationChanged.drain(); // Clears the stream
//     playerController.onCompletion.drain();
//     playerController.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Row(
//       children: [
//         Container(
//           width: 240.w,
//           height: 40,
//           padding: EdgeInsets.symmetric(horizontal: 10.h),
//           decoration: BoxDecoration(
//             borderRadius: BorderRadius.circular(20),
//             color: nineAGrey,
//           ),
//           child: Row(
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             children: [
//               (localAudioPath == null)
//                   ? Text(
//                       convertToPercentage(downloadProgress),
//                       style: TextStyles.toastText,
//                     )
//                   : InkWell(
//                       onTap: playPause,
//                       child: Icon(
//                         isPlaying
//                             ? Icons.pause_circle_outline
//                             : Icons.play_circle_outline,
//                         color: Colors.white,
//                       ),
//                     ),
//               if (waveformData != null)
//                 AudioFileWaveforms(
//                   waveformData: waveformData!,
//                   waveformType: WaveformType.fitWidth,
//                   playerWaveStyle: const PlayerWaveStyle(
//                     fixedWaveColor: Colors.white54,
//                     liveWaveColor: Colors.white,
//                     spacing: 6,
//                   ),
//                   playerController: playerController,
//                   size: Size(150.w, 50.h),
//                 )
//               else
//                 SizedBox(
//                   width: 20.w, // Adjust the size as needed
//                   height: 20.w,
//                   child: CircularProgressIndicator(
//                     strokeWidth: 2.5, // Adjust the thickness
//                     color: Colors.white, // Customize the color
//                   ),
//                 ),
//               Text(
//                 currentPosition,
//                 style: TextStyles.toastText,
//               ),
//             ],
//           ),
//         ),
//       ],
//     );
//   }
// }
