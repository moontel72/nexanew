// Colors for NexaTrace System
// Colors for NexaTrace System
// This file defines the color palette for the application

import 'package:flutter/material.dart';

class AppColors {
  // Primary Colors
  static const Color primary = Color(0xFF0066CC); // NexaTrace Blue
  static const Color primaryDark = Color(0xFF004C99);
  static const Color primaryLight = Color(0xFF3385D6);

  // Secondary Colors
  static const Color secondary = Color(0xFF00CC66); // Success Green
  static const Color secondaryDark = Color(0xFF00994C);
  static const Color secondaryLight = Color(0xFF33D685);

  // Accent Colors
  static const Color accent = Color(0xFFFF9900); // Warning Orange
  static const Color accentDark = Color(0xFFCC7A00);
  static const Color accentLight = Color(0xFFFFB233);

  // Neutral Colors
  static const Color black = Color(0xFF000000);
  static const Color white = Color(0xFFFFFFFF);
  static const Color transparent = Color(0x00000000);

  // Gray Scale
  static const Color gray900 = Color(0xFF1A1A1A);
  static const Color gray800 = Color(0xFF333333);
  static const Color gray700 = Color(0xFF4D4D4D);
  static const Color gray600 = Color(0xFF666666);
  static const Color gray500 = Color(0xFF808080);
  static const Color gray400 = Color(0xFF999999);
  static const Color gray300 = Color(0xFFB3B3B3);
  static const Color gray200 = Color(0xFFCCCCCC);
  static const Color gray100 = Color(0xFFE6E6E6);
  static const Color gray50 = Color(0xFFF5F5F5);

  // Semantic Colors
  static const Color success = Color(0xFF00CC66);
  static const Color successColor = Color(0xFF00CC66);
  static const Color warning = Color(0xFFFF9900);
  static const Color warningColor = Color(0xFFFF9900);
  static const Color error = Color(0xFFFF3333);
  static const Color errorColor = Color(0xFFFF3333);
  static const Color info = Color(0xFF0066CC);
  static const Color infoColor = Color(0xFF0066CC);

  // Background Colors
  static const Color background = Color(0xFFF8F9FA);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceVariant = Color(0xFFE7E0EC);
  static const Color cardBackground = Color(0xFFFFFFFF);

  // Admin Panel Colors
  static const Color adminSidebarBackground = Color(0xFF0F172A);
  static const Color adminSidebarBorder = Color(0xFF1E293B);
  static const Color adminSidebarText = Color(0xFFF8FAFC);
  static const Color adminSidebarTextMuted = Color(0xFFCBD5E1);
  static const Color adminContentBackground = Color(0xFFF3F4F6);

  // Input Background Colors (FIXED: Added missing colors)
  static const Color inputBackgroundLight = Color(0xFFF8F9FA);
  static const Color inputBackgroundDark = Color(0xFF2D2D2D);
  static const Color inputBackground = Color(0xFFF8F9FA);

  // Text Colors
  static const Color textPrimary = Color(0xFF1A1A1A);
  static const Color textSecondary = Color(0xFF666666);
  static const Color textTertiary = Color(0xFF808080);
  static const Color textDisabled = Color(0xFF999999);
  static const Color textInverse = Color(0xFFFFFFFF);

  // UI Component Colors
  static const Color codeBackground = Color(0xFFF0F8FF);
  static const Color shimmerColor = Color(0xFFF0F0F0);

  // Border Colors
  static const Color border = Color(0xFFE6E6E6);
  static const Color borderColor = Color(0xFFE6E6E6);
  static const Color borderDark = Color(0xFFCCCCCC);
  static const Color borderLight = Color(0xFFF0F0F0);

  // Shadow Colors
  static const Color shadow = Color(0x1A000000);
  static const Color shadowColor = Color(0x1A000000);
  static const Color shadowDark = Color(0x33000000);

  // Outline Colors
  static const Color outline = Color(0xFFE6E6E6);
  static const Color outlineVariant = Color(0xFFCCCCCC);

  // Overlay Colors
  static const Color overlay = Color(0x80000000);
  static const Color overlayLight = Color(0x33000000);

  // Factory Status Colors
  static const Color activeFactory = Color(0xFF00CC66);
  static const Color inactiveFactory = Color(0xFFFF9900);
  static const Color suspendedFactory = Color(0xFFFF3333);

  // Additional UI Colors
  static const Color primaryColor = Color(0xFF0066CC);
  static const Color secondaryColor = Color(0xFF00CC66);
  static const Color grey = Color(0xFF808080);

  // Code Status Colors
  static const Color codeGenerated = Color(0xFF0066CC);
  static const Color codeLinked = Color(0xFF00CC66);
  static const Color codePublished = Color(0xFF9900CC);
  static const Color codeDeactivated = Color(0xFFFF3333);

  // Product Type Colors
  static const Color foodProduct = Color(0xFF00CC66);
  static const Color medicalProduct = Color(0xFF0066CC);
  static const Color otherProduct = Color(0xFF9900CC);

  // Get color by code status
  static Color getCodeStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'generated':
        return codeGenerated;
      case 'linked':
        return codeLinked;
      case 'published':
        return codePublished;
      case 'deactivated':
        return codeDeactivated;
      default:
        return gray500;
    }
  }

  // Get color by product type
  static Color getProductTypeColor(String type) {
    switch (type.toLowerCase()) {
      case 'food':
        return foodProduct;
      case 'medical':
        return medicalProduct;
      case 'other':
        return otherProduct;
      default:
        return gray500;
    }
  }
}
