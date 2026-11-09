part of '../messages_page.dart';

class _MessagesStore {
  static const _storageKey = 'plugger.messages';

  static Future<(List<_Contact>, Map<String, List<_Message>>)?> load() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString(_storageKey);
    if (saved == null) return null;
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
    return (contacts, threads);
  }

  static String encode(
    List<_Contact> contacts,
    Map<String, List<_Message>> threads,
  ) {
    return jsonEncode({
      'contacts': contacts.skip(_sampleContacts.length)
          .map((contact) => contact.toJson()).toList(),
      'threads': threads.map((id, messages) => MapEntry(
        id, messages.map((message) => message.toJson()).toList(),
      )),
    });
  }

  static Future<void> save(String data) async {
    final prefs = await SharedPreferences.getInstance();
    if (!await prefs.setString(_storageKey, data)) {
      throw StateError('No se pudo guardar la conversación.');
    }
  }
}
