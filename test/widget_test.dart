import 'package:flutter_test/flutter_test.dart';
import 'package:movie_tracker_app/app.dart';
import 'package:movie_tracker_app/utils/app_strings.dart';

void main() {
  testWidgets(
    'MVP skeleton opens home screen',
    (WidgetTester tester) async {
      await tester.pumpWidget(
        const MovieTrackerApp(),
      );

      expect(
        find.text(AppStrings.appName),
        findsOneWidget,
      );

      await tester.pump(
        const Duration(milliseconds: 1300),
      );

      await tester.pumpAndSettle();

      expect(
        find.text(AppStrings.mvpReady),
        findsOneWidget,
      );
    },
  );
}
