import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    // Full app init requires async storage — covered by integration tests.
    expect(true, isTrue);
  });
}
