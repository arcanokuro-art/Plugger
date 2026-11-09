part of '../messages_page.dart';

class _Contact {
  const _Contact(this.id, this.name, this.subtitle);

  final String id;
  final String name;
  final String subtitle;

  factory _Contact.fromJson(Map<String, dynamic> json) =>
      _Contact(json['id'] as String, json['name'] as String, '');

  Map<String, String> toJson() => {'id': id, 'name': name};
}

class _Message {
  const _Message(this.text, this.time, {this.image});

  final String text;
  final DateTime time;
  final String? image;

  factory _Message.fromJson(Map<String, dynamic> json) => _Message(
    json['text'] as String,
    DateTime.parse(json['time'] as String),
    image: json['image'] as String?,
  );

  Map<String, String?> toJson() =>
      {'text': text, 'time': time.toIso8601String(), 'image': image};
}
