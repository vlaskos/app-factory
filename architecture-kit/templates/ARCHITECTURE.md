# Architecture — {{PROJECT_NAME}}

_High-level design decisions. This doc explains **why** the code is shaped the way it is; the code
itself explains **what** it does. Update when a big call is made or reversed. This is the source of
truth the review checklist (`05`) and the audit skill compare the code against._

## Overview

_2–3 sentences: the architectural pattern (from `01`), the main layers, and notable technology choices._

## Layer diagram

```
_Replace with your real layers. Example (MVVM):_
┌────────────┐    ┌────────────┐    ┌────────────┐
│  Views     │──▶│  ViewModels │──▶│  Services   │
└────────────┘    └────────────┘    └────────────┘
                                          │
                                          ▼
                                   ┌────────────┐
                                   │  Network    │
                                   └────────────┘
```

## Chosen pattern & rationale

- **Pattern:** _(e.g. MVVM, feature-first outer layout)_
- **Why this one:** _(scope-based reasoning from `01` — keep it one or two sentences)_
- **Organization:** _by feature / by type, and where shared infra lives (`Core/`)._

## Key patterns

_The 3–5 conventions a newcomer must know to be productive._

- **_(pattern name)_** — _one sentence: what it is and why._
- …

## Testability conventions

- _Dependencies injected via `init` with `.shared`/fake defaults._
- _I/O mocked behind a protocol seam._
- _Pure logic extracted from views for unit tests._

## Intended structure (and what isn't built yet)

_For Xcode synchronized-group projects especially: list the full intended directory layout here so the
empty layers are documented even though no placeholder files exist for them. Mark which exist today._

## Things deliberately not done

_The most useful section — decisions and their rationale. When someone asks "why don't we…", the answer
lives here._

- **No _X_** — _reason._
- …

## Re-evaluate when…

_Triggers for revisiting the above._

- _(e.g. a second data source needs to plug into the network layer)_
- _(e.g. team grows past 3 devs and `.pbxproj` merge pain starts)_
