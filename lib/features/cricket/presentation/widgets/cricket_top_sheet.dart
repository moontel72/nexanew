import 'package:flutter/material.dart';

/// Opens a form panel anchored to the TOP of the screen (instead of a
/// bottom sheet), with a dim barrier that dismisses on outside tap.
Future<void> showCricketTopSheet(
  BuildContext context, {
  required Widget child,
}) {
  return showGeneralDialog<void>(
    context: context,
    barrierDismissible: true,
    barrierLabel: 'Close',
    barrierColor: Colors.black54,
    transitionDuration: const Duration(milliseconds: 220),
    transitionBuilder: (context, animation, _, child) {
      final curved = CurvedAnimation(
        parent: animation,
        curve: Curves.easeOutCubic,
      );
      return FadeTransition(
        opacity: curved,
        child: SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0, -0.15),
            end: Offset.zero,
          ).animate(curved),
          child: child,
        ),
      );
    },
    pageBuilder: (context, _, __) => SafeArea(
      child: Align(
        alignment: Alignment.topCenter,
        child: Container(
          constraints: const BoxConstraints(maxWidth: 560),
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
          decoration: BoxDecoration(
            color: const Color(0xFF0F2936),
            borderRadius: BorderRadius.circular(16),
          ),
          child: child,
        ),
      ),
    ),
  );
}

/// Shared sheet header: title + close (X) button.
class CricketSheetHeader extends StatelessWidget {
  final String title;
  const CricketSheetHeader({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        IconButton(
          icon: const Icon(Icons.close, color: Color(0xFFBDD8DB)),
          tooltip: 'Close',
          onPressed: () => Navigator.of(context).pop(),
        ),
      ],
    );
  }
}
