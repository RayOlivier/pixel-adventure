import 'dart:async';

import 'package:flame/components.dart';
import 'package:just_audio/just_audio.dart';
import 'package:pixel_adventure/pixel_adventure.dart';

class AudioManager extends Component with HasGameRef<PixelAdventure> {
  final bgmPlayer = AudioPlayer();
  final _audioPlayer = AudioPlayer();
  static String basePath = 'assets/audio/';
  static String musicPath = 'assets/audio/music/';
  final fruitCollectPlayer = SfxPlayer('${basePath}collectFruit.wav');

  @override
  FutureOr<void> onLoad() async {
    await bgmPlayer.setAsset('${musicPath}forest.mp3');
    bgmPlayer.setLoopMode(LoopMode.all);

    return super.onLoad();
  }

  @override
  void onMount() {
    // TODO: implement onMount
    super.onMount();
  }

  void playOnce(String fileName) async {
    await _audioPlayer.setAsset(basePath + fileName);
    _audioPlayer.play();
  }

  void playMusic() async {
    bgmPlayer.play();
  }

  void pauseMusic() {
    bgmPlayer.pause();
  }
}

// SFX Player for reused sounds
class SfxPlayer {
  static final _sfxPlayer = AudioPlayer();
  String assetPath;

  SfxPlayer(
    this.assetPath,
  ) {
    _sfxPlayer.setAsset(assetPath); // could cause issues without await
  }

  void play() {
    _sfxPlayer.play();
    _sfxPlayer.load(); // load to be played again
  }
}
