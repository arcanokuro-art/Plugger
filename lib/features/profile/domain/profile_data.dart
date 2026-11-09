part of '../profile_page.dart';

class ProfileData {
  const ProfileData([this.values = const {}]);

  final Map<String, Object?> values;

  String text(String key, [String fallback = '']) =>
      values[key] as String? ?? fallback;
  String get name => text('name', 'Kuro Arcano');
  String get handle => text('handle', 'kuro.arcano');
  String get bio => text(
    'bio',
    'Desarrollador • Artista • Creador de Velyntora\nDibujo, animación, tecnología y más. 🎨',
  );
  int get theme =>
      (values['theme'] as int? ?? 2).clamp(0, _themes.length - 1).toInt();
  bool get useAccent => values['accent'] as bool? ?? true;
  bool get coverEffect => values['effect'] as bool? ?? false;
  bool get rounded => values['rounded'] as bool? ?? true;

  ProfileData withValue(String key, Object? value) =>
      ProfileData({...values, key: value});
}
