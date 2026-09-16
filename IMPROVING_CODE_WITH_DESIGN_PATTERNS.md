## Exercise: Design Pattern Implementation Challenge
**Code description**

The code feels messy and hard to maintain because the DatabaseConnection class is trying to handle too many different database types in one place. The __init__ method has a long list of parameters, many of which only apply to certain databases, making it difficult to know what is actually needed for each connection. The connect() method is also very long because it contains separate connection logic for MySQL, PostgreSQL, MongoDB, and Redis, so changing or adding one database type means modifying the same large method. The connection-string logic is different for each database and is mixed together with the connection process, which makes the code harder to read and test. Some settings, such as pool_size and retry_attempts, are only relevant to MongoDB, while others are specific to particular databases, but they all live in the same class. This creates a lot of conditional logic and makes the class more likely to become complicated as more database types or configuration options are added.

**Applied Prompt 1: Pattern Opportunity Identification**

With the explanation I got from Claude, I understood the problem the patters were solving. The prompt was detailed, as a result, Claude elaborated on a lot of of points, identified structure, made suggestions, explained the benefits of each pattern, highlighted potential drawbacks or implementation challenges.  I found that helpful.

**Patterns suggested:**

## Suggested patterns

1. **Factory Method / Simple Factory** — replaces the `if/elif` chain with one class per database type, created via a factory function. *Highest priority.*
2. **Builder** — replaces the 10-parameter constructor with step-by-step, self-documenting configuration. *High priority, pairs with Factory.*
3. **Connection registry via Dependency Injection** (not a literal Singleton) — reuses pooled connections instead of creating duplicates. *Medium priority, only if connection reuse matters.*
4. **Strategy** — isolates the connection-string-building logic as swappable units. *Lower priority — Factory already covers most of this need.*

**Prompt 2: Pattern Implementation Guidance**

Claude corrected my understanding of what Strategy actually does.  it highlighted that strategy design pattern leans more into Interchangeable algorithm. Claude corrected my implementation detail of Strategy and defined the patterns trait as being common interface that is implemented by multiple interchangeable classes, and a context object that holds a reference to one of them and delegates to it instead of branching internally.



