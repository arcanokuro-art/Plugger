part of '../profile_page.dart';

const _classicDark = Color(0xFF0D0F18);
const _violet = Color(0xFF9860FF);
const _defaultThemeIndex = 2;

const _themes = <(String, Color, Color)>[
  ('Oscuro violeta', _classicDark, _violet),
  ('Oscuro', Color(0xFF151620), Color(0xFFAAA9CC)),
  ('Blanco', pluggerCanvas, pluggerViolet),
  ('Violeta', Color(0xFF1B1036), Color(0xFFAB65FF)),
  ('Azul', Color(0xFF081D35), Color(0xFF4FAAFF)),
  ('Rojo', Color(0xFF300F19), Color(0xFFFF637D)),
  ('Verde', Color(0xFF0E281E), Color(0xFF53D799)),
  ('Ámbar', Color(0xFF30210D), Color(0xFFFFBA52)),
  ('Rosa', Color(0xFF33182C), Color(0xFFFF80BE)),
];

ThemeData profileTheme(ProfileData data) {
  if (data.theme == _defaultThemeIndex) return pluggerLightTheme();
  final (_, background, color) = _themes[data.theme];
  final accent = data.useAccent ? color : _violet;
  const brightness = Brightness.dark;
  return ThemeData(
    brightness: brightness,
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: accent,
      brightness: brightness,
    ),
    scaffoldBackgroundColor: background,
    appBarTheme: AppBarTheme(backgroundColor: background, elevation: 0),
  );
}
