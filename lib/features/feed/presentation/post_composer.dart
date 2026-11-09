import 'package:flutter/material.dart';

void showPostComposer(
  BuildContext context,
  ValueChanged<String> onPublish,
) {
  final controller = TextEditingController();
  showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (sheetContext) => Padding(
      padding: EdgeInsets.fromLTRB(
        20,
        8,
        20,
        MediaQuery.viewInsetsOf(sheetContext).bottom + 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Crear publicación',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: controller,
            maxLines: 5,
            minLines: 3,
            maxLength: 500,
            decoration: const InputDecoration(
              hintText: '¿Qué quieres compartir?',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: () {
                final message = controller.text.trim();
                if (message.isEmpty) return;
                onPublish(message);
                Navigator.pop(sheetContext);
              },
              icon: const Icon(Icons.send_rounded),
              label: const Text('Publicar'),
            ),
          ),
        ],
      ),
    ),
  ).whenComplete(controller.dispose);
}
