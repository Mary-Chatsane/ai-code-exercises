# Code Understanding Journal - Exercise: Codebase Exploration Challenge

A running log of my findings as I learn how the Task Management System is built (python).
---
Exercise part 1-4 
---
**Exercise Part 1: Understanding a Specific Feature**

Feature Deep-Dive: Task Creation & Status Updates
Main components involved
cli.py — entry point, parses arguments
TaskManager.create_task() / TaskManager.update_task_status() — business logic
Task (constructor and mark_as_done()) — the data + a couple of self-contained rules
TaskStorage (in storage.py, not yet reviewed) — persistence, assumed to read/write tasks.json

**Execution flow — creating a task**
python cli.py create "Title" -p 3 -u "2024-02-01" → cli.py parses args → calls TaskManager.create_task(...)
create_task() converts the raw int priority into a TaskPriority enum, and parses the due-date string into a real datetime (invalid format → prints error, returns None, nothing is created)
A new Task(...) is constructed — this generates a UUID, forces status = TODO, and stamps created_at/updated_at
create_task() passes the Task to storage.add_task(task), which is expected to persist it and return the new ID
cli.py prints the returned ID

**Execution flow — updating status**
python cli.py status <id> done → TaskManager.update_task_status(task_id, "done")
String converted to TaskStatus.DONE
Special case for DONE: fetch the Task object → call task.mark_as_done() (sets status + completed_at) → explicitly call storage.save()
Any other status: skip the above, call storage.update_task(task_id, status=new_status) directly — a generic path

**How data is stored/retrieved**
Not fully confirmed yet (need storage.py), but inferred: JSON file (tasks.json by default), accessed only through TaskStorage methods (add_task, get_task, get_all_tasks, update_task, delete_task, save, etc.)
TaskManager never reads/writes files directly — always goes through TaskStorage

**Design patterns spotted**
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

**Exercise Part 2: Deepen Understanding Through Guided Questions**

In this part, I used *"Prompt 2: Deepen understanding of a codebase"* which helped me understand the creation of task management through the
command-line applications. I understood that the system allows users to create tasks with information such as title, description, priority, due 
date, and tags. Users can make lists, updates, and view tasks. They can also manage their tags and view statistics. 

*My initial understanding vs. what I discovered*
- As I was exploring how the code works, my understanding was that all the files that get involved in task creation are a breakdown of the task management system, for example; cil.py, model.py, storage.py etc. What I did not know was that, although files like cil.py, model.py, storage.py and task_manager.py are all files that have their own function in a creation of a task, the files split responsibilities across layers. As a result; acting as cli.py - data model, model.py -persistence, storage.py - business logic, and task_manager.py - user interface. However, for this code in particular, cli.py was the only file involved in the README, and not all of them. So what I discovered that, for this exercise, the main focus was the README document. in which, its aim was to tell me what the project is about, how to install or run it, and what commands are available.  So cli.py as the only file involved, it is the entry point in which data flows in one direction when you run a command, by interpreting and receiving the command, then calls another part of the program. The focus of this exercise was on task priorities, and I learnt that the task management systems aligns each task one of four priority levels (priority 1-4), with priority 2 representing MEDIUM and priority 3 representing HIGH. The priority can be specified when creating a task using *--priority.* and can also be used to filter tasks when listing them.  

*The key insights the guided questions helped you uncover*
- the prompt 'prompt 2' resulted in AI asking relevant questions and giving insights that helped me to learn how the code work, and how AI
responds to direct prompt after I had attempted to fill it according to my understanding. it revealed information that was unknown to me, and corrected my understanding on how codes work from how I filled in the prompt. The aim of prompt 2 was to deepen my understanding of code base, and that is what I got out of it.

*Any misconceptions you had that were clarified*
- The misconception was basically own how files interactions work with each other. I only understood as I asked and answered questions that AI asked me, and that the README that I worked with in this exercise was not part of the program executions. The point was for me to understand how task commands that have to do with low to high priorities are made. So that was a highlight for me, because to understand how code works, I needed to understand the base of it, and how commands in task creation are made.


**Exercise part 3: Mapping data flow**


**Exercise part 4: Reflection and presentation**


