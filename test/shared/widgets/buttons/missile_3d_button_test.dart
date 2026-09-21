// The first real test in this repo.
//
// WHAT THIS IS FOR
// ================
// `test/widget_test.dart` was a 17-line placeholder that pumped a bare
// `SizedBox` — it proved that `flutter test` starts, and nothing about the app.
// Meanwhile there were zero Flutter tests in CI, so the whole frontend could
// regress unobserved.
//
// This file does two jobs:
//
//   1. It is a real test of the one widget shared by four different panels.
//      `Missile3DButton` is the pencil/3D dashboard button — the de-facto design
//      identity of every admin panel. It used to live inside
//      `features/bus_operations/` and was imported ACROSS panel boundaries by
//      BUS, CRICKET, SUPER and `shared/`'s admin sidebar, which was a layering
//      violation. It now lives in `lib/shared/widgets/buttons/`, and this guards
//      the move: if the widget or its contract changes, this fails.
//
//   2. It sets the pattern. A widget test needs no network, no database and no
//      GStreamer, so it runs everywhere — unlike anything that touches the media
//      engine. New panels should copy this shape.
//
// WHY IT IS DELIBERATELY SMALL
// ============================
// Two focused assertions, not a rendering snapshot. A golden-file test would
// have to be regenerated on every styling change, and the owner is ABOUT to
// change styling on purpose (the design-system consolidation, decision D4 —
// "one consistent design across every panel"). A snapshot would fight that
// work instead of supporting it. The contract being pinned here is behaviour:
// it renders its label, and a tap reaches the callback.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:trace_odd/shared/widgets/buttons/missile_3d_button.dart';

void main() {
  testWidgets('Missile3DButton renders its label and is tappable',
      (WidgetTester tester) async {
    var taps = 0;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Missile3DButton(
            label: 'Scoring Console',
            icon: Icons.scoreboard,
            color: const Color(0xFF10B981),
            onTap: () => taps++,
          ),
        ),
      ),
    );

    // The label is what the operator reads, so it must actually reach the tree.
    expect(find.text('Scoring Console'), findsOneWidget);
    expect(find.byIcon(Icons.scoreboard), findsOneWidget);

    // A tap has to reach the callback — this is the whole point of a button,
    // and it is the part a styling change must never break.
    await tester.tap(find.byType(Missile3DButton));
    await tester.pump();
    expect(taps, 1);

    // Tapping again must not be swallowed: these are navigation controls and
    // they are tapped repeatedly in normal use.
    await tester.tap(find.byType(Missile3DButton));
    await tester.pump();
    expect(taps, 2);
  });

  testWidgets('Missile3DButton pins the CURRENT behaviour of its height parameter',
      (WidgetTester tester) async {
    // ⚠️ THIS TEST PINS A BUG, ON PURPOSE — read the whole comment.
    //
    // `height` is a public parameter with a documented default of 80. The
    // cricket manager passes 72 (manager_dashboard_page.dart). Writing this
    // test showed that **the parameter currently has no effect at all**.
    //
    // Root cause, in the widget itself:
    //
    //     CustomPaint(
    //       painter: Pencil3DPainter(...),
    //       size: Size(double.infinity, height),   // ignored
    //       child: Padding(... Row(...)),           // a child IS present
    //     )
    //
    // `CustomPaint.size` is only consulted when `child == null`. With a child,
    // CustomPaint sizes to the child, so the painted body takes its height from
    // the content (a 40px icon container plus 6px padding either side = 52).
    //
    // Measured, which is how this was found: 52 in the constraint context real
    // callers use (a Column inside a scroll view), and 600 — the whole viewport
    // — when dropped straight into a Scaffold body, where the content is allowed
    // to fill. Neither number comes from `height`.
    //
    // So this asserts the TRUTH rather than the intention: two different heights
    // render identically. That is a characterisation test — it documents the
    // defect and will fail loudly the moment someone fixes it, which is the
    // point. Fixing it changes the rendered height in four panels, so it belongs
    // with the design-system work (decision D4: one consistent design across
    // every panel), not in a test-only change.
    //
    // To fix: give the painter a real box (wrap in a SizedBox of the requested
    // height, or drop the child and paint the content inside the painter).
    Future<double> renderedHeight(double height) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: Column(
                children: [
                  Missile3DButton(
                    label: 'Live Video',
                    icon: Icons.live_tv,
                    color: const Color(0xFF2563EB),
                    height: height,
                    onTap: () {},
                  ),
                ],
              ),
            ),
          ),
        ),
      );
      return tester.getSize(find.byType(Missile3DButton)).height;
    }

    final at72 = await renderedHeight(72);
    final at200 = await renderedHeight(200);

    expect(
      at72,
      at200,
      reason: 'height is currently ignored. If this fails, someone made the '
          'parameter effective - good - and this test should be rewritten to '
          'assert the requested heights, then the D4 work should re-check the '
          'panels that pass height: (manager_dashboard_page.dart passes 72).',
    );

    // The content-driven height, asserted so a layout change to the button is
    // also noticed: 40px icon container + 6px padding top and bottom.
    expect(at72, 52);
  });
}
