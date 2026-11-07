import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:reelhouse/app.dart';
import 'package:reelhouse/data/local_storage_service.dart';
import 'package:reelhouse/data/local_movie_repository.dart';
import 'package:reelhouse/widgets/motion/ticket_tear_animation.dart';
import 'package:reelhouse/theme/motion.dart';

void main() {
  group('Widget & Animation Tests', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({});
    });

    testWidgets('TicketTearAnimation completes animation and stamps SAVED', (WidgetTester tester) async {
      bool isSaved = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StatefulBuilder(
              builder: (context, setState) {
                return TicketTearAnimation(
                  isSaved: isSaved,
                  title: 'OPPENHEIMER (1945)',
                  onToggle: () {
                    setState(() {
                      isSaved = !isSaved;
                    });
                  },
                );
              },
            ),
          ),
        ),
      );

      // Initially shows unstamped ticket stub
      expect(find.text('TEAR STUB'), findsOneWidget);
      expect(find.text('SAVED'), findsNothing);

      // Tap ticket to trigger tear sequence
      await tester.tap(find.byType(TicketTearAnimation));
      await tester.pump(); // Start animation controller

      // Pump through tear interval (300ms)
      await tester.pump(const Duration(milliseconds: 300));

      // Pump through screen shake and stamp slam (640ms total)
      await tester.pump(const Duration(milliseconds: 400));
      await tester.pumpAndSettle();

      // Verify rubber-stamp "SAVED" is slammed in
      expect(find.text('SAVED'), findsOneWidget);
    });

    testWidgets('Reduced motion disables motion and renders accessible fallback', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MotionScope(
              reduceMotion: true,
              child: TicketTearAnimation(
                isSaved: true,
                title: 'DUNE: PART TWO',
                onToggle: () {},
              ),
            ),
          ),
        ),
      );

      // With reduced motion, complex animation controller is replaced with direct accessible button
      expect(find.text('SAVED TO WATCHLIST'), findsOneWidget);
      expect(find.byType(OutlinedButton), findsOneWidget);
    });

    testWidgets('ReelhouseApp boots and displays initial frame', (WidgetTester tester) async {
      final storage = await LocalStorageService.init();
      final repository = LocalMovieRepository();

      await tester.pumpWidget(
        ReelhouseApp(
          storage: storage,
          repository: repository,
        ),
      );

      // Verify initial boot
      expect(find.byType(MaterialApp), findsOneWidget);
    });
  });
}
