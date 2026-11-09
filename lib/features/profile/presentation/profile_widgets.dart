part of '../profile_page.dart';

extension _ProfileWidgets on _ProfilePageState {
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
              _stat('$_postCount', 'Publicaciones'),
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
    return Material(
      color: colors.brightness == Brightness.light
          ? Colors.white
          : colors.surfaceContainer,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        side: BorderSide(color: colors.outlineVariant.withValues(alpha: .45)),
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
            _selectTab(index);
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
}
