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
    expect(
      tester.widget<NavigationBar>(find.byType(NavigationBar)).labelBehavior,
      NavigationDestinationLabelBehavior.alwaysHide,
    );
    expect(find.byType(NavigationDestination), findsNWidgets(5));
    expect(find.byIcon(Icons.home), findsWidgets);
    expect(find.byIcon(Icons.explore_outlined), findsWidgets);
    expect(find.byIcon(Icons.notifications_none), findsWidgets);
    expect(find.byIcon(Icons.person_outline), findsWidgets);
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
    await tester.tap(find.byIcon(Icons.person_outline));
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

  testWidgets('A contact opens a chat and the message survives restart', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(390, 844));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(const PluggerApp());
    await tester.pumpAndSettle();
    final messagesTab = find.byIcon(Icons.chat_bubble_outline);
    await tester.tap(messagesTab);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Contactos'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Mariana López'));
    await tester.pumpAndSettle();
    expect(find.text('Aún no hay mensajes'), findsOneWidget);
    await tester.enterText(find.byType(TextField), 'Hola desde Plugger');
    await tester.tap(find.byTooltip('Enviar mensaje'));
    await tester.pumpAndSettle();
    expect(find.text('Hola desde Plugger'), findsOneWidget);

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pumpAndSettle();
    await tester.pumpWidget(const PluggerApp());
    await tester.pumpAndSettle();
    await tester.tap(messagesTab);
    await tester.pumpAndSettle();
    expect(find.text('Hola desde Plugger'), findsOneWidget);
  });

  testWidgets('The selected theme colors every tab and profile routes open instantly', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(390, 844));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(const PluggerApp());
    await tester.pumpAndSettle();
    await tester.tap(find.byIcon(Icons.person_outline));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Apariencia del perfil'));
    await tester.pumpAndSettle();

    final appearance = tester.element(find.text('Apariencia del perfil'));
    final route = ModalRoute.of(appearance)!;
    expect(route.transitionDuration, Duration.zero);
    expect(route.reverseTransitionDuration, Duration.zero);

    await tester.tap(find.text('Rojo'));
    await tester.pumpAndSettle();
    const red = Color(0xFF300F19);
    expect(Theme.of(appearance).scaffoldBackgroundColor, red);
    await tester.pageBack();
    await tester.pumpAndSettle();

    for (final icon in [
      Icons.home_outlined,
      Icons.explore_outlined,
      Icons.notifications_none,
      Icons.chat_bubble_outline,
    ]) {
      final destination = find.descendant(
        of: find.byType(NavigationBar),
        matching: find.byIcon(icon),
      );
      await tester.tap(destination);
      await tester.pumpAndSettle();
      final appBar = tester.element(find.byType(AppBar));
      expect(Theme.of(appBar).scaffoldBackgroundColor, red);
      expect(Theme.of(appBar).brightness, Brightness.dark);
    }
  });
}
