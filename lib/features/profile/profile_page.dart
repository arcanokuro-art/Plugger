import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:plugger/shared/theme/palette.dart';

part 'data/profile_networks.dart';
part 'data/profile_store.dart';
part 'domain/profile_data.dart';
part 'presentation/profile_theme.dart';
part 'presentation/profile_editor.dart';
part 'presentation/profile_appearance.dart';
part 'presentation/profile_widgets.dart';

const _assetPath = 'assets/profile/';

class ProfilePage extends StatefulWidget {
  const ProfilePage({
    super.key,
    required this.profile,
    required this.posts,
    required this.onCompose,
  });

  final ValueNotifier<ProfileData> profile;

  final List<String> posts;
  final VoidCallback onCompose;

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  ValueNotifier<ProfileData> get _profile => widget.profile;
  final _scroll = ScrollController();
  int _tab = 0;
  int get _postCount => widget.posts.length + 1;

  void _selectTab(int index) => setState(() => _tab = index);

  bool _ready = false;
  Future<void> _pendingSave = Future.value();

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final data = await _ProfileStore.load();
      if (mounted && data != null) _profile.value = data;
    } catch (_) {
      if (mounted) _message('No se pudo recuperar el perfil guardado.');
    } finally {
      if (mounted) setState(() => _ready = true);
    }
  }

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  void _message(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _update(String key, Object? value) {
    final data = _profile.value.withValue(key, value);
    _profile.value = data;
    _pendingSave = _pendingSave.then((_) async {
      try {
        await _ProfileStore.save(data);
      } catch (_) {
        if (mounted) {
          _message('No se pudo guardar el cambio en el dispositivo.');
        }
      }
    });
    return _pendingSave;
  }

  Future<void> _pickImage(String key) async {
    try {
      final image = await ImagePicker().pickImage(
        source: ImageSource.gallery,
        maxWidth: key == 'avatar' ? 768 : 1800,
        imageQuality: 88,
      );
      if (image == null || !mounted) return;
      final directory = await getApplicationDocumentsDirectory();
      final file = File(
        '${directory.path}/profile-$key-${DateTime.now().microsecondsSinceEpoch}',
      );
      await image.saveTo(file.path);
      if (!mounted) return;
      final previous = _profile.value.text(key);
      await _update(key, file.path);
      if (previous.isNotEmpty) {
        final saved = await _ProfileStore.load();
        if (saved != null && saved.values[key] != previous) {
          final oldFile = File(previous);
          if (await oldFile.exists()) await oldFile.delete();
        }
      }
    } catch (_) {
      if (mounted) _message('No se pudo cargar la imagen.');
    }
  }

  @override
  Widget build(BuildContext context) => ValueListenableBuilder(
    valueListenable: _profile,
    builder: (_, data, __) => Theme(
      data: profileTheme(data),
      child: Builder(
        builder: (context) => Material(
          color: Theme.of(context).scaffoldBackgroundColor,
          child: !_ready
              ? const Center(child: CircularProgressIndicator())
              : ListView(
                  controller: _scroll,
                  padding: const EdgeInsets.fromLTRB(12, 10, 12, 24),
                  children: [
                    if (_tab != 3) ...[
                      _header(context, data),
                      _identity(context, data),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: FilledButton.icon(
                              style: FilledButton.styleFrom(
                                minimumSize: const Size(0, 48),
                                backgroundColor: Theme.of(context)
                                    .colorScheme.primaryContainer,
                                foregroundColor: Theme.of(context)
                                    .colorScheme.onPrimaryContainer,
                              ),
                              onPressed: _editProfile,
                              icon: const Icon(Icons.edit_outlined),
                              label: const Text('Editar perfil'),
                            ),
                          ),
                          const SizedBox(width: 8),
                          IconButton.filledTonal(
                            onPressed: _appearance,
                            tooltip: 'Apariencia del perfil',
                            icon: const Icon(Icons.settings_outlined),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                    ],
                    Row(
                      children: [
                        _tabButton(
                          context,
                          data,
                          0,
                          'Publicaciones',
                          Icons.grid_view_rounded,
                        ),
                        _tabButton(
                          context,
                          data,
                          1,
                          'Fotos',
                          Icons.image_outlined,
                        ),
                        _tabButton(
                          context,
                          data,
                          2,
                          'Videos',
                          Icons.play_circle_outline,
                        ),
                        _tabButton(context, data, 3, 'Conectado', Icons.link),
                      ],
                    ),
                    const SizedBox(height: 16),
                    if (_tab == 0) ...[
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton.icon(
                          onPressed: widget.onCompose,
                          icon: const Icon(Icons.add),
                          label: const Text('Publicar'),
                        ),
                      ),
                      for (final post in widget.posts) ...[
                        _post(context, data, post),
                        const SizedBox(height: 10),
                      ],
                      _post(context, data),
                    ],
                    if (_tab == 1) _post(context, data),
                    if (_tab == 2)
                      _panel(context, data, const [
                        ListTile(
                          leading: Icon(Icons.play_circle_outline),
                          title: Text('Todavía no hay videos'),
                        ),
                      ]),
                    if (_tab == 3) _connected(context, data),
                  ],
                ),
        ),
      ),
    ),
  );
}
