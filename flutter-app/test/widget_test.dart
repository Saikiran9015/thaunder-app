import 'package:flutter_test/flutter_test.dart';
import 'package:thundercut/main.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const ThunderCutApp());
    
    // Simply verify that the app builds without crashing
    expect(find.byType(ThunderCutApp), findsOneWidget);
  });
}
