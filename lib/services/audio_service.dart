import 'package:audioplayers/audioplayers.dart';
import 'prefs_service.dart';

class AudioService {
  static final AudioPlayer _player = AudioPlayer();

  static Future<void> playCorrect() async {
    if (await PrefsService.isSoundEnabled()) {
      await _player.play(AssetSource('sounds/correct.mp3'));
    }
  }

  static Future<void> playWrong() async {
    if (await PrefsService.isSoundEnabled()) {
      await _player.play(AssetSource('sounds/wrong.mp3'));
    }
  }
}
