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
                  ElevatedButton(
                      onPressed: () async {
                        game.openSettings();
                      },
                      child: const Text('Settings')),
                  const SizedBox(
                    height: 10,
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
