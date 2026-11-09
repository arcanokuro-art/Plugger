import 'package:flutter/material.dart';

import 'package:plugger/shared/widgets/empty_state.dart';
import 'package:plugger/shared/widgets/notice.dart';
import '../domain/social_post.dart';

class FeedPage extends StatelessWidget {
  const FeedPage({
    super.key,
    required this.posts,
    required this.likedPosts,
    required this.filter,
    required this.onFilter,
    required this.onLike,
  });

  final List<SocialPost> posts;
  final Set<SocialPost> likedPosts;
  final String filter;
  final ValueChanged<String> onFilter;
  final ValueChanged<SocialPost> onLike;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final filtered = posts.where((post) {
      if (filter == 'Todos') return true;
      if (filter == 'Plugger') return post.source == 'Plugger';
      return post.source.startsWith(filter);
    }).toList();

    return ListView(
      padding: const EdgeInsets.only(bottom: 100),
      children: [
        Container(
          padding: const EdgeInsets.fromLTRB(20, 22, 20, 18),
          color: colors.surface,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Tu mundo, en un solo lugar 👋',
                style: TextStyle(
                  fontSize: 23,
                  fontWeight: FontWeight.bold,
                  color: colors.onSurface,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Descubre novedades de tu comunidad y tus plataformas favoritas.',
                style: TextStyle(color: colors.onSurfaceVariant),
              ),
            ],
          ),
        ),
        SizedBox(
          height: 68,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            children: ['Todos', 'Plugger', 'YouTube', 'X'].map((source) {
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: ChoiceChip(
                  label: Text(source),
                  selected: filter == source,
                  onSelected: (_) => onFilter(source),
                ),
              );
            }).toList(),
          ),
        ),
        if (filtered.isEmpty)
          const EmptyState(
            Icons.dynamic_feed_outlined,
            'Sin publicaciones',
            'Todavía no hay contenido en esta categoría.',
          )
        else
          ...filtered.map((post) => _postCard(context, post)),
      ],
    );
  }

  Widget _postCard(BuildContext context, SocialPost post) {
    final colors = Theme.of(context).colorScheme;
    final liked = likedPosts.contains(post);
    final sourceColor = switch (post.source) {
      'Plugger' => colors.primary,
      'X · Demo' => colors.onSurface,
      _ => post.color,
    };
    return Card(
      margin: const EdgeInsets.fromLTRB(14, 5, 14, 11),
      elevation: 0,
      color: colors.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(17),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: sourceColor.withValues(alpha: 0.12),
                  child: Icon(post.icon, color: sourceColor),
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
                        style: TextStyle(
                          fontSize: 12,
                          color: colors.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                Chip(
                  avatar: Icon(post.icon, size: 15, color: sourceColor),
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
                  onPressed: () => onLike(post),
                  icon: Icon(
                    liked ? Icons.favorite : Icons.favorite_border,
                    size: 19,
                    color: liked ? Colors.pink : null,
                  ),
                  label: Text(liked ? 'Te gusta' : 'Me gusta'),
                ),
                TextButton.icon(
                  onPressed: () => showNotice(context, 
                    'Los comentarios estarán disponibles próximamente.',
                  ),
                  icon: const Icon(Icons.mode_comment_outlined, size: 19),
                  label: const Text('Comentar'),
                ),
                IconButton(
                  tooltip: 'Compartir',
                  onPressed: () =>
                      showNotice(context, 'Próximamente podrás compartir publicaciones.'),
                  icon: const Icon(Icons.share_outlined, size: 20),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
