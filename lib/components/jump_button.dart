import 'dart:async';

import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:pixel_adventure/pixel_adventure.dart';

class JumpButton extends SpriteComponent
    with HasGameRef<PixelAdventure>, TapCallbacks {
  JumpButton();

  final margin = 32;
  final buttonSize = 52;

  @override
  FutureOr<void> onLoad() {
    priority = 100;
    sprite = Sprite(game.images.fromCache('HUD/JumpButton.png'));
    updatePosition();

    return super.onLoad();
  }

  @override
  void onTapDown(TapDownEvent event) {
    game.player.hasJumped = true;
    super.onTapDown(event);
  }

  @override
  void onTapUp(TapUpEvent event) {
    game.player.hasJumped = false;
    super.onTapUp(event);
  }

  void updatePosition({newGameSize}) {
    if (newGameSize != null) {
      position = Vector2(
        newGameSize.x - margin - buttonSize,
        newGameSize.y - margin - buttonSize,
      );
    } else {
      position = Vector2(
        game.size.x - margin - buttonSize,
        game.size.y - margin - buttonSize,
      );
    }

    print('position $position');
  }
}
