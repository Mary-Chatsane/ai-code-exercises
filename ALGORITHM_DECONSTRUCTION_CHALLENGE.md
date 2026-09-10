# Using AI to comprehend existing codebases
---
## Exercise: Algorithm Deconstruction Challenge - Task priority sorting and filtering algorithm(python)

**Reflection Questions**

**How did the AI’s explanation change your understanding of the algorithm?**

*After filling out the prompt 1: Understand an Algorithm Through Step-by-Step Analysis*

AI highlighted my misunderstandings and corrected my mishaps that only needed little fixing. It explained the whole algorithm into key sections. It explained the calculation behind sorting tasks by priority level.  

it broke down the algorithm into key sections with their purposes, walked me through a simple example execution with concrete values, explained the core technique/pattern being used, and highlighted any non-obvious optimizations or tricks.

**What aspects were still difficult to understand after AI explanation?**
The task calculation with python, and how priority levels do mean urgent is automatically mean "highest than the other levels when calculated

**How would you explain this algorithm to another junior developer?** 
The code assigns each task a numerical priority score. It starts with a weighted score based on the task's priority level, then adjusts thatbscore according to how soon the task is due, whether it is completed or under review, whether it has important tags, and whether it was recently updated. Once every task has a score,the tasks are sorted from highest to lowest score, and the top N tasks can be returned.

**Tested understanding against AI**

How might you improve the algorithm based on your understanding?

There seems to not be an obvious reason why the algorithm uses fixed, hand-picked numbers (35, 20, 15, 50, etc). Those numbers determine what the system considers “important," yet there's no clear explanation why that is.


 *After filling out prompt 2:Decipher Code with Unclear Intent or Poor Documentation*

AI helped decipher code that had unclear intentions with poor naming that could have been thought through better for the sake of users understanding the function. it identified unclear names like "score" that did not give the score 'range'. leaving it to readers to figure out the score range.

Claude pointed out that the biggest gap overall is that nothing documents intended range or interpretation of the output — that's the single piece of missing context that would help a reader most, since every other design choice (weights, bonuses, penalties) only makes sense once you know what scale they're meant to produce. and that is something I missed when filling in the prompt. 

it also pointed out that The function has a docstring ("""Calculate a priority score...""") but it just restates the function name — it doesn't explain what a "good" score looks like, whether higher is always better, or what the intended consumer of this score is (we found out separately that nothing in the codebase actually uses it yet).

another sparse comment was that there is no comment explaining the tag boost's magic list — ["blocker", "critical", "urgent"] is hardcoded inline. There's no comment saying where these tag names come from (are they enforced anywhere? case-sensitive? user-typed freely via task_parser.py's @tag syntax, so could easily be misspelled and silently not match).

Also, no comment on why reverse=True combined with tuple sorting is safe — given the latent tie-breaking bug we found earlier (if two tasks have equal scores, Python falls back to comparing Task objects directly), a comment flagging "assumes no two tasks ever tie, or that Task supports comparison" would have surfaced that risk before it becomes a hidden crash.

As a result, I learnt the importance of good documentation with clear intent. The use of prompt, questioning and answering questions with AI clears out misunderstandings in functions, and also compels AI to answer questions posed toward it with reason and evidence. 

 *After filling out Prompt 3: Understand Complex Logic and Control Flow*

My current understanding of the control flow from what I learnt and from my interaction with AI is that: 
The function starts with a base score from priority (weight × 10), then goes through five separate if-blocks in sequence, each one independently adding to or subtracting from the same score variable: a due-date bonus (with its own nested 4-way branch inside it), a status penalty, a tag-based bonus, and a 
recency bonus. There's only one level of real nesting due-date thresholds inside the due_date check) — the rest are flat sequential conditionals stacked one after another, not nested inside each other.

There aren't any explicit nested loops in the provided algorithm.There are separate iterations over tasks and tags, but they aren't written as one loop directly inside another.

**Plain English explanation**

Imagine you have a big pile of to-do list tasks and you need to figure out which ones to tackle first. This function gives every task a "score" — basically a number that says how urgent it is — by starting from zero and adding or subtracting points based on different clues. It starts with how important you said the task was (LOW, MEDIUM, HIGH, URGENT) — URGENT tasks start with way more points than LOW ones. Then it checks the deadline: if it's already overdue, that's a big red flag, so it adds a lot of points. Due today adds a decent chunk, due this week adds a little. If the task is already finished, it drops the score way down — so finished tasks sink to the bottom of the list, out of your way. Tasks stuck "in review" get knocked down a bit too, since they're not something you need to actively work on right now. Then it checks the labels on the task — if it's tagged "urgent" or "critical" or "blocker," it gets a small bonus. Finally, tasks you touched recently get a tiny nudge up, on the theory that stuff you're actively working on should stay visible. Once every task has a score, it just sorts them highest to lowest — score is a stand-in for "how much attention this deserves right now."


**Edge cases the algorithm doesn't handle:**

**Tie-breaking crashes.** If two tasks land on the exact same score (easy to happen — e.g. two DONE tasks with the same priority and no due date), the sort tries to compare the Task objects directly and will crash unless someone added comparison support to the Task class.

**No due date at all**. A task with due_date = None skips the entire due-date bonus block — it gets zero points from urgency, even if it's HIGH priority and genuinely important. It could end up ranked below a MEDIUM priority task that just happens to be due tomorrow.

**Far-future due dates get nothing**. Anything due more than 7 days out gets no bonus — there's no partial credit or decay, it just cliffs to zero. A task due in 8 days scores identically (on this factor) to a task due in 8 months.

**Tag matching is case-sensitive and exact.** "Urgent" or "URGENT" won't match "urgent" in the hardcoded list — a typo or inconsistent capitalization (easy to introduce since tags are user-typed via the @tag shorthand) silently loses the bonus with no warning.

**Score can go negative**, and nothing stops that or documents whether it's expected — a DONE, no-due-date, LOW-priority task scores 1*10 - 50 = -40. That's presumably fine (it just sinks to the bottom), but nothing confirms negative scores are meant to be valid rather than a sign something's off.

**Unknown/invalid priority values** default silently to 0 via .get(task.priority, 0) — if task.priority were ever None or some future enum value not yet added to the dict, it fails silently instead of raising an error, which could hide a data bug rather than surface it.