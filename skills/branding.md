---
name: branding
description: Give the app its per-client identity (display name + icon) from the assigned slot, with a hard icon gate against ITMS-90717. ESDLC pipeline skill — stage 6 (pre-release identity).
model: Sonnet
---

Stamp the per-client visual identity onto the green build before release. Each demo app lives in a **permanent pool slot** (fixed Bundle ID + global ASC listing name); the only things that vary per client are the **home-screen display name** and the **app icon**.

**Autonomous skill.** Runs after `audit` is green, before the release lane. Does not touch signing or the Bundle ID (that is the slot's permanent identity).

Load `swiftui-design-principles` (semantic color/tokens) + `writing-for-interfaces` (sanity-check the display name).

Follow these steps exactly — do not skip or reorder them.

## Step 1 — Load context
Read `brief.json` (`display_name`, `archetype`), the assigned slot (Bundle ID — **read-only**), and the green working tree. Confirm the slot identity; you will NOT change `CFBundleIdentifier`, SKU, or the ASC listing name.

## Step 2 — Display name
Set `CFBundleDisplayName` = `display_name` (home-screen name). Keep it short and human (sanity-check with `writing-for-interfaces`); this is the ONLY per-client name the user sees — the TestFlight/ASC list shows the generic slot name.

## Step 3 — Icon (default: deterministic, reliable)
Generate the AppIcon **programmatically** — the de-risked default:
- the archetype glyph (SF Symbol: `cart` / `person.2` / `plusminus` / `list.bullet`) centered on a solid **semantic-accent** rounded square (tokens from `swiftui-design-principles`);
- render with SwiftUI `ImageRenderer` at **1024×1024**, then flatten.
This guarantees an opaque, square, on-brand icon with zero external dependency.

_Optional AI-generated icon_ is allowed **only if** it clears Step 4; AI icons routinely ship an alpha channel and get rejected.

## Step 4 — Icon gate (HARD — prevents ITMS-90717)
Assert the final icon is: **1024×1024**, square, **sRGB 8-bit**, and **fully opaque (NO alpha channel)**. Flatten/strip alpha + convert color space if needed (`sips`/Core Graphics). If any check fails, **fall back to the deterministic Step-3 icon** — never upload an icon with alpha. Write it into `Assets.xcassets` AppIcon (single 1024 slot).

## Step 5 — Accent (optional)
Set `AccentColor` in `Assets.xcassets` to match the icon's accent, so the app's tint is coherent.

## Report format (return verbatim)
```
Branding: QuickCart (shopping-list) → slot-03
Display name: CFBundleDisplayName = "QuickCart"
Icon: deterministic (cart glyph on accent) — 1024×1024 sRGB opaque ✓ (ITMS-90717 gate PASS)
Bundle ID: com.esdlc.slot03 (unchanged) · ASC listing name: unchanged
AccentColor: set
```

**Constraints — always apply:**
- Never change `CFBundleIdentifier`, SKU, or the ASC listing name — slot identity is permanent.
- Icon MUST be 1024×1024, square, sRGB 8-bit, **opaque** — no alpha ever reaches upload (ITMS-90717).
- On any icon-gate failure, fall back to the deterministic icon; do not block the pipeline on a fancy icon.
- Never touch signing or entitlements.
