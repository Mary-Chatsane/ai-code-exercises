# Using AI to comprehend existing codebases
---
## Exercise: Algorithm Deconstruction Challenge - Task priority sorting and filtering algorithm(python)

**Reflection Questions**

**How did the AI’s explanation change your understanding of the algorithm?**

## *After filling out the prompt 1: Understand an Algorithm Through Step-by-Step Analysis*

AI highlighted my misunderstandings and corrected my mishaps that only needed little fixing. It explained the whole algorithm into key sections. It explained the calculation behind sorting tasks by priority level.  

it broke down the algorithm into key sections with their purposes, walked me through a simple example execution with concrete values, explained the core technique/pattern being used, and highlighted any non-obvious optimizations or tricks.

**What aspects were still difficult to understand after AI explanation?**
The task calculation with python, and how priority levels do mean urgent is automatically mean "highest than the other levels when calculated

**How would you explain this algorithm to another junior developer?** 
The code assigns each task a numerical priority score. It starts with a weighted score based on the task's priority level, then adjusts thatbscore according to how soon the task is due, whether it is completed or under review, whether it has important tags, and whether it was recently updated. Once every task has a score,the tasks are sorted from highest to lowest score, and the top N tasks can be returned.

**Tested understanding against AI**

How might you improve the algorithm based on your understanding?

There seems to not be an obvious reason why the algorithm uses fixed, hand-picked numbers (35, 20, 15, 50, etc). Those numbers determine what the system considers “important," yet there's no clear explanation why that is.


## *After filling out prompt 2:Decipher Code with Unclear Intent or Poor Documentation*

AI helped decipher code that had unclear intentions with poor naming that could have been thought through better for the sake of users understanding the function. it identified unclear names like "score" that did not give the score 'range'. leaving it to readers to figure out the score range.

Claude pointed out that the biggest gap overall is that nothing documents intended range or interpretation of the output — that's the single piece of missing context that would help a reader most, since every other design choice (weights, bonuses, penalties) only makes sense once you know what scale they're meant to produce. and that is something I missed when filling in the prompt. 

it also pointed out that The function has a docstring ("""Calculate a priority score...""") but it just restates the function name — it doesn't explain what a "good" score looks like, whether higher is always better, or what the intended consumer of this score is (we found out separately that nothing in the codebase actually uses it yet).

another sparse comment was that there is no comment explaining the tag boost's magic list — ["blocker", "critical", "urgent"] is hardcoded inline. There's no comment saying where these tag names come from (are they enforced anywhere? case-sensitive? user-typed freely via task_parser.py's @tag syntax, so could easily be misspelled and silently not match).

Also, no comment on why reverse=True combined with tuple sorting is safe — given the latent tie-breaking bug we found earlier (if two tasks have equal scores, Python falls back to comparing Task objects directly), a comment flagging "assumes no two tasks ever tie, or that Task supports comparison" would have surfaced that risk before it becomes a hidden crash.

As a result, I learnt the importance of good documentation with clear intent. The use of prompt, questioning and answering questions with AI clears out misunderstandings in functions, and also compels AI to answer questions posed toward it with reason and evidence. 

## *After filling out Prompt 3: Understand Complex Logic and Control Flow*

My current understanding of the control flow from what I learnt and from my interaction with AI is that: 
The function starts with a base score from priority (weight × 10), then goes through five separate if-blocks in sequence, each one independently adding to or subtracting from the same score variable: a due-date bonus (with its own nested 4-way branch inside it), a status penalty, a tag-based bonus, and a 
recency bonus. There's only one level of real nesting due-date thresholds inside the due_date check) — the rest are flat sequential conditionals stacked one after another, not nested inside each other.

There aren't any explicit nested loops in the provided algorithm.There are separate iterations over tasks and tags, but they aren't written as one loop directly inside another.