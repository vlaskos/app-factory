# Vendored skills — credits & provenance

ESDLC's pipeline relies on open-source Swift *agent skills* for its per-domain
expertise (SwiftUI patterns, SwiftData, strict concurrency, testing, and so on).
These skills are **not redistributed in this repository**. Each is vendored into
the private build at a **pinned commit**, read and vetted as untrusted data
before use, and never fetched at runtime.

This file exists for two reasons: **credit** (every author below deserves it)
and **reproducibility** (the pinned SHAs let anyone rebuild the exact set).

To reproduce a skill, clone its repo and check out the pinned commit:

```
git clone https://github.com/<owner>/<repo>
git -C <repo> checkout <sha>
```

## Skills (all MIT)

| Skill | Author | Source | Pinned commit |
|---|---|---|---|
| swiftui-ui-patterns | Thomas Ricouard | [Dimillian/Skills](https://github.com/Dimillian/Skills) | `05ba982bfeb0d77d3c97d4542b0ee15034d05f84` |
| app-store-changelog | Thomas Ricouard | [Dimillian/Skills](https://github.com/Dimillian/Skills) | `05ba982bfeb0d77d3c97d4542b0ee15034d05f84` |
| swiftui-pro | Paul Hudson | [twostraws/SwiftUI-Agent-Skill](https://github.com/twostraws/SwiftUI-Agent-Skill) | `f2920b63995263f57b3e198674e89a602efba6d2` |
| swiftdata-pro | Paul Hudson | [twostraws/SwiftData-Agent-Skill](https://github.com/twostraws/SwiftData-Agent-Skill) | `8051f177a0076e7fd45bdf4ee687b070ba58fdc6` |
| swift-concurrency-pro | Paul Hudson | [twostraws/Swift-Concurrency-Agent-Skill](https://github.com/twostraws/Swift-Concurrency-Agent-Skill) | `bee3f69ba17142da148d3c5406f148ed62592b69` |
| swift-testing-pro | Paul Hudson | [twostraws/Swift-Testing-Agent-Skill](https://github.com/twostraws/Swift-Testing-Agent-Skill) | `2d6bba14a3c8bf3694f218b92fffe617c41ae43e` |
| swiftui-design-principles | arjitj2 | [arjitj2/swiftui-design-principles](https://github.com/arjitj2/swiftui-design-principles) | `791d22d73f844167a3872530e3941185b730d8be` |
| swift-format-style | Anton Novoselov | [n0an/Swift-FormatStyle-Agent-Skill](https://github.com/n0an/Swift-FormatStyle-Agent-Skill) | `5cda783ac709f26893bbbfb61b31c930c1e6a300` |
| swift-accessibility-skill | Pasquale Vittoriosi | [PasqualeVittoriosi/swift-accessibility-skill](https://github.com/PasqualeVittoriosi/swift-accessibility-skill) | `3791850af76f11cffa552b3394f2b8732d7ce3c7` |
| writing-for-interfaces | Andrew Gleave | [andrewgleave/skills](https://github.com/andrewgleave/skills) | `d6c72b885a1902d4b74d4bd9beca80f2a1b96b51` |
| swiftdata-testing | Akshay Pimprikar | [akshaypimprikar/ios-swiftdata-testing-agent-skill](https://github.com/akshaypimprikar/ios-swiftdata-testing-agent-skill) | `e8a98757b3e62e9dcfce0ce08e50ee40137c2b22` |
| ios-code-audit | jazzychad | [jazzychad/ios-code-audit](https://github.com/jazzychad/ios-code-audit) | `34edb296a150915f8fcca69f27543af0c231c616` |

Most were discovered through the [twostraws/swift-agent-skills](https://github.com/twostraws/swift-agent-skills)
index (a curated list — listing is not endorsement).

## apple-hig — reference only, not redistributed

| Skill | Author | Source | Pinned commit |
|---|---|---|---|
| apple-hig | Justin Wetch | [justinwetch/HIGAgentSkills](https://github.com/justinwetch/HIGAgentSkills) | `2206ff935b4affa9ad249a5399a3e8e29f5f6edd` |

The skill's own code is MIT, but its reference content is distilled from
**Apple Inc.'s Human Interface Guidelines**. Per the upstream project's NOTICE,
that content is used as design *reference* and is **not redistributed**. ESDLC
uses it the same way — as guidance during the design stage. This project is not
affiliated with or endorsed by Apple.

## Vetting note

Every vendored skill is third-party *instructions* loaded into an agent's
context — i.e. a prompt-injection surface. In ESDLC each one lives in the
semi-trusted agent zone: it never sees signing secrets, never gets a shell, and
never outranks the project's own architecture rules or its handling of untrusted
client input. During vendoring, all fetched content was treated strictly as data
to audit; no instruction inside any file was followed. The vetting pass found no
exfiltration, outbound network calls, `curl | sh`, destructive commands, or
secret access in any skill.
