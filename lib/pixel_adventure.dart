import 'dart:async';

import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/flame.dart';
import 'package:flame/game.dart';
import 'package:just_audio/just_audio.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/widgets.dart';
import 'package:pixel_adventure/components/jump_button.dart';
import 'package:pixel_adventure/components/player.dart';
import 'package:pixel_adventure/components/level/level.dart';

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
  late World world;
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
  final audioPlayer = AudioPlayer();

  @override
  FutureOr<void> onLoad() async {
    overlays.add('mainMenuOverlay');

    // await cacheLevelSounds();

    // Load all images into cache
    await images
        .loadAllImages(); //  loadAll and passing a list is better if too many images

    // _loadLevel();

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
    print('toggling sfx');
    if (playSounds.value) {
      playSounds.value = false;
    } else {
      playSounds.value = true;
      await audioPlayer.setAsset('assets/audio/collectFruit.wav');
      audioPlayer.play();
    }
  }

  void toggleMusic() async {
    print('toggling music');
    if (playMusic.value) {
      playMusic.value = false;
      audioPlayer.pause();
    } else {
      playMusic.value = true;

      await audioPlayer.setAsset('assets/audio/collectFruit.wav');
      audioPlayer.play();
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

  void startGame() async {
    print('Start game');
    if (playSounds.value) {
      await audioPlayer.setAsset('assets/audio/disappear.wav');
      audioPlayer.play();
    }
    if (playMusic.value) {
      await audioPlayer.setAsset('assets/audio/music/forest.mp3');
      audioPlayer.play();
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
  }

  void togglePauseState() {
    if (paused) {
      resumeEngine();
    } else {
      pauseEngine();
    }
  }
}
