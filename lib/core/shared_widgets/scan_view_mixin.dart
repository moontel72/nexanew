// Scan View Mixin — Injectable QR/NFC scan boundary overlay
//
// Lightweight mixin (< 100 lines) that can be added to any StatefulWidget
// to project a branded scan boundary.  Integrates HardwareScanService for
// callback dispatch and uses BrandingConfig colors for the overlay accent.
//
// Usage:
//   class _MyDashboardState extends State<MyDashboard>
//       with ScanViewMixin {
//     @override
//     Widget build(BuildContext context) {
//       return Scaffold(
//         body: Column(children: [
//           ...myWidgets,
//           buildCompactScanTrigger(context, UserPanel.factory),
//         ]),
//       );
//     }
//   }

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:nexatrace_system/core/navigation/panel_routes.dart';
import 'package:nexatrace_system/core/services/hardware_scan_service.dart';
import 'package:nexatrace_system/core/theme/branding_config.dart';
import 'package:nexatrace_system/shared/theme/colors.dart';

mixin ScanViewMixin<T extends StatefulWidget> on State<T> {
  HardwareScanService? _scanService;

  /// Bind a scan service.  Call in `initState()`.
  void bindScanService(HardwareScanService service) {
    _scanService = service;
  }

  /// The accent color used for scan boundary borders.
  Color _scanColorFor(UserPanel panel) => BrandingConfig.forPanel(panel).primaryColor;

  /// Compact scan trigger button — opens full-screen scanner.
  Widget buildCompactScanTrigger(BuildContext context, UserPanel panel) {
    final color = _scanColorFor(panel);
    return GestureDetector(
      onTap: () => _openFullScanner(context, panel),
      child: Container(
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          Icon(Icons.qr_code_scanner, color: color, size: 24.sp),
          SizedBox(width: 10.w),
          Text('Tap to Scan', style: TextStyle(color: color, fontWeight: FontWeight.w600, fontSize: 15.sp)),
        ]),
      ),
    );
  }

  /// Inline scan boundary overlay — projects a scanning frame with brand accent.
  Widget buildScanBoundary(BuildContext context, UserPanel panel, {Widget? child}) {
    final color = _scanColorFor(panel);
    return Stack(children: [
      if (child != null) child,
      IgnorePointer(
        child: CustomPaint(
          size: MediaQuery.of(context).size,
          painter: _ScanBoundaryPainter(color: color),
        ),
      ),
    ]);
  }

  void _openFullScanner(BuildContext context, UserPanel panel) {
    // Delegates to the platform's full-screen scanner.
    // The caller wires this by providing a route or bottom sheet.
    if (_scanService == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Scanner service not initialized')),
      );
      return;
    }
    // Default: push to existing scanner screen via named route.
    Navigator.of(context).pushNamed('/factory/store-keeper/scanner');
  }

  @override
  void dispose() {
    _scanService = null;
    super.dispose();
  }
}

/// Paints a branded corner-border scan frame.
class _ScanBoundaryPainter extends CustomPainter {
  final Color color;
  _ScanBoundaryPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final area = size.width * 0.65;
    final left = (size.width - area) / 2;
    final top = (size.height - area) / 2;
    final cl = area * 0.12;
    final p = Paint()..color = color..style = PaintingStyle.stroke..strokeWidth = 3.0..strokeCap = StrokeCap.round;

    // ── Overlay dim ──────────────────────────────────────
    final overlay = Paint()..color = Colors.black.withValues(alpha: 0.45)..style = PaintingStyle.fill;
    final path = Path()..addRect(Rect.fromLTWH(0, 0, size.width, size.height));
    final cutout = RRect.fromRectAndRadius(Rect.fromLTWH(left, top, area, area), const Radius.circular(16));
    path.addRRect(cutout);
    path.fillType = PathFillType.evenOdd;
    canvas.drawPath(path, overlay);

    // ── Corner accents ───────────────────────────────────
    void corner(double x, double y, double dx, double dy) {
      canvas.drawLine(Offset(x, y + cl * dy.sign), Offset(x, y), p);
      canvas.drawLine(Offset(x, y), Offset(x + cl * dx.sign, y), p);
    }
    corner(left, top, 1, 1);
    corner(left + area, top, -1, 1);
    corner(left, top + area, 1, -1);
    corner(left + area, top + area, -1, -1);
  }

  @override
  bool shouldRepaint(covariant _ScanBoundaryPainter old) => color != old.color;
}
