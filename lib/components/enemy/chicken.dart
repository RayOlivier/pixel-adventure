import 'dart:async';
import 'dart:ui';
import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:just_audio/just_audio.dart';
import 'package:pixel_adventure/components/player.dart';
import 'package:pixel_adventure/pixel_adventure.dart';

enum ChickenState { idle, run, hit }

class Chicken extends SpriteAnimationGroupComponent
    with HasGameRef<PixelAdventure> {
  final double offNeg;
  final double offPos;
  Chicken({super.position, super.size, this.offNeg = 0, this.offPos = 0});

  static const stepTime = 0.05;
  static const tileSize = 16;
  static const runSpeed = 80;
  static const _bounceHeight = 260.0;
  final textureSize = Vector2(32, 34);

  Vector2 velocity = Vector2.zero();
  double rangeNeg = 0;
  double rangePos = 0;
  double moveDirection = 1;
  double targetDirection = -1;
  bool gotStomped = false;

  late final Player player;
  late final SpriteAnimation _idleAnimation;
  late final SpriteAnimation _runAnimation;
  late final SpriteAnimation _hitAnimation;

  final _jumpOffPlayer = AudioPlayer();

  @override
  FutureOr<void> onLoad() async {
    player = game.player;

    add(RectangleHitbox(position: Vector2(4, 6), size: Vector2(24, 26)));
    await _jumpOffPlayer.setAsset('assets/audio/jumpOffEnemy.wav');
    _loadAllAnimations();
    _calculateRange();
    return super.onLoad();
  }

  @override
  void update(double dt) {
    if (!gotStomped) {
      _updateChickenState();
      _movement(dt);
    }
    super.update(dt);
  }

  void _loadAllAnimations() {
    _idleAnimation = _spriteAnimation('Idle', 13);
    _runAnimation = _spriteAnimation('Run', 14);
    _hitAnimation = _spriteAnimation('Hit', 5)..loop = false;

    animations = {
      ChickenState.idle: _idleAnimation,
      ChickenState.run: _runAnimation,
      ChickenState.hit: _hitAnimation
    };

    current = ChickenState.idle;
  }

  SpriteAnimation _spriteAnimation(String state, int amount) {
    return SpriteAnimation.fromFrameData(
        game.images.fromCache('Enemies/Chicken/$state (32x34).png'),
        SpriteAnimationData.sequenced(
            amount: amount, stepTime: stepTime, textureSize: textureSize));
  }

  void _calculateRange() {
    rangeNeg = position.x - offNeg * tileSize;
    rangePos = position.x + offPos * tileSize;
  }

  void _movement(dt) {
    // set velocity to 0
    velocity.x = 0;

    // account for width of sprites when mirrored
    double playerOffset = (player.scale.x > 0) ? 0 : -player.width;
    double chickenOffset = (scale.x > 0) ? 0 : -width;

    if (playerInRange()) {
      targetDirection =
          (player.x + playerOffset < position.x + chickenOffset) ? -1 : 1;
      velocity.x = targetDirection * runSpeed;
    }

    moveDirection = lerpDouble(moveDirection, targetDirection, 0.1) ??
        1; // lerp adds a small delay??? stops the chicken from turning back and forth rapidly

    position.x += velocity.x * dt;
  }

  bool playerInRange() {
    double playerOffset = (player.scale.x > 0) ? 0 : -player.width;

    return player.x + playerOffset >= rangeNeg && // within range left
        player.x + playerOffset <= rangePos && // within range right
        player.y + player.height >
            position.y && // bottom of player below top of chicken
        player.y < position.y + y; // top of player above bottom of chicken
  }

  void _updateChickenState() {
    current = velocity.x != 0 ? ChickenState.run : ChickenState.idle;

    if ((moveDirection > 0 && scale.x > 0) ||
        (moveDirection < 0 && scale.x < 0)) {
      flipHorizontallyAroundCenter();
    }
  }

  void collidedWithPlayer() async {
    if (player.velocity.y > 0 && player.y + player.height > position.y) {
      if (game.playSounds.value) {
        _jumpOffPlayer.play(); // better for safari
      }

      gotStomped = true;
      current = ChickenState.hit;
      player.velocity.y = -_bounceHeight;
      await animationTicker?.completed;
      removeFromParent();
      _jumpOffPlayer.dispose();
    } else {
      player.collidedWithEnemy();
      velocity = Vector2.zero();
    }
  }
}
