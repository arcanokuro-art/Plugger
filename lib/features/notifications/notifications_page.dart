import 'package:flutter/material.dart';

import 'package:plugger/shared/widgets/empty_state.dart';

class NotificationsPage extends StatelessWidget {
  const NotificationsPage({super.key});

  @override
  Widget build(BuildContext context) => const EmptyState(
    Icons.notifications_none_rounded,
    'Todo al día',
    'Aquí aparecerán tus notificaciones cuando conectemos las cuentas.',
  );
}
