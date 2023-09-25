import 'dart:async';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
// import 'package:flame_audio/flame_audio.dart';
import 'package:flutter/services.dart';
import 'package:pixel_adventure/components/enemy/rhino.dart';
import 'package:pixel_adventure/components/level/checkpoint.dart';
import 'package:pixel_adventure/components/enemy/chicken.dart';
import 'package:pixel_adventure/components/utility/collision_block.dart';
import 'package:pixel_adventure/components/utility/custom_hitbox.dart';
import 'package:pixel_adventure/components/level/fruit.dart';
import 'package:pixel_adventure/components/enemy/saw.dart';
import 'package:pixel_adventure/components/utility/utils.dart';
import 'package:pixel_adventure/components/utility/variables.dart';
import 'package:pixel_adventure/pixel_adventure.dart';

enum PlayerState {
  idle,
  running,
  jumping,
  falling,
  hit,
  appearing,
  disappearing
}

// enum PlayerDirection { left, right, none }

class Player extends SpriteAnimationGroupComponent
    with HasGameRef<PixelAdventure>, KeyboardHandler, CollisionCallbacks {
  String character;
  // constructor
  Player({position, this.character = 'Ninja Frog'}) : super(position: position);

  late final SpriteAnimation idleAnimation;
  late final SpriteAnimation runningAnimation;
  late final SpriteAnimation jumpingAnimation;
  late final SpriteAnimation fallingAnimation;
  late final SpriteAnimation hitAnimation;
  late final SpriteAnimation appearingAnimation;
  late final SpriteAnimation disappearingAnimation;

  final double stepTime = 0.05;
  final double _jumpForce = 260;
  final double _terminalVelocity = 300;

  double horizontalMovement = 0;
  Vector2 velocity = Vector2.zero();
  Vector2 startingPosition = Vector2.zero();
  bool isOnGround = false;
  bool hasJumped = false;
  bool gotHit = false;
  bool reachedCheckpoint = false;

  List<CollisionBlock> collisionBlocks = [];
  CustomHitbox hitbox =
      CustomHitbox(offsetX: 10, offsetY: 4, width: 14, height: 28);

  double fixedDeltaTime = 1 / 60; // targeting 60fps
  double accumulatedTime = 0;

  @override
  FutureOr<void> onLoad() {
    _loadAllAnimations();

    // debugMode = true;

    startingPosition = Vector2(position.x, position.y);

    add(RectangleHitbox(
        position: Vector2(hitbox.offsetX, hitbox.offsetY),
        size: Vector2(hitbox.width, hitbox.height)));

    return super.onLoad();
  }

  @override
  bool onKeyEvent(RawKeyEvent event, Set<LogicalKeyboardKey> keysPressed) {
    horizontalMovement = 0;
    final isLeftKeyPressed = keysPressed.contains(LogicalKeyboardKey.keyA) ||
        keysPressed.contains(LogicalKeyboardKey.arrowLeft);
    final isRightKeyPressed = keysPressed.contains(LogicalKeyboardKey.keyD) ||
        keysPressed.contains(LogicalKeyboardKey.arrowRight);

    horizontalMovement += isLeftKeyPressed ? -1 : 0;
    horizontalMovement += isRightKeyPressed
        ? 1
        : 0; // separate to prevent movement if both pressed

    hasJumped = keysPressed.contains(LogicalKeyboardKey.space);

    return super.onKeyEvent(event, keysPressed);
  }

// onCollisionStart only triggers once
  @override
  void onCollisionStart(
      Set<Vector2> intersectionPoints, PositionComponent other) {
    if (!reachedCheckpoint) {
      if (other is Fruit) other.collidedWithPlayer();
      if (other is Saw) _respawn();
      if (other is Checkpoint) _reachedCheckpoint();
      if (other is Chicken) other.collidedWithPlayer();
      if (other is Rhino) other.collidedWithPlayer();
    }

    super.onCollisionStart(intersectionPoints, other);
  }

  @override
  void update(double dt) {
    // dt is delta time, depends on framerate ?

    accumulatedTime += dt;
    while (accumulatedTime >= fixedDeltaTime) {
      if (!gotHit && !reachedCheckpoint) {
        _updatePlayerState();
        _updatePlayerMovement(fixedDeltaTime);
        _checkHorizontalCollisions();
        _applyGravity(fixedDeltaTime);
        _checkVerticalCollisions();
      }

      accumulatedTime -= fixedDeltaTime;
    }

    super.update(dt);
  }

  void _loadAllAnimations() {
    idleAnimation = _spriteAnimation('Idle', 11);
    runningAnimation = _spriteAnimation('Run', 12);
    jumpingAnimation = _spriteAnimation('Jump', 1);
    fallingAnimation = _spriteAnimation('Fall', 1);
    hitAnimation = _spriteAnimation('Hit', 7)..loop = false; // cascade operator
    appearingAnimation = _specialSpriteAnimation('Appearing', 7);
    disappearingAnimation = _specialSpriteAnimation('Disappearing', 7);

    // list of all animations
    animations = {
      PlayerState.idle: idleAnimation,
      PlayerState.running: runningAnimation,
      PlayerState.jumping: jumpingAnimation,
      PlayerState.falling: fallingAnimation,
      PlayerState.hit: hitAnimation,
      PlayerState.appearing: appearingAnimation,
      PlayerState.disappearing: disappearingAnimation,
    };

    //set current animation
    current = PlayerState.idle;
  }

  SpriteAnimation _spriteAnimation(String characterState, int frameCount) {
    return SpriteAnimation.fromFrameData(
        game.images.fromCache(
            'Main Characters/$character/$characterState (32x32).png'),
        SpriteAnimationData.sequenced(
            amount: frameCount,
            stepTime: stepTime,
            textureSize: Vector2.all(32)));
  }

  SpriteAnimation _specialSpriteAnimation(
      String characterState, int frameCount) {
    return SpriteAnimation.fromFrameData(
        game.images.fromCache('Main Characters/$characterState (96x96).png'),
        SpriteAnimationData.sequenced(
            amount: frameCount,
            stepTime: stepTime,
            textureSize: Vector2.all(96),
            loop: false));
  }

  void _updatePlayerState() {
    PlayerState playerState = PlayerState.idle;

    if (velocity.x < 0 && scale.x > 0) {
      flipHorizontallyAroundCenter();
    } else if (velocity.x > 0 && scale.x < 0) {
      flipHorizontallyAroundCenter();
    }

    // if moving, set running
    if (velocity.x > 0 || velocity.x < 0) playerState = PlayerState.running;

    if (velocity.y > gravity) playerState = PlayerState.falling;
    if (velocity.y < 0) playerState = PlayerState.jumping;

    current = playerState;
  }

  void _updatePlayerMovement(double dt) {
    if (hasJumped && isOnGround) _playerJump(dt);

    // prevents jumping after falling (ie walking off ledge)
    if (velocity.y > gravity) isOnGround = false;

    velocity.x = horizontalMovement * playerSpeed;
    position.x += velocity.x * dt;
  }

  void _checkHorizontalCollisions() {
    for (final block in collisionBlocks) {
      // handle collision
      if (!block.isPlatform) {
        if (checkCollision(this, block)) {
          if (velocity.x > 0) {
            velocity.x = 0;
            position.x = block.x - hitbox.offsetX - hitbox.width;
            break;
          }
          if (velocity.x < 0) {
            velocity.x = 0;
            position.x = block.x + block.width + hitbox.width + hitbox.offsetX;
            break;
          }
        }
      }
    }
  }

  void _applyGravity(double dt) {
    velocity.y += gravity;
    velocity.y = velocity.y.clamp(-_jumpForce,
        _terminalVelocity); // clamp applies an upper and lower limit
    position.y += velocity.y * dt;
  }

  void _checkVerticalCollisions() {
    for (final block in collisionBlocks) {
      if (block.isPlatform) {
        if (checkCollision(this, block)) {
          if (velocity.y > 0) {
            velocity.y = 0;
            position.y = block.y - hitbox.height - hitbox.offsetY;
            isOnGround = true;
            break;
          }
        }
      } else {
        if (checkCollision(this, block)) {
          if (velocity.y > 0) {
            velocity.y = 0;
            position.y = block.y - hitbox.height - hitbox.offsetY;
            isOnGround = true;
            break;
          }
          if (velocity.y < 0) {
            velocity.y = 0;
            position.y = block.y + block.height - hitbox.offsetY;
          }
        }
      }
    }
  }

  void _playerJump(double dt) async {
    if (game.playSounds.value) {
      // FlameAudio.play('jump.wav', volume: game.soundVolume);
      // game.audioPlayer.play(AssetSource('audio/jump.wav'));
      await game.justAudioPlayer.setAsset('assets/audio/jump.wav');
      game.justAudioPlayer.play();
      // game.jumpPlayer.play();
    }
    velocity.y = -_jumpForce;
    position.y += velocity.y * dt;
    isOnGround = false;
    hasJumped = false;
  }

  void _respawn() async {
    if (game.playSounds.value) {
      // FlameAudio.play('hit.wav', volume: game.soundVolume);
    }
    const cantMoveDuration = Duration(milliseconds: 400);
    gotHit = true;
    current = PlayerState.hit;

    await animationTicker?.completed;
    animationTicker?.reset();

    print('start $startingPosition');

    position = startingPosition -
        Vector2.all(
            32); // offset starting position by difference in character size and appearing animation size

    current = PlayerState.appearing;
    await animationTicker?.completed;
    animationTicker?.reset();

    velocity = Vector2.zero();
    position = startingPosition;
    _updatePlayerState();
    Future.delayed(cantMoveDuration, () => gotHit = false);
  }

  void _reachedCheckpoint() async {
    if (game.playSounds.value) {
      // FlameAudio.play('disappear.wav', volume: game.soundVolume);
    }
    reachedCheckpoint = true;
    if (scale.x > 0) {
      position = position - Vector2.all(32);
    } else if (scale.x < 0) {
      position = position + Vector2(32, -32);
    }

    current = PlayerState.disappearing;

    await animationTicker?.completed;
    animationTicker?.reset();

    reachedCheckpoint = false;
    position = Vector2.all(-640); // move player off screen

    const waitToChangeDuration = Duration(seconds: 2);
    // todo game menus and level transitions
    Future.delayed(waitToChangeDuration, () => game.loadNextLevel());
  }

  void collidedWithEnemy() {
    _respawn();
  }

  void spawn(Vector2 position, {scaleX = 1}) {
    startingPosition = position;
    this.position = position;
  }
}
