import 'dart:html';

import 'package:flame/flame.dart';
import 'package:flame/game.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:pixel_adventure/overlays/game_over.dart';
import 'package:pixel_adventure/overlays/gameplay.dart';
import 'package:pixel_adventure/overlays/main_menu.dart';
import 'package:pixel_adventure/overlays/settings.dart';
import 'package:pixel_adventure/pixel_adventure.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<StatefulWidget> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  final PixelAdventure game = PixelAdventure();

  @override
  didChangeAppLifecycleState(AppLifecycleState state) async {
    print('The APP state: $state');

    switch (state) {
      case AppLifecycleState.resumed:
        print('app resumed');
        break;
      case AppLifecycleState.hidden:
        print('app hidden');
        break;
      case AppLifecycleState.inactive:
        print('app inactive');
        // game.pauseMusic();
        break;
      case AppLifecycleState.paused:
        print('app paused');
        break;
      case AppLifecycleState.detached:
        print('app detached');
        break;
    }
  }

  @override
  void initState() {
    super.initState();
    if (kIsWeb) {
      print('is web!!');
      window.addEventListener('focus', onFocus);
      window.addEventListener('blur', onBlur);
      window.addEventListener('visibilityChange', onVisibilityChange);
    } else {
      WidgetsBinding.instance.addObserver(this);
    }
  }

  @override
  void dispose() {
    print('main dispose');
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  void onFocus(Event e) {
    didChangeAppLifecycleState(AppLifecycleState.resumed);
    game.lifecycleStateChange(AppLifecycleState.resumed);
  }

  void onBlur(Event e) async {
    didChangeAppLifecycleState(AppLifecycleState.inactive);
    game.lifecycleStateChange(AppLifecycleState.inactive);
  }

  void onVisibilityChange(Event e) {
    didChangeAppLifecycleState(AppLifecycleState.hidden);
    game.lifecycleStateChange(AppLifecycleState.hidden);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        constraints: const BoxConstraints(
            maxWidth: 800, minWidth: 300, maxHeight: 500, minHeight: 200),
        child: GameWidget(
          game: kDebugMode ? PixelAdventure() : game,
          overlayBuilderMap: <String,
              Widget Function(BuildContext, PixelAdventure)>{
            'gameplayOverlay': (context, game) => GameplayOverlay(game),
            'mainMenuOverlay': (context, game) => MainMenuOverlay(game: game),
            'settingsOverlay': (context, game) => SettingsOverlay(game: game),
            'gameOverOverlay': (context, game) => GameOverOverlay(game: game),
          },
        ));
    // throw UnimplementedError();
  }
}
