import 'package:chatter/constants/sounds.dart';
import 'package:just_audio/just_audio.dart';

class AudioService {
  final AudioPlayer _player = AudioPlayer();

  Future<void> playIncomingSoundSound() async {
    try {
      await _player.setAudioSource(AudioSource.asset(incomingMessageSound));
      _player.play();
    } catch (e) {
      print("Error playing sound: $e");
    }
  }

  Future<void> playOutGoingSoundSound() async {
    try {
      await _player.setAudioSource(AudioSource.asset(sendMessageSound));
      _player.play();
    } catch (e) {
      print("Error playing sound: $e");
    }
  }

  void dispose() {
    _player.dispose();
  }
}
