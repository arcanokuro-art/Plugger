part of '../profile_page.dart';

extension _ProfileEditor on _ProfilePageState {
  void _openPage(
    String title,
    Widget Function(BuildContext, ProfileData) content,
  ) {
    Navigator.of(context).push(
      PageRouteBuilder<void>(
        transitionDuration: Duration.zero,
        reverseTransitionDuration: Duration.zero,
        pageBuilder: (_, __, ___) => ValueListenableBuilder(
          valueListenable: _profile,
          builder: (context, data, _) => Scaffold(
            appBar: AppBar(title: Text(title), centerTitle: true),
            body: content(context, data),
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
      builder: (dialogContext) => AlertDialog(
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
        uri.host.contains(' ')) {
      return null;
    }
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
}
