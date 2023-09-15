import 'package:flutter/material.dart';
import 'package:pixel_adventure/pixel_adventure.dart';

class SettingsOverlay extends StatelessWidget {
  final PixelAdventure game;

  const SettingsOverlay({super.key, required this.game});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
          image: DecorationImage(
              image: AssetImage('assets/images/Background/leafBorderBg.png'))),
      child: const Padding(
        padding: EdgeInsets.symmetric(vertical: 12.0, horizontal: 48.0),
        // child: Center(
        child: Row(
          children: [
            Text(
              'Settings',
              style: TextStyle(fontSize: 24),
              textAlign: TextAlign.center,
            ),
            SizedBox(
              height: 20,
            ),
            Column(
              children: [
                // mute toggle
                // volume slider
                //
              ],
            )
          ],
        ),
        // ),
      ),
    );
  }
}
