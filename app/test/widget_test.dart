import 'package:flutter_test/flutter_test.dart';

import 'package:ponderada_04/main.dart';

void main() {
  testWidgets('shows login screen', (WidgetTester tester) async {
    await tester.pumpWidget(const GameFinderApp());

    expect(find.text('FreeGame Finder'), findsOneWidget);
    expect(find.text('Enter app'), findsOneWidget);
    expect(find.text('Create account'), findsOneWidget);
  });

  testWidgets('navigates from login to home', (WidgetTester tester) async {
    await tester.pumpWidget(const GameFinderApp());

    await tester.tap(find.text('Enter app'));
    await tester.pump();

    expect(find.text('Discover'), findsOneWidget);
    expect(find.text('Recommended free games'), findsOneWidget);
  });
}
