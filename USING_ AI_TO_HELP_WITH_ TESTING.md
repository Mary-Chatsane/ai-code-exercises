## Exercise: Learning how to test code with AI
**Part 1: Understanding What to Test**
**Exercise 1.1: Behavior Analysis*

**Five listed cases built through conversation with AI**

## Test Plan: `calculate_task_score`

## 1. Base Case (write this first)
A plain task with no bonuses or penalties — confirms the priority-weight math alone works correctly before layering on anything else.
- MEDIUM priority, no due date, no tags, not recently updated, status TODO

## 2. Priority Levels in Isolation
Confirm each priority level produces the expected base score on its own.
- LOW priority
- MEDIUM priority
- HIGH priority
- URGENT priority

## 3. Due-Date Boundaries (boundary value analysis)
Test the exact edges where the score bucket changes, not every possible day count.

| `days_until_due` | Boundary being tested |
|---|---|
| -1 | Just inside "overdue" (`< 0`) |
| 0 | Just outside overdue / inside "due today" (`== 0`) |
| 1 | Just outside "due today" |
| 2 | Just inside "due in next 2 days" (`<= 2`) |
| 3 | Just outside "due in next 2 days" |
| 7 | Just inside "due in next week" (`<= 7`) |
| 8 | Just outside "due in next week" (no bonus) |

## 4. Status Penalties in Isolation
- Status = DONE (expect -50)
- Status = REVIEW (expect -15)

## 5. Tag Bonus in Isolation
- Tags include a matching value (e.g. `"urgent"`, `"critical"`, or `"blocker"`) → expect +8
- Tags list is empty → expect no bonus, no error
- Tags present but none match the list → expect no bonus

## 6. Recency Bonus in Isolation
- `updated_at` less than 1 day ago → expect +5
- `updated_at` 1 day ago or more → expect no bonus

## 7. Missing / Unusual Data
- `due_date = None` → due-date section should be skipped without error
- `tags = []` → confirm `any()` returns `False` cleanly, no error
- `priority` value not present in `priority_weights` (e.g. `None` or an unexpected value) → confirm it silently falls back to 0 via `.get(task.priority, 0)`, rather than crashing

## 8. Combinations (only after all of the above pass individually)
Test these only once each contributing factor is independently verified — a failure here should then clearly indicate an interaction bug, not a base-rule bug.
- Task is both overdue **and** marked DONE — confirm the DONE penalty behaves sensibly against the overdue bonus
- Task has URGENT priority **and** an "urgent" tag — confirm both bonuses stack independently rather than double-counting or conflicting

**Exercise 1.2: Test Planning**

**Priority of test cases**



**Types of tests needed (unit, integration)**


**Test dependencies**


**Expected outcomes for each test**

