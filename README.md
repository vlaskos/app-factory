# ESDLC — an autonomous software delivery engine

A client idea goes in; a working, native iOS app comes out — designed, built, tested, and launched on a device, with two human checkpoints and nothing in between. This repository is the conference showcase: the slide deck, the presenter notes, the agent skills that drive each stage, and three example apps the engine produced.

**▶ Live deck:** <https://vlaskos.github.io/esdlc/> &nbsp;·&nbsp; **Presenter notes:** [cheatsheet.html](cheatsheet.html)

> The deck runs entirely in the browser — one self-contained file, no build step. Use **← / →** to navigate and **L** to toggle English / Ukrainian.

## What it is

ESDLC is an **autonomous, spec-driven SDLC running on an agent harness**. A written specification with acceptance criteria — not a prompt — drives the design, the code, and the tests that verify it. The pipeline runs ten stages from intake to release; a human approves the spec and approves the ship, and everything between is hands-off.

## How it works

The core is a **harness**: a trusted, deterministic orchestrator around the model. The model *proposes* — it returns data (JSON), never touches the machine, and never gets a shell. The harness *disposes* — it validates every value against strict allow-lists and assembles the app across three isolated zones:

- **untrusted** — the raw client text; sanitized on the way in, sees no secrets.
- **agent** — the model as a pure generator; returns artifacts as data only.
- **harness (trusted)** — validates, writes files, runs the build and the tests, owns signing.

Because the model can only return data, a hostile prompt can change what the app *looks like* — never what the code *does* or what the machine runs. That is what makes it safe to point at untrusted input.

## What's in this repo

| Path | What |
|---|---|
| `index.html` | The deck — self-contained; GitHub Pages serves it live |
| `cheatsheet.html` | Presenter notes — per-slide goals and talk track |
| `skills/` | The ten pipeline skills (intake → release) the harness loads per stage |
| `architecture-kit/` | The standing iOS architecture kit every generated app obeys |
| `examples/` | Three apps the engine built — real, compilable Swift |

## What's intentionally not here

- **The spine** — the orchestrator itself — is not published; it is the engine's implementation.
- **Vendored third-party skills** are not redistributed here. They are listed with author, source, and pinned commit in [VENDORED-SKILLS.md](VENDORED-SKILLS.md), so the set stays reproducible and properly credited.

## Example apps

`examples/` holds three local-only apps the pipeline produced end to end — a bill-splitter, a calculator, and a shopping list — each with its SwiftUI sources, an XcodeGen `project.yml`, and swift-testing suites. They target the current iOS baseline (Swift 6, SwiftUI, Observation, SwiftData).

## Running the deck

It is a single file — open `index.html` in any browser. To serve it on the web, enable **GitHub Pages**: *Settings → Pages → Deploy from a branch → `main` → `/ (root)`*. GitHub publishes it at the URL above within a minute.

## Credits

The pipeline's Swift expertise comes from open-source agent skills by Paul Hudson, Thomas Ricouard, and others — each MIT-licensed and vendored at a pinned commit. See [VENDORED-SKILLS.md](VENDORED-SKILLS.md) for the full list and attribution. Apple's Human Interface Guidelines are referenced as design guidance only; this project is not affiliated with or endorsed by Apple.

## License

[MIT](LICENSE) © 2026 Vladyslav Kosyi. The example apps and the original skills in `skills/` and `architecture-kit/` are covered by this license; third-party vendored skills retain their own (see [VENDORED-SKILLS.md](VENDORED-SKILLS.md)).
