## Exercise: Design Pattern Implementation Challenge
## Factory Pattern Opportunity (Python)

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

It explained that the Strategy Pattern helps separate different ways of performing an operation, but it does not solve the problem of having too many parameters in a class constructor. That is a separate issue that would be better addressed using the Builder Pattern. Although the Strategy Pattern and Factory Pattern are related, they serve different purposes. A Factory decides which class or object to create, while a Strategy allows an existing object to choose which approach or algorithm to use at runtime. And that in practice, both patterns can work together: a factory-like selection can choose the appropriate strategy, and the main object can delegate the actual work to that strategy. Using them together is common and does not mean they are competing with each other.

**Step-by-step refactoring plan by Claude**

- Define a ConnectionStrategy interface with one required method: connect(config).
- Create one concrete strategy class per database type (MySQLStrategy, PostgreSQLStrategy, MongoDBStrategy, RedisStrategy), each implementing connect() with only the logic that type needs.
- Move each elif branch's body verbatim into its matching strategy class.
- Change DatabaseConnection.__init__ to select and store a strategy instance (via a lookup dict) instead of just storing db_type as a string.
- Change DatabaseConnection.connect() to delegate: self.connection = self._strategy.connect(self._config) — no more if/elif in the context class.
Keep the public API (DatabaseConnection(db_type=..., ...).connect()) unchanged so existing call sites don't break.


**The pattern Claude recommended**

Unlike the Strategy alone that I recommended, Claude recommended that we have it combined with the Factory Method. Reason being:

- Strategy (what you just implemented) solves the if/elif sprawl — each database's connection logic is now isolated and independently testable. That's real, done, working.
- But Strategy alone still leaves construction awkward: DatabaseConnection.__init__ still takes 10 parameters, and the _strategies dict lookup inside __init__ is functionally a small Factory already hiding inside your context class.

---

**Refactored code with Strategy and Factory Method:**
Proving that the code was refactored with the same end result as before, just better organized.

```
from abc import ABC, abstractmethod


# ---------------------------------------------------------------------------
# Strategy: one interchangeable algorithm per database type
# ---------------------------------------------------------------------------

class ConnectionStrategy(ABC):
    """Common interface all database connection strategies must implement."""

    @abstractmethod
    def build_connection_string(self, config: dict) -> str:
        ...

    @abstractmethod
    def connect(self, config: dict):
        """Perform the connection and return the connection object."""
        ...


class MySQLStrategy(ConnectionStrategy):
    def build_connection_string(self, config):
        cs = (f"mysql://{config['username']}:{config['password']}"
              f"@{config['host']}:{config['port']}/{config['database']}")
        cs += f"?charset={config.get('charset', 'utf8')}"
        cs += f"&connectionTimeout={config.get('connection_timeout', 30)}"
        if config.get('use_ssl'):
            cs += "&useSSL=true"
        return cs

    def connect(self, config):
        connection_string = self.build_connection_string(config)
        print(f"MySQL Connection: {connection_string}")
        # In a real app: return mysql.connector.connect(...)
        return None


class PostgreSQLStrategy(ConnectionStrategy):
    def build_connection_string(self, config):
        cs = (f"postgresql://{config['username']}:{config['password']}"
              f"@{config['host']}:{config['port']}/{config['database']}")
        if config.get('use_ssl'):
            cs += "?sslmode=require"
        return cs

    def connect(self, config):
        connection_string = self.build_connection_string(config)
        print(f"PostgreSQL Connection: {connection_string}")
        # In a real app: return psycopg2.connect(...)
        return None


class MongoDBStrategy(ConnectionStrategy):
    def build_connection_string(self, config):
        cs = (f"mongodb://{config['username']}:{config['password']}"
              f"@{config['host']}:{config['port']}/{config['database']}")
        cs += f"?retryAttempts={config.get('retry_attempts', 3)}"
        cs += f"&poolSize={config.get('pool_size', 5)}"
        if config.get('use_ssl'):
            cs += "&ssl=true"
        return cs

    def connect(self, config):
        connection_string = self.build_connection_string(config)
        print(f"MongoDB Connection: {connection_string}")
        # In a real app: return pymongo.MongoClient(...)
        return None


class RedisStrategy(ConnectionStrategy):
    def build_connection_string(self, config):
        return f"{config['host']}:{config['port']}/{config['database']}"

    def connect(self, config):
        print(f"Redis Connection: {self.build_connection_string(config)}")
        # In a real app: return redis.Redis(...)
        return None


# ---------------------------------------------------------------------------
# Factory Method: isolated, reusable strategy-selection logic
# ---------------------------------------------------------------------------

_STRATEGIES = {
    'mysql': MySQLStrategy,
    'postgresql': PostgreSQLStrategy,
    'mongodb': MongoDBStrategy,
    'redis': RedisStrategy,
}


def create_strategy(db_type: str) -> ConnectionStrategy:
    """Factory function: map a db_type string to a ConnectionStrategy instance."""
    if db_type not in _STRATEGIES:
        raise ValueError(f"Unsupported database type: {db_type}")
    return _STRATEGIES[db_type]()


# ---------------------------------------------------------------------------
# Context: holds config, delegates all connection logic to its strategy
# ---------------------------------------------------------------------------

class DatabaseConnection:
    """Context class: delegates connection logic to a ConnectionStrategy
    obtained from the create_strategy factory."""

    def __init__(self, db_type, host, port, username, password, database,
                 use_ssl=False, connection_timeout=30, retry_attempts=3,
                 pool_size=5, charset='utf8'):
        self.db_type = db_type
        self._strategy = create_strategy(db_type)
        self._config = {
            'host': host,
            'port': port,
            'username': username,
            'password': password,
            'database': database,
            'use_ssl': use_ssl,
            'connection_timeout': connection_timeout,
            'retry_attempts': retry_attempts,
            'pool_size': pool_size,
            'charset': charset,
        }
        self.connection = None

    def connect(self):
        print(f"Connecting to {self.db_type} database...")
        self.connection = self._strategy.connect(self._config)
        print("Connection successful!")
        return self.connection


# ---------------------------------------------------------------------------
# Example usage — identical to the original, same end result
# ---------------------------------------------------------------------------

if __name__ == "__main__":
    mysql_db = DatabaseConnection(
        db_type='mysql',
        host='localhost',
        port=3306,
        username='db_user',
        password='password123',
        database='app_db',
        use_ssl=True
    )
    mysql_db.connect()

    mongo_db = DatabaseConnection(
        db_type='mongodb',
        host='mongodb.example.com',
        port=27017,
        username='mongo_user',
        password='mongo123',
        database='analytics',
        pool_size=10,
        retry_attempts=5
    )
    mongo_db.connect()
```

**Tests that verified that nothing broke**

```
Tests verifying the Strategy+Factory refactor preserves the original
DatabaseConnection behavior.

Run with: pytest test_db_connection.py -v
"""

import pytest
from db_connection_strategy_factory import DatabaseConnection, create_strategy


def test_mysql_connection_string_matches_original_format():
    """
    Original MySQL branch built:
    mysql://{user}:{pw}@{host}:{port}/{db}?charset={c}&connectionTimeout={t}&useSSL=true
    """
    strategy = create_strategy('mysql')
    config = {
        'username': 'db_user',
        'password': 'password123',
        'host': 'localhost',
        'port': 3306,
        'database': 'app_db',
        'use_ssl': True,
        'charset': 'utf8',
        'connection_timeout': 30,
    }

    result = strategy.build_connection_string(config)

    expected = (
        "mysql://db_user:password123@localhost:3306/app_db"
        "?charset=utf8&connectionTimeout=30&useSSL=true"
    )
    assert result == expected


def test_mongodb_connection_string_matches_original_format():
    """
    Original MongoDB branch built:
    mongodb://{user}:{pw}@{host}:{port}/{db}?retryAttempts={r}&poolSize={p}&ssl=true
    """
    strategy = create_strategy('mongodb')
    config = {
        'username': 'mongo_user',
        'password': 'mongo123',
        'host': 'mongodb.example.com',
        'port': 27017,
        'database': 'analytics',
        'use_ssl': False,
        'retry_attempts': 5,
        'pool_size': 10,
    }

    result = strategy.build_connection_string(config)

    expected = (
        "mongodb://mongo_user:mongo123@mongodb.example.com:27017/analytics"
        "?retryAttempts=5&poolSize=10"
    )
    assert result == expected
    # use_ssl was False, so "&ssl=true" must NOT appear (matches original behavior)
    assert "ssl=true" not in result


def test_unsupported_db_type_raises_same_error_as_original():
    """
    Original code raised: ValueError(f"Unsupported database type: {db_type}")
    both from the factory and from DatabaseConnection construction.
    """
    with pytest.raises(ValueError, match="Unsupported database type: oracle"):
        create_strategy('oracle')

    with pytest.raises(ValueError, match="Unsupported database type: oracle"):
        DatabaseConnection(
            db_type='oracle',
            host='localhost',
            port=1521,
            username='u',
            password='p',
            database='d',
        )


def test_full_connect_flow_returns_and_prints_like_original(capsys):
    """
    End-to-end check: DatabaseConnection(...).connect() should print the same
    three lines the original monolithic version printed, and return None
    (since no real driver is wired up, same as the original stub behavior).
    """
    db = DatabaseConnection(
        db_type='mysql',
        host='localhost',
        port=3306,
        username='db_user',
        password='password123',
        database='app_db',
        use_ssl=True,
    )
    result = db.connect()

    captured = capsys.readouterr()
    assert "Connecting to mysql database..." in captured.out
    assert "MySQL Connection: mysql://db_user:password123@localhost:3306/app_db" in captured.out
    assert "Connection successful!" in captured.out
    assert result is None
```


**What each test confirms against the original behavior**

1. **MySQL connection string format** — exact match to the original's `mysql://...?charset=...&connectionTimeout=...&useSSL=true` string, including SSL appended.
2. **MongoDB connection string format** — exact match to the original's `mongodb://...?retryAttempts=...&poolSize=...`, and confirms `ssl=true` is correctly *absent* when `use_ssl=False`, same as the original's conditional.
3. **Same error on unsupported type** — both the factory and the full `DatabaseConnection` constructor raise the identical `ValueError` message the original raised.
4. **Full end-to-end flow** — checks the three printed lines and `None` return value match exactly what the original monolithic `connect()` produced.


**Reflection**

Before, the `DatabaseConnection` class did everything in one place: a single `connect()` method used a long `if/elif` chain to check the database type and then built a completely different connection string for each one, all mixed together with a bloated 10-parameter constructor that made you pass irrelevant settings (like `pool_size` for a MySQL connection, which doesn't use it) just to satisfy the signature. Applying the Strategy pattern pulled each database's connection logic out into its own small class, all following the same shared interface, so `DatabaseConnection` no longer needs to know *how* each database connects — it just delegates to whichever strategy it was given. Adding the Factory Method on top moved the "which class handles which database name" decision into one dedicated function, so that lookup logic isn't buried inside the object's constructor either. Going forward, adding support for a new database (say, SQLite or Oracle) means writing one new strategy class and adding one line to the factory's lookup table — no existing class has to be touched or re-tested, and each database's logic can be tested completely on its own instead of through the whole tangled object.