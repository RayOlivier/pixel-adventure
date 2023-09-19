import 'dart:async';

import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flame_audio/flame_audio.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/widgets.dart';
import 'package:pixel_adventure/components/jump_button.dart';
import 'package:pixel_adventure/components/player.dart';
import 'package:pixel_adventure/components/level.dart';

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
  double musicVolume = 0.1;

  List<String> levelNames = ['level-01', 'level-01'];
  int currentLevelIndex = 0;

  @override
  FutureOr<void> onLoad() async {
    overlays.add('mainMenuOverlay');
    FlameAudio.bgm.initialize();

    // Load all images into cache
    await images
        .loadAllImages(); //  loadAll and passing a list is better if too many images

    await FlameAudio.audioCache.loadAll([
      'collectFruit.wav',
      'disappear.wav',
      'hit.wav',
      'jump.wav',
      'jumpOffEnemy.wav',
      'music/menu.mp3',
      'music/forest.mp3'
    ]);

// player must interact with document
    // FlameAudio.bgm.play('music/menu.mp3', volume: musicVolume);

    _loadLevel();

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
  void update(double dt) {
    if (useMobileControls.value) {
      updateJoystick(); //don't necessarily need dt bc it's in our player movement
    }
    super.update(dt);
  }

  void toggleSfx() async {
    if (playSounds.value) {
      playSounds.value = false;

      FlameAudio.audioCache.clearAll();
    } else {
      playSounds.value = true;

      await FlameAudio.audioCache.loadAll([
        'collectFruit.wav',
        'disappear.wav',
        'hit.wav',
        'jump.wav',
        'jumpOffEnemy.wav'
      ]);

      FlameAudio.play('collectFruit.wav');
    }
  }

  void toggleMusic() async {
    if (playMusic.value) {
      playMusic.value = false;

      FlameAudio.bgm.pause();
    } else {
      playMusic.value = true;
      FlameAudio.bgm.resume();

      FlameAudio.play('collectFruit.wav');
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
      // add(JumpButton());
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
    if (playSounds.value) {
      FlameAudio.play('disappear.wav', volume: soundVolume);
    }
    if (playMusic.value) {
      // FlameAudio.bgm.initialize();
      FlameAudio.bgm.stop();
      FlameAudio.bgm.play('music/forest.mp3', volume: musicVolume);
      // FlameAudio.bgm.load('music/menu.mp3');
      // .loop('music/menu.mp3', volume: musicVolume);
    }
    _initializeGameStart();
  }

  void reset() {
    // TODO implement game reset
  }

  void _initializeGameStart() {
    // game.state = GameState.playing;
    overlays.remove('mainMenuOverlay');
  }
}
