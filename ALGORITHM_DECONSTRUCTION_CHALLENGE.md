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


*After filling out prompt 2:Decipher Code with Unclear Intent or Poor Documentation*

AI helped decipher code that had unclear intentions with poor naming thst could have been thought through better for the sake of users understanding the function. it identified unclear names like "score" that did not give the score 'range'. leaving it to readers to figure out the score range.
