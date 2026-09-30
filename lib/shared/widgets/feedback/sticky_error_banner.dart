// Sticky error banner — the shared way to show a failure to the operator.
//
// WHY THIS EXISTS (owner's request, 2026-09-27)
// --------------------------------------------
// Errors in these panels used to flash on screen for a second and vanish, which made them impossible to
// read and impossible to report. Twice that cost real time: an empty Factory list and a failing Drivers
// list both looked like "no data" instead of "this request failed".
//
// So a failure must be:
//   * STICKY   — it stays until the operator closes it, it never auto-dismisses;
//   * COPYABLE — one tap copies the message plus its source, ready to paste into a bug report;
//   * CLOSABLE — an explicit X, so a fixed problem can be got rid of without a reload.
//
// This is deliberately ONE widget. Adoption is per screen (panel by panel), so that a screen added later
// gets the same behaviour by using this instead of inventing its own banner.
//
// Usage:
//   if (_error != null)
//     StickyErrorBanner(
//       message: _error!,
//       source: 'Factory · Drivers · GET /api/v1/factory/drivers/list',
//       onDismiss: () => setState(() => _error = null),
//     )

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:trace_odd/core/utils/clipboard_guard.dart';
import 'package:trace_odd/shared/theme/colors.dart';

class StickyErrorBanner extends StatefulWidget {
  /// The message to show. If it comes from an exception, prefer `fromError` below.
  final String message;

  /// Where it happened — panel / screen / endpoint. This is what makes a copied report actionable.
  final String? source;

  /// Optional stack trace. It is NOT rendered (it would swamp the panel) — it is
  /// appended to the copied text, so a minified web error still arrives with the
  /// line that produced it.
  final String? stack;

  /// Called when the operator taps X. The caller owns the state (the banner stays until then).
  final VoidCallback? onDismiss;

  const StickyErrorBanner({
    super.key,
    required this.message,
    this.source,
    this.stack,
    this.onDismiss,
  });

  /// Build from a caught error. `error.toString()` is kept whole on purpose — it often carries the
  /// server's own explanation, and trimming it is how information gets lost.
  factory StickyErrorBanner.fromError(
    Object error, {
    Key? key,
    String? source,
    String? stack,
    VoidCallback? onDismiss,
  }) {
    return StickyErrorBanner(
      key: key,
      message: error.toString(),
      source: source,
      stack: stack,
      onDismiss: onDismiss,
    );
  }

  @override
  State<StickyErrorBanner> createState() => _StickyErrorBannerState();
}

class _StickyErrorBannerState extends State<StickyErrorBanner> {
  bool _copied = false;

  String get _copyText {
    final lines = <String>[];
    if (widget.source != null && widget.source!.isNotEmpty) {
      lines.add(widget.source!);
    }
    lines.add(widget.message);
    if (widget.stack != null && widget.stack!.trim().isNotEmpty) {
      lines.add('Stack:');
      lines.add(widget.stack!.trim());
    }
    return lines.join('\n');
  }

  Future<void> _copy() async {
    // In an insecure context the clipboard API silently does nothing instead of
    // throwing, so a try/catch is not enough — skip it and show the manual dialog
    // (see `clipboardLikelyUnavailable`).
    if (!clipboardLikelyUnavailable) {
      try {
        await Clipboard.setData(ClipboardData(text: _copyText));
        if (!mounted) return;
        setState(() => _copied = true);
        return;
      } catch (_) {
        // Fall through to the manual path below.
      }
    }

    if (!mounted) return;

    // WHY THIS FALLBACK EXISTS (owner, 2026-09-29: "the error still does not
    // copy"). The browser Clipboard API is only available in a SECURE context.
    // This panel is also opened over plain http:// (e.g. http://135.181.46.27),
    // where `navigator.clipboard` does not exist, so `Clipboard.setData` fails —
    // silently, because nothing here used to catch it. A button that does nothing
    // is worse than none, so when the API refuses we show the text pre-selected
    // with the manual instruction. That copy always works.
    await showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Copy this manually'),
        content: SizedBox(
          width: 520,
          child: SingleChildScrollView(
            child: SelectableText(
              _copyText,
              style: const TextStyle(fontSize: 12.5),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.fromLTRB(14, 12, 6, 12),
      decoration: BoxDecoration(
        color: AppColors.error.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.error.withValues(alpha: 0.45)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.error_outline, color: AppColors.error, size: 22),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (widget.source != null && widget.source!.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Text(
                      widget.source!,
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                SelectableText(
                  widget.message,
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            tooltip: _copied ? 'Copied' : 'Copy',
            icon: Icon(
              _copied ? Icons.check : Icons.copy,
              size: 18,
              color: _copied ? AppColors.success : AppColors.textSecondary,
            ),
            onPressed: _copy,
          ),
          if (widget.onDismiss != null)
            IconButton(
              tooltip: 'Close',
              icon: const Icon(
                Icons.close,
                size: 18,
                color: AppColors.textSecondary,
              ),
              onPressed: widget.onDismiss,
            ),
        ],
      ),
    );
  }
}
