import 'package:flutter_test/flutter_test.dart';
import 'package:apk/main.dart';
  import 'package:apk/splash_screen.dart'; 

void main() {
  testWidgets('SplashScreen renders', (WidgetTester tester) async {
    await tester.pumpWidget(const ExoticApp());
    await tester.pump();
    expect(find.byType(SplashScreen), findsOneWidget);
  });
}