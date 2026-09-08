# Knowing Where to Start

# Exercise part 1-4 (python)

---

**Setup**

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
├── task_list_merger.py     ← likely combines/merges task lists
├── task_parser.py          ← likely parses task-related data/input
├── task_priority.py        ← likely handles task priorities
└── README.md               ← project documentation

The prompt helped me understand what the application does based on the files involved. it gave me deeper insight of the task management. I had assumptions on how files interacted with each other and did not understand the technologies used, and only got to find out that the technologies are in fact; programming languages, frameworks, libraries, tools, and platforms used to build/run/test the application. what I did not know was that the term 'technologies' is used for such. As a result, the application appears to rely entirely on pythons standard library rather than external packages/frameworks. 

*AI analysis compared to my observation*
AI analysis were more sure and reliant on evidence and documents placed before it, whilst I made a couple of intuitive guesses and assumptions. But I received corrections, and a better understanding. From that I also learnt that pythons standard libraries like argparse, datetime and unittest are also technologies and the project itself is divided into several python modules mentioned above. 
 
---

## Exercise Part 2: Finding Feature Implementation

**Goal:** Trace a specific feature from entry point to implementation.

- Feature I chose to trace:
  -

- Prompts/commands I used:
  -
  -

- Path the code takes (entry point → logic → data layer):
  1.
  2.
  3.

- What patterns or conventions did I notice repeated across features?
  -

---

## Exercise Part 3: Understanding Domain Model

**Goal:** Understand the core entities, relationships, and business concepts the code represents.

- Prompts/commands I used:
  -
  -

- Core entities/models identified:
  -

- Relationships between entities:
  -

- Business rules or constraints encoded in the model:
  -

---

## Exercise Part 4: Practical Application

**Goal:** Apply your understanding by implementing a new business rule.

- The business rule I implemented:
  -

- Where in the codebase I made changes:
  -

- Prompts/commands I used to figure out where/how to make the change:
  -
  -

- Challenges I ran into:
  -

- How I verified the change worked correctly:
  -

---

## Final Discussion and Reflection

- Overall reflections on the exercise:
  -

- What was harder or easier than expected:
  -

---

## Submission

**1. Your initial vs. final understanding of the Task Manager codebase**

*Initial understanding:*
-

*Final understanding:*
-

**2. The most valuable insights gained from each prompt**

| Prompt | Insight Gained |
|--------|-----------------|
|        |                 |

**3. Your approach to implementing the new business rule**

-

**4. Any strategies you've developed for approaching unfamiliar code in the future**

-
-
-
