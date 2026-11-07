// SCREEN: 404 Not Found
// Cinema themed 404: "THIS SCREEN ISN'T IN THE PROJECTION SCHEDULE"

import 'package:flutter/material.dart';
import '../theme/tokens.dart';
import '../theme/text_styles.dart';
import '../widgets/app_scaffold.dart';

class NotFoundScreen extends StatelessWidget {
  const NotFoundScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      showHeader: true,
      showFooter: true,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '404',
                style: TextStyle(
                  fontFamily: CinemaTokens.fontDisplay,
                  fontSize: 96,
                  letterSpacing: 6,
                  color: CinemaTokens.projectorAmber,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'THIS SCREEN ISN\'T IN THE PROJECTION SCHEDULE',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: CinemaTokens.fontDisplay,
                  fontSize: 28,
                  letterSpacing: 2,
                  color: CinemaTokens.bone,
                ),
              ),
              const SizedBox(height: 12),
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 480),
                child: Text(
                  'The projector beam illuminates an empty screen. The reel canister you requested does not exist in our cinema archives.',
                  textAlign: TextAlign.center,
                  style: CinemaText.bodyMedium(color: CinemaTokens.ash),
                ),
              ),
              const SizedBox(height: 28),
              ElevatedButton.icon(
                onPressed: () => Navigator.of(context).pushReplacementNamed('/home'),
                icon: const Icon(Icons.arrow_back, size: 18),
                label: const Text('RETURN TO MAIN SCREENING HALL'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
