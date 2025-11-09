import 'package:flutter_test/flutter_test.dart';

import 'package:isaac_app/main.dart';

void main() {
  testWidgets('App works', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());
  });
}
