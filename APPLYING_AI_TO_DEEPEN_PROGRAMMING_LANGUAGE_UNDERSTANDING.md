## Exercise: Writing Better Code in Your Own Language (Deepening Knowledge of Your Current Programming Language)

**Activity 1: Idiomatic Code Transformation**

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

**Claude's idiomatic version after applying the Idiomatic Code Transformation prompt**

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

**Activity 2: Code Quality Detective**

I did not have code that I had written three or more months ago, so I created a small Python Task Management function for this activity to simulate reviewing older code with fresh eyes. The code:

```
def manage_tasks(tasks):
    completed_tasks = []
    pending_tasks = []
    urgent_tasks = []
    total_tasks = 0

    for task in tasks:
        total_tasks = total_tasks + 1

        if task["status"] == "done":
            completed_tasks.append(task)
        else:
            pending_tasks.append(task)

        if task["priority"] == "urgent":
            urgent_tasks.append(task)

    print("Total tasks:", total_tasks)
    print("Completed tasks:", len(completed_tasks))
    print("Pending tasks:", len(pending_tasks))
    print("Urgent tasks:", len(urgent_tasks))

    print("\nCompleted:")
    for task in completed_tasks:
        print("-", task["title"])

    print("\nPending:")
    for task in pending_tasks:
        print("-", task["title"])

    return completed_tasks, pending_tasks, urgent_tasks
```

I used Claude's Code Quality prompt to identify code smells and evaluate the readability, performance, and maintainability of the function.

Claude identified that this function was doing three jobs at once, which is categorising the tasks, printing the report, and returning the data. It then separated the task into separate responsibilities. in total, I learnt that a function can become difficult to maintain when it is responsible for several different things. Separating these responsibilities makes the code easier to reuse, test, and change.

I also learned that Python has built-in features that can replace code I might otherwise write manually. For example, instead of manually increasing a counter with "total_tasks = total_tasks + 1", I can use "len(tasks)" to get the number of items in a list. Also that magic strings such as ""done"" and ""urgent"" can make code harder to maintain. If the same value is used in several places, defining it more clearly can reduce mistakes caused by spelling errors or inconsistent values.

So below is my personal checklist:

When writing or reviewing Python code, I will ask myself:

- Does each function have a clear and focused responsibility?
- Am I duplicating code that could be simplified?
- Am I manually doing something Python already has a built-in feature for?
- Are my function and variable names descriptive?
- Am I using unexplained "magic strings" or values?
- Is the return value clear to someone reading the code?
- Would adding a docstring make the function easier to understand?
- Is the code easy to test independently?
- Would changing one part of the function require unnecessary changes elsewhere?


**Activity 3: Understanding Language Feature**

