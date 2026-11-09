import 'package:flutter/material.dart';

import 'package:plugger/features/explore/explore_page.dart';
import 'package:plugger/features/feed/data/demo_posts.dart';
import 'package:plugger/features/feed/domain/social_post.dart';
import 'package:plugger/features/feed/presentation/feed_page.dart';
import 'package:plugger/features/feed/presentation/post_composer.dart';
import 'package:plugger/features/messages/messages_page.dart';
import 'package:plugger/features/notifications/notifications_page.dart';
import 'package:plugger/features/profile/profile_page.dart';
import 'package:plugger/shared/theme/palette.dart';

class PluggerHome extends StatefulWidget {
  const PluggerHome({super.key, required this.profile});

  final ValueNotifier<ProfileData> profile;

  @override
  State<PluggerHome> createState() => _PluggerHomeState();
}

class _PluggerHomeState extends State<PluggerHome> {
  int _tab = 0;
  String _filter = 'Todos';
  final List<SocialPost> _posts = [...demoPosts];
  final Set<SocialPost> _liked = {};
  final List<String> _ownPosts = [];

  void _compose() {
    showPostComposer(context, (message) {
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
    });
  }

  void _toggleLike(SocialPost post) {
    setState(() {
      if (!_liked.remove(post)) _liked.add(post);
    });
  }

  @override
  Widget build(BuildContext context) {
    final titles = ['Inicio', 'Explorar', 'Notificaciones', 'Mensajes', 'Perfil'];
    final profile = _tab == 4;
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Icon(
              Icons.hub_rounded,
              color: Theme.of(context).colorScheme.primary,
              size: 28,
            ),
            const SizedBox(width: 9),
            Flexible(
              child: Text(
                profile
                    ? 'Plugger'
                    : _tab == 0
                    ? 'plugger'
                    : titles[_tab],
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.6,
                ),
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
          FeedPage(
            posts: _posts,
            likedPosts: _liked,
            filter: _filter,
            onFilter: (filter) => setState(() => _filter = filter),
            onLike: _toggleLike,
          ),
          const ExplorePage(),
          const NotificationsPage(),
          const MessagesPage(),
          ProfilePage(
            profile: widget.profile,
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
}
