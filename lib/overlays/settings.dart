import 'package:flutter/material.dart';
import 'package:pixel_adventure/pixel_adventure.dart';

class SettingsOverlay extends StatelessWidget {
  final PixelAdventure game;

  const SettingsOverlay({super.key, required this.game});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(color: Color.fromRGBO(10, 20, 60, 1)
          // image: DecorationImage(
          //     image: AssetImage('assets/images/Background/leafBorderBg.png'),
          //     fit: BoxFit.contain)
          ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 48.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Text(
              'Settings',
              style: TextStyle(fontSize: 32, color: Colors.white),
              textAlign: TextAlign.center,
            ),
            const SizedBox(
              height: 20,
            ),
            Row(children: [
              const Text(
                'SFX:',
                style: TextStyle(fontSize: 16, color: Colors.white),
              ),
              const SizedBox(width: 20),
              ValueListenableBuilder<bool>(
                valueListenable: game.playSounds,
                builder: (context, soundsOn, child) => ElevatedButton.icon(
                  // 'Sound FX',
                  label: Text(soundsOn ? 'Mute' : 'Unmute'),
                  icon: Icon(soundsOn ? Icons.volume_up : Icons.volume_off),
                  onPressed: () => game.toggleSfx(),
                ),
              ),
            ]),
            const SizedBox(
              height: 20,
            ),
            Row(children: [
              const Text(
                'Music:',
                style: TextStyle(fontSize: 16, color: Colors.white),
              ),
              const SizedBox(width: 20),
              ValueListenableBuilder<bool>(
                valueListenable: game.playMusic,
                builder: (context, musicOn, child) => ElevatedButton.icon(
                  // 'Music',
                  label: Text(musicOn ? 'Mute' : 'Unmute'),
                  icon: Icon(musicOn ? Icons.music_note : Icons.music_off),
                  onPressed: () => game.toggleMusic(),
                ),
              ),
            ]),
            const SizedBox(
              height: 20,
            ),
            Row(children: [
              const Text(
                'Controls:',
                style: TextStyle(fontSize: 16, color: Colors.white),
              ),
              const SizedBox(width: 20),
              ValueListenableBuilder<bool>(
                valueListenable: game.useMobileControls,
                builder: (context, mobileControls, child) =>
                    ElevatedButton.icon(
                  // 'Controls',
                  label: Text(mobileControls ? 'Touch' : 'Keyboard'),
                  icon: Icon(mobileControls ? Icons.touch_app : Icons.keyboard),
                  onPressed: () => game.toggleMobileControls(),
                ),
              ),
            ]),
            const SizedBox(
              height: 20,
            ),
            ElevatedButton.icon(
              onPressed: () => game.closeSettings(),
              icon: const Icon(Icons.close),
              label: const Text('Close'),
            ),
          ],
        ),
      ),
    );
  }
}
