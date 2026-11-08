import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:plugger/main.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  testWidgets('Plugger opens its home screen', (tester) async {
    await tester.pumpWidget(const PluggerApp());
    await tester.pumpAndSettle();

    expect(find.text('plugger'), findsOneWidget);
    expect(find.text('Inicio'), findsOneWidget);
    expect(find.text('Explorar'), findsOneWidget);
    expect(find.text('Avisos'), findsOneWidget);
    expect(find.text('Perfil'), findsOneWidget);
  });

  testWidgets('Profile edits are saved and the connected tab opens', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(390, 844));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(const PluggerApp());
    await tester.pumpAndSettle();
    final homeBar = Theme.of(tester.element(find.byType(AppBar)));
    final homeNavigation = Theme.of(tester.element(find.byType(NavigationBar)));
    await tester.tap(find.text('Perfil'));
    await tester.pumpAndSettle();
    final profileBar = Theme.of(tester.element(find.byType(AppBar)));
    final profileNavigation = Theme.of(
      tester.element(find.byType(NavigationBar)),
    );
    expect(profileBar.appBarTheme.backgroundColor, homeBar.appBarTheme.backgroundColor);
    expect(profileNavigation.colorScheme, homeNavigation.colorScheme);


    await tester.tap(find.text('Editar perfil'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Nombre'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextFormField), 'Perfil de prueba');
    await tester.tap(find.text('Guardar'));
    await tester.pumpAndSettle();

    expect(find.text('Perfil de prueba'), findsOneWidget);
    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getString('plugger.profile'), contains('Perfil de prueba'));

    await tester.pageBack();
    await tester.pumpAndSettle();
    await tester.tap(find.text('Conectado'));
    await tester.pumpAndSettle();
    expect(find.text('Actividad reciente'), findsOneWidget);
  });
}
