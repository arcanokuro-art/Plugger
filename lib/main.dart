import 'package:flutter/material.dart';

import 'messages.dart';
import 'palette.dart';
import 'profile.dart';

void main() => runApp(const PluggerApp());

class PluggerApp extends StatelessWidget {
  const PluggerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Plugger',
      debugShowCheckedModeBanner: false,
      theme: pluggerLightTheme(),
      home: const PluggerHome(),
    );
  }
}

class SocialPost {
  const SocialPost({
    required this.author,
    required this.handle,
    required this.source,
    required this.time,
    required this.message,
    required this.icon,
    required this.color,
  });

  final String author;
  final String handle;
  final String source;
  final String time;
  final String message;
  final IconData icon;
  final Color color;
}

const demoPosts = [
  SocialPost(
    author: 'Mariana López',
    handle: '@mariana',
    source: 'Plugger',
    time: 'Hace 12 min',
    message: '¡Hola, Plugger! ✨ Un nuevo espacio para descubrir y compartir todo lo que nos gusta.',
    icon: Icons.auto_awesome,
    color: pluggerViolet,
  ),
  SocialPost(
    author: 'Canal Creativo',
    handle: '@creativo',
    source: 'YouTube · Demo',
    time: 'Hace 1 h',
    message: '🎬 Hoy descubrimos nuevas ideas para crear contenido. Próximamente podremos explorar videos aquí.',
    icon: Icons.play_circle_fill,
    color: Color(0xFFE5484D),
  ),
  SocialPost(
    author: 'Noticias Tech',
    handle: '@noticiastech',
    source: 'X · Demo',
    time: 'Hace 3 h',
    message: 'La tecnología conecta comunidades. Este es un ejemplo visual de una publicación externa.',
    icon: Icons.tag,
    color: Color(0xFF22232A),
  ),
];

class PluggerHome extends StatefulWidget {
  const PluggerHome({super.key});

  @override
  State<PluggerHome> createState() => _PluggerHomeState();
}

class _PluggerHomeState extends State<PluggerHome> {
  int _tab = 0;
  String _filter = 'Todos';
  final List<SocialPost> _posts = [...demoPosts];
  final Set<SocialPost> _liked = {};
  final List<String> _ownPosts = [];
  final _profile = ValueNotifier(const ProfileData());

  @override
  void dispose() {
    _profile.dispose();
    super.dispose();
  }

  void _compose() {
    final controller = TextEditingController();
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (sheetContext) => Padding(
        padding: EdgeInsets.fromLTRB(
          20,
          8,
          20,
          MediaQuery.viewInsetsOf(sheetContext).bottom + 24,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Crear publicación',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: controller,
              maxLines: 5,
              minLines: 3,
              maxLength: 500,
              decoration: const InputDecoration(
                hintText: '¿Qué quieres compartir?',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: () {
                  final message = controller.text.trim();
                  if (message.isEmpty) return;
                  setState(() {
                    _ownPosts.insert(0, message);
                    _posts.insert(
                      0,
                      SocialPost(
                        author: 'Tu perfil',
                        handle: '@usuario',
                        source: 'Plugger',
                        time: 'Ahora',
                        message: message,
                        icon: Icons.auto_awesome,
                        color: pluggerViolet,
                      ),
                    );
                    _filter = 'Todos';
                    _tab = 0;
                  });
                  Navigator.pop(sheetContext);
                },
                icon: const Icon(Icons.send_rounded),
                label: const Text('Publicar'),
              ),
            ),
          ],
        ),
      ),
    ).whenComplete(controller.dispose);
  }

  @override
  Widget build(BuildContext context) => ValueListenableBuilder(
    valueListenable: _profile,
    builder: (context, data, _) => Theme(
      data: _tab == 4 ? profileTheme(data) : Theme.of(context),
      child: _home(),
    ),
  );

  Widget _home() {
    final titles = ['Inicio', 'Explorar', 'Notificaciones', 'Mensajes', 'Perfil'];
    final profile = _tab == 4;
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            const Icon(Icons.hub_rounded, color: pluggerViolet, size: 28),
            const SizedBox(width: 9),
            Text(
              profile
                  ? 'Plugger'
                  : _tab == 0
                  ? 'plugger'
                  : titles[_tab],
              style: const TextStyle(
                fontWeight: FontWeight.w800,
                letterSpacing: -0.6,
              ),
            ),
          ],
        ),
        actions: [
          if (_tab != 3)
            IconButton(
              tooltip: 'Buscar',
              onPressed: () => setState(() => _tab = 1),
              icon: const Icon(Icons.search_rounded),
            ),
          if (profile)
            IconButton(
              tooltip: 'Avisos',
              onPressed: () => setState(() => _tab = 2),
              icon: const Icon(Icons.notifications_none),
            ),
          const SizedBox(width: 8),
        ],
      ),
      body: IndexedStack(
        index: _tab,
        children: [
          _feed(),
          _explore(),
          _emptyPage(
            Icons.notifications_none_rounded,
            'Todo al día',
            'Aquí aparecerán tus notificaciones cuando conectemos las cuentas.',
          ),
          const MessagesPage(),
          ProfilePage(
            profile: _profile,
            posts: _ownPosts,
            onCompose: _compose,
          ),
        ],
      ),
      floatingActionButton: _tab == 0
          ? FloatingActionButton.extended(
              onPressed: _compose,
              icon: const Icon(Icons.edit_rounded),
              label: const Text('Publicar'),
            )
          : null,
      bottomNavigationBar: NavigationBar(
        labelBehavior: NavigationDestinationLabelBehavior.alwaysHide,
        selectedIndex: _tab,
        onDestinationSelected: (value) => setState(() => _tab = value),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Inicio',
          ),
          NavigationDestination(
            icon: Icon(Icons.explore_outlined),
            selectedIcon: Icon(Icons.explore),
            label: 'Explorar',
          ),
          NavigationDestination(
            icon: Icon(Icons.notifications_none),
            selectedIcon: Icon(Icons.notifications),
            label: 'Avisos',
          ),
          NavigationDestination(
            icon: Icon(Icons.chat_bubble_outline),
            selectedIcon: Icon(Icons.chat_bubble),
            label: 'Mensajes',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: 'Perfil',
          ),
        ],
      ),
    );
  }

  Widget _feed() {
    final filtered = _posts.where((post) {
      if (_filter == 'Todos') return true;
      if (_filter == 'Plugger') return post.source == 'Plugger';
      return post.source.startsWith(_filter);
    }).toList();

    return ListView(
      padding: const EdgeInsets.only(bottom: 100),
      children: [
        Container(
          padding: const EdgeInsets.fromLTRB(20, 22, 20, 18),
          color: Colors.white,
          child: const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Tu mundo, en un solo lugar 👋',
                style: TextStyle(
                  fontSize: 23,
                  fontWeight: FontWeight.bold,
                  color: pluggerInk,
                ),
              ),
              SizedBox(height: 6),
              Text(
                'Descubre novedades de tu comunidad y tus plataformas favoritas.',
                style: TextStyle(color: Colors.black54),
              ),
            ],
          ),
        ),
        SizedBox(
          height: 68,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            children: ['Todos', 'Plugger', 'YouTube', 'X'].map((filter) {
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: ChoiceChip(
                  label: Text(filter),
                  selected: _filter == filter,
                  onSelected: (_) => setState(() => _filter = filter),
                ),
              );
            }).toList(),
          ),
        ),
        if (filtered.isEmpty)
          _emptyPage(
            Icons.dynamic_feed_outlined,
            'Sin publicaciones',
            'Todavía no hay contenido en esta categoría.',
          )
        else
          ...filtered.map((post) => _postCard(post)),
      ],
    );
  }

  Widget _postCard(SocialPost post) {
    final liked = _liked.contains(post);
    return Card(
      margin: const EdgeInsets.fromLTRB(14, 5, 14, 11),
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(17),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: post.color.withValues(alpha: 0.12),
                  child: Icon(post.icon, color: post.color),
                ),
                const SizedBox(width: 11),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        post.author,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        '${post.handle} · ${post.time}',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.black54,
                        ),
                      ),
                    ],
                  ),
                ),
                Chip(
                  avatar: Icon(post.icon, size: 15, color: post.color),
                  label: Text(
                    post.source,
                    style: const TextStyle(fontSize: 11),
                  ),
                  visualDensity: VisualDensity.compact,
                ),
              ],
            ),
            const SizedBox(height: 18),
            Text(
              post.message,
              style: const TextStyle(fontSize: 15, height: 1.45),
            ),
            const SizedBox(height: 15),
            const Divider(height: 1),
            Wrap(
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                TextButton.icon(
                  onPressed: () => setState(() {
                    if (liked) {
                      _liked.remove(post);
                    } else {
                      _liked.add(post);
                    }
                  }),
                  icon: Icon(
                    liked ? Icons.favorite : Icons.favorite_border,
                    size: 19,
                    color: liked ? Colors.pink : null,
                  ),
                  label: Text(liked ? 'Te gusta' : 'Me gusta'),
                ),
                TextButton.icon(
                  onPressed: () => _notice(
                    'Los comentarios estarán disponibles próximamente.',
                  ),
                  icon: const Icon(Icons.mode_comment_outlined, size: 19),
                  label: const Text('Comentar'),
                ),
                IconButton(
                  tooltip: 'Compartir',
                  onPressed: () =>
                      _notice('Próximamente podrás compartir publicaciones.'),
                  icon: const Icon(Icons.share_outlined, size: 20),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _explore() {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        const Text(
          'Descubre más',
          style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        const Text(
          'Explora las fuentes que formarán parte de tu experiencia.',
          style: TextStyle(color: Colors.black54),
        ),
        const SizedBox(height: 24),
        ...[
          ('Plugger', 'Tu comunidad', Icons.hub, pluggerViolet),
          ('YouTube', 'Videos y creadores', Icons.play_circle_fill, Colors.red),
          ('X', 'Conversaciones y tendencias', Icons.tag, pluggerInk),
          ('Facebook', 'Páginas y publicaciones', Icons.groups, Colors.blue),
        ].map(
          (item) => Card(
            color: Colors.white,
            elevation: 0,
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: item.$4.withValues(alpha: 0.12),
                child: Icon(item.$3, color: item.$4),
              ),
              title: Text(
                item.$1,
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              subtitle: Text(item.$2),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => _notice(
                'La integración con ${item.$1} llegará en una etapa posterior.',
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _emptyPage(IconData icon, String title, String subtitle) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 62, color: pluggerViolet),
            const SizedBox(height: 16),
            Text(
              title,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.black54),
            ),
          ],
        ),
      ),
    );
  }

  void _notice(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }
}
