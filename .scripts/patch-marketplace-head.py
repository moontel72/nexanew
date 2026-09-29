#!/usr/bin/env python3
"""Patch the BUILT marketplace index.html <head> in place.

WHY THIS EXISTS (2026-09-29 production incident)
------------------------------------------------
The first version of this site copied a hand-written `web/index-marketplace.html`
OVER `build/web/index.html` after the build, to add a zoomable viewport and the
marketplace title. That template carried Flutter's build-time placeholder:

    <base href="$FLUTTER_BASE_HREF" />

Flutter resolves that placeholder during `flutter build`, so the BUILT file was
correct — and copying the raw template over it put the literal `$FLUTTER_BASE_HREF`
back. The loader then refused the page:

    Exception: The base href has to end with a "/" to work correctly

...and market.traceodd.com rendered blank.

So: never overwrite the built file. Patch it. The base href belongs to Flutter and
this script never touches it.

WHAT IT DOES
------------
  * viewport  — insert ours (pinch-zoom + pan allowed). The shared template has no
                viewport meta, so Flutter's loader injects `maximum-scale=1.0,
                user-scalable=no`; declaring ours first wins, because the loader
                only adds one when none exists.
  * title / description / theme-color — marketplace branding.

Safe to run twice (idempotent).

Usage:  python3 .scripts/patch-marketplace-head.py build/web/index.html
"""

from __future__ import annotations

import pathlib
import re
import sys

VIEWPORT_CONTENT = (
    "width=device-width, initial-scale=1.0, minimum-scale=0.25, "
    "maximum-scale=5.0, user-scalable=yes"
)
TITLE = "Trace Odd Marketplace — Wholesale from Verified Factories"
DESCRIPTION = (
    "Trace Odd Marketplace — wholesale from verified factories. Browse every "
    "published product with its wholesale price and MOQ. No login required."
)
THEME_COLOR = "#4F46E5"


def _replace_or_insert_meta(html: str, name: str, content: str) -> str:
    """Set <meta name="{name}" content="...">, replacing any existing one."""
    pattern = re.compile(
        r'<meta\s+name="' + re.escape(name) + r'"[^>]*>', re.IGNORECASE
    )
    tag = f'<meta name="{name}" content="{content}" />'
    if pattern.search(html):
        return pattern.sub(tag, html, count=1)
    return html.replace("<head>", f"<head>\n        {tag}", 1)


def patch(path: pathlib.Path) -> str:
    html = path.read_text(encoding="utf-8")

    if "<base href=" not in html:
        raise SystemExit(
            f"refusing to patch {path}: no <base href> found — this does not look "
            "like a built Flutter index.html"
        )

    # 1. viewport — replace Flutter's (or add ours when absent)
    html = _replace_or_insert_meta(html, "viewport", VIEWPORT_CONTENT)

    # 2. branding
    html = _replace_or_insert_meta(html, "description", DESCRIPTION)
    html = _replace_or_insert_meta(html, "theme-color", THEME_COLOR)
    html = re.sub(r"<title>.*?</title>", f"<title>{TITLE}</title>", html, count=1, flags=re.DOTALL)

    path.write_text(html, encoding="utf-8")
    return html


def main() -> int:
    if len(sys.argv) != 2:
        print(__doc__)
        return 2

    target = pathlib.Path(sys.argv[1])
    if not target.is_file():
        raise SystemExit(f"not a file: {target}")

    html = patch(target)

    # Report what the loader will read, so a bad build is visible in the CI log.
    base = re.search(r'<base href="([^"]*)"', html)
    viewport = re.search(r'<meta name="viewport" content="([^"]*)"', html)
    print(f"patched {target}")
    print(f"  base href : {base.group(1) if base else '(none)'}")
    print(f"  viewport  : {viewport.group(1) if viewport else '(none)'}")

    if not (base and base.group(1).endswith("/")):
        print("ERROR: base href does not end with '/' — the page will be blank.")
        return 1

    return 0


if __name__ == "__main__":
    sys.exit(main())
