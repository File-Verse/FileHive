import 'package:flutter_test/flutter_test.dart';
import 'package:filehive/main.dart';

void main() {
  testWidgets('App loads successfully', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const FileHiveApp());

    // Verify that the app loaded without crashing.
    expect(find.byType(FileHiveApp), findsOneWidget);
  });
}