// Pencil3DButton — Custom 3D pencil-shaped navigation button
//
// Renders a horizontal right-pointing pencil shape with:
//   • Clean flat left edge flush against sidebar boundary
//   • Sharp single-point tip on the right (nook wali pencil)
//   • Gradient fill for beveled 3D shading
//   • Multi-layer BoxShadow for pronounced depth
//   • Unique vibrant color per instance for instant scannability
//
// Used in the Bus Owner Dashboard sidebar navigation deck.

import 'package:flutter/material.dart';

/// A single Pencil (nook wali pencil) 3D navigation button.
///
/// The button is drawn via [Pencil3DPainter] which produces a right-pointing
/// pencil shape with a flat left edge, tapered body, and sharp point.
class Missile3DButton extends StatelessWidget {
  /// Display label for the button.
  final String label;

  /// Icon displayed on the left side.
  final IconData icon;

  /// Background color of the button body.
  final Color color;

  /// Called when the button is tapped.
  final VoidCallback onTap;

  /// Optional subtitle shown below the label (deprecated in Phase 1).
  final String? subtitle;

  /// Height of the button. Defaults to 80.
  final double height;

  const Missile3DButton({
    super.key,
    required this.label,
    required this.icon,
    required this.color,
    required this.onTap,
    this.subtitle,
    this.height = 80,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: GestureDetector(
        onTap: onTap,
        child: CustomPaint(
          painter: Pencil3DPainter(color: color, shadowColor: color),
          size: Size(double.infinity, height),
          child: Padding(
            // Leave room for the pencil tip on the right (~48px)
            padding: const EdgeInsets.only(left: 20, right: 54),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.25),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: Colors.white, size: 22),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        label,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.3,
                          height: 1.2,
                        ),
                        maxLines: 2,
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

/// CustomPainter that draws a 3D pencil shape pointing right.
///
/// The shape has a clean flat left edge (no ears/notches)
/// and tapers to a sharp single-point tip on the right.
class Pencil3DPainter extends CustomPainter {
  final Color color;
  final Color shadowColor;

  Pencil3DPainter({required this.color, required this.shadowColor});

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final tipX = w; // the very right point
    final tipY = h / 2;
    final bodyW = w * 0.82; // body extends to 82% of width, rest is taper

    // ── Build the pencil path ────────────────────────────
    final path = Path();

    // Start at top-left (clean flat edge, no radius)
    path.moveTo(0, 0);

    // Top edge to the taper start
    path.lineTo(bodyW, 0);

    // Taper diagonally to the sharp pencil point
    path.lineTo(tipX, tipY);

    // Taper diagonally back from point to bottom of body
    path.lineTo(bodyW, h);

    // Bottom edge back to left
    path.lineTo(0, h);

    // Close back to top-left (clean vertical left edge)
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
    highlightPath.moveTo(0, 3);
    highlightPath.lineTo(bodyW, 3);
    highlightPath.lineTo(tipX - 2, tipY);

    final highlightPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.22)
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    canvas.drawPath(highlightPath, highlightPaint);

    // ── Subtle bottom shadow line inside ────────────────
    final bottomPath = Path();
    bottomPath.moveTo(0, h - 3);
    bottomPath.lineTo(bodyW, h - 3);
    bottomPath.lineTo(tipX - 2, tipY);

    final bottomPaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.12)
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    canvas.drawPath(bottomPath, bottomPaint);
  }

  @override
  bool shouldRepaint(covariant Pencil3DPainter oldDelegate) =>
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
