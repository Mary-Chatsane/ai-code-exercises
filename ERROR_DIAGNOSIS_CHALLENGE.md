## Exercise: Understanding and diagnosing code error

## Selected: Off by One Error (Python)

Applied Prompt 1: Error Message Translation to the Python inventory/stock management application.

## Error Analysis: Off-by-one error

**Error Description:**
Of-by-one error: The loop runs one iteration beyond the valid indexes of the inventory list, causing an IndexError when it attempts to access an item that does not exist.

**Root Cause:**
The root cause is the + 1 in: range(len(items) + 1)
In simple words: the loop is told to go one step too far.
There are 3 items, but the loop tries to access a 4th item that doesn't exist, causing the error.

**Solution:**
The solution is to remove the + 1 from the loop. This makes the loop stop at the last valid item instead of trying to access a fourth item that doesn't exist. An even more Python-friendly solution is to use enumerate(), but for fixing this specific error, removing + 1 is the direct solution.

**Learning Points:**
Here's what actually helps, in plain terms:

*Trust `range(len(...))` on its own.* It's already built to give you exactly the right indexes for a list — 0 up to (but not including) the length. If you ever feel tempted to add or subtract a number from inside that `range()` call, stop and ask why. Almost always, the adjustment you're trying to make (like starting item numbers at 1 instead of 0) belongs somewhere else — like in what you *print*, not in what you *loop over*.

*Separate "which item am I touching" from "what number do I show the user."* Those are two different jobs. The loop's job is just to safely visit every item. Display formatting — showing "Item 1" instead of "Item 0" — is a completely separate, cosmetic step that happens after you already have the item in hand. Mixing the two into one number is where bugs like this sneak in.

*Prefer tools that hand you the item directly, instead of making you calculate its position.* `enumerate()` gives you both the index and the item together, safely, every time — you never have to do the length math yourself, so there's no math to get wrong.

*When something crashes with "index out of range," don't guess — check the actual numbers.* Print the length of your list and compare it to what your loop is producing. Nine times out of ten, the mismatch is obvious once you see the two numbers side by side, rather than trying to spot it by reading the code alone.

*Whenever you see "+1" or "-1" near a loop or index, treat it as a small red flag worth double-checking*, not something to write on autopilot. It's one of the most common places for a tiny slip to cause a real bug.