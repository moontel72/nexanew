import 'package:flutter/material.dart';
import 'package:trace_odd/shared/theme/colors.dart';

class ScannerOverlay extends StatelessWidget {
  final bool isActive;
  final Color? activeColor;
  const ScannerOverlay({super.key, this.isActive = true, this.activeColor});
  @override
  Widget build(BuildContext context) => IgnorePointer(
    child: CustomPaint(
      size: MediaQuery.of(context).size,
      painter: _ScannerOverlayPainter(
        isActive: isActive,
        activeColor: activeColor ?? AppColors.accent,
      ),
    ),
  );
}

class _ScannerOverlayPainter extends CustomPainter {
  final bool isActive;
  final Color activeColor;
  _ScannerOverlayPainter({required this.isActive, required this.activeColor});
  @override
  void paint(Canvas canvas, Size size) {
    final scanAreaSize = size.width * 0.65;
    final left = (size.width - scanAreaSize) / 2;
    final top = (size.height - scanAreaSize) / 2;
    final cl = scanAreaSize * 0.12;
    final overlayPaint = Paint()
      ..color = Colors.black.withOpacity(0.55)
      ..style = PaintingStyle.fill;
    final path = Path()..addRect(Rect.fromLTWH(0, 0, size.width, size.height));
    final cutout = RRect.fromRectAndRadius(
      Rect.fromLTWH(left, top, scanAreaSize, scanAreaSize),
      const Radius.circular(16),
    );
    path.addRRect(cutout);
    path.fillType = PathFillType.evenOdd;
    canvas.drawPath(path, overlayPaint);
    final borderPaint = Paint()
      ..color = isActive ? activeColor : Colors.grey
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5;
    canvas.drawRRect(cutout, borderPaint);
    final cp = Paint()
      ..color = isActive ? activeColor : Colors.grey
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4.0
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(Offset(left, top + cl), Offset(left, top), cp);
    canvas.drawLine(Offset(left, top), Offset(left + cl, top), cp);
    canvas.drawLine(
      Offset(left + scanAreaSize - cl, top),
      Offset(left + scanAreaSize, top),
      cp,
    );
    canvas.drawLine(
      Offset(left + scanAreaSize, top),
      Offset(left + scanAreaSize, top + cl),
      cp,
    );
    canvas.drawLine(
      Offset(left, top + scanAreaSize - cl),
      Offset(left, top + scanAreaSize),
      cp,
    );
    canvas.drawLine(
      Offset(left, top + scanAreaSize),
      Offset(left + cl, top + scanAreaSize),
      cp,
    );
    canvas.drawLine(
      Offset(left + scanAreaSize - cl, top + scanAreaSize),
      Offset(left + scanAreaSize, top + scanAreaSize),
      cp,
    );
    canvas.drawLine(
      Offset(left + scanAreaSize, top + scanAreaSize),
      Offset(left + scanAreaSize, top + scanAreaSize - cl),
      cp,
    );
    final tp = TextPainter(
      text: TextSpan(
        text: 'Align code within the frame',
        style: TextStyle(
          color: Colors.white.withOpacity(0.7),
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
      ),
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.center,
    )..layout(maxWidth: scanAreaSize);
    tp.paint(canvas, Offset(left, top + scanAreaSize + 24));
  }

  @override
  bool shouldRepaint(covariant _ScannerOverlayPainter oldDelegate) =>
      isActive != oldDelegate.isActive ||
      activeColor != oldDelegate.activeColor;
}
