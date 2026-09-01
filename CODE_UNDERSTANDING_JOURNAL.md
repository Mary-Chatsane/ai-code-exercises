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

**Purpose:** *Contains TaskManager, the business-logic layer. Converts raw CLI input (strings/ints) into proper domain objects, and coordinates between Task/enums (models.py) and persistence (storage.py).*

**Key concepts encountered:**
-Concept	What it means
TaskPriority(priority_value)	Converting a raw int into an Enum member; raises an error if invalid
datetime.strptime(str, format)	Parses a text date into a real datetime object
try/except ValueError	Catches bad date input instead of crashing
Delegation to self.storage	TaskManager never touches files directly — it calls methods on a TaskStorage object instead

**Notable observations:**
-create_task() builds a Task object, then hands it to storage.add_task() — TaskManager doesn't know or care how it's saved.
update_task_status() has a special case: setting status to DONE goes through task.mark_as_done() (which also stamps completed_at), while any other status goes through a generic storage.update_task(task_id, status=...). Two different code paths for what looks like "the same kind of action."
get_statistics() builds counts by looping over all tasks in memory (self.storage.get_all_tasks()) rather than asking storage to do the counting — logic lives in the manager layer, not the storage layer.

**Open questions:**
-
What does storage.py / TaskStorage actually do? (confirmed dependency, not yet reviewed)
Is tasks.json created automatically if it doesn't exist yet?
Does storage.update_task() call Task.update() internally? (strongly suspected, not confirmed)
---

## File: `models.py`

**Purpose:** *Purpose: Defines the core data: the Task class itself, plus the TaskPriority and TaskStatus enums.*

**Key concepts encountered:**
-Concept	What it means
Enum	A fixed, named set of valid values (e.g. TaskStatus.TODO) instead of raw strings/numbers scattered everywhere
uuid.uuid4()	Generates a random unique ID — this is why task IDs are long random strings, not sequential numbers
tags=None then tags or []	Avoids a classic Python bug where a mutable default argument (like tags=[]) gets shared across every instance
**kwargs + hasattr/setattr	A generic way to update any attribute by name, without writing a separate method for each field

**Notable observations:**
-Every new Task is hardcoded to start at TaskStatus.TODO — you can't create a task that starts "in progress" or "done."
mark_as_done() bundles two changes together (status + completed_at) into one method — encapsulating a business rule on the model itself rather than leaving callers to remember to set both fields.
is_overdue() returns False if there's no due date, and also False if the task is already DONE — even if the due date has passed. So "overdue" specifically means "not done and past due," not just "past due."
update() has no validation — it will happily overwrite any attribute that exists on the object, including id or created_at, if called carelessly.

**Open questions:**
-
Is there any validation preventing something like an empty title?
Are priority and status ever compared/sorted anywhere (e.g., is URGENT > HIGH used logically)?
---

Feature Deep-Dive: Task Creation & Status Updates
Main components involved
cli.py — entry point, parses arguments
TaskManager.create_task() / TaskManager.update_task_status() — business logic
Task (constructor and mark_as_done()) — the data + a couple of self-contained rules
TaskStorage (in storage.py, not yet reviewed) — persistence, assumed to read/write tasks.json

Execution flow — creating a task
python cli.py create "Title" -p 3 -u "2024-02-01" → cli.py parses args → calls TaskManager.create_task(...)
create_task() converts the raw int priority into a TaskPriority enum, and parses the due-date string into a real datetime (invalid format → prints error, returns None, nothing is created)
A new Task(...) is constructed — this generates a UUID, forces status = TODO, and stamps created_at/updated_at
create_task() passes the Task to storage.add_task(task), which is expected to persist it and return the new ID
cli.py prints the returned ID

Execution flow — updating status
python cli.py status <id> done → TaskManager.update_task_status(task_id, "done")
String converted to TaskStatus.DONE
Special case for DONE: fetch the Task object → call task.mark_as_done() (sets status + completed_at) → explicitly call storage.save()
Any other status: skip the above, call storage.update_task(task_id, status=new_status) directly — a generic path

How data is stored/retrieved
Not fully confirmed yet (need storage.py), but inferred: JSON file (tasks.json by default), accessed only through TaskStorage methods (add_task, get_task, get_all_tasks, update_task, delete_task, save, etc.)
TaskManager never reads/writes files directly — always goes through TaskStorage

Design patterns spotted
Layered architecture: CLI → Manager (logic) → Model (data) → Storage (persistence); each layer only talks to the one below it
Repository pattern (likely): storage details isolated in one file, so swapping JSON for a database later wouldn't require touching task_manager.py or cli.py
Enums for controlled vocabulary: prevents invalid priority/status values from ever existing
Encapsulated business rule: mark_as_done() keeps "what happens when a task is completed" in one place
Generic reflective update: flexible, but no validation — a noted fragility/tech-debt point
Correct handling of mutable default arguments (tags=None pattern)

Feature Deep-Dive (Prompt 1 applied): Task Creation & Status Updates

Using the "understand a specific feature" prompt template, with cli.py, task_manager.py, and models.py as inputs.

1. What this component actually does

TaskManager is the "brain" of the app. It takes raw input (strings/numbers from the command line) and turns it into properly structured Task objects, applies rules to them (e.g. "only DONE tasks get a completion timestamp"), then hands them off to storage. cli.py never touches a Task directly for creation logic — it only ever talks to TaskManager.

2. Execution flow

Creating a task (python cli.py create "Title" -p 3 -u "2024-02-01"):

cli.py parses arguments → calls task_manager.create_task(title, description, priority, due, tags)
create_task() converts the raw 3 into TaskPriority.HIGH, and the date string into a real datetime (try/except catches a malformed date and aborts creation)
A Task(...) is constructed — generates a UUID, forces status to TODO, stamps created_at
The task is handed to storage.add_task(task), which persists it and returns the new ID
The ID travels back up to cli.py, which prints it

Updating status (python cli.py status <id> done):

cli.py calls task_manager.update_task_status(task_id, "done")
The string is converted into TaskStatus.DONE
If DONE: the task is fetched → task.mark_as_done() is called (sets status and completed_at) → storage is explicitly told to save
If any other status: a generic storage.update_task(task_id, status=new_status) handles it instead, skipping the fetch-then-mutate-then-save dance
3. How the files interact
cli.py depends on TaskManager — imports it, calls its public methods. It imports TaskStatus/TaskPriority too, but only for formatting output, not for creation logic.
task_manager.py depends on models.py (to build Task objects, convert enum values) and on storage.py (to persist/retrieve).
models.py depends on nothing else in the project — only the standard library (datetime, enum, uuid). It's the most self-contained file, which is a good sign: core data definitions aren't tangled up with display or storage concerns.

Dependency direction flows one way: cli.py → task_manager.py → models.py, with task_manager.py also reaching sideways into storage.py.

4. External dependencies

None outside Python's standard library (argparse, datetime, enum, uuid) — matches the README's "no additional external dependencies" claim. The one internal "service" this component relies on is TaskStorage.

5. Complex code block explained
python
if new_status == TaskStatus.DONE:
    task = self.storage.get_task(task_id)
    if task:
        task.mark_as_done()
        self.storage.save()
        return True
else:
    return self.storage.update_task(task_id, status=new_status)

Two different strategies for what should conceptually be one action ("change the status"). The DONE branch does a fetch → mutate → save cycle; the else branch does a single delegated call, trusting storage.update_task() to handle everything internally. Also: if status is DONE but the task doesn't exist, the function implicitly returns None instead of False — inconsistent with the else branch, which always returns a real boolean.

6. Mental model

Think of it as a relay race with three runners:

cli.py catches what the user types and translates it into a clean instruction
TaskManager is the referee — checks the instruction makes sense (valid priority? valid date?), applies special rules, decides what happens
Task is the "form" being filled out — a data container with a couple of self-contained rules of its own (mark_as_done())
TaskStorage (unseen) is the filing cabinet — actually writes the form to disk

Data flows one direction through these layers; nothing reaches back up the chain.

3 small changes to validate understanding (requirements only, no code)
Reject empty titles. create_task() should print an error and return None if title is empty/whitespace-only, mirroring how it already handles a bad due-date string. Tests understanding of where validation currently does/doesn't happen.
Make updated_at consistent across both status-update branches. Regardless of whether DONE or the generic else branch handles the update, Task.updated_at should end up refreshed in both cases. Tests understanding of the asymmetry between the two branches.
Add a new status, e.g. BLOCKED. Should be settable via python cli.py status <id> blocked and appear correctly in get_statistics()'s "by status" breakdown without breaking anything else. Tests understanding of how the enum, the CLI's choices=[...] list, and the statistics counter all need to stay in sync.

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
