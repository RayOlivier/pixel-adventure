import 'dart:async';

import 'package:flame/components.dart';
import 'package:flame/parallax.dart';
import 'package:flutter/material.dart';
import 'package:pixel_adventure/pixel_adventure.dart';

class BackgroundTile extends ParallaxComponent<PixelAdventure> {
  final String color;
  BackgroundTile({this.color = 'Gray', position}) : super(position: position);

  final double scrollSpeed = 30;

  @override
  Future<void> onLoad() async {
    priority = -10;
    size = Vector2.all(64);
    parallax = await game.loadParallax([
      ParallaxImageData('Background/$color.png'),
    ],
        baseVelocity: Vector2(0, -scrollSpeed),
        repeat: ImageRepeat.repeat,
        fill: LayerFill.none);

    return super.onLoad();
  }
}
