---
name: intake
description: Turn a client's raw (sanitized) app idea into a scoped, buildable MVP brief and open the trigger issue. ESDLC pipeline skill — stage 1.
model: Sonnet
---

Turn the client's idea in `$INPUT` into a **scoped MVP brief** and open the trigger issue.

**This is an autonomous ESDLC skill.** It runs headless, invoked by the orchestrator spine. It does NOT chat with the operator. It emits one structured artifact (`brief.json`) and opens one GitHub Issue. The only live interaction allowed is the *time-boxed* clarifying step (3.2), surfaced through the booth chat UI, never a terminal prompt.

`$INPUT` is the client idea **after** `policy-guard` has cleared it and the sanitizer has normalized Unicode. Never read raw client text here.

Follow these steps exactly — do not skip or reorder them.

## Step 1 — Classify the archetype
Match the idea to exactly one supported archetype from the catalog in [[architecture]] (§ Supported archetypes):
- `shopping-list` — items with add/check/delete, local persistence
- `bill-splitter` — people + expenses → per-person balance (Splitwise-style)
- `calculator` — expression input → computed result
- `generic-list` — fallback for a simple CRUD-over-a-list idea

If the idea cannot be served **inside the capability allow-list** ([[architecture]] § Capability allow-list) by one of these, STOP and emit `{"status":"refused","reason":"<one plain sentence>"}`. Do not half-build an out-of-scope app.

## Step 2 — Cut scope hard
The ceiling is non-negotiable (this is a live demo, not a product):
- **≤ 3 screens**, **≤ 5 features**, **0 external network**, **local persistence only**.
- Anything beyond the archetype's core loop goes to `out_of_scope`, not `features`.

## Step 3 — Fill the brief

### 3.1 — Draft from defaults
Each archetype ships sensible defaults in [[architecture]]. Start from them; only deviate for what the client explicitly asked.

### 3.2 — Clarify only if load-bearing (time-boxed)
Ask **at most 3** questions, and only when a missing detail changes the build (e.g. "split evenly or by share?"). Surface them in the chat UI with a 30s timeout; on timeout, take the default and note it in `assumptions`. Never block the pipeline on an answer.

### 3.3 — Write acceptance criteria
Every criterion must be **one testable statement with an ID** (`AC-1`, `AC-2`, …). "Verifiable by a unit test or a data-dependent UI assertion" is the bar — no vague goals.

## Step 4 — Emit the brief
Write `brief.json`:
```json
{
  "status": "ok",
  "title": "Grocery list",
  "archetype": "shopping-list",
  "display_name": "QuickCart",
  "problem": "one sentence",
  "user": "one sentence",
  "features": ["add item", "check off item", "delete item"],
  "out_of_scope": ["sharing", "categories", "sync"],
  "acceptance_criteria": [
    {"id": "AC-1", "text": "Adding a non-empty item appends it to the visible list and persists across relaunch"},
    {"id": "AC-2", "text": "Checking an item toggles its done state and moves it below unchecked items"}
  ],
  "assumptions": ["split evenly (no answer in 30s)"]
}
```

## Step 5 — Open the trigger issue
Create a GitHub Issue, title = `display_name`, body = the brief rendered as markdown, label = `agent-ready`. The issue number is the run's source of truth; return it to the spine.

**Constraints — always apply:**
- Never exceed the capability allow-list or the scope ceiling.
- Never invent a feature the client did not ask for.
- Every AC must be individually verifiable; if you can't phrase it as a test, it's not an AC.
- Output is machine-read by the spine — emit valid JSON, no prose around it.
