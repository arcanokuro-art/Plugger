import 'package:flutter/material.dart';

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
