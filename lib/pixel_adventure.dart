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
  Player player = Player(character: 'Ninja Frog');
  late JoystickComponent joystick;

  bool showControls = true;
  bool playMusic = false;

  ValueNotifier<bool> playSounds = ValueNotifier(true);
  double soundVolume = 0.5;
  double musicVolume = 0.1;

  List<String> levelNames = ['level-01', 'level-01'];
  int currentLevelIndex = 0;

  @override
  FutureOr<void> onLoad() async {
    overlays.add('mainMenuOverlay');

    // Load all images into cache
    await images
        .loadAllImages(); //  loadAll and passing a list is better if too many images

    await FlameAudio.audioCache.loadAll([
      'collectFruit.wav',
      'disappear.wav',
      'hit.wav',
      'jump.wav',
      'jumpOffEnemy.wav'
    ]);

    _loadLevel();

    if (showControls) {
      addJoystick();
      add(JumpButton());
    }

    return super.onLoad();
  }

  @override
  void onGameResize(Vector2 size) {
    // @TODO: turn off joystick for desktop or make it a setting
    if (isLoaded) {
      removeWhere((component) => component is JoystickComponent);
      removeWhere((component) => component is JumpButton);
      addJoystick();
      add(JumpButton());
    }

    super.onGameResize(size);
  }

  @override
  void update(double dt) {
    if (showControls) {
      updateJoystick(); //don't necessarily need dt bc it's in our player movement
    }
    super.update(dt);
  }

  void toggleAudio() async {
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

  void startGame() async {
    if (playSounds.value) {
      FlameAudio.play('disappear.wav');
    }
    if (playMusic) {
      FlameAudio.bgm.initialize();
      FlameAudio.bgm.play('music/menu.mp3');
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
