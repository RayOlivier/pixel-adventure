import 'dart:async';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
// import 'package:flame_audio/flame_audio.dart';
import 'package:pixel_adventure/components/utility/custom_hitbox.dart';
import 'package:pixel_adventure/pixel_adventure.dart';

class Fruit extends SpriteAnimationComponent
    with HasGameRef<PixelAdventure>, CollisionCallbacks {
  final String fruit;
  Fruit({this.fruit = 'Apple', position, size})
      : super(position: position, size: size);

  final double stepTime = 0.05;
  final hitbox = CustomHitbox(offsetX: 10, offsetY: 10, width: 12, height: 12);
  bool collected = false;

  @override
  FutureOr<void> onLoad() {
    // debugMode = true;
    priority = -1;

    add(
      RectangleHitbox(
        position: Vector2(hitbox.offsetX, hitbox.offsetY),
        size: Vector2(hitbox.width, hitbox.height),
        collisionType: CollisionType
            .passive, //only checks collision with player (not each other)
      ),
    );
    animation = SpriteAnimation.fromFrameData(
        game.images.fromCache('Items/Fruits/$fruit.png'),
        SpriteAnimationData.sequenced(
            amount: 17, stepTime: stepTime, textureSize: Vector2.all(32)));
    return super.onLoad();
  }

  void collidedWithPlayer() async {
    if (!collected) {
      collected = true;
      if (game.playSounds.value) {
        // FlameAudio.play('collectFruit.wav', volume: game.soundVolume);
        // game.collectPlayer.play();
        await game.justAudioPlayerFruit.setAsset('assets/audio/collect.wav');
        game.justAudioPlayer.play();
      }
      animation = SpriteAnimation.fromFrameData(
          game.images.fromCache('Items/Fruits/Collected.png'),
          SpriteAnimationData.sequenced(
              amount: 6,
              stepTime: stepTime,
              textureSize: Vector2.all(32),
              loop: false));

      await animationTicker?.completed;
      removeFromParent();
    }
  }
}
