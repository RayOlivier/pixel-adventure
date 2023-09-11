import 'dart:async';

import 'package:flame/components.dart';
import 'package:pixel_adventure/pixel_adventure.dart';

class BackgroundTile extends SpriteComponent with HasGameRef<PixelAdventure> {
  final String color;
  BackgroundTile({this.color = 'gray', position}) : super(position: position);

  @override
  FutureOr<void> onLoad() {
    // TODO: implement onLoad
    size = Vector2.all(64);
    sprite = Sprite(game.images.fromCache('Background/$color.png'));
    return super.onLoad();
  }
}
