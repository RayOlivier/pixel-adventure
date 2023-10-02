import 'dart:async';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:just_audio/just_audio.dart';
import 'package:pixel_adventure/components/player.dart';
import 'package:pixel_adventure/components/utility/variables.dart';
import 'package:pixel_adventure/pixel_adventure.dart';

enum RhinoState { idle, run, hit, hitWall }

class Rhino extends SpriteAnimationGroupComponent
    with HasGameRef<PixelAdventure> {
  final double offNeg;
  final double offPos;
  late final Vector2 spawnPosition;
  Rhino({super.position, super.size, this.offNeg = 0, this.offPos = 0});

  Vector2 velocity = Vector2.zero();

  static const stepTime = 0.05;
  static const runSpeed = 150;
  static const walkSpeed = 80;

  double rangeNeg = 0;
  double rangePos = 0;
  double moveDirection = 1;
  double targetDirection = 1;

  bool chargingAtPlayer = false;
  bool hitWall = false;
  bool walkingBack = false;
  late final bool chargesLeft;

  final textureSize = Vector2(52, 34);

  late final Player player;
  late final SpriteAnimation _idleAnimation;
  late final SpriteAnimation _runAnimation;
  late final SpriteAnimation _hitAnimation;
  late final SpriteAnimation _hitWallAnimation;

  final AudioPlayer _wallHitPlayer = AudioPlayer();

  @override
  FutureOr<void> onLoad() async {
    player = game.player;

    _loadAllAnimations();
    _calculateRange();

    _wallHitPlayer.setAsset('assets/audio/hit.wav');
    chargesLeft = offNeg > 0;

    spawnPosition = Vector2.copy(position);
    add(RectangleHitbox(position: Vector2(2, 6), size: Vector2(44, 28)));

    return super.onLoad();
  }

  @override
  void update(double dt) {
    if (!hitWall) {
      // wait for hitWall anim to finish before updating again
      _updateRhinoState();
      _movement(dt);
    }
    super.update(dt);
  }

  void _loadAllAnimations() {
    _idleAnimation = _rhinoSpriteAnimation('Idle', 11);
    _runAnimation = _rhinoSpriteAnimation('Run', 6);
    _hitAnimation = _rhinoSpriteAnimation('Hit', 5)..loop = false;
    _hitWallAnimation = _rhinoSpriteAnimation('Hit Wall', 4)..loop = false;

    animations = {
      RhinoState.idle: _idleAnimation,
      RhinoState.run: _runAnimation,
      RhinoState.hit: _hitAnimation,
      RhinoState.hitWall: _hitWallAnimation
    };

    current = RhinoState.idle;
  }

  SpriteAnimation _rhinoSpriteAnimation(String state, int amount) {
    return SpriteAnimation.fromFrameData(
        game.images.fromCache('Enemies/Rhino/$state (52x34).png'),
        SpriteAnimationData.sequenced(
            amount: amount, stepTime: stepTime, textureSize: textureSize));
  }

  // calculate distance Rhino runs
  void _calculateRange() {
    rangeNeg = position.x - offNeg * tileSize;
    rangePos = position.x + offPos * tileSize;
  }

  // check if player is in sight
  bool playerInRange() {
    double playerOffset = (player.scale.x > 0) ? 0 : -player.width;

    return player.x + playerOffset >= rangeNeg && // within range left
        player.x + playerOffset <= rangePos && // within range right
        player.y + player.height >
            position.y && // bottom of player below top of rhino
        player.y < position.y + y;
  }

  void _movement(dt) async {
    velocity.x = 0;

    int currentSpeed = walkingBack
        ? walkSpeed
        : chargingAtPlayer
            ? runSpeed
            : 0;

    if ((chargesLeft ? position.x <= rangeNeg : position.x >= rangePos) &&
        !hitWall) {
      // hits ending wall
      _hitWall();
    } else if (walkingBack &&
        (chargesLeft
            ? (position.x - textureSize.x) >= spawnPosition.x
            : position.x <= spawnPosition.x)) {
      // turn around at starting wall
      _resetCharge();
    } else if (playerInRange()) {
      targetDirection = chargesLeft ? -1 : 1;
      chargingAtPlayer = true;
      velocity.x = targetDirection * currentSpeed;
    } else {
      velocity.x = targetDirection * currentSpeed;
    }

    position.x += velocity.x * dt;
  }

  void _hitWall() async {
    current = RhinoState.hitWall;
    hitWall = true;
    chargingAtPlayer = false;
    _wallHitPlayer.play();
    _wallHitPlayer.load();

    await animationTicker?.completed;
    animationTicker
        ?.reset(); // allows animation to play again when loop is false

    targetDirection =
        chargesLeft ? 1 : -1; // walks back to the right if charges left
    velocity.x = targetDirection * walkSpeed;

    hitWall = false;
    walkingBack = true;

    flipHorizontallyAroundCenter();
  }

  void _resetCharge() {
    velocity.x = 0;
    hitWall = false;
    chargingAtPlayer = false;
    flipHorizontallyAroundCenter();
    walkingBack = false;
  }

  void _updateRhinoState() {
    current = velocity.x != 0 ? RhinoState.run : RhinoState.idle;
  }

  void collidedWithPlayer() async {
    // TODO allow player to kill rhino

    player.collidedWithEnemy();
    velocity = Vector2.zero();
  }
}
