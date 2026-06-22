import 'package:flutter_test/flutter_test.dart';

import 'package:ponderada_04/app/game_finder_app.dart';

void main() {
  testWidgets('shows login screen', (WidgetTester tester) async {
    await tester.pumpWidget(const GameFinderApp());

    expect(find.text('FreeGame Finder'), findsOneWidget);
    expect(find.text('Login'), findsOneWidget);
    expect(find.text('Create account'), findsOneWidget);
  });

  testWidgets('navigates from login to register', (WidgetTester tester) async {
    await tester.pumpWidget(const GameFinderApp());

    await tester.tap(find.text('Create account'));
    await tester.pumpAndSettle();

    expect(
      find.text('Your saved games will stay linked to your profile.'),
      findsOneWidget,
    );
  });
}
