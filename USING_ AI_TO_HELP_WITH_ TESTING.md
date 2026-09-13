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


## Exercise 1.2: Test Planning

## Test Plan: Task Scoring & Sorting Functions

Each test case below is labeled with: **Priority**, **Test Type**, **Dependencies**, and **Expected Outcome**.

## Priority 1 — `calculate_task_score`
*(Foundation — `sort_tasks_by_importance` and `get_top_priority_tasks` both depend on this function's correctness, so it must be verified first and in isolation.)*

**Type: Unit test** for all cases below — this function has no dependency on other functions in the module, only on `TaskPriority`/`TaskStatus` enums and a `task` object's attributes.

**Dependencies:** None on other functions. Requires a mock/stub `task` object (or real `Task` instance) with controllable `priority`, `due_date`, `status`, `tags`, `updated_at`.

| Test Case | Priority | Expected Outcome |
|---|---|---|
| Base case: MEDIUM priority, no due date, no tags, not recently updated, TODO | High | Score = 20 (2 × 10), no bonuses/penalties applied |
| LOW / MEDIUM / HIGH / URGENT priority in isolation | High | Scores of 10 / 20 / 40 / 60 respectively (all other factors neutral) |
| days_until_due = -1 | High | +35 applied |
| days_until_due = 0 | High | +20 applied |
| days_until_due = 1 | High | No "due today" bonus; falls into "next 2 days" bucket instead, +15 |
| days_until_due = 2 | High | +15 applied |
| days_until_due = 3 | High | Drops to "next week" bucket, +10 applied |
| days_until_due = 7 | High | +10 applied |
| days_until_due = 8 | High | No due-date bonus at all (+0) |
| Status = DONE | High | -50 applied |
| Status = REVIEW | High | -15 applied |
| Tag list includes a matching tag ("urgent"/"critical"/"blocker") | Medium | +8 applied |
| Tag list is empty | Medium | No error; no bonus applied |
| Tag list present but no match | Medium | No bonus applied |
| Updated < 1 day ago | Medium | +5 applied |
| Updated ≥ 1 day ago | Medium | No recency bonus |
| due_date = None | High | Due-date section skipped entirely; no error |
| priority not in priority_weights (e.g. None or unrecognized value) | Medium | Falls back to 0 via `.get()`; no crash |
| Overdue AND status = DONE (combination) | Low (run only after all above pass) | Confirms penalty/bonus interaction produces a sensible net score — document actual result |
| URGENT priority AND "urgent" tag (combination) | Low (run only after all above pass) | Confirms both bonuses stack additively rather than double-counting or conflicting |

## Priority 2 — `sort_tasks_by_importance`

**Type: Unit test**, deliberately isolated from `calculate_task_score`'s correctness. Achieve this by using tasks with pre-determined/mocked scores (or by trusting Priority 1 tests already passed) so a failure here points specifically to ordering logic, not scoring math.

**Dependencies:** Calls `calculate_task_score` internally — Priority 1 tests must pass first, otherwise a failure here is ambiguous (could be either function's fault).

| Test Case | Priority | Expected Outcome |
|---|---|---|
| Tasks with distinct scores, unsorted input | High | Returned list is ordered highest score → lowest score |
| Already-sorted input | Medium | Order unchanged |
| Reverse-sorted input | Medium | Order fully reversed to descending |
| Tasks with equal scores | High | Original relative order preserved (Python `sorted()` stability guarantee, holds with `reverse=True`) |
| Empty task list | Medium | Returns empty list, no error |
| Single-task list | Low | Returns the same single task |

## Priority 3 — `get_top_priority_tasks`

**Type: Unit test** for limit behavior; effectively an **integration test** for the overall pipeline, since it exercises `sort_tasks_by_importance` → `calculate_task_score` end-to-end.

**Dependencies:** Requires Priority 1 and Priority 2 tests to pass first — this function's correctness is contingent on both.

| Test Case | Priority | Expected Outcome |
|---|---|---|
| Default limit (5), more than 5 tasks provided | High | Returns exactly the top 5 tasks by score |
| Small positive limits (1, 2) | High | Returns exactly that many top-scoring tasks |
| limit = 0 | Medium | Returns empty list (Python `[:0]` behavior) |
| limit greater than number of tasks available | Medium | Returns all available tasks, no error (Python slicing stops safely at list end) |
| limit = -1 | Low — edge case for documentation, not a supported use case | Returns all tasks except the last one (Python negative-slice behavior) — flag as a potential design gap; consider whether negative limits should raise an error instead |
| Full pipeline integration: unsorted tasks with mixed priorities/due dates/statuses, no scores pre-mocked | High (integration test) | Confirms the three functions work correctly together end-to-end, not just individually |

---

**Part 2: Improving a Single Test**
**Exercise 2.1: Writing Your First Test**

**Basic Test:**

```
def test_calculate_task_score_basic():
    # Create a simple task with LOW priority
    task = Task(priority=TaskPriority.LOW)

    # Calculate the score
    score = calculate_task_score(task)

    # Check that the score matches the LOW priority weight
    assert score == 10
```

**calculateTaskScore function with the prompt to improve the test:**

I wrote this test for the following function:

Function:
def calculate_task_score(task):
    """Calculate a priority score for a task based on multiple factors."""
    # Base priority weights
    priority_weights = {
        TaskPriority.LOW: 1,
        TaskPriority.MEDIUM: 2,
        TaskPriority.HIGH: 4,
        TaskPriority.URGENT: 6
    }

My test:

def test_calculate_task_score_basic():
    # Create a simple task with LOW priority
    task = Task(priority=TaskPriority.LOW)

    # Calculate the score
    score = calculate_task_score(task)

    # Check that the score matches the LOW priority weight
    assert score == 10

Instead of rewriting it for me, please:
1. Ask me questions about what my test is trying to verify
2. Help me identify if my test is checking behavior or implementation details
3. Suggest how I could make the test's purpose clearer
4. Ask me what edge cases my test might be missing
5. Guide me in improving my assertions to be more precise


**Improved test of `test_calculate_task_score_basic` after conversations with answered questions from Claude**

```python
def test_calculate_task_score_basic():
    # Create a task with LOW priority, and every other scoring
    # factor explicitly neutralized so this test isolates only
    # the priority-weight calculation.
    task = Task(
        priority=TaskPriority.LOW,
        due_date=None,
        status=TaskStatus.TODO,
        tags=[],
        updated_at=datetime.now() - timedelta(days=7),  # well clear of the recency boundary
    )

    score = calculate_task_score(task)

    # LOW priority weight (1) * 10 = 10, with no other bonuses/penalties
    assert score == 10
```

**What Changed and Why:**

| Field | Original | Corrected | Reason |
|---|---|---|---|
| `priority` | `TaskPriority.LOW` | `TaskPriority.LOW` | Unchanged — this is the one factor the test intends to verify |
| `due_date` | *(not set — relied on Task's default)* | `None` | Explicitly skips the due-date bonus section entirely |
| `status` | *(not set — relied on Task's default)* | `TaskStatus.TODO` | Avoids both the DONE (-50) and REVIEW (-15) penalties |
| `tags` | *(not set — relied on Task's default)* | `[]` | Guarantees no tag bonus is applied |
| `updated_at` | *(not set — relied on Task's default)* | `datetime.now() - timedelta(days=7)` | Avoids the recency bonus with clear buffer — deliberately not placed at the exact 1-day boundary, since that boundary isn't what this test is checking |

## Exercise 2.2: Learning From Examples