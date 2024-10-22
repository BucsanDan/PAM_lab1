import 'package:flutter_test/flutter_test.dart';
// Asigură-te că calea este corectă

void main() {
  testWidgets('Testarea afisarii textului', (WidgetTester tester) async {
    // Construiește widgetul MyApp și injectează-l în test.
    await tester.pumpWidget(const MyApp());

    // Verifică dacă textul de introducere a valorii pentru conversie este afișat.
    expect(find.text('Introduceți valorile pentru conversie:'), findsOneWidget);
  });
}
