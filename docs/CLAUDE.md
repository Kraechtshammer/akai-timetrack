# docs/

The project's written memory. Future sessions rely on it, so keep it current in the same commit as the change it describes.

## Files

| File | What it is | When to edit |
|---|---|---|
| `HANDOFF.md` | Current state: what works and how it was checked, open points in priority order, code map, how to work in the repo. The first thing a new session reads. | After every feature or finding: move items between "done" and "open", note what was checked where (emulator, Pixel, Xiaomi). |
| `01-research.md` | The problem, features F1–F9, platform research, decisions Q1–Q10 | Rarely. It's the record of why. Don't rewrite history; add a note if a decision changes. |
| `02-design.md` | Architecture, data model, domain rules, calendar sync, notifications, screens, theming, release and signing, milestones, prepared extensions (backup, tips/salary) | When behaviour changes. Update the section itself, and list deviations from the original design in §16. |
| `03-dev-setup.md` | Dev container, Claude token, phone and emulator, build tasks, using the container from Windows, why builds are slow, releases and secrets | When the workflow or tooling changes. |
| `concepts/` | Approved UI concept screens (`*.dc.html` design-canvas sources and `canvas.json`). The user approved them on 2026-11-04. | Only when the user changes the concepts. The live canvas is linked in `02-design.md`. The app follows these screens; ask before departing from them. |

The README in the repo root has only a status line and links here.

## Writing style

The user cares about this. Match the existing text:

- **Plain English, short sentences.** One idea per sentence. No marketing words ("seamless", "robust", "powerful"), no filler.
- **Concrete:** real paths, commands, setting names, numbers and dates (2026-11-04, not "today"). Commands go in fenced blocks.
- **Say why** when a choice isn't obvious ("…so the background isolate can read them").
- **Headings, bullets and tables** for structure. Bullets are short; they don't nest more than one level.
- **German UI terms stay German** and are quoted the way the app shows them ("Heute", "Jetzt synchronisieren", "Ende 23:00"). Everything else is English.
- **The person the app is for** is "she"/"her" (e.g. "her Xiaomi"). Never write the user's or her personal data into docs.
- **Honest status.** Write "checked on the emulator", "not tested yet" or "not confirmed on a phone" rather than implying more.
- **No secrets.** No passwords or key contents; fingerprints and paths are fine.

## Keeping HANDOFF.md useful

- The top section says what works and how it was checked.
- "Open points" is in rough priority order. Remove finished items, or move them to the "done" list with one line on how they were solved.
- Record surprises and traps, such as the release shrinker removing `ic_notification`, so nobody hits them twice.
- Keep the code map in sync when folders or key files are added.
