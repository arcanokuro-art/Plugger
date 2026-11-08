import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

const profileBackground = Color(0xFF0D0F18);
const _violet = Color(0xFF9860FF);
const _assetPath = 'assets/profile/';
const _storageKey = 'plugger.profile';

const _themes = <(String, Color, Color)>[
  ('Predeterminado', profileBackground, _violet),
  ('Oscuro', Color(0xFF151620), Color(0xFFAAA9CC)),
  ('Claro', Color(0xFFF4F1FB), Color(0xFF683ACA)),
  ('Violeta', Color(0xFF1B1036), Color(0xFFAB65FF)),
  ('Azul', Color(0xFF081D35), Color(0xFF4FAAFF)),
  ('Rojo', Color(0xFF300F19), Color(0xFFFF637D)),
  ('Verde', Color(0xFF0E281E), Color(0xFF53D799)),
  ('Ámbar', Color(0xFF30210D), Color(0xFFFFBA52)),
  ('Rosa', Color(0xFF33182C), Color(0xFFFF80BE)),
];

const _networks = <(String, String, IconData, Color)>[
  ('youtube', 'YouTube', Icons.smart_display, Color(0xFFD71824)),
  ('x', 'X (Twitter)', Icons.close, Color(0xFF171820)),
  ('facebook', 'Facebook', Icons.facebook, Color(0xFF1877F2)),
  ('photos', 'Picasa', Icons.camera, Color(0xFF8451E6)),
];

ThemeData get profileTheme => _theme(const ProfileData());

ThemeData _theme(ProfileData data) {
  final (_, background, color) = _themes[data.theme];
  final brightness = data.theme == 2 ? Brightness.light : Brightness.dark;
  final accent = data.useAccent ? color : _violet;
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
      (values['theme'] as int? ?? 0).clamp(0, _themes.length - 1).toInt();
  bool get useAccent => values['accent'] as bool? ?? true;
  bool get coverEffect => values['effect'] as bool? ?? false;
  bool get rounded => values['rounded'] as bool? ?? true;

  ProfileData withValue(String key, Object? value) =>
      ProfileData({...values, key: value});
}

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key, required this.posts, required this.onCompose});

  final List<String> posts;
  final VoidCallback onCompose;

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final _profile = ValueNotifier(const ProfileData());
  final _prefs = SharedPreferencesAsync();
  final _scroll = ScrollController();
  int _tab = 0;
  bool _ready = false;
  Future<void> _pendingSave = Future.value();

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final stored = await _prefs.getString(_storageKey);
      if (!mounted) return;
      if (stored != null) {
        _profile.value = ProfileData(
          jsonDecode(stored) as Map<String, dynamic>,
        );
      }
    } catch (_) {
      if (mounted) _message('No se pudo recuperar el perfil guardado.');
    } finally {
      if (mounted) setState(() => _ready = true);
    }
  }

  @override
  void dispose() {
    _scroll.dispose();
    _profile.dispose();
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
        await _prefs.setString(_storageKey, jsonEncode(data.values));
      } catch (_) {
        if (mounted)
          _message('No se pudo guardar el cambio en el dispositivo.');
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
        final saved = await _prefs.getString(_storageKey);
        if (saved != null &&
            (jsonDecode(saved) as Map<String, dynamic>)[key] != previous) {
          final oldFile = File(previous);
          if (await oldFile.exists()) await oldFile.delete();
        }
      }
    } catch (_) {
      if (mounted) _message('No se pudo cargar la imagen.');
    }
  }

  void _openPage(
    String title,
    Widget Function(BuildContext, ProfileData) content,
  ) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => ValueListenableBuilder(
          valueListenable: _profile,
          builder: (_, data, __) => Theme(
            data: _theme(data),
            child: Builder(
              builder: (context) => Scaffold(
                appBar: AppBar(title: Text(title), centerTitle: true),
                body: content(context, data),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _editText(
    BuildContext context,
    String key,
    String label,
    String initial, {
    int lines = 1,
    bool required = false,
    bool url = false,
  }) async {
    var draft = initial;
    final formKey = GlobalKey<FormState>();
    final value = await showDialog<String>(
      context: context,
      builder: (dialogContext) => Theme(
        data: _theme(_profile.value),
        child: AlertDialog(
          title: Text(label),
          content: Form(
            key: formKey,
            child: TextFormField(
              initialValue: initial,
              onChanged: (value) => draft = value,
              autofocus: true,
              maxLines: lines,
              maxLength: url
                  ? null
                  : lines > 1
                  ? 240
                  : 80,
              keyboardType: url ? TextInputType.url : null,
              validator: (input) {
                final value = input?.trim() ?? '';
                if (required && value.isEmpty) return 'Escribe un valor.';
                if (key == 'handle' &&
                    !RegExp(r'^@?[A-Za-z0-9._]{2,30}$').hasMatch(value)) {
                  return 'Usa de 2 a 30 letras, números, puntos o guiones bajos.';
                }
                if (url && value.isNotEmpty && _webUri(value) == null) {
                  return 'Escribe un enlace válido.';
                }
                return null;
              },
              decoration: InputDecoration(labelText: label),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancelar'),
            ),
            FilledButton(
              onPressed: () {
                if (formKey.currentState!.validate()) {
                  Navigator.pop(dialogContext, draft.trim());
                }
              },
              child: const Text('Guardar'),
            ),
          ],
        ),
      ),
    );
    if (value == null || !mounted) return;
    await _update(
      key,
      key == 'handle' ? value.replaceFirst(RegExp(r'^@'), '') : value,
    );
  }

  Uri? _webUri(String value) {
    final uri = Uri.tryParse(value.contains('://') ? value : 'https://$value');
    if (uri == null ||
        !['https', 'http'].contains(uri.scheme) ||
        !uri.host.contains('.') ||
        uri.host.contains(' '))
      return null;
    return uri;
  }

  Future<void> _openLink(String value) async {
    final uri = _webUri(value);
    if (uri == null) return;
    try {
      if (await launchUrl(uri, mode: LaunchMode.externalApplication)) return;
    } catch (_) {
      // Surface launcher failures in the profile.
    }
    if (mounted) _message('No se pudo abrir el enlace.');
  }

  void _editProfile() {
    _openPage(
      'Editar perfil',
      (context, data) => ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _header(context, data, editing: true),
          const SizedBox(height: 16),
          _panel(context, data, [
            _editRow(
              Icons.person_outline,
              'Nombre',
              data.name,
              () => _editText(
                context,
                'name',
                'Nombre',
                data.name,
                required: true,
              ),
            ),
            _editRow(
              Icons.alternate_email,
              'Usuario',
              '@${data.handle}',
              () => _editText(
                context,
                'handle',
                'Usuario',
                data.handle,
                required: true,
              ),
            ),
            _editRow(
              Icons.edit_outlined,
              'Biografía',
              data.bio,
              () => _editText(context, 'bio', 'Biografía', data.bio, lines: 3),
            ),
            _editRow(
              Icons.account_circle_outlined,
              'Avatar',
              null,
              () => _pickImage('avatar'),
            ),
            _editRow(
              Icons.image_outlined,
              'Portada',
              null,
              () => _pickImage('cover'),
            ),
            _editRow(
              Icons.link,
              'Enlaces',
              'YouTube, X, Facebook y álbumes',
              _editLinks,
            ),
            _editRow(
              Icons.info_outline,
              'Sobre mí',
              'Ubicación, sitio web e intereses',
              _editAbout,
            ),
            _editRow(
              Icons.settings_outlined,
              'Apariencia del perfil',
              'Tema, colores y vista previa',
              _appearance,
            ),
          ]),
        ],
      ),
    );
  }

  void _editLinks() {
    _openPage(
      'Enlaces',
      (context, data) => ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text('Agrega enlaces a tus cuentas o álbumes.'),
          const SizedBox(height: 12),
          _panel(context, data, [
            for (final (key, label, icon, _) in _networks)
              _editRow(
                icon,
                label,
                data.text(key, 'Agregar enlace'),
                () => _editText(context, key, label, data.text(key), url: true),
              ),
          ]),
        ],
      ),
    );
  }

  void _editAbout() {
    _openPage(
      'Sobre mí',
      (context, data) => ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _panel(context, data, [
            _editRow(
              Icons.location_on_outlined,
              'Ubicación',
              data.text('location', 'México'),
              () => _editText(
                context,
                'location',
                'Ubicación',
                data.text('location', 'México'),
              ),
            ),
            _editRow(
              Icons.language,
              'Sitio web',
              data.text('website'),
              () => _editText(
                context,
                'website',
                'Sitio web',
                data.text('website'),
                url: true,
              ),
            ),
            _editRow(
              Icons.interests_outlined,
              'Intereses',
              data.text('interests', 'Dibujo, Animación, IA, Tecnología'),
              () => _editText(
                context,
                'interests',
                'Intereses',
                data.text('interests', 'Dibujo, Animación, IA, Tecnología'),
                lines: 2,
              ),
            ),
          ]),
        ],
      ),
    );
  }

  void _appearance() {
    _openPage(
      'Apariencia del perfil',
      (context, data) => DefaultTabController(
        length: 2,
        child: Column(
          children: [
            const TabBar(
              tabs: [
                Tab(text: 'Tema del perfil'),
                Tab(text: 'Vista previa'),
              ],
            ),
            Expanded(
              child: TabBarView(
                children: [
                  ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      const Text(
                        'Estos ajustes se aplican en este dispositivo.',
                      ),
                      const SizedBox(height: 16),
                      GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 3,
                              mainAxisSpacing: 12,
                              crossAxisSpacing: 10,
                              mainAxisExtent: 94,
                            ),
                        itemCount: _themes.length,
                        itemBuilder: (_, index) =>
                            _themeTile(context, data, index),
                      ),
                      const SizedBox(height: 16),
                      _panel(context, data, [
                        SwitchListTile(
                          title: const Text('Usar color de acento'),
                          value: data.useAccent,
                          onChanged: (value) => _update('accent', value),
                        ),
                        SwitchListTile(
                          title: const Text('Efecto en portada'),
                          value: data.coverEffect,
                          onChanged: (value) => _update('effect', value),
                        ),
                        SwitchListTile(
                          title: const Text('Bordes redondeados'),
                          value: data.rounded,
                          onChanged: (value) => _update('rounded', value),
                        ),
                      ]),
                    ],
                  ),
                  ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      _header(context, data),
                      _identity(context, data),
                      const SizedBox(height: 16),
                      _post(context, data),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _themeTile(BuildContext context, ProfileData data, int index) {
    final (name, background, color) = _themes[index];
    final selected = data.theme == index;
    return InkWell(
      onTap: () => _update('theme', index),
      borderRadius: BorderRadius.circular(12),
      child: Column(
        children: [
          Expanded(
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(9),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Color.alphaBlend(color.withValues(alpha: .36), background),
                    background,
                  ],
                ),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: selected ? color : color.withValues(alpha: .35),
                  width: selected ? 2 : 1,
                ),
              ),
              child: Align(
                alignment: Alignment.bottomRight,
                child: Icon(
                  selected ? Icons.check_circle : Icons.view_agenda_outlined,
                  size: 21,
                  color: color,
                ),
              ),
            ),
          ),
          const SizedBox(height: 4),
          FittedBox(fit: BoxFit.scaleDown, child: Text(name)),
        ],
      ),
    );
  }

  Widget _header(
    BuildContext context,
    ProfileData data, {
    bool editing = false,
  }) {
    final accent = Theme.of(context).colorScheme.primary;
    return LayoutBuilder(
      builder: (context, constraints) {
        final height = (constraints.maxWidth * .42)
            .clamp(124.0, 252.0)
            .toDouble();
        return SizedBox(
          height: height + 44,
          child: Stack(
            children: [
              Positioned(
                left: 0,
                right: 0,
                top: 0,
                height: height,
                child: ClipRRect(
                  borderRadius: _radius(data),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      _image(data, 'cover'),
                      if (data.coverEffect)
                        DecoratedBox(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topRight,
                              end: Alignment.bottomLeft,
                              colors: [
                                accent.withValues(alpha: .4),
                                Colors.transparent,
                                Colors.black54,
                              ],
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              Positioned(
                left: 14,
                bottom: 0,
                child: Container(
                  width: 108,
                  height: 108,
                  padding: const EdgeInsets.all(3),
                  decoration: BoxDecoration(
                    color: accent,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: accent.withValues(alpha: .55),
                        blurRadius: 12,
                      ),
                    ],
                  ),
                  child: ClipOval(child: _image(data, 'avatar')),
                ),
              ),
              if (editing) ...[
                Positioned(
                  right: 5,
                  top: height - 49,
                  child: _camera('Cambiar portada', 'cover'),
                ),
                Positioned(
                  left: 84,
                  bottom: 0,
                  child: _camera('Cambiar avatar', 'avatar'),
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _camera(String label, String key) => IconButton.filledTonal(
    tooltip: label,
    onPressed: () => _pickImage(key),
    icon: const Icon(Icons.photo_camera_outlined),
  );

  Widget _image(ProfileData data, String key) {
    final asset = Image.asset('$_assetPath$key.webp', fit: BoxFit.cover);
    final path = data.text(key);
    return path.isEmpty
        ? asset
        : Image.file(
            File(path),
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => asset,
          );
  }

  Widget _identity(BuildContext context, ProfileData data) {
    final text = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.fromLTRB(6, 10, 6, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            data.name,
            style: text.headlineSmall?.copyWith(fontWeight: FontWeight.w800),
          ),
          Text(
            '@${data.handle}',
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          if (data.bio.isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(data.bio),
          ],
          const SizedBox(height: 16),
          Row(
            children: [
              _stat('${widget.posts.length + 1}', 'Publicaciones'),
              _stat('0', 'Seguidores'),
              _stat('0', 'Siguiendo'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _stat(String count, String label) => Expanded(
    child: Column(
      children: [
        Text(
          count,
          style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 18),
        ),
        Text(
          label,
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 12),
        ),
      ],
    ),
  );

  BorderRadius _radius(ProfileData data) =>
      BorderRadius.circular(data.rounded ? 18 : 3);

  Widget _panel(BuildContext context, ProfileData data, List<Widget> children) {
    final colors = Theme.of(context).colorScheme;
    return Container(
      decoration: BoxDecoration(
        color: colors.surfaceContainer,
        border: Border.all(color: colors.outlineVariant.withValues(alpha: .45)),
        borderRadius: _radius(data),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (int i = 0; i < children.length; i++) ...[
            if (i > 0) const Divider(height: 1, indent: 14, endIndent: 14),
            children[i],
          ],
        ],
      ),
    );
  }

  Widget _editRow(
    IconData icon,
    String title,
    String? subtitle,
    VoidCallback onTap,
  ) => ListTile(
    leading: Icon(icon),
    title: Text(title),
    subtitle: subtitle == null
        ? null
        : Text(subtitle, maxLines: 2, overflow: TextOverflow.ellipsis),
    trailing: const Icon(Icons.chevron_right),
    onTap: onTap,
  );

  Widget _post(BuildContext context, ProfileData data, [String? message]) =>
      _panel(context, data, [
        ListTile(
          leading: SizedBox(
            width: 36,
            height: 36,
            child: ClipOval(child: _image(data, 'avatar')),
          ),
          title: Text(data.name),
          subtitle: Text(message == null ? 'Publicación de muestra' : 'Ahora'),
        ),
        if (message == null)
          Padding(
            padding: const EdgeInsets.all(8),
            child: ClipRRect(
              borderRadius: _radius(data),
              child: Image.asset(
                '${_assetPath}post.webp',
                fit: BoxFit.cover,
                width: double.infinity,
              ),
            ),
          )
        else
          Padding(padding: const EdgeInsets.all(14), child: Text(message)),
      ]);

  Widget _tabButton(
    BuildContext context,
    ProfileData data,
    int index,
    String label,
    IconData icon,
  ) {
    final selected = _tab == index;
    final colors = Theme.of(context).colorScheme;
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 3),
        child: InkWell(
          borderRadius: _radius(data),
          onTap: () {
            if (_tab != index && (_tab == 3 || index == 3)) _scroll.jumpTo(0);
            setState(() => _tab = index);
          },
          child: Ink(
            height: 66,
            decoration: BoxDecoration(
              color: selected
                  ? colors.primaryContainer
                  : colors.surfaceContainer,
              borderRadius: _radius(data),
              border: selected ? Border.all(color: colors.primary) : null,
              boxShadow: selected
                  ? [
                      BoxShadow(
                        color: colors.primary.withValues(alpha: .35),
                        blurRadius: 9,
                      ),
                    ]
                  : null,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, size: 23),
                const SizedBox(height: 5),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(label, style: const TextStyle(fontSize: 12)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _connected(BuildContext context, ProfileData data) {
    final website = data.text('website');
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _panel(context, data, [
          for (final (key, title, icon, color) in _networks)
            ListTile(
              leading: CircleAvatar(
                backgroundColor: color,
                foregroundColor: Colors.white,
                child: Icon(icon),
              ),
              title: Text(title),
              subtitle: Text(
                data.text(key).isEmpty
                    ? 'Agregar enlace'
                    : _webUri(data.text(key))?.host ?? '',
              ),
              trailing: Icon(
                data.text(key).isEmpty ? Icons.add_link : Icons.open_in_new,
              ),
              onTap: data.text(key).isEmpty
                  ? _editLinks
                  : () => _openLink(data.text(key)),
            ),
        ]),
        const SizedBox(height: 12),
        _panel(context, data, const [
          ListTile(
            leading: Icon(Icons.show_chart),
            title: Text('Actividad reciente'),
            subtitle: Text('Vista de demostración'),
          ),
          ListTile(
            leading: Icon(Icons.smart_display, color: Colors.redAccent),
            title: Text('Nuevo video en YouTube'),
            subtitle: Text('Proceso de animación en Velyntora'),
          ),
          ListTile(
            leading: Icon(Icons.close),
            title: Text('Publicación en X'),
            subtitle: Text('Avances de Velyntora Animation'),
          ),
          ListTile(
            leading: Icon(Icons.facebook, color: Colors.blueAccent),
            title: Text('Publicación en Facebook'),
            subtitle: Text('Nuevo arte realizado en Velyntora'),
          ),
        ]),
        const SizedBox(height: 12),
        _panel(context, data, [
          ListTile(
            leading: const Icon(Icons.info_outline),
            title: const Text('Sobre mí'),
            trailing: const Icon(Icons.edit_outlined),
            onTap: _editAbout,
          ),
          ListTile(
            leading: const Icon(Icons.location_on_outlined),
            title: const Text('Ubicación'),
            subtitle: Text(data.text('location', 'México')),
          ),
          ListTile(
            leading: const Icon(Icons.language),
            title: const Text('Sitio web'),
            subtitle: Text(website.isEmpty ? 'Agregar sitio web' : website),
            onTap: website.isEmpty ? _editAbout : () => _openLink(website),
          ),
          ListTile(
            leading: const Icon(Icons.interests_outlined),
            title: const Text('Intereses'),
            subtitle: Text(
              data.text('interests', 'Dibujo, Animación, IA, Tecnología'),
            ),
          ),
        ]),
      ],
    );
  }

  @override
  Widget build(BuildContext context) => ValueListenableBuilder(
    valueListenable: _profile,
    builder: (_, data, __) => Theme(
      data: _theme(data),
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
                                backgroundColor: _violet,
                                foregroundColor: const Color(0xFF100722),
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
