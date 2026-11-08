import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _storageKey = 'plugger.messages';

const _sampleContacts = [
  _Contact('mariana', 'Mariana López', 'Contacto de muestra'),
  _Contact('luna', 'Luna Rivera', 'Contacto de muestra'),
  _Contact('alex', 'Alex Torres', 'Contacto de muestra'),
  _Contact('sofia', 'Sofía Reyes', 'Contacto de muestra'),
];

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

class MessagesPage extends StatefulWidget {
  const MessagesPage({super.key});

  @override
  State<MessagesPage> createState() => _MessagesPageState();
}

class _MessagesPageState extends State<MessagesPage> {
  final _contacts = <_Contact>[..._sampleContacts];
  final _threads = <String, List<_Message>>{};
  bool _ready = false;
  bool _showContacts = false;
  bool _alphabetical = false;
  String _query = '';
  Future<void> _pendingSave = Future.value();

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final saved = prefs.getString(_storageKey);
      if (saved == null || !mounted) return;
      final data = jsonDecode(saved) as Map<String, dynamic>;
      final contacts = (data['contacts'] as List<dynamic>)
          .cast<Map<String, dynamic>>().map(_Contact.fromJson).toList();
      final threads = (data['threads'] as Map<String, dynamic>).map(
        (id, messages) => MapEntry(
          id,
          (messages as List<dynamic>)
              .cast<Map<String, dynamic>>().map(_Message.fromJson).toList(),
        ),
      );
      _contacts.addAll(contacts);
      _threads.addAll(threads);
    } catch (_) {
      if (mounted) _notice('No se pudieron recuperar los mensajes locales.');
    } finally {
      if (mounted) setState(() => _ready = true);
    }
  }

  void _notice(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  void _save() {
    final data = jsonEncode({
      'contacts': _contacts.skip(_sampleContacts.length)
          .map((contact) => contact.toJson()).toList(),
      'threads': _threads.map((id, messages) => MapEntry(
        id, messages.map((message) => message.toJson()).toList(),
      )),
    });
    _pendingSave = _pendingSave.then((_) async {
      try {
        final prefs = await SharedPreferences.getInstance();
        if (!await prefs.setString(_storageKey, data)) {
          throw StateError('No se pudo guardar la conversación.');
        }
      } catch (_) {
        if (mounted) _notice('No se pudieron guardar los cambios en el teléfono.');
      }
    });
  }

  void _openChat(_Contact contact) {
    Navigator.of(context).push(MaterialPageRoute<void>(
      builder: (_) => _Conversation(
        contact: contact,
        initialMessages: _threads[contact.id] ?? const [],
        onSend: (messages) {
          setState(() => _threads[contact.id] = messages);
          _save();
        },
      ),
    ));
  }

  Future<void> _addContact() async {
    final form = GlobalKey<FormState>();
    var name = '';
    final result = await showDialog<String>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Agregar contacto'),
        content: Form(
          key: form,
          child: TextFormField(
            autofocus: true,
            maxLength: 60,
            decoration: const InputDecoration(labelText: 'Nombre'),
            onChanged: (value) => name = value.trim(),
            validator: (_) => name.isEmpty ? 'Escribe un nombre.' : null,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () {
              if (form.currentState!.validate()) Navigator.pop(dialogContext, name);
            },
            child: const Text('Agregar'),
          ),
        ],
      ),
    );
    if (result == null || !mounted) return;
    setState(() => _contacts.add(
      _Contact('local-${DateTime.now().microsecondsSinceEpoch}', result, ''),
    ));
    _save();
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final entries = _contacts.where((contact) {
      return (_showContacts || _threads.containsKey(contact.id)) &&
          contact.name.toLowerCase().contains(_query);
    }).toList();
    if (_showContacts && _alphabetical) {
      entries.sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
    } else if (!_showContacts) {
      entries.sort((a, b) =>
          _threads[b.id]!.last.time.compareTo(_threads[a.id]!.last.time));
    }

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 8, 12, 4),
          child: SizedBox(
            width: double.infinity,
            child: SegmentedButton<bool>(
              segments: const [
                ButtonSegment(
                  value: false,
                  icon: Icon(Icons.chat_bubble_outline),
                  label: Text('Chats'),
                ),
                ButtonSegment(
                  value: true,
                  icon: Icon(Icons.people_outline),
                  label: Text('Contactos'),
                ),
              ],
              selected: {_showContacts},
              onSelectionChanged: (selected) =>
                  setState(() => _showContacts = selected.single),
              showSelectedIcon: false,
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 8, 12, 4),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  onChanged: (value) => setState(() => _query = value.trim().toLowerCase()),
                  decoration: InputDecoration(
                    hintText: _showContacts ? 'Buscar contactos' : 'Buscar chats',
                    prefixIcon: const Icon(Icons.search),
                    filled: true,
                    fillColor: Colors.white,
                    isDense: true,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(28),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ),
              if (_showContacts) ...[
                const SizedBox(width: 6),
                IconButton(
                  tooltip: _alphabetical ? 'Orden original' : 'Ordenar de A a Z',
                  onPressed: () => setState(() => _alphabetical = !_alphabetical),
                  icon: Icon(Icons.sort_by_alpha, color: colors.primary),
                ),
              ],
            ],
          ),
        ),
        if (!_ready)
          const Expanded(child: Center(child: CircularProgressIndicator()))
        else
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 16),
              children: [
                if (_showContacts)
                  Card(
                    elevation: 0,
                    color: Colors.white,
                    child: ListTile(
                      leading: const Icon(Icons.person_add_alt_1_outlined),
                      title: const Text('Agregar contacto'),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: _addContact,
                    ),
                  ),
                if (entries.isEmpty)
                  Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      children: [
                        Icon(Icons.forum_outlined, size: 44, color: colors.primary),
                        const SizedBox(height: 12),
                        Text(
                          _query.isNotEmpty ? 'Sin resultados' : 'Aún no hay chats',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        if (!_showContacts && _query.isEmpty)
                          TextButton(
                            onPressed: () => setState(() => _showContacts = true),
                            child: const Text('Nuevo mensaje'),
                          ),
                      ],
                    ),
                  )
                else
                  Card(
                    elevation: 0,
                    color: Colors.white,
                    clipBehavior: Clip.antiAlias,
                    child: Column(
                      children: [
                        for (final contact in entries)
                          ListTile(
                            leading: _ContactAvatar(contact),
                            title: Text(contact.name),
                            subtitle: Text(
                              _showContacts ? _contactStatus(contact) : _summary(contact),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            trailing: _showContacts ? null : Text(
                              TimeOfDay.fromDateTime(_threads[contact.id]!.last.time)
                                  .format(context),
                            ),
                            onTap: () => _openChat(contact),
                          ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
      ],
    );
  }

  String _contactStatus(_Contact contact) =>
      contact.subtitle.isEmpty ? 'Contacto local' : contact.subtitle;

  String _summary(_Contact contact) {
    final last = _threads[contact.id]!.last;
    return last.image != null ? 'Foto' : last.text;
  }
}

class _ContactAvatar extends StatelessWidget {
  const _ContactAvatar(this.contact);

  final _Contact contact;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final initials = contact.name.split(RegExp(r'\s+')).take(2)
        .map((part) => part.characters.first.toUpperCase()).join();
    return CircleAvatar(
      backgroundColor: colors.primaryContainer,
      foregroundColor: colors.onPrimaryContainer,
      child: Text(initials),
    );
  }
}

class _Conversation extends StatefulWidget {
  const _Conversation({
    required this.contact,
    required this.initialMessages,
    required this.onSend,
  });

  final _Contact contact;
  final List<_Message> initialMessages;
  final ValueChanged<List<_Message>> onSend;

  @override
  State<_Conversation> createState() => _ConversationState();
}

class _ConversationState extends State<_Conversation> {
  final _draft = TextEditingController();
  late var _messages = [...widget.initialMessages];
  bool _picking = false;

  @override
  void dispose() {
    _draft.dispose();
    super.dispose();
  }

  void _send({String? image, String? sticker}) {
    final text = sticker ?? _draft.text.trim();
    if (text.isEmpty && image == null) return;
    setState(() => _messages = [
      ..._messages,
      _Message(text, DateTime.now(), image: image),
    ]);
    if (sticker == null) _draft.clear();
    widget.onSend(_messages);
  }

  Future<void> _pickPhoto() async {
    if (_picking) return;
    setState(() => _picking = true);
    try {
      final photo = await ImagePicker().pickImage(
        source: ImageSource.gallery,
        maxWidth: 1600,
        imageQuality: 88,
      );
      if (photo == null || !mounted) return;
      final directory = await getApplicationDocumentsDirectory();
      if (!mounted) return;
      final path =
          '${directory.path}/chat-photo-${DateTime.now().microsecondsSinceEpoch}';
      await photo.saveTo(path);
      if (mounted) {
        _send(image: path);
      } else {
        await File(path).delete();
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No se pudo adjuntar la foto.')),
        );
      }
    } finally {
      if (mounted) setState(() => _picking = false);
    }
  }

  Future<void> _chooseEmoji() async {
    final emoji = await showModalBottomSheet<String>(
      context: context,
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Wrap(
            children: [
              for (final emoji in ['👋', '😊', '💜', '😂', '✨', '👍', '🎨', '🙌'])
                TextButton(
                  onPressed: () => Navigator.pop(context, emoji),
                  child: Text(emoji, style: const TextStyle(fontSize: 26)),
                ),
            ],
          ),
        ),
      ),
    );
    if (!mounted || emoji == null) return;
    final selection = _draft.selection;
    final start = selection.isValid ? selection.start : _draft.text.length;
    final end = selection.isValid ? selection.end : start;
    _draft.value = TextEditingValue(
      text: _draft.text.replaceRange(start, end, emoji),
      selection: TextSelection.collapsed(offset: start + emoji.length),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0,
        title: Row(
          children: [
            _ContactAvatar(widget.contact),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(widget.contact.name, overflow: TextOverflow.ellipsis),
                  Text(
                    'Conversación local',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      body: CustomPaint(
        painter: _ChatWallpaper(colors.primary.withValues(alpha: .09)),
        child: Column(
          children: [
            Expanded(
              child: _messages.isEmpty
                  ? Center(
                      child: Card(
                        elevation: 0,
                        color: Colors.white,
                        margin: const EdgeInsets.all(24),
                        child: Padding(
                          padding: const EdgeInsets.all(18),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Text('Aún no hay mensajes'),
                              const Text('Escribe algo o toca el saludo.'),
                              TextButton(
                                onPressed: () => _send(sticker: '👋'),
                                child: const Text('👋', style: TextStyle(fontSize: 44)),
                              ),
                            ],
                          ),
                        ),
                      ),
                    )
                  : ListView.builder(
                      reverse: true,
                      padding: const EdgeInsets.all(12),
                      itemCount: _messages.length,
                      itemBuilder: (context, index) =>
                          _bubble(context, _messages[_messages.length - 1 - index]),
                    ),
            ),
            SafeArea(
              top: false,
              minimum: const EdgeInsets.fromLTRB(8, 4, 8, 8),
              child: Material(
                color: Colors.white,
                borderRadius: BorderRadius.circular(28),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    IconButton(
                      tooltip: 'Insertar emoji',
                      onPressed: _chooseEmoji,
                      icon: const Icon(Icons.emoji_emotions_outlined),
                    ),
                    Expanded(
                      child: TextField(
                        controller: _draft,
                        minLines: 1,
                        maxLines: 4,
                        maxLength: 2000,
                        textCapitalization: TextCapitalization.sentences,
                        decoration: const InputDecoration(
                          hintText: 'Mensaje',
                          border: InputBorder.none,
                          counterText: '',
                        ),
                      ),
                    ),
                    IconButton(
                      tooltip: 'Adjuntar foto',
                      onPressed: _picking ? null : _pickPhoto,
                      icon: const Icon(Icons.attach_file),
                    ),
                    IconButton.filled(
                      tooltip: 'Enviar mensaje',
                      onPressed: () => _send(),
                      icon: const Icon(Icons.send_rounded),
                    ),
                    const SizedBox(width: 4),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _bubble(BuildContext context, _Message message) {
    final colors = Theme.of(context).colorScheme;
    final image = message.image;
    return Align(
      alignment: Alignment.centerRight,
      child: Container(
        constraints: BoxConstraints(maxWidth: MediaQuery.sizeOf(context).width * .78),
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: colors.primaryContainer,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(18),
            topRight: Radius.circular(18),
            bottomLeft: Radius.circular(18),
            bottomRight: Radius.circular(5),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            if (image != null)
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.file(
                  File(image),
                  width: 240,
                  cacheWidth: 640,
                  errorBuilder: (_, __, ___) => const Text('Foto no disponible'),
                ),
              ),
            if (message.text.isNotEmpty) Text(
              message.text,
              style: TextStyle(color: colors.onPrimaryContainer),
            ),
            const SizedBox(height: 3),
            Text(
              TimeOfDay.fromDateTime(message.time).format(context),
              style: Theme.of(context).textTheme.labelSmall,
            ),
          ],
        ),
      ),
    );
  }
}

class _ChatWallpaper extends CustomPainter {
  const _ChatWallpaper(this.color);

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;
    for (int row = 0; row * 68 < size.height; row++) {
      for (double x = row.isEven ? 14 : 48; x < size.width; x += 68) {
        final y = row * 68 + 16.0;
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromLTWH(x, y, 25, 17), const Radius.circular(6),
          ),
          paint,
        );
        canvas.drawLine(Offset(x + 6, y + 17), Offset(x + 4, y + 21), paint);
        canvas.drawCircle(Offset(x + 35, y + 38), 3, paint);
        canvas.drawLine(Offset(x + 45, y + 9), Offset(x + 51, y + 9), paint);
        canvas.drawLine(Offset(x + 48, y + 6), Offset(x + 48, y + 12), paint);
      }
    }
  }

  @override
  bool shouldRepaint(_ChatWallpaper oldDelegate) => color != oldDelegate.color;
}
