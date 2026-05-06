import 'package:flutter_test/flutter_test.dart';
import 'package:exotic_gaming_and_cafe/main.dart';
import 'package:exotic_gaming_and_cafe/splash_screen.dart';

void main() {
  testWidgets('SplashScreen renders', (WidgetTester tester) async {
    await tester.pumpWidget(const ExoticApp());
    await tester.pump();
    expect(find.byType(SplashScreen), findsOneWidget);
  });
}
