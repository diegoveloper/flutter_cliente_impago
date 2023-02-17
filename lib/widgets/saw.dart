import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

const _maxAmount = 25000;

class Saw extends StatefulWidget {
  const Saw({super.key});

  @override
  State<Saw> createState() => _SawState();
}

class _SawState extends State<Saw> {
  final player = AudioPlayer();
  bool showTimer = false;
  String pathImage = 'assets/extras/saw.gif';
  Timer? timer;

  @override
  void initState() {
    player.play(AssetSource('sounds/saw_audio.mp3'));
    Timer(const Duration(seconds: 12), () {
      if (mounted) {
        setState(() {
          showTimer = true;
          pathImage = 'assets/extras/saw_static.jpg';
        });
      }
    });
    super.initState();
  }

  @override
  void dispose() {
    timer?.cancel();
    player.dispose();
    super.dispose();
  }

  Text _buildAmount(int value) {
    return Text(
      '\$ ${NumberFormat('##,###').format(value)} USD',
      style: const TextStyle(
        color: Colors.white,
        fontSize: 50,
        fontWeight: FontWeight.bold,
      ),
      textAlign: TextAlign.center,
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.of(context).pop(),
      child: Scaffold(
          backgroundColor: Colors.black,
          body: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                pathImage,
                fit: BoxFit.cover,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 50.0),
                child: Image.asset(
                  'assets/extras/credit_card.png',
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(height: 15),
              if (showTimer)
                TweenAnimationBuilder(
                    tween: IntTween(begin: _maxAmount, end: 0),
                    duration: const Duration(
                      hours: 1,
                    ),
                    builder: (context, value, _) {
                      return _buildAmount(value);
                    })
              else
                _buildAmount(_maxAmount)
            ],
          )),
    );
  }
}
