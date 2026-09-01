# Code Understanding Journal

A running log of my findings as I learn how the Task Management System is built.

---

## Project Overview

- **What it is:** (e.g., a command-line to-do/task manager written in Python)
- **How you interact with it:** (e.g., via `python cli.py <command>`)
- **Key files identified so far:**
  - `cli.py` — handles command-line input and dispatches to the logic
  - `task_manager.py` — (not yet reviewed) likely contains the `TaskManager` class with the actual task logic
  - `models.py` — (not yet reviewed) likely defines `TaskStatus`, `TaskPriority`, and probably a `Task` class/data structure
  - `tests/` — unit tests for the project

---

## File: `cli.py`

**Purpose:** Entry point for the CLI. Parses command-line arguments and calls methods on `TaskManager`.

**Key concepts encountered:**
| Concept | What it means |
|---|---|
| `argparse` | Python's built-in library for parsing command-line arguments |
| Subparsers | Lets one script support multiple subcommands (`create`, `list`, `show`, etc.) |
| Positional argument | Required input, order matters (e.g. `title`) |
| Optional flag | e.g. `-p` / `--priority`, not required unless specified |
| `choices=[...]` | Restricts valid input values |
| `default=...` | Value used if the flag is omitted |
| `action="store_true"` | Makes a flag a simple on/off switch |
| f-string | Python syntax for formatting strings with embedded variables |
| Enum (`TaskStatus`, `TaskPriority`) | A fixed set of named values instead of raw strings/numbers |

**Notable observations:**
- The README describes commands like `update-status`, `update-priority`, `add-tag` — but the actual code uses `status`, `priority`, `tag`, `untag`. **README may be outdated.**
- `cli.py` contains no actual task-storage logic — it only translates commands into calls on `TaskManager`. Logic and interface are separated (good design practice).

**Open questions:**
- Where/how does `TaskManager` store tasks? (in memory? a file? a database?)
- What does a `Task` object actually look like (its attributes)?

---

## File: `task_manager.py`

**Purpose:** *(fill in once reviewed)*

**Key concepts encountered:**
-

**Notable observations:**
-

**Open questions:**
-

---

## File: `models.py`

**Purpose:** *(fill in once reviewed)*

**Key concepts encountered:**
-

**Notable observations:**
-

**Open questions:**
-

---

## Tests (`tests/`)

**Purpose:** *(fill in once reviewed)*

**What's being tested:**
-

---

## Glossary (terms I looked up)

| Term | Definition |
|---|---|
| Fork | A personal copy of someone else's repository under your own GitHub account |
| Commit | A saved snapshot of changes, with a message describing what changed |
| Branch | A separate timeline/version of the project (default branch is usually `main`) |
| Repository (repo) | A project's folder plus its full history, tracked by Git |

---

## General Takeaways / Reflections

*(Write freeform thoughts here as you go — things that surprised you, patterns you're starting to notice across files, etc.)*
