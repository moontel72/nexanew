// Clipboard capability guard.
//
// WHY THIS EXISTS (owner, 2026-09-29)
// -----------------------------------
// The browser Clipboard API only exists in a SECURE context. The panels are also
// opened over plain `http://` (the raw IP used for testing), where
// `navigator.clipboard` is undefined — and Flutter's web implementation does NOT
// throw in that case, it simply does nothing. So a `try { Clipboard.setData(...) }`
// fallback never fires: the button reports success while the clipboard stays empty.
//
// Owner's words on `/factory/orders`: "neither before nor now does it copy".
//
// So the insecure context must be detected UP FRONT, and the caller must show a
// manual-copy surface (the text pre-selected in a dialog) instead.
//
// Lives in `core/` on purpose: both `core` (ErrorHandler) and `shared`
// (StickyErrorBanner, CopyableErrorSurface) need it, and `core` may not import
// `shared` — see the layering rule in MASTER-TASK-LIST.md §5b.1.
import 'package:flutter/foundation.dart' show kIsWeb;

/// True when the browser Clipboard API cannot be trusted.
///
/// `https`, `localhost` and `127.0.0.1` are treated as secure (browsers allow the
/// API there); anything else over plain http:// is not.
bool get clipboardLikelyUnavailable {
  if (!kIsWeb) return false;
  final base = Uri.base;
  if (base.scheme == 'https') return false;
  final host = base.host;
  return host != 'localhost' && host != '127.0.0.1';
}
