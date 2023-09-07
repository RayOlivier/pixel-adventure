import 'dart:async';

import 'package:flame/components.dart';
import 'package:pixel_adventure/pixel_adventure.dart';

enum PlayerState { idle, running }

class Player extends SpriteAnimationGroupComponent
    with HasGameRef<PixelAdventure> {
  String character;
  // constructor
  Player({position, required this.character}) : super(position: position);

  late final SpriteAnimation idleAnimation;
  late final SpriteAnimation runningAnimation;
  final double stepTime = 0.05;

  @override
  FutureOr<void> onLoad() {
    _loadAllAnimations();

    return super.onLoad();
  }

  void _loadAllAnimations() {
    idleAnimation = _spriteAnimation('Idle', 11);

    runningAnimation = _spriteAnimation('Run', 12);

    // list of all animations
    animations = {
      PlayerState.idle: idleAnimation,
      PlayerState.running: runningAnimation,
    };

    //set current animation
    current = PlayerState.running;
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
}
