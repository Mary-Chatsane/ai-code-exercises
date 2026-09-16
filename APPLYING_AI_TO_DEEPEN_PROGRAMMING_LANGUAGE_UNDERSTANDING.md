## Exercise: Writing Better Code in Your Own Language (Deepening Knowledge of Your Current Programming Language)

**Activity 1**

**Original code**

I created a small function for the exercise because I didn't have a suitable function that I had previously written.

```
def find_high_priority_tasks(tasks):
    high_priority_tasks = []

    for task in tasks:
        if task["priority"] == "high":
            high_priority_tasks.append(task)

    if len(high_priority_tasks) > 0:
        print("High priority tasks found:")
        for task in high_priority_tasks:
            print(task["title"])
    else:
        print("No high priority tasks found.")

    return high_priority_tasks
```

**Claude's idiomatic version after applying the Idiomatic Code Transformationprompt**

I leant that list comprehensions can replace a loop that only builds a list. Instead of creating an empty list, looping through everything, checking each task, and appending matching tasks, Python lets you express the same operation in one line.
I also learnt that pythons uses truthiness, therefore `if len(high_priority_tasks) > 0:` on the code was not needed because Python treats a non-empty list as True and an empty list as False.

I also learnt that a function should ideally have one responsibility. My original function both found the tasks and printed them. Claude separated those responsibilities into find_high_priority_tasks() and print_high_priority_tasks(). This makes the finder reusable—for example, a test can call it and examine the returned list without dealing with printed output.

As a result, I implemented what learnt from Claude to improve my code, and this was the improved version:

```
def find_high_priority_tasks(tasks):
    return [task for task in tasks if task["priority"] == "high"]


def print_high_priority_tasks(tasks):
    high_priority_tasks = find_high_priority_tasks(tasks)

    if high_priority_tasks:
        print("High priority tasks found:")
        for task in high_priority_tasks:
            print(task["title"])
    else:
        print("No high priority tasks found.")

    return high_priority_tasks
```