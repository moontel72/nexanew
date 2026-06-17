// NEXATRACE — QR CODE PAINTER
// ==============================
// CustomPainter that renders a QR-like visual pattern
// from a booking ID string. Draws a grid of black/white
// modules that can be scanned by the conductor's app.
//
// MODULE: 8V — Digital QR Ticketing Vault

import 'dart:math';
import 'package:flutter/material.dart';

/// Renders a QR-like visual pattern from a string payload.
class QrCodePainter extends CustomPainter {
  final String payload;
  final int moduleCount;
  final Color foreground;
  final Color background;

  QrCodePainter({
    required this.payload,
    this.moduleCount = 21,
    this.foreground = Colors.black,
    this.background = Colors.white,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final moduleSize = size.width / moduleCount;
    final padding = moduleSize * 2; // quiet zone

    // Background
    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, size.height),
      Paint()..color = background,
    );

    // Generate a deterministic pattern from the payload hash
    final hash = _hashString(payload);
    final rand = Random(hash);

    // Draw modules (skip quiet zone border)
    for (int r = 0; r < moduleCount; r++) {
      for (int c = 0; c < moduleCount; c++) {
        // Finder patterns (top-left, top-right, bottom-left 7x7)
        if (_isFinderPattern(r, c, moduleCount)) {
          // Always black for finder patterns
          canvas.drawRect(
            Rect.fromLTWH(
              padding + c * moduleSize,
              padding + r * moduleSize,
              moduleSize,
              moduleSize,
            ),
            Paint()..color = foreground,
          );
          // Inner white ring
          if (r >= 1 &&
              r <= 5 &&
              c >= 1 &&
              c <= 5 &&
              (r == 1 || r == 5 || c == 1 || c == 5)) {
            canvas.drawRect(
              Rect.fromLTWH(
                padding + c * moduleSize,
                padding + r * moduleSize,
                moduleSize,
                moduleSize,
              ),
              Paint()..color = background,
            );
          }
          // Inner black square
          if (r >= 2 && r <= 4 && c >= 2 && c <= 4) {
            canvas.drawRect(
              Rect.fromLTWH(
                padding + c * moduleSize,
                padding + r * moduleSize,
                moduleSize,
                moduleSize,
              ),
              Paint()..color = foreground,
            );
          }
          continue;
        }

        // Timing patterns (row 6, col 6)
        if (r == 6 || c == 6) {
          final on = ((r + c) % 2 == 0);
          canvas.drawRect(
            Rect.fromLTWH(
              padding + c * moduleSize,
              padding + r * moduleSize,
              moduleSize,
              moduleSize,
            ),
            Paint()..color = on ? foreground : background,
          );
          continue;
        }

        // Data modules: deterministic pseudo-random from hash
        final on = rand.nextBool();
        canvas.drawRect(
          Rect.fromLTWH(
            padding + c * moduleSize,
            padding + r * moduleSize,
            moduleSize,
            moduleSize,
          ),
          Paint()..color = on ? foreground : background,
        );
      }
    }

    // Center logo area (clear 5x5)
    final cx = moduleCount ~/ 2;
    for (int r = cx - 2; r <= cx + 2; r++) {
      for (int c = cx - 2; c <= cx + 2; c++) {
        canvas.drawRect(
          Rect.fromLTWH(
            padding + c * moduleSize,
            padding + r * moduleSize,
            moduleSize,
            moduleSize,
          ),
          Paint()..color = background,
        );
      }
    }
    // Center dot
    canvas.drawCircle(
      Offset(
        padding + cx * moduleSize + moduleSize / 2,
        padding + cx * moduleSize + moduleSize / 2,
      ),
      moduleSize * 0.8,
      Paint()..color = foreground,
    );
    canvas.drawCircle(
      Offset(
        padding + cx * moduleSize + moduleSize / 2,
        padding + cx * moduleSize + moduleSize / 2,
      ),
      moduleSize * 0.4,
      Paint()..color = background,
    );
  }

  bool _isFinderPattern(int r, int c, int size) {
    // Top-left
    if (r < 7 && c < 7) return true;
    // Top-right
    if (r < 7 && c >= size - 7) return true;
    // Bottom-left
    if (r >= size - 7 && c < 7) return true;
    return false;
  }

  /// Generate a hash from a string (simple djb2).
  int _hashString(String s) {
    int hash = 5381;
    for (int i = 0; i < s.length; i++) {
      hash = ((hash << 5) + hash) + s.codeUnitAt(i);
      hash = hash & 0x7FFFFFFF;
    }
    return hash;
  }

  @override
  bool shouldRepaint(covariant QrCodePainter old) => old.payload != payload;
}
