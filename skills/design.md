---
name: design
description: Derive the app's visual design system from its own brief (Apple HIG when unspecified) and return it as DATA the spine renders into DesignSystem.swift. ESDLC pipeline skill — runs after scaffold, before build.
model: Opus
---

Give the scaffolded app a cohesive **visual design system**, derived from the app's **own brief**, returned as DATA only. Runs after `scaffold` (the tree already compiles) and before `build` (so every feature screen is built against the system). The spine owns the Swift: you return tokens, it renders `Sources/DesignSystem.swift` from a fixed, known-good template and rebuilds to prove green.

**Autonomous skill.** Headless `claude -p`. Returns ONE JSON object of design tokens — never Swift, never a file map, never a tool call. The spine validates every value against allow-lists and writes the byte. Opus on purpose: the look is a creative judgement.

Load the vendored **`apple-hig`** skill (`vendor-skills/apple-hig/` — Apple Human Interface Guidelines corpus: `references/hig/color.md`, `dark-mode.md`, `typography.md`, `layout.md`, `materials.md`, `design-principles.md`, `sf-symbols.md`, `accessibility.md`) as the **authoritative source for the HIG defaults** — exact iOS system colors, Dynamic Type sizes, contrast floors, base-8 spacing. Also load `swiftui-design-principles` (semantic color, restraint) and `writing-for-interfaces` (voice, if the brief implies one). The HIG essentials are also distilled inline into the spine's design prompt, so a tool-less `claude -p` run stays grounded without file access.

Follow these steps exactly — do not skip or reorder them.

## Step 1 — Read the brief, find the direction
Read `brief.json` (idea/title, `archetype`, `display_name`). **The design comes from the app, not from any house brand:**
- If the idea names or implies a visual direction — a mood, a domain, a color, words like "minimal", "playful", "elegant", "dark", "retro", "fintech", or a named brand — design to **that**. The user's words win.
- If the idea gives **no** visual direction, default to **Apple Human Interface Guidelines**: system semantic colors, SF typography, standard spacing — a clean, native look. Impose **no** company brand (ESDLC builds client apps, not CHI-branded ones).

## Step 2 — Decide the system (with intent for THIS app)
- **Palette** — `background`, `surface`, `surfaceAlt`, `primary`, `accent`, `onAccent`, `textPrimary`, `textSecondary`, `textMuted`, `separator`. Each a 6-digit hex with a **light AND a dark** value. Text must stay legible on its background in **both** themes. (`success`/`warning`/`danger` are fixed by the system — do not send them.)
- **Typography** — one `fontDesign`: `rounded` (friendly/consumer), `serif` (editorial/reading), `monospaced` (numbers/code), or `default` (neutral/productivity). On-device SF — no font bundling.
- **Corner radius** — one integer `0–28` (0 sharp · ~12 standard · ~20 soft).
- **feel** — one sentence of art direction.

## Step 3 — Return the tokens (DATA ONLY)
Return ONLY this JSON object — no Swift, no CSS, no prose, no code fences:
```json
{
  "feel": "<one sentence art direction>",
  "fontDesign": "rounded",
  "cornerRadius": 16,
  "palette": {
    "background":    {"light":"#FFFFFF","dark":"#000000"},
    "surface":       {"light":"#F2F2F7","dark":"#1C1C1E"},
    "surfaceAlt":    {"light":"#FFFFFF","dark":"#2C2C2E"},
    "primary":       {"light":"#1E66F5","dark":"#4C8DFF"},
    "accent":        {"light":"#1E66F5","dark":"#4C8DFF"},
    "onAccent":      {"light":"#FFFFFF","dark":"#FFFFFF"},
    "textPrimary":   {"light":"#000000","dark":"#FFFFFF"},
    "textSecondary": {"light":"#6C6C70","dark":"#AEAEB2"},
    "textMuted":     {"light":"#9B9BA0","dark":"#8E8E93"},
    "separator":     {"light":"#C6C6C8","dark":"#38383A"}
  }
}
```

## What the spine does with it (for your mental model)
Validates every field (6-digit hex, enum `fontDesign`, bounded radius; **HIG fallback** on anything missing or invalid), then renders `Sources/DesignSystem.swift` and rebuilds. The generated API every screen uses:
- `DS.Palette.*` (dynamic light/dark colors) · `DS.Typeface.largeTitle/title/headline/body/callout/caption` · `DS.Space.xs…xl` · `DS.Radius.sm/md/lg`
- Components: `DSCard { … }`, `.buttonStyle(DSPrimaryButtonStyle())` / `DSSecondaryButtonStyle()`, `DSSectionHeader("…")`, `.dsScreenBackground()`
- `branding` reuses your `primary`/`accent` for a coherent app icon; `audit` flags any screen that hardcodes a color or font.

**Constraints — always apply:**
- Return **DATA only** — never Swift, never a file map, never a tool call. The spine owns every byte of the Swift.
- Every color is 6-digit hex with a light **and** dark value; keep text legible on its background in both themes.
- Derive from the brief; default to **Apple HIG** when the brief is silent; never impose a house/company brand.
- Keep it coherent and restrained — **one** accent, used for the primary action; semantic colors stay semantic.
