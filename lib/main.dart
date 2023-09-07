import 'package:flame/flame.dart';
import 'package:flame/game.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:pixel_adventure/pixel_adventure.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // await is very important for real devices, as it takes time to switch to landscape (but it works without await on emulators)
  await Flame.device.fullScreen();
  await Flame.device.setLandscape();

  PixelAdventure game = PixelAdventure();
  runApp(GameWidget(
      game: kDebugMode
          ? PixelAdventure()
          : game)); // debug mode refreshes/starts game on changes
}
