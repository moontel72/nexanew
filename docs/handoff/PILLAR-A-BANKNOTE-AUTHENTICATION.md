# Pillar A — Pakistani Banknote Authentication

**Surface:** **#25** · **Group 8 — Trust & Safety** (see `PANEL-SEPARATION-PLAN.md` §11)
**Status:** spec only. **Zero code, zero backend, zero spec coverage before this file.**
**Read with:** `PANEL-SEPARATION-PLAN.md` §11 (registry) and §15 (pillars tracked outside the plan),
and the correction notice at the top of `NEXATRACE_SUPREME_MASTER_SPEC.md`.

**Provenance of the content below:** drafted 2026-09-25 from material supplied directly by the owner
(disclaimer wording, result-screen rules, and the training-dataset blueprint). The owner supplied
that material in Urdu **to convey intent**; per the owner's instruction it is recorded here as
**points in English**, not as Urdu text. The Urdu user-facing strings belong in the app's translation
resource (see §3.6), not in documentation.

---

## 1. What this panel is

A consumer tool (inside the Universal Customer App surface #3 family, or as its own surface #25 —
see §10) that uses the phone camera, and optionally a dedicated capture device, to **draw the user's
attention to anomalies on a Pakistani currency note**.

It is deliberately **not** an authentication authority. See §2.1.

---

## 2. Owner's binding decisions

These are settled. A future plan or agent must not re-litigate them.

| # | Decision | Consequence for the build |
|---|---|---|
| **2.1** | **No authenticity verdict — ever.** | The UI never says *authentic* or *fake*. See §3.4 for the approved wording. |
| **2.2** | **Low confidence is stated openly** — the disclaimer says results may be *"around 50%"* accurate. | Honest framing over marketing. The exact figure and how any on-screen confidence is computed is an **open item** (§10). |
| **2.3** | **Legal clearance precedes coding.** Serial-number verification is pursued **only if State Bank of Pakistan rules permit it.** | §9 is a **gate**, not a task: no serial-checking code before written clearance. |
| **2.4** | **A dedicated capture device is permitted.** The phone camera is not the only option. | Removes the hard optical ceiling on micro-text (§4). |
| **2.5** | **Three delivery phases** (on-device → native kernel → server model). | §5 is the delivery order. |
| **2.6** | **The user is always routed to a human authority.** | The advisory in §3.3 is **mandatory** on the result screen, not optional copy. |
| **2.7** | **"Zero database dependency" means no SBP serial-number lookup.** | A physics-based reference set **is** required and is within the constraint — see §8. |

---

## 3. User-facing copy and UX rules

### 3.1 Pre-scan disclaimer (mandatory, before the first scan)

**English (owner-supplied, verbatim):**

> **Important Notice:** This tool is for educational and informational purposes only. This camera
> scanner does not guarantee 100% accuracy, and results may have a confidence level of around 50%.
> It does not provide official authentication. Please manually verify all security features of the
> currency note.

### 3.2 Result-screen disclaimer (mandatory, on every result)

**English (owner-supplied, verbatim):**

> **Result Disclaimer:** This scan is intended solely to draw your attention to specific note
> features. Do not rely solely on this result. For final verification, please use State Bank
> recommended methods (e.g., watermark, raised printing, and security thread).

### 3.3 Bank-branch advisory — the legal shield (mandatory)

**English (owner-supplied, verbatim):**

> **Important Advisory:** This app merely highlights potential anomalies in this specific banknote to
> draw your attention. To avoid any financial loss, please verify this specific banknote with your
> nearest bank branch before accepting or proceeding with the transaction.

**Owner's rationale, recorded because it justifies the whole design:**

- **Legal:** State Bank of Pakistan law holds that only a bank or SBP can authoritatively decide a
  note's status. This wording aligns the app with official procedure instead of competing with it.
- **Trust:** The user reads the app as a *pre-warning that protects them*, not as a final judge.
- **Commerce:** At a point of sale, a shopkeeper can politely ask the customer to have the note
  checked at a bank — which removes the argument, rather than starting one.

### 3.4 Approved result wording (never deviate)

| ❌ Never use | ✅ Use instead |
|---|---|
| "Authentic" / "Genuine" / "Real" | **"Standard Pattern Matched"** |
| "Fake" / "Counterfeit" / "Jaali" | **"Suspicious Pattern Detected"** |

Rationale: a false "fake" verdict on a genuine note is the single fastest way to destroy trust and
create legal exposure. Suspicion is a prompt, not a verdict.

### 3.5 Required interactions

1. **Proceed checkbox** — the scan action stays disabled until the user ticks:
   *"I have read and agree to the disclaimer above."*
2. **State Bank official guide button** on the result screen — a small link that opens SBP's own
   guidance so the user can read every security feature themselves.
3. The advisory in §3.3 shown on the result screen (not buried in settings).

### 3.6 Urdu strings

The owner supplied Urdu equivalents for §3.1–§3.3. They are **user-facing app strings**, so they
belong in the app's translation resource:

```
assets/translations/ur.json   ← Urdu   (currently an EMPTY folder: only .gitkeep)
assets/translations/en.json   ← English
```

Suggested keys: `banknote.disclaimer.pre_scan`, `banknote.disclaimer.result`,
`banknote.advisory.bank_branch`, `banknote.result.standard`, `banknote.result.suspicious`.

**Do not** paste long Urdu text into `.md` files in this repo — the editor (Zed) does not render
right-to-left text correctly, so it appears scrambled even though the file content is fine.
See `PANEL-SEPARATION-PLAN.md` §16 for the editor findings.

---

## 4. Honest technical limits (read before promising anything)

PKR notes are printed to a fidelity that a phone camera cannot fully resolve. Stating this up front
prevents an expectation gap later.

| Security feature | Phone-camera feasibility | Why |
|---|---|---|
| **Micro-text / micro-printing** | ⚠️ **Very hard** | Scale is roughly **0.2 mm**. Phone optics plus the diffraction limit cannot reliably resolve print-press fidelity. This is an **optical** problem, not only a software one — hence decision §2.4 (dedicated device). |
| **OVI (optically variable ink) colour shift** | ✅ **Best candidate** | The hue shift is measurable across **multiple frames at different angles**. Highest value per unit of effort. |
| **Security thread / fibre pattern** | 🟨 Conditional | Requires **transmitted light** (backlight) to see the thread and its fibre texture; needs controlled illumination, which is what a dedicated device provides. |
| **Raised printing (RLE)** | 🟨 Conditional | Detectable via shadow/relief cues, but sensitive to lighting direction. |
| **Serial number** | ⚠️ **Gated** | Only worth pursuing if SBP permits serial verification (§9). |

**The honest summary:** the app can reliably draw attention to *some* anomalies. It cannot certify
authenticity. The disclaimer in §3 says exactly that — keep the product aligned with it.

---

## 5. Delivery phases

| Phase | Scope | Where it runs |
|---|---|---|
| **1** | Guided **capture protocol** + quality gate + **OVI heuristic** | On-device (Flutter + native kernel) |
| **2** | **Thread / fibre verification** (transmitted-light path) | Native kernel (Rust) |
| **3** | **Server-side model** + continuous improvement | Laravel + model runtime |

The capture protocol is deliberately **Phase 1 and is not AI work** — good capture is most of the
accuracy. It includes: multi-frame guided capture, torch/LED control, backlight mode, distance and
angle guidance, and rejection of unusable frames.

---

## 6. Training dataset blueprint

Owner-supplied. This is what the model is trained on — the AI only recognises what it is taught.

### 6.1 Data collection

| Dimension | Coverage required |
|---|---|
| **Denominations** | 10, 20, 50, 100, 500, 1,000, 5,000 |
| **Condition** | Uncirculated (new), lightly used, **creased/folded**, worn/faded |
| **Lighting** | Natural daylight, low light, tube light, **UV** |
| **Angles** | Straight-on **and tilted** (users never hold a note perfectly flat) |
| **Sides** | Front and back |

### 6.2 Annotation

Tooling: **LabelImg** or **Roboflow**. Tag these key regions on every sample:

| Region | Purpose |
|---|---|
| Portrait (Quaid-e-Azam) | Geometry + print quality anchor |
| Watermark area | Presence, placement, shape |
| Windowed security thread | Position + pattern |
| Raised printing (RLE) areas | Relief cues |
| Serial-number region | Font/pattern reference (gated by §9) |
| Note geometry | Size, aspect ratio, border ratios |

### 6.3 Model training

- **Tooling:** YOLO / OpenCV / CNN-based vision models.
- **Approach:** build a mathematical **embedding of the genuine blueprint**, then compare each new
  scan's features against it (`Real vs Anomaly` comparison).
- **Flagging rule (owner-specified):** a deviation of **≈50% or more** in a feature region marks the
  note **suspicious** — never "fake".

### 6.4 Reference data model

```
note_id / denomination        e.g. PKR-500
version / series              year or series identifier
feature_anchors:
    watermark_bounding_box    [coordinates]
    security_thread_pattern   [hash / feature vector]
    serial_font_type          [standard font vector]   ← gated by §9
    uv_glow_points            [UV light array]
```

This reference set is **small, versioned, and offline-syncable** — it is *not* a serial-number
lookup service. See §8.

---

## 7. Where this sits in the architecture

- **Runtime:** Flutter BLoC + **native Rust kernel** + platform-native inference — surface #25's row
  in `PANEL-SEPARATION-PLAN.md` §12.2.
- **Critical rule (§12.3):** the native kernel must **not** be called synchronously from the UI
  isolate, or the app will stutter. Use the async bridge / worker isolate, and keep camera frames out
  of the Dart heap.
- **Prerequisite:** the native packaging gap in `PANEL-SEPARATION-PLAN.md` §13.5 must be fixed before
  any Rust kernel can ship inside a mobile app.

---

## 8. How "zero database dependency" is honoured

The owner's constraint is **no dependence on a State Bank serial-number database**. It does **not**
mean "no reference data at all" — no vision model can work without something to compare against.

| Excluded by the constraint | Required anyway |
|---|---|
| SBP serial-number lookup | A small, versioned **reference set** of genuine-note feature vectors (§6.4) |
| Per-note registration on a server | On-device comparison against that set |

This distinction matters, because the whole design depends on it.

---

## 9. Legal and compliance gate

- **Gate:** State Bank of Pakistan rules on currency handling, note imaging, and serial verification
  must be clarified **in writing before Phase 1 coding begins**.
- **Owner's task.** Also confirm whether capturing/storing note images is permitted, and under what
  conditions.
- If serial verification is **not** permitted, §6.4's `serial_font_type` anchor and any serial logic
  are dropped — the rest of the design is unaffected.

---

## 10. Open items

| # | Item | Owner |
|---|---|---|
| 1 | SBP written clarification (§9) | Owner |
| 2 | Group 8 route prefix in `routes/panels/*.php` and the panel's backend file | Dev, with #25 |
| 3 | What "around 50%" means on screen — is any numeric confidence shown at all, and how is it computed? | Dev |
| 4 | Capture-device choice (if Phase 1 is not enough) | Owner + dev |
| 5 | Whether this ships as its own surface (#25) or inside the Universal Customer App (#3) | Owner |
| 6 | Reference-set storage: bundled asset vs downloaded-on-first-run (offline-first) | Dev |

---

## 11. Provenance

| Date | Change |
|---|---|
| 2026-09-25 | File created. Owner's disclaimer wording, result-screen rules, legal-shield advisory and dataset blueprint extracted from owner-supplied material and recorded in English. Surface numbered **#25**, group **8 Trust & Safety** (created the same cycle). |
