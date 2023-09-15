import 'package:flutter/material.dart';
import 'package:pixel_adventure/pixel_adventure.dart';

class GameOverOverlay extends StatelessWidget {
  final PixelAdventure game;

  const GameOverOverlay({super.key, required this.game});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
          image: DecorationImage(
              image: AssetImage('assets/images/Background/leafBorderBg.png'))),
      child: const Padding(
        padding: EdgeInsets.all(24.0),
        // child: Center(
        child: Center(
          child: Text(
            'Game Over',
            style: TextStyle(fontSize: 32),
            textAlign: TextAlign.center,
          ),
        ),
        // ),
      ),
    );
  }
}
