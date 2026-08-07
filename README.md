# TaskFlow

A task manager built around one idea: a list you can read at a glance. Rows
stay one line no matter how much a task carries, sections are a blue heading
over a hairline rather than a card, and opening a task expands it in place
instead of pushing a screen — so you never lose your position in the list you
were reading.

## Lists

Six built-in lists, in the order they appear on Home:

| List | What lands here |
| --- | --- |
| **Inbox** | Anything captured without a decision about when |
| **Today** | Work for today, plus a **This Evening** section |
| **Upcoming** | Scheduled work, grouped by day |
| **Anytime** | Live work with no date |
| **Someday** | Deliberately parked |
| **Logbook** | Completed, most recent first |

Home shows counts on Inbox and Today only, with a red badge on Today for
deadlines that are due or overdue. The rest stay quiet so the column reads as
navigation rather than a dashboard.

## Areas, projects, headings

Areas group projects; projects hold to-dos; headings divide a project into
sections. A project's headings are stored on the project itself, so a heading
you have just added survives before anything is filed under it. To-dos with no
heading sit above the first one.

- Add a to-do straight into a section from its `+`
- Drag a to-do between headings; a drop zone appears mid-drag to pull one back
  out to no heading
- Rename a heading and its to-dos follow
- Projects show a completion ring

## Capture and search

**Quick capture** opens over whatever you were doing, with notes, checklist,
tags, a scheduled date and a deadline. `Ctrl/Cmd+N` opens it from Home. It
reads plain phrasing in the title — `tomorrow`, `in 3 days`, `next friday`,
`monday at 9:30 am`, `every friday` (which sets a weekly recurrence), and
`someday`.

**Quick Find** opens over the current screen and searches lists, projects,
to-do titles and tags.

## Working with to-dos

- Tap a row to open it in place: notes, checklist, tags, and where it lives
- Full editor behind **Edit** for when, deadline, area, project and heading
- Long-press a row for multi-select, then reschedule, move, or delete a batch
  from the floating toolbar
- Checklists, free-form tags, a scheduled date and a separate deadline
- Completing a recurring to-do writes its next occurrence with a fresh
  checklist

The interface follows the system light/dark setting.

## Status

The list-first redesign is implemented across every screen, ported from a
[Claude Design](https://claude.ai/design) document. The palette is iOS system
blue.

`flutter analyze` is clean and `flutter test` runs 40 tests covering
serialisation, the provider, and the scheduling parser.

**Known limitations**

- **The web build keeps data in memory only.** `sqflite` has no web backend, so
  the browser falls back to an in-memory store and a reload starts empty. The
  web deploy is a demo, not a usable client. Android and iOS persist to SQLite.
- **A weekday word anywhere in a title is treated as a date, and removed from
  the title.** `Plan the monday standup agenda` is stored as `Plan the standup
  agenda`, scheduled for Monday. Pinned by a test so it cannot drift, but not
  yet fixed — see `test/natural_language_schedule_test.dart`.
- Only Android, iOS and web are configured. There are no desktop targets.

## Getting started

Requires Flutter **3.44.8** — the same version `scripts/vercel-build.sh`
installs, so local and deploy builds resolve identically.

```bash
flutter pub get
flutter run              # a connected device, or -d chrome
flutter test
flutter analyze
```

## Layout

```
lib/
  design/taskflow_tokens.dart   palette, light/dark theme extension, type scale
  models/                       Task, Area, Project
  providers/task_provider.dart  app state over a TaskStore
  services/
    task_store.dart             storage interface the provider depends on
    database_helper.dart        SQLite implementation (v8 schema)
    natural_language_schedule.dart
  screens/                      home, system lists, project detail, capture, find
  widgets/                      shared primitives: rows, checkbox, section header
test/                           fake store plus model, provider and parser tests
```

`TaskProvider` depends on the `TaskStore` interface rather than the database
directly, which is what lets the suite drive it against an in-memory store.

## Deployment

The web build deploys to Vercel via `scripts/vercel-build.sh`, which pins the
Flutter version and caches the SDK between builds, re-downloading whenever the
pin moves.

```bash
flutter build web --release --base-href /
```
