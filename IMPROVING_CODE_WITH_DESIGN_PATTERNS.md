## Exercise: Design Pattern Implementation Challenge
**Code description**

The code feels messy and hard to maintain because the DatabaseConnection class is trying to handle too many different database types in one place. The __init__ method has a long list of parameters, many of which only apply to certain databases, making it difficult to know what is actually needed for each connection. The connect() method is also very long because it contains separate connection logic for MySQL, PostgreSQL, MongoDB, and Redis, so changing or adding one database type means modifying the same large method. The connection-string logic is different for each database and is mixed together with the connection process, which makes the code harder to read and test. Some settings, such as pool_size and retry_attempts, are only relevant to MongoDB, while others are specific to particular databases, but they all live in the same class. This creates a lot of conditional logic and makes the class more likely to become complicated as more database types or configuration options are added.

**Applied Prompt 1: Pattern Opportunity Identification**



