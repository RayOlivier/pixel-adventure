// Copyright 2022 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:io' show Platform;
import 'package:flame/game.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:pixel_adventure/pixel_adventure.dart';

// import 'widgets.dart';

class GameplayOverlay extends StatefulWidget {
  const GameplayOverlay(this.game, {super.key});

  final Game game;

  @override
  State<GameplayOverlay> createState() => GameplayOverlayState();
}

class GameplayOverlayState extends State<GameplayOverlay> {
  // bool isPaused = false;
  // Mobile Support: Add isMobile boolean
  final bool isMobile = !kIsWeb && (Platform.isAndroid || Platform.isIOS);

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Stack(
        children: [
          Positioned(
            top: 30,
            right: 30,
            child: ElevatedButton(
              child: (widget.game as PixelAdventure).paused
                  ? const Icon(
                      Icons.play_arrow,
                      size: 48,
                    )
                  : const Icon(
                      Icons.pause,
                      size: 48,
                    ),
              onPressed: () {
                (widget.game as PixelAdventure).togglePauseState();
              },
            ),
          ),
          if ((widget.game as PixelAdventure).paused)
            Positioned(
              top: MediaQuery.of(context).size.height / 2 - 72.0,
              right: MediaQuery.of(context).size.width / 2 - 72.0,
              child: const Icon(
                Icons.pause_circle,
                size: 144.0,
                color: Colors.black12,
              ),
            ),
          if ((widget.game as PixelAdventure).paused)
            Positioned(
              top: MediaQuery.of(context).size.height / 2 + 100.0,
              right: MediaQuery.of(context).size.width / 2 - 70.0,
              child: ElevatedButton.icon(
                label: const Text('Settings',
                    style: TextStyle(fontSize: 22, color: Colors.white)),
                icon: const Icon(
                  Icons.settings,
                  size: 32,
                ),
                onPressed: () {
                  (widget.game as PixelAdventure).openSettings();
                },
              ),
            ),
        ],
      ),
    );
  }
}
