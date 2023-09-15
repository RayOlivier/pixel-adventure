import 'package:flutter/material.dart';
import 'package:pixel_adventure/pixel_adventure.dart';

class MainMenuOverlay extends StatelessWidget {
  final PixelAdventure game;

  const MainMenuOverlay({super.key, required this.game});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
          image: DecorationImage(
              image: AssetImage('assets/images/Background/mainMenuBg.png'),
              fit: BoxFit.fitWidth)),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Text(
                'Pixel Adventure',
                style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.white),
                textAlign: TextAlign.center,
              ),
              const SizedBox(
                height: 20,
              ),
              Column(
                children: [
                  ElevatedButton(
                      onPressed: () async {
                        game.startGame();
                      },
                      child: const Text('Play')),
                  const SizedBox(
                    height: 10,
                  ),
                  ValueListenableBuilder<bool>(
                    valueListenable: game.playSounds,
                    builder: (context, soundsOn, child) => ElevatedButton.icon(
                      // 'Sound FX',
                      label: Text(soundsOn ? 'Mute' : 'UnMute'),
                      icon:
                          Icon(soundsOn ? Icons.graphic_eq : Icons.volume_off),
                      onPressed: () => game.toggleAudio(),
                    ),
                  ),
                  // ElevatedButton(
                  //     onPressed: () async {
                  //       game.toggleAudio();
                  //     },
                  //     child: Text(game.playSounds ? 'Mute' : 'UnMute')),
                  const SizedBox(
                    height: 10,
                  ),
                  // ElevatedButton.icon(
                  //     onPressed: () async {
                  //       game.openSettings();
                  //     },
                  //     icon: const Icon(Icons.settings),
                  //     label: const Text('settings')),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
