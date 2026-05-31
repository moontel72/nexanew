// Missile3DButton — Custom 3D arrow-shaped navigation button
//
// Renders a horizontal right-pointing missile/rocket shape with:
//   • Angular arrowhead on the right side
//   • Gradient fill for beveled 3D shading
//   • Multi-layer BoxShadow for pronounced depth
//   • Unique vibrant color per instance for instant scannability
//
// Used in the Bus Owner Dashboard sidebar navigation deck.

import 'package:flutter/material.dart';

/// A single Mizaeel (missile/arrow) 3D navigation button.
///
/// The button is drawn via [Missile3DPainter] which produces a right-pointing
/// arrow with a beveled gradient and stacked shadows for a tactile look.
class Missile3DButton extends StatelessWidget {
  /// Display label for the button.
  final String label;

  /// Icon displayed on the left (rocket body) side.
  final IconData icon;

  /// Background color of the button body.
  final Color color;

  /// Called when the button is tapped.
  final VoidCallback onTap;

  /// Optional subtitle shown below the label.
  final String? subtitle;

  /// Height of the button. Defaults to 64.
  final double height;

  const Missile3DButton({
    super.key,
    required this.label,
    required this.icon,
    required this.color,
    required this.onTap,
    this.subtitle,
    this.height = 64,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: GestureDetector(
        onTap: onTap,
        child: CustomPaint(
          painter: Missile3DPainter(color: color, shadowColor: color),
          size: Size(double.infinity, height),
          child: Padding(
            // Leave room for the arrowhead on the right (~40px)
            padding: const EdgeInsets.only(left: 18, right: 48),
            child: Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.25),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, color: Colors.white, size: 20),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        label,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.3,
                          height: 1.15,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (subtitle != null)
                        Text(
                          subtitle!,
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.75),
                            fontSize: 11,
                            fontWeight: FontWeight.w400,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// CustomPainter that draws a 3D missile/arrow shape pointing right.
class Missile3DPainter extends CustomPainter {
  final Color color;
  final Color shadowColor;

  Missile3DPainter({required this.color, required this.shadowColor});

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final arrowW = 36.0; // width of the arrowhead
    final r = 14.0; // corner radius on the body
    final tipX = w; // the very right point
    final tipY = h / 2;
    final baseX = w - arrowW; // where arrowhead meets body

    // ── Build the missile path ──────────────────────────
    final path = Path();

    // Start at top-left (with radius inset)
    path.moveTo(r, 0);

    // Top edge to the arrowhead base
    path.lineTo(baseX - r, 0);

    // Small rounded corner at top arrowhead junction
    path.arcToPoint(Offset(baseX + 6, 8), radius: const Radius.circular(6));

    // Angled top edge of arrowhead → tip
    path.lineTo(tipX - 4, tipY - 2);
    path.lineTo(tipX, tipY);

    // Angled bottom edge of arrowhead ← tip
    path.lineTo(tipX - 4, tipY + 2);
    path.lineTo(baseX + 6, h - 8);

    // Small rounded corner at bottom arrowhead junction
    path.arcToPoint(Offset(baseX - r, h), radius: const Radius.circular(6));

    // Bottom edge back to left
    path.lineTo(r, h);

    // Left rounded edge
    path.arcToPoint(Offset(0, h - r), radius: Radius.circular(r));
    path.lineTo(0, r);
    path.arcToPoint(Offset(r, 0), radius: Radius.circular(r));

    path.close();

    // ── Multi-layer shadows for 3D bevel effect ─────────
    final shadowPaint = Paint()
      ..color = shadowColor.withValues(alpha: 0.45)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);
    canvas.drawPath(path.shift(const Offset(0, 4)), shadowPaint);

    final shadowPaint2 = Paint()
      ..color = shadowColor.withValues(alpha: 0.25)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 12);
    canvas.drawPath(path.shift(const Offset(0, 8)), shadowPaint2);

    // ── Gradient fill for 3D surface ────────────────────
    final gradient = LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [_lighten(color, 0.35), color, _darken(color, 0.35)],
      stops: const [0.0, 0.45, 1.0],
    );

    final fillPaint = Paint()
      ..shader = gradient.createShader(Rect.fromLTWH(0, 0, w, h))
      ..style = PaintingStyle.fill;
    canvas.drawPath(path, fillPaint);

    // ── Top highlight line for bevel ────────────────────
    final highlightPath = Path();
    highlightPath.moveTo(r, 3);
    highlightPath.lineTo(baseX - r, 3);
    highlightPath.arcToPoint(
      Offset(baseX + 6, 9),
      radius: const Radius.circular(4),
    );
    highlightPath.lineTo(tipX - 4, tipY - 2);

    final highlightPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.22)
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    canvas.drawPath(highlightPath, highlightPaint);

    // ── Subtle bottom shadow line inside ────────────────
    final bottomPath = Path();
    bottomPath.moveTo(r, h - 3);
    bottomPath.lineTo(baseX - r, h - 3);
    bottomPath.arcToPoint(
      Offset(baseX + 6, h - 9),
      radius: const Radius.circular(4),
    );
    bottomPath.lineTo(tipX - 4, tipY + 2);

    final bottomPaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.12)
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    canvas.drawPath(bottomPath, bottomPaint);
  }

  @override
  bool shouldRepaint(covariant Missile3DPainter oldDelegate) =>
      color != oldDelegate.color || shadowColor != oldDelegate.shadowColor;

  /// Lighten a color by [amount] (0.0–1.0).
  static Color _lighten(Color c, double amount) {
    return Color.fromARGB(
      c.alpha,
      (c.red + ((255 - c.red) * amount).round()).clamp(0, 255),
      (c.green + ((255 - c.green) * amount).round()).clamp(0, 255),
      (c.blue + ((255 - c.blue) * amount).round()).clamp(0, 255),
    );
  }

  /// Darken a color by [amount] (0.0–1.0).
  static Color _darken(Color c, double amount) {
    return Color.fromARGB(
      c.alpha,
      (c.red * (1.0 - amount)).round().clamp(0, 255),
      (c.green * (1.0 - amount)).round().clamp(0, 255),
      (c.blue * (1.0 - amount)).round().clamp(0, 255),
    );
  }
}
