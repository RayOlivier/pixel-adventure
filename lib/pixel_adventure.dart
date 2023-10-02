import 'dart:async';
import 'dart:html' as html;
// import 'dart:html';

import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:pixel_adventure/components/jump_button.dart';
import 'package:pixel_adventure/components/player.dart';
import 'package:pixel_adventure/components/level/level.dart';
import 'package:pixel_adventure/components/utility/audio_manager.dart';

enum GameState { isPaused, isPlaying, isGameOver, isMainMenu }

class PixelAdventure extends FlameGame
    with
        HasKeyboardHandlerComponents,
        DragCallbacks,
        TapCallbacks,
        HasCollisionDetection {
  PixelAdventure();
  @override
  Color backgroundColor() => const Color(0xFF211F30);

  late CameraComponent cam;
  late World world;
  JumpButton jumpButton = JumpButton();
  Player player = Player(character: 'Ninja Frog');
  late JoystickComponent joystick;

  ValueNotifier<bool> playSounds = ValueNotifier(true);
  ValueNotifier<bool> musicOn = ValueNotifier(true);
  ValueNotifier<bool> useMobileControls = ValueNotifier(true);

  List<String> levelNames = ['level-01', 'level-02'];

  int currentLevelIndex = 0;

  // can't play audio until user interacts
  bool initialInteraction = false;
  AudioManager audioManager = AudioManager();

  @override
  FutureOr<void> onLoad() async {
    if (kIsWeb) {
      html.window.addEventListener('focus', onFocus);
      html.window.addEventListener('blur', onBlur);
      html.window.addEventListener('visibilityChange', onVisibilityChange);
    }

    overlays.add('mainMenuOverlay');

    // Load all images into cache
    await images
        .loadAllImages(); //  loadAll and passing a list is better if too many images

    if (useMobileControls.value) {
      addMobileControls();
    }

    await add(audioManager);

    return super.onLoad();
  }

  void onFocus(html.Event e) {
    if (initialInteraction &&
        !audioManager.bgmPlayer.playing &&
        musicOn.value) {
      audioManager.playMusic();
    }
  }

  void onBlur(html.Event e) async {
    audioManager.pauseMusic();
  }

  void onVisibilityChange(html.Event e) {
    audioManager.pauseMusic();
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
    print('toggling sfx');
    if (playSounds.value) {
      playSounds.value = false;
    } else {
      playSounds.value = true;
      audioManager.playOnce('collectFruit.wav');
    }
  }

  void toggleMusic() async {
    if (musicOn.value) {
      musicOn.value = false;
      audioManager.pauseMusic();
    } else {
      musicOn.value = true;
      audioManager.playMusic();
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
    world = Level(levelName: levelNames[currentLevelIndex], player: player);

    cam = CameraComponent.withFixedResolution(
        world: world, width: 640, height: 360);
    cam.viewfinder.anchor = Anchor.topLeft;

    addAll([cam, world]);
  }

  void openSettings() {
    initialInteraction = true;
    overlays.add('settingsOverlay');
  }

  void closeSettings() {
    overlays.remove('settingsOverlay');
  }

  void startGame() async {
    initialInteraction = true;

    _loadLevel();
    if (playSounds.value) {
      audioManager.playOnce('disappear.wav');
    }
    if (musicOn.value) {
      audioManager.playMusic();
    }
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
