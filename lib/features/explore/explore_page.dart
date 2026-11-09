import 'package:flutter/material.dart';

import 'package:plugger/shared/widgets/notice.dart';

class ExplorePage extends StatelessWidget {
  const ExplorePage({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        const Text(
          'Descubre más',
          style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Text(
          'Explora las fuentes que formarán parte de tu experiencia.',
          style: TextStyle(color: colors.onSurfaceVariant),
        ),
        const SizedBox(height: 24),
        ...[
          ('Plugger', 'Tu comunidad', Icons.hub, colors.primary),
          ('YouTube', 'Videos y creadores', Icons.play_circle_fill, Colors.red),
          ('X', 'Conversaciones y tendencias', Icons.tag, colors.onSurface),
          ('Facebook', 'Páginas y publicaciones', Icons.groups, Colors.blue),
        ].map(
          (item) => Card(
            color: colors.surface,
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
              onTap: () => showNotice(context, 
                'La integración con ${item.$1} llegará en una etapa posterior.',
              ),
            ),
          ),
        ),
      ],
    );
  }
}
