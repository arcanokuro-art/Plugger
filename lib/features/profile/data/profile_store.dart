part of '../profile_page.dart';

class _ProfileStore {
  static const _storageKey = 'plugger.profile';

  static Future<ProfileData?> load() async {
    final prefs = await SharedPreferences.getInstance();
    final stored = prefs.getString(_storageKey);
    return stored == null
        ? null
        : ProfileData(jsonDecode(stored) as Map<String, dynamic>);
  }

  static Future<void> save(ProfileData data) async {
    final prefs = await SharedPreferences.getInstance();
    if (!await prefs.setString(_storageKey, jsonEncode(data.values))) {
      throw StateError('No se pudo guardar el perfil.');
    }
  }
}
