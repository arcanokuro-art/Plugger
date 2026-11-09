import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'data/demo_contacts.dart';
part 'data/messages_store.dart';
part 'domain/chat_models.dart';
part 'presentation/contact_avatar.dart';
part 'presentation/conversation_page.dart';
part 'presentation/chat_wallpaper.dart';

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
      final saved = await _MessagesStore.load();
      if (saved == null || !mounted) return;
      final (contacts, threads) = saved;
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
    final data = _MessagesStore.encode(_contacts, _threads);
    _pendingSave = _pendingSave.then((_) async {
      try {
        await _MessagesStore.save(data);
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
