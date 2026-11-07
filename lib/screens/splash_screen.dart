// ENTRANCE SEQUENCE:
// 0ms: 35mm SMPTE Film Leader countdown initiates (3-2-1)
// 3000ms: Countdown reaches zero
// 3100ms: Projector lamp white flash burst
// 3300ms: IrisShutterTransition cuts to Home screening

import 'package:flutter/material.dart';
import '../widgets/motion/projector_countdown_leader.dart';
import '../widgets/motion/iris_shutter_transition.dart';
import 'home_screen.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: ProjectorCountdownLeader(
        onCountdownComplete: () {
          Navigator.of(context).pushReplacement(
            IrisPageRoute(page: const HomeScreen()),
          );
        },
      ),
    );
  }
}
