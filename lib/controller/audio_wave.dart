import 'package:audio_waveforms/audio_waveforms.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

/// Controller for handling audio playback within a chat interface.
/// It manages the waveform visualization and playback of recorded audio messages
class WaveBubbleController extends GetxController {
  late PlayerController playerController;
  var currentPosition = 0.obs;
  final String? path;

  WaveBubbleController({this.path});
  var isPlaying = false.obs;

  @override
  void onInit() {
    super.onInit();
    playerController = PlayerController();
    // Listen for player state changes to update UI.

    playerController.onPlayerStateChanged.listen((_) {
      update();
    });
    // Listen for current playback position updates.

    playerController.onCurrentDurationChanged.listen((position) {
      currentPosition.value = position;
    });
    _preparePlayer();
  }

  /// Prepares the audio player by setting the file path and extracting waveform data.

  void _preparePlayer() async {
    if (path != null) {
      const style = PlayerWaveStyle();
      final samples = style.getSamplesForWidth(130.w);
      playerController.preparePlayer(
          path: path!, shouldExtractWaveform: true, noOfSamples: samples);
      playerController.setFinishMode(finishMode: FinishMode.pause);
    }
  }

  /// Updates the playing state of the audio player.

  void setIsPlaying(bool value) {
    isPlaying.value = value;
  }

  @override
  void onClose() {
    playerController.dispose();
    super.onClose();
  }

  /// Formats the duration from milliseconds to `mm:ss` format.

  String formatDuration(int milliseconds) {
    int seconds = (milliseconds / 1000).truncate();
    int minutes = (seconds / 60).truncate();
    seconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }
}
