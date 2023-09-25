import 'dart:async';

import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/flame.dart';
import 'package:flame/game.dart';
// import 'package:flame_audio/flame_audio.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/widgets.dart';
import 'package:pixel_adventure/components/jump_button.dart';
import 'package:pixel_adventure/components/player.dart';
import 'package:pixel_adventure/components/level/level.dart';
import 'package:just_audio/just_audio.dart';

enum GameState { isPaused, isPlaying, isGameOver, isMainMenu }

class PixelAdventure extends FlameGame
    with
        HasKeyboardHandlerComponents,
        DragCallbacks,
        TapCallbacks,
        HasCollisionDetection {
  @override
  Color backgroundColor() => const Color(0xFF211F30);

  late CameraComponent cam;
  late Level world;
  JumpButton jumpButton = JumpButton();
  Player player = Player(character: 'Ninja Frog');
  late JoystickComponent joystick;

  ValueNotifier<bool> playSounds = ValueNotifier(true);
  ValueNotifier<bool> playMusic = ValueNotifier(true);
  ValueNotifier<bool> useMobileControls = ValueNotifier(true);

  double soundVolume = 0.5;
  double musicVolume = 0.01;

  List<String> levelNames = ['level-01', 'level-02'];

  int currentLevelIndex = 0;

  // final audioPlayer = AudioPlayer();
  late AudioPlayer justAudioPlayer = AudioPlayer();
  late AudioPlayer justAudioPlayerFruit = AudioPlayer();

  // late AudioPlayer jumpPlayer = AudioPlayer();
  // late AudioPlayer disappearPlayer = AudioPlayer();
  // late AudioPlayer collectPlayer = AudioPlayer();

  @override
  FutureOr<void> onLoad() async {
    overlays.add('mainMenuOverlay');

    // Load all images into cache
    await images
        .loadAllImages(); //  loadAll and passing a list is better if too many images

    if (useMobileControls.value) {
      addMobileControls();
    }

    return super.onLoad();
  }

  @override
  void onGameResize(Vector2 size) {
    if (isLoaded && useMobileControls.value) {
      jumpButton.updatePosition(newGameSize: size);
    }

    super.onGameResize(size);
  }

  @override
  void lifecycleStateChange(AppLifecycleState state) {
    // TODO: implement lifecycleStateChange
    print('The state is $state'); // not working for web
    super.lifecycleStateChange(state);
  }

  @override
  void update(double dt) {
    if (useMobileControls.value) {
      updateJoystick(); //don't necessarily need dt bc it's in our player movement
    }
    super.update(dt);
  }

  void toggleSfx() async {
    if (playSounds.value) {
      playSounds.value = false;

      // FlameAudio.audioCache.clearAll();
    } else {
      playSounds.value = true;

      await cacheLevelSounds();

      // FlameAudio.play('collectFruit.wav');
    }
  }

  void toggleMusic() async {
    if (playMusic.value) {
      playMusic.value = false;

      // FlameAudio.bgm.pause();
    } else {
      playMusic.value = true;
      // FlameAudio.bgm.resume();

      // FlameAudio.play('collectFruit.wav');
    }
  }

  void toggleMobileControls() async {
    if (useMobileControls.value) {
      useMobileControls.value = false;
      removeWhere((component) => component is JoystickComponent);
      removeWhere((component) => component is JumpButton);
    } else {
      useMobileControls.value = true;
      addMobileControls();
    }
  }

  void addMobileControls() {
    addJoystick();
    add(jumpButton);
  }

  void addJoystick() {
    joystick = JoystickComponent(
        priority: 10,
        knob: SpriteComponent(
            sprite: Sprite(
          images.fromCache('HUD/Knob.png'),
        )),
        background: SpriteComponent(
            sprite: Sprite(images.fromCache('HUD/Joystick.png'))),
        margin: const EdgeInsets.only(left: 32, bottom: 32));

    add(joystick);
  }

  void updateJoystick() {
    switch (joystick.direction) {
      case JoystickDirection.left:
      case JoystickDirection.upLeft:
      case JoystickDirection.downLeft:
        player.horizontalMovement = -1;
        break;
      case JoystickDirection.right:
      case JoystickDirection.downRight:
      case JoystickDirection.upRight:
        player.horizontalMovement = 1;
        break;
      default:
        player.horizontalMovement = 0;
        break;
    }
  }

  void loadNextLevel() {
    removeWhere((component) => component is Level);
    if (currentLevelIndex < levelNames.length - 1) {
      currentLevelIndex++;
      _loadLevel();
    } else {
      // no more levels. go to menu? temporarily reset to first level
      currentLevelIndex = 0;
      _loadLevel();
    }
  }

  void _loadLevel() {
    Future.delayed(const Duration(milliseconds: 100), () {
      // allow time to destroy and recreate level
      world = Level(levelName: levelNames[currentLevelIndex], player: player);

      cam = CameraComponent.withFixedResolution(
          world: world, width: 640, height: 360);
      cam.viewfinder.anchor = Anchor.topLeft;

      addAll([cam, world]);
    });
  }

  void openSettings() {
    overlays.add('settingsOverlay');
  }

  void closeSettings() {
    overlays.remove('settingsOverlay');
  }

  cacheLevelSounds() async {
    print('caching sound here');
    // await jumpPlayer.setAsset('assets/audio/jump.wav');
    // await disappearPlayer.setAsset('assets/audio/disappear.wav');
    // await collectPlayer.setAsset('assets/audio/collectFruit.wav');
    // await audioPlayer.audioCache.load('jump.wav');
    //  await game.justAudioPlayer.setAsset('assets/audio/jump.wav');

    // final jumpSource = await justAudioPlayer.setAsset('assets/audio/jump.wav');

    // await audioPlayer.audioCache.loadAll([
    //   'audio/jump.wav',
    //   'audio/collectCoin.mp3',
    //   'audio/collectFruit.wav',
    //   'audio/disappear.wav',
    //   'audio/hit.wav',
    //   'audio/jumpOffEnemy.wav'
    // ]);
    // print('cache: ${audioPlayer.audioCache.loadedFiles}');
    // await FlameAudio.audioCache.loadAll([
    //   'jump.wav',
    //   'collectCoin.mp3',
    //   'collectFruit.wav',
    //   'disappear.wav',
    //   'hit.wav',
    //   'jumpOffEnemy.wav'
    // ]);

    // await justAudioPlayer.audioC
  }

  void startGame() async {
    print('Start game');
    // FlameAudio.bgm.initialize();
    await cacheLevelSounds();
    if (playSounds.value) {
      // FlameAudio.play('disappear.wav', volume: soundVolume);
      await justAudioPlayer.setAsset('assets/audio/disappear.wav');
      justAudioPlayer.play();
      // disappearPlayer.play();
    }
    if (playMusic.value) {
      // FlameAudio.bgm.stop();
      // FlameAudio.bgm.play('music/forest.mp3', volume: musicVolume);
    }
    _loadLevel();
    overlays.remove('mainMenuOverlay');
    // overlays.add('gameplayOverlay');
  }

  void reset() {
    // TODO implement game reset
  }

  void quit() {
    // TODO implement game quit
    // FlameAudio.bgm.dispose();
  }

  void togglePauseState() {
    if (paused) {
      resumeEngine();
    } else {
      pauseEngine();
    }
  }
}
