import 'package:flutter_test/flutter_test.dart';

import '../example/lib/main.dart';

void main() {
  testWidgets('smoke test for the app', (WidgetTester tester) async {
    await tester.pumpWidget(MyApp());
    expect(find.text("This item represents A."), findsOneWidget);
  });

  testWidgets('full dragging', (WidgetTester tester) async {
    await tester.pumpWidget(MyApp());
    await tester.drag(find.byType(MyApp), Offset(0.0, 400.0));
    tester.pumpAndSettle();
  });

  testWidgets('incomplete dragging', (WidgetTester tester) async {
    await tester.pumpWidget(MyApp());
    await tester.drag(find.byType(MyApp), Offset(0.0, 100.0));
    tester.pumpAndSettle();
  });
}
