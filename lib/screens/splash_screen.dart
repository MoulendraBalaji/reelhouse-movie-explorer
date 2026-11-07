// ENTRANCE SEQUENCE:
// 0ms: 35mm SMPTE Film Leader countdown initiates (3-2-1)
// 3000ms: Countdown reaches zero
// 3100ms: Projector lamp white flash burst
// 3300ms: IrisShutterTransition cuts to Home screening

import 'package:flutter/material.dart';
import '../widgets/motion/projector_countdown_leader.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  void _enterCinema(BuildContext context) {
    Navigator.of(context).pushReplacementNamed('/home');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          ProjectorCountdownLeader(
            onCountdownComplete: () => _enterCinema(context),
          ),
          Positioned(
            bottom: 32,
            right: 32,
            child: TextButton.icon(
              onPressed: () => _enterCinema(context),
              style: TextButton.styleFrom(
                foregroundColor: const Color(0xFFFFB020),
                backgroundColor: const Color(0x331A1611),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              ),
              icon: const Icon(Icons.skip_next, size: 20),
              label: const Text(
                'ENTER CINEMA',
                style: TextStyle(letterSpacing: 2, fontWeight: FontWeight.bold, fontSize: 13),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
