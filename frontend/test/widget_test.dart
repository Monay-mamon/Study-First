import 'package:flutter_test/flutter_test.dart';
import 'package:study_first/main.dart';

void main() {
  testWidgets('Study First app starts with AuthScreen', (WidgetTester tester) async {
    await tester.pumpWidget(const StudyFirstApp());

    expect(find.text('Study First'), findsWidgets);
    expect(find.text('Login'), findsOneWidget);
  });
}
