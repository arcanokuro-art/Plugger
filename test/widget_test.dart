import 'package:flutter_test/flutter_test.dart';
import 'package:plugger/main.dart';

void main() {
  testWidgets('Plugger opens its home screen', (tester) async {
    await tester.pumpWidget(const PluggerApp());
    await tester.pumpAndSettle();

    expect(find.text('plugger'), findsOneWidget);
    expect(find.text('Inicio'), findsOneWidget);
    expect(find.text('Explorar'), findsOneWidget);
    expect(find.text('Avisos'), findsOneWidget);
    expect(find.text('Perfil'), findsOneWidget);
  });
}
