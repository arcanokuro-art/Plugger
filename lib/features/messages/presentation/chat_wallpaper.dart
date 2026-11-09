part of '../messages_page.dart';

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
