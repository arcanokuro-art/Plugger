part of '../messages_page.dart';

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
