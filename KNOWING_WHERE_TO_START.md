# Knowing Where to Start

# Exercise part 1-4 (python)

---

## Submission 

For each exercise part, I recorded the prompts I used, as well as what I learned.

---

## Exercise Part 1: Understanding Project Structure

I familiarized myself with the task_manager.py codebase structure and configuration files like package.json, pom.xml, and requirement.txt etc, as well as their functions in programming. I skimmed through main files of the provided codes.

- Prompts/commands I used:
  - Prompt 1: Understanding Project Structure and Technology Stack

- What I learned about how the project is organized:

My best guess is that the codebase is organized into separate components with different responsibilities. TaskManager appears to sit between the command-line interface and the storage layer. It imports task-related classes from models.py, such as Task, TaskStatus, and TaskPriority, which are used to represent and manage task information. TaskManager also creates a TaskStorage object, using tasks.json as the storage path. This suggests that TaskStorage is responsible for handling the persistence and retrieval of task data, while TaskManager handles the higher-level task operations. My current mental model is therefore: cli.py → TaskManager → TaskStorage → tasks.json, with TaskManager also relying on models.py for the task objects and their statuses/priorities.

---
**Prompt 1: "Understanding Project Structure and Technology Stack" prompt with AI**

*Initial understanding questions*

my understanding is that the project structure of the Task Management System is structured in a way that the developer of a project chooses to structure their project files. As a beginner, I have learned that the structure of this Task Management System project goes as follows: 

task-manager/
│
├── cli.py                  ← command-line interface
├── task_manager.py         ← task-management operations
├── models.py               ← task-related models/classes
├── storage.py              ← likely data storage/retrieval
├── task_list_merge.py      ← likely combines/merges task lists
├── task_parser.py          ← likely parses task-related data/input
├── task_priority.py        ← likely handles task priorities
└── README.md               ← project documentation

The prompt helped me understand what the application does based on the files involved. it gave me deeper insight of the task management. I had assumptions on how files interacted with each other and did not understand the technologies used, and only got to find out that the technologies are in fact; programming languages, frameworks, libraries, tools, and platforms used to build/run/test the application. what I did not know was that the term 'technologies' is used for such. As a result, the application appears to rely entirely on pythons standard library rather than external packages/frameworks. 

*AI analysis compared to my observation*
AI analysis were more sure and reliant on evidence and documents placed before it, whilst I made a couple of intuitive guesses and assumptions. But I received corrections, and a better understanding. From that I also learnt that pythons standard libraries like argparse, datetime and unittest are also technologies and the project itself is divided into several python modules mentioned above. 
 
---

## Exercise Part 2: Finding Feature Implementation

## **1.Initial search**

I searched the codebase, looked into cli.py, models.py, storage.py, task_manager.py, task_parser.py, task_list_merge.py, task_priority.py, and this is what I found in *storage.py* (file related functionality that reads and writes task data from a file)

with open(self.storage_path, 'r') as f:
    tasks_data = json.load(f, cls=TaskDecoder)

with open(self.storage_path, 'w') as f:
    json.dump(list(self.tasks.values()), f, cls=TaskEncoder, indent=2)

which means TaskStorage is responsible for loading and saving tasks to a JSON file (tasks.json). It uses json.load() to read tasks and json.dump() to write them.

what I found in *Task_Manager.py*

self.storage = TaskStorage(storage_path)

THEREFORE:
No existing CSV functionality found


## **2.Hyphothesis**

The codebase already has a mechanism for converting task objects into JSON and writing them to an external file. Which means the search might provide a pattern for implementing CSV export. In all the other files I didn't find anything that looked like a file that could have been exported.

I suspect the new CSV export functionality may belong near the existing storage/data-handling functionality because TaskStorage already handles writing task data to an external file. However, I need to investigate TaskEncoder/TaskDecoder and how task data is represented before deciding where the CSV functionality should actually be implemented. cli.py would also likely need modification so the user can trigger the export command.


## **3.Feature location Prompt**

After using and filling the "finding feature implementation location" with AI, I found that my findings were the same findings that Claude shared and confirmed: there's genuinely no existing export or CSV functionality anywhere in this codebase.

**Filled in prompt**

I need to work on the "Task Export to CSV" feature in this codebase, but I'm not sure where the code for this feature lives.

My approach so far:
- I searched for keywords like: export, csv, to_csv, download, write_report, file
- I looked in: cli.py, models.py, storage.py, task_manager.py, task_parser.py, task_list_merge.py, task_priority.py
- I think the feature might relate to storage.py (file I/O pattern) and cli.py (where a new subcommand would be added)

Project structure:
task_manager/
├── cli.py           - argparse CLI, subcommands (create, list, status, priority, due, tag, untag, show, delete, stats)
├── models.py        - Task, TaskPriority, TaskStatus classes
├── storage.py       - TaskStorage class, JSON load/save via TaskEncoder/TaskDecoder
├── task_manager.py  - TaskManager, business logic wrapping TaskStorage
├── task_parser.py   - parses free-text task strings into Task objects
├── task_list_merge.py - merges local/remote task lists (sync)
└── task_priority.py - scoring/sorting tasks by importance

Based on my search, no export functionality currently exists. The most relevant files are:
- storage.py (TaskEncoder/save() shows the file-writing + serialization pattern)
- cli.py (would need a new "export" subparser)
- task_manager.py (would need a new method to bridge cli.py → storage)

## **4.Documented findings**

**Implementing "Task Export to CSV"**

Files affected:

`cli.py` — new export subparser + handling block
`task_manager.py` — new export_tasks_to_csv() method (the bridge)
`New file`: task_exporter.py (or similar) — the actual CSV-writing logic, mirroring how storage.py isolates encoding logic
`models.py` — not modified, but its fields to decide CSV columns should be known.
`storage.py` — not modified, but get_all_tasks() is the data source

**Approach**:

New module task_exporter.py — keep CSV logic separate from storage logic, same way task_parser.py is separate from `task_manager.py`. Use Python's built-in csv module `(csv.writer` or `csv.DictWriter)`. Convert enums `(task.priority.name`, `task.status.value)` and `datetimes` `(.isoformat())` to strings, same conversions `TaskEncoder` already does.

---

## Exercise Part 3: Understanding Domain Model

## 1.**domain model**

*Core entity classes (from models.py):*

`Task` — the central entity: id, title, description, priority, status, created_at, updated_at, due_date, completed_at, tags
`TaskPriority` (enum) — LOW, MEDIUM, HIGH, URGENT (values 1–4)
`TaskStatus` (enum) — TODO, IN_PROGRESS, REVIEW, DONE (string values)

*Business logic scattered across other files:*

Task.mark_as_done() and Task.is_overdue() — behavior lives on the entity itself
`task_priority.py` — a derived concept not stored on the model: an importance score, computed from priority weight + due-date urgency + status penalty + tag boosts + recency boost
task_list_merge.py — conflict resolution rules for sync (most-recent-wins, but DONE status always wins regardless of timestamp, tags always union)
`task_parser.py` — a mini "task shorthand" syntax specific to this app (!priority, @tag, #date)

*Concepts that are specific to the application:*

"Overdue" = has a due date in the past and not DONE (REVIEW/IN_PROGRESS tasks can be overdue, but DONE tasks never are)
"Score"/"importance" is a computed ranking value, not a stored field
Status transitions aren't validated anywhere — nothing stops you going DONE → TODO → REVIEW in any order

## 2.**Initial understanding**

*How the entities relate*

`Task` is the central entity in this domain. It doesn't stand alone — two of its own fields are constrained by enums: `Task.priority` can only be one of the four `TaskPriority` values (LOW/MEDIUM/HIGH/URGENT), and `Task.status` can only be one of the four `TaskStatus` values (TODO/IN_PROGRESS/REVIEW/DONE). So `TaskPriority` and `TaskStatus` aren't independent entities in their own right — they're closed vocabularies that `Task` is typed against.

Around that core, four modules each have a distinct relationship to `Task`:

`task_parser` creates `Task` objects. It's a factory: it takes free-form shorthand text and produces a new, fully-formed Task instance.
`task_priority` reads Task objects but never changes them. It computes a derived "importance score" from a task's priority, due date, status, and tags — this score isn't stored on the `Task` itself, it's calculated fresh each time.
`task_list_merge` reconciles two versions of the same Task (a local copy and a remote copy), applying rules to decide which fields win, and returns a merged `Task`.
`storage.py` persists `Task` objects — it's the only module that knows how to turn a `Task` into JSON and back again.

Finally, `task_manager.py` orchestrates all of the above. It's the facade that cli.py talks to — when the CLI needs to create, filter, update, or export tasks, `task_manager.py` is what calls into `task_parser`, `task_priority`, `task_list_merge`, and storage.py on Task's behalf. `Task` never talks to any of these modules directly; they all reach in through `task_manager.py`.


*What each entity represents:*

`Task` — the aggregate root; everything else operates on it
`TaskPriority/TaskStatus` — enums that constrain two of `Task`'s fields to fixed value sets, not free-standing entities
`task_parser` — a factory that builds `Task` objects from shorthand text
`task_priority` — read-only; computes a derived score, never mutates the model
`task_list_merge` — conflict-resolution rules for two copies of the same task
`storage.py` — persistence boundary; the only place `Task` gets serialized/deserialized
`task_manager.py` — the facade tying it all together for `cli.py`

*Open questions about the business logic:*

Should `is_overdue()/mark_as_done()` live on `Task` itself (as they do now) or move to a service layer? Right now behavior and data are mixed on the entity.
No validation exists anywhere for status transitions — is that intentional, or a gap?
`task_priority`'s score is never persisted or exposed via CLI — is it dead code, or feeding something not yet built?


## **Domain model Prompt I used**:

I'd like you to act as a senior developer who deeply understands our codebase's 
domain model. I'm a junior developer trying to make sense of the business logic 
and domain concepts in this application.

Here's what I've found in the codebase:
- Task class (models.py): id, title, description, priority, status, created_at, 
  updated_at, due_date, completed_at, tags. Has methods mark_as_done() and is_overdue().
- TaskPriority enum: LOW, MEDIUM, HIGH, URGENT
- TaskStatus enum: TODO, IN_PROGRESS, REVIEW, DONE
- task_priority.py: computes a numeric "importance score" from priority weight, 
  due-date urgency, status, tags, and recency — but this score isn't stored anywhere
- task_list_merge.py: merges two copies of a Task (local vs remote) for sync, 
  with DONE status always winning regardless of timestamp
- task_parser.py: converts shorthand text like "Buy milk @shopping !2 #tomorrow" 
  into a Task object

Based on this code, my current understanding is:
- The system seems to be modeling a personal task-tracking workflow with 
  priority, status, and deadlines
- I think Task and TaskStatus are related because status represents where a 
  task sits in its lifecycle (not started -> active -> reviewed -> finished)
- The task_priority score appears to represent how urgently a task should be 
  worked on, but I'm not sure who or what consumes this score since it's 
  computed but never saved
- I'm confused about why "DONE always wins" in the merge logic even if the 
  remote copy has a more recent timestamp — is that intentional business logic 
  or a bug?

Could you, as a senior developer:
1. Validate my current understanding, correcting any misconceptions
2. Help me recognize the core domain concepts represented in this code
3. Explain the relationships between these entities in business terms, not 
   just technical relationships
4. Clarify any domain-specific terminology or patterns I might be missing
5. Help me connect these models to actual user-facing features or business 
   processes
 

**AI's response**:

*1–2.Validating your understanding + core domain concepts*
You're mostly right, with one correction. This is a personal task-tracking domain, and TaskStatus does represent lifecycle stage — but it's not strictly linear. Nothing in the code enforces TODO → IN_PROGRESS → REVIEW → DONE in order; a task could jump from TODO straight to DONE, or bounce back from REVIEW to IN_PROGRESS. So think of status as "current state," not "step N of a fixed pipeline," until you decide to add validation.

Core concepts I see: a Task (the unit of work), a priority (business importance, assigned by a human), a status (current lifecycle state), and a separately computed urgency score (derived from priority + due date + status, not stored). Those last two are easy to conflate but they're different concepts: priority is declared, urgency score is calculated.

*3.Relationships in business terms*
A Task has a priority — a human's judgment of "how important is this," set once and rarely changes.
A Task has a status — where it currently sits, which changes constantly as work progresses.
The Task's computed urgency score is a business signal for "what should I work on next," combining the human's priority judgment with objective facts (how close is the deadline, is it already overdue).
Two copies of a Task can conflict (local vs. remote after being offline), and the merge logic encodes a business rule: completed work is authoritative and shouldn't be "un-done" by a stale remote copy, even if that copy has a later timestamp
.
*4.Terminology/patterns you might be missing*
The "DONE always wins" behavior is very likely intentional, not a bug — it's a common sync pattern called "completion is sticky." The reasoning: if you marked something done on your laptop, then your phone syncs a stale in-progress version from before you finished, you don't want the phone's stale state to resurrect a task you already closed out. This is worth flagging explicitly in a comment if it isn't already, because the next person will have your exact question.

*5.Connecting to user-facing features*
task_priority's score, though unused today, is exactly what you'd need for a "smart sort" or "what should I do next" feature — it's pre-built infrastructure for a feature that doesn't exist yet in the UI/CLI.
task_parser's shorthand syntax is what powers quick task creation — a power-user feature.
task_list_merge is what makes offline-first sync viable — without it, using the app on two devices would silently lose data.

---

I tested my understanding with AI questions.

___

*Diagram to sketch:*

A simple box-and-arrow: Task in the center, with two enum boxes (TaskPriority, TaskStatus) feeding into it, and one box off to the side labeled "computed urgency score" with a dotted arrow (not solid — to signal "derived, not stored") pointing from Task. That dotted vs. solid line is the detail that will help the distinction between "declared data" and "derived data" stick.


## **Glossary of domain terms**

*Task Manager — Domain Glossary*

`Task`
The central entity representing a single unit of work. Holds identity (id), description, a declared priority, a current status, and lifecycle timestamps (created_at, due_date, completed_at).

`Priority`
A human-assigned judgment of importance, set once and rarely changed. One of LOW, MEDIUM, HIGH, URGENT. Declared, not calculated — it doesn't shift on its own as time passes.

`Status`
The task's current lifecycle state: TODO, IN_PROGRESS, REVIEW, or DONE. Not enforced as a strict pipeline — nothing stops a task moving out of order (e.g. TODO straight to DONE, or REVIEW back to IN_PROGRESS).

`Urgency score`
A computed value (from task_priority.py) blending priority, due-date closeness, status, tags, and recency into a single ranking number. Distinct from priority: priority is declared by a person, urgency score is calculated from facts. Currently computed but not stored or surfaced anywhere in the app.

`Overdue`
A derived condition (Task.is_overdue()): true when a task has a due date in the past and its status is not DONE. A completed task is never considered overdue, regardless of when it was finished.

`Completion-sticky merge`
The rule in task_list_merge.py that a DONE status always wins during sync, even if the other copy has a more recent timestamp. Prevents a stale "still in progress" copy from undoing work that was already finished elsewhere.

`Tags`
Free-form labels on a Task, used for categorization/filtering. During merge, tags are unioned (kept from both copies) rather than one side winning.

`Shorthand syntax`
The mini task-creation language parsed by task_parser.py — e.g. !2 for priority, @shopping for a tag, #tomorrow for a due date — letting a task be created from one line of text instead of a form.

`Facade`
The architectural role played by task_manager.py: the single entry point that cli.py talks to, which internally delegates to storage, parsing, priority scoring, and merging so that no other module needs to know about those directly.

`Persistence boundary`
The role played by storage.py — the only place a Task is converted to/from JSON. Nothing else in the codebase reads or writes the task file directly.

---

## Exercise Part 4: Practical Application

- *The new business logic the team needs to implement*:

  -Tasks that are overdue for more than 7 days should be automatically marked as abandoned unless they are marked as high priority."

- *files to modify with outlined changes*:

`models.py` — `TaskStatus` currently only has TODO/IN_PROGRESS/REVIEW/DONE. There's no `ABANDONED` value. You'd need to add it to the enum first, before anything else can reference it.
`models.py` (again) — `Task` already has `is_overdue()`. The new rule's condition ("overdue by more than 7 days, unless HIGH priority") is a variant of that logic, so it likely belongs right next to `is_overdue()` as something like `should_be_abandoned()` — following the pattern already established rather than reinventing it elsewhere.
`task_manager.py` — needs a method that actually applies the status change (e.g. `check_and_abandon_overdue_tasks())`, since `task_manager.py` is the facade that mutates state and would call `storage.save()` afterward.
`cli.py` — maybe. This is the open question below.

-*Questions I would ask team before implementing*:

Since this rule is automatic — "should be marked" implies it happens without a user typing a command. So before touching any file, we would need to decide: does this run every time the app loads tasks (e.g., inside `TaskStorage.load()` or `TaskManager.__init__)`? On every `list` command? On a schedule (cron)? Or is it actually meant to be a manual CLI command like `check-abandoned` that a human runs periodically?


-*Reflection*:


**The most valuable insights gained from each prompt**

| Prompt | Insight Gained.                                |
|----------------|----------------------------------------|
| Finding Feature Implementation  Locations

**Any strategies you've developed for approaching unfamiliar code in the future**

- I learned how to make an export of a file, and what files to look at in order to make implementation of new rules. 
- I have learned how the codebase work, the functions and responsibilities for each file. 
- Making use of AI when using Prompts makes reading code efficient and easy to work around. 
-
