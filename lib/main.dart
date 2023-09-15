import 'package:flame/flame.dart';
import 'package:flame/game.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:pixel_adventure/overlays/game_over.dart';
import 'package:pixel_adventure/overlays/main_menu.dart';
import 'package:pixel_adventure/overlays/settings.dart';
import 'package:pixel_adventure/pixel_adventure.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // await is very important for real devices, as it takes time to switch to landscape (but it works without await on emulators)
  await Flame.device.fullScreen();
  await Flame.device.setLandscape();

  PixelAdventure game = PixelAdventure();
  runApp(Container(
      constraints: const BoxConstraints(
          maxWidth: 800, minWidth: 300, maxHeight: 500, minHeight: 200),
      child: GameWidget(
        game: kDebugMode ? PixelAdventure() : game,
        overlayBuilderMap: <String,
            Widget Function(BuildContext, PixelAdventure)>{
          // 'gameplayOverlay': (context, game) => GameplayOverlay(game),
          'mainMenuOverlay': (context, game) => MainMenuOverlay(game: game),
          'settingsOverlay': (context, game) => SettingsOverlay(game: game),
          'gameOverOverlay': (context, game) => GameOverOverlay(game: game),
        },
      ))); // debug mode refreshes/starts game on changes
}
