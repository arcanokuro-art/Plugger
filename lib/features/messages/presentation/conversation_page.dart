part of '../messages_page.dart';

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
                        color: colors.surface,
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
                color: colors.surface,
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
