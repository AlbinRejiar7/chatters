import 'dart:io';

import 'package:chatter/constants/colors.dart';
import 'package:chatter/utils/seconds.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

class VoiceBubble extends StatefulWidget {
  final String downloadUrl;

  const VoiceBubble({super.key, required this.downloadUrl});

  @override
  State<VoiceBubble> createState() => _VoiceBubbleState();
}

class _VoiceBubbleState extends State<VoiceBubble>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animationController;
  final AudioPlayer _audioPlayer = AudioPlayer();
  bool _isDownloading = false;
  double _downloadProgress = 0.0;
  String? _localFilePath;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    _checkIfFileExists();
    _audioPlayer.playerStateStream.listen((state) async {
      if (state.processingState == ProcessingState.completed) {
        _animationController.reverse();
        await _audioPlayer.pause();
        _audioPlayer.seek(Duration.zero); // Reset player position
      }
    });
  }

  /// Checks if the file is already downloaded and sets the player source.
  Future<void> _checkIfFileExists() async {
    final directory = Platform.isAndroid
        ? await getExternalStorageDirectory()
        : await getApplicationDocumentsDirectory();

    final filePath = '${directory!.path}/downloaded_audio.mp3';
    if (File(filePath).existsSync()) {
      setState(() {
        _localFilePath = filePath;
      });
      await _audioPlayer.setFilePath(filePath);
    }
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _togglePlayPause() async {
    if (_localFilePath == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please download the audio first')),
      );
      return;
    }

    if (_audioPlayer.playing) {
      _animationController.reverse();
      await _audioPlayer.pause();
    } else {
      _animationController.forward();
      await _audioPlayer.play();
    }
  }

  Future<void> _downloadAudio() async {
    if (_isDownloading) return;

    setState(() {
      _isDownloading = true;
      _downloadProgress = 0.0;
    });

    if (await Permission.storage.request().isGranted) {
      try {
        final directory = Platform.isAndroid
            ? await getExternalStorageDirectory()
            : await getApplicationDocumentsDirectory();

        final filePath = '${directory!.path}/downloaded_audio.mp3';

        await Dio().download(
          widget.downloadUrl,
          filePath,
          onReceiveProgress: (count, total) {
            setState(() {
              _downloadProgress = count / total;
            });
          },
        );

        setState(() {
          _localFilePath = filePath;
          _isDownloading = false;
        });

        await _audioPlayer.setFilePath(filePath);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Download complete: $filePath')),
        );
      } catch (e) {
        setState(() {
          _isDownloading = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Download failed: $e')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Storage permission denied')),
      );

      setState(() {
        _isDownloading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<Duration>(
      stream: _audioPlayer.positionStream,
      builder: (context, snapshot) {
        final position = snapshot.data ?? Duration.zero;
        final duration = _audioPlayer.duration ?? Duration.zero;

        return Row(
          children: [
            IconButton(
              color: AppColors.whiteColor,
              onPressed: _togglePlayPause,
              icon: AnimatedIcon(
                icon: AnimatedIcons.play_pause,
                progress: _animationController,
              ),
            ),
            Flexible(
              flex: 3,
              child: Slider.adaptive(
                inactiveColor: AppColors.whiteColor,
                activeColor: AppColors.whiteColor,
                min: 0,
                max: duration.inSeconds.toDouble(),
                value: position.inSeconds
                    .toDouble()
                    .clamp(0.0, duration.inSeconds.toDouble()),
                onChanged: (value) =>
                    _audioPlayer.seek(Duration(seconds: value.toInt())),
              ),
            ),
            Flexible(
                flex: 1,
                child: Text(
                  formatDuration(snapshot.data ?? duration),
                  style: const TextStyle(color: AppColors.whiteColor),
                )),
            if (_localFilePath ==
                null) // Hide download button if already downloaded
              Stack(
                alignment: Alignment.center,
                children: [
                  IconButton(
                    icon:
                        const Icon(Icons.download, color: AppColors.whiteColor),
                    onPressed: _downloadAudio,
                  ),
                  if (_isDownloading)
                    SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        value: _downloadProgress,
                        strokeWidth: 2,
                        color: AppColors.whiteColor,
                      ),
                    ),
                ],
              ),
          ],
        );
      },
    );
  }
}
