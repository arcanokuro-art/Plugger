import 'package:flutter/material.dart';

import 'package:plugger/shared/theme/palette.dart';
import '../domain/social_post.dart';

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
