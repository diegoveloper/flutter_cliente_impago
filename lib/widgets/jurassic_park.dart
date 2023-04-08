import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';

import '../main.dart';

class JurassicPark extends StatefulWidget {
  const JurassicPark({super.key});

  @override
  State<JurassicPark> createState() => _JurassicParkState();
}

class _JurassicParkState extends State<JurassicPark> {
  final player = AudioPlayer();
  bool showTimer = false;
  String pathImage = 'assets/extras/jurassic_park.gif';

  @override
  void initState() {
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) player.play(AssetSource('sounds/jurassic_park_locked.mp3'));
    });
    super.initState();
  }

  @override
  void dispose() {
    player.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.of(context).pop(),
      child: Scaffold(
          body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(25.0),
          child: Stack(
            fit: StackFit.expand,
            children: [
              Positioned.fill(
                child: Image.asset(
                  pathImage,
                  fit: BoxFit.cover,
                ),
              ),
              Align(
                alignment: const Alignment(0.0, 0.6),
                child: PayYourDebt(
                  Navigator.of(context).pop,
                  height: 160,
                ),
              ),
              const SizedBox(height: 15),
            ],
          ),
        ),
      )),
    );
  }
}
