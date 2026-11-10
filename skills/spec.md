---
name: spec
description: Turn an approved brief into a template-bound spec + plan + ordered task graph. ESDLC pipeline skill — stage 2. Subject of Gate 1.
model: Opus
---

Turn `brief.json` into three artifacts — `spec.md`, `plan.md`, `tasks.json` — bound to the golden template and [[architecture]]. The output of this skill is what the operator approves at **Gate 1**; everything downstream is built from it.

**Autonomous skill.** Runs headless, invoked by the spine. Emits artifacts, does not chat. Uses GitHub Spec Kit conventions (`/specify → /plan → /tasks`) with the constitution pinned to [[architecture]].

Follow these steps exactly — do not skip or reorder them.

## Step 1 — Load inputs
Read `brief.json` (from `intake`) and [[architecture]] (the constitution). If `brief.status != "ok"`, STOP and pass the status through unchanged.

## Step 2 — Map archetype → screens + template base
From `archetype`, pull the screen set and template base from [[architecture]] § Supported archetypes. Stay at the ceiling: **≤ 3 screens**. Name each screen; one `Features/<Name>/` folder per screen.

## Step 3 — Write `spec.md`
Restate every `AC-N` verbatim, then for each one record:
- **Satisfied by** — which screen / component / piece of logic realizes it.
- **Verified by** — the test or data-dependent UI assertion that will prove it (this is the `test-author` contract; a hollow app must not be able to pass).
- **Stub vs real** — explicitly mark any value that is hardcoded for the demo. Default is **real**; a stub needs a one-line justification and is flagged for Gate 1. (Demo-ware is the pipeline's natural failure mode — make the decision visible, not silent.)

## Step 4 — Write `plan.md`
List every file to create or modify, grouped by owner per [[architecture]] § Shared-file ownership:
- **Scaffold-owned** — App entry, composition root (router/tab), `Shared/` models + `ItemStore`, `Package.swift`, `Info.plist`, `Assets.xcassets`.
- **Feature-owned** — files inside each `Features/<Name>/`.
Each feature entry declares its **needs** (routes to register, shared-model fields, Info.plist keys, SPM deps) as structured data — the merge step applies these; feature agents never edit shared files directly.

## Step 5 — Write `tasks.json`
Emit an ordered task graph:
```json
{
  "tasks": [
    {"id": "T0", "kind": "scaffold", "owns": ["App/","Shared/","Package.swift","Info.plist","Assets.xcassets"],
     "creates_routes": ["list","detail"], "depends_on": []},
    {"id": "T1", "kind": "feature", "name": "ItemList", "owns": ["Features/ItemList/"],
     "satisfies": ["AC-1","AC-2"], "needs": {"routes":["list"],"model_fields":["items:[Item]"]},
     "skills": ["swiftdata-pro","swiftui-ui-patterns","swift-accessibility-skill"], "depends_on": ["T0"]},
    {"id": "T2", "kind": "feature", "name": "AddItem", "owns": ["Features/AddItem/"],
     "satisfies": ["AC-1"], "needs": {"routes":["add"]}, "depends_on": ["T0"]}
  ]
}
```
Rules:
- `T0` (scaffold) runs first and alone; feature tasks depend on it.
- Each task lists the **vendored skills** it will lean on in a `skills` array (per [[architecture]] § Vendored skills) — the builder loads exactly these, no more.
- For the MVP, prefer **sequential** feature tasks. Only mark two features parallel-safe when their `owns` sets are disjoint AND neither's `needs` overlaps — otherwise last-writer-wins silently drops a screen.

## Step 6 — Self-check before emitting (hard gate on your own output)
Refuse to emit unless ALL hold:
- Every `AC-N` appears in some task's `satisfies` **and** has a `Verified by` in `spec.md`.
- Every planned shared file is owned by exactly one task (`T0`).
- No feature task's `owns` includes a shared path.
- Total screens ≤ 3, capabilities ⊆ allow-list.
If any fails, fix the plan and re-check; do not pass a broken graph to the builder.

**Constraints — always apply:**
- The constitution ([[architecture]]) wins over anything convenient; never plan around it.
- Every AC must trace to ≥1 task and ≥1 test. No orphan ACs, no orphan tasks.
- Mark stubs explicitly — an unmarked hardcoded value is a spec defect.
- Emit valid artifacts only; this is Gate-1 material and must be human-readable (`spec.md`/`plan.md`) + machine-read (`tasks.json`).
