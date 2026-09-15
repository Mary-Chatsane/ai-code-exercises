## Using AI to improve Code quality 
**Exercise 1: Code Readability Improvement (Java)**

# Code Review: `UserMgr` / `U`

## 1. Hard-to-Understand Parts

- **`U`, `u_list`, `un`, `pw`, `em`, `d`, `nu`, `res`** — single/double-letter names force the reader to hold a mental lookup table. Not readable at a glance.
- **`a()` and `f()`** — meaningless verbs. You can't tell what they do without reading the body.
- **String-concatenated SQL** (`"INSERT INTO users VALUES ('" + un + ...`) — this is a SQL injection vulnerability, not just a style issue. Any `'` in the username/email breaks the query or worse.
- **Plaintext password storage** — `pw` is stored and inserted as-is, with no hashing.
- **Linear search over `u_list`** in both `a()` and `f()` — fine for a toy example, but worth flagging since it's O(n) per lookup and duplicates logic.
- **`boolean` return from `a()`** — the caller can't tell *why* it failed (bad input? duplicate user? DB error?).

## 2. Naming Suggestions

| Current | Suggested |
|---|---|
| `UserMgr` | `UserManager` |
| `U` | `User` |
| `u_list` | `users` |
| `db` / `DBConn` / `d` | `database` / `DatabaseConnection` / `connection` |
| `a(un, pw, em)` | `registerUser(username, password, email)` |
| `f(un)` | `findUserByUsername(username)` |
| `nu` | `newUser` |
| `res` | `insertSucceeded` |
| `getUn/getPw/getEm` | `getUsername/getPassword/getEmail` |

## 3. Breaking Down Complex Sections

`registerUser` is doing four separate jobs in one method: validation, duplicate-check, object creation, and persistence. Split into:

- `isValidInput(...)`
- `isUsernameTaken(...)`
- the insert itself

This also makes each piece unit-testable in isolation.

## 4. Style/Consistency Issues

- Mixed abbreviation styles (`un` vs `db` vs full words like `execute`) — pick one convention (full words) and apply everywhere.
- Magic numbers `3` and `8` should be named constants (`MIN_USERNAME_LENGTH`, `MIN_PASSWORD_LENGTH`).
- No braces-consistency issues here, but the getters being one-liners while everything else is multi-line is a minor inconsistency — fine either way, just be consistent project-wide.

## Refactored Version

```java
class UserManager {
    private static final int MIN_USERNAME_LENGTH = 3;
    private static final int MIN_PASSWORD_LENGTH = 8;

    private final List<User> users;
    private final DatabaseConnection database;

    public UserManager(DatabaseConnection database) {
        this.database = database;
        this.users = new ArrayList<>();
    }

    public boolean registerUser(String username, String password, String email) {
        if (!isValidInput(username, password, email)) {
            return false;
        }
        if (isUsernameTaken(username)) {
            return false;
        }

        User newUser = new User(username, hashPassword(password), email);
        users.add(newUser);
        return insertUserIntoDatabase(newUser);
    }

    public User findUserByUsername(String username) {
        for (User user : users) {
            if (user.getUsername().equals(username)) {
                return user;
            }
        }
        return null;
    }

    private boolean isValidInput(String username, String password, String email) {
        return username.length() >= MIN_USERNAME_LENGTH
            && password.length() >= MIN_PASSWORD_LENGTH
            && email.contains("@");
    }

    private boolean isUsernameTaken(String username) {
        return findUserByUsername(username) != null;
    }

    private String hashPassword(String password) {
        // TODO: replace with a real hashing algorithm (e.g. BCrypt)
        return password;
    }

    private boolean insertUserIntoDatabase(User user) {
        String sql = "INSERT INTO users (username, password, email) VALUES (?, ?, ?)";
        return database.executeUpdate(sql, user.getUsername(), user.getPassword(), user.getEmail());
    }
}

class User {
    private final String username;
    private final String password;
    private final String email;

    public User(String username, String password, String email) {
        this.username = username;
        this.password = password;
        this.email = email;
    }

    public String getUsername() { return username; }
    public String getPassword() { return password; }
    public String getEmail() { return email; }
}
```

## Additional Notes

- **SQL injection**: switched to a parameterized query (`?` placeholders) — this assumes `DatabaseConnection.executeUpdate` supports parameters; if it doesn't yet, that's worth fixing before anything else here.
- **Password hashing**: left a `TODO` since real hashing depends on your chosen library (BCrypt, Argon2, etc.) — happy to fill that in if you tell me what's available in your project.

----

# Why the Suggested Names Are Better

A few concrete reasons, beyond just "longer feels nicer":

- **Names should answer questions the code would otherwise force you to look up.** `un`, `pw`, `em` require you to hold a decoder ring in your head. `username`, `password`, `email` answer the question instantly, every time you read them — no cost to future readers (including future you).

- **Verbs should describe what happens, not just gesture at "some action."** `a()` tells you nothing — you have to read the body to know it's registration logic. `registerUser()` lets you understand a call site without ever opening the method. This matters most in larger codebases where you're scanning, not reading line-by-line.

- **Good names double as documentation that can't go stale.** A comment saying "// finds a user by username" can drift out of sync with the code. A method named `findUserByUsername` can't — the name *is* the behavior, enforced by the compiler/interface.

- **Names carry intent that types alone don't.** `U` tells you it's some class; `User` tells you what it represents in the domain. When you're modeling real-world concepts (users, orders, accounts), the domain vocabulary should show up directly in the code — this is a core idea in domain-driven design.

- **Abbreviations save the writer time but cost every reader time**, repeatedly. You type `un` once; everyone who reads it afterward has to reconstruct what it means, every single time. That trade is almost always bad in shared or long-lived code.

The general principle: **optimize for reading, not writing.** Code is read far more often than it's written, so a few extra keystrokes now are cheap compared to the repeated cognitive tax of cryptic names later.

---

# Before / After Comparison

| Aspect | Before | After | Why It Changed |
|---|---|---|---|
| Class name | `UserMgr` | `UserManager` | Full words over abbreviations; clearer at a glance |
| Data class name | `U` | `User` | A single letter gives zero domain meaning |
| Field: user list | `u_list` | `users` | Plain, obvious, no abbreviation needed |
| Field: DB connection | `db` (type `DBConn`) | `database` (type `DatabaseConnection`) | Spelled-out type and field name match and self-document |
| Method: register | `a(un, pw, em)` | `registerUser(username, password, email)` | Verb + parameter names describe exactly what the method does |
| Method: find user | `f(un)` | `findUserByUsername(username)` | Name states the lookup key and return intent |
| Local var: new user | `nu` | `newUser` | No decoding required |
| Local var: DB result | `res` | *(removed — returned directly)* | Simplified by removing the unnecessary intermediate variable |
| Getters | `getUn() / getPw() / getEm()` | `getUsername() / getPassword() / getEmail()` | Matches full field names, consistent with the rest of the class |
| Validation logic | Inline in `a()` | Extracted to `isValidInput(...)` | Single-responsibility: one method, one job, independently testable |
| Duplicate check | Inline loop in `a()` | Extracted to `isUsernameTaken(...)` | Removes duplicate logic (reuses `findUserByUsername`), easier to read |
| Magic numbers | `3`, `8` hardcoded | `MIN_USERNAME_LENGTH`, `MIN_PASSWORD_LENGTH` constants | Self-explaining, easy to change in one place |
| SQL query | String concatenation (`"...VALUES ('" + un + ...`) | Parameterized query (`?` placeholders) | Closes a SQL injection vulnerability |
| Password handling | Stored and inserted as plaintext | Passed through `hashPassword(...)` (stub, needs real algorithm) | Flags a security gap; sets up a safe place to add real hashing |
| Return value | Bare `boolean` from registration | Still `boolean`, but now built from clearly separated checks | Doesn't fully solve "why did it fail," but makes failure paths traceable in the source |

**Net effect:** the refactor didn't just rename things — it separated concerns (validation vs. duplicate-check vs. persistence), removed a security vulnerability, and made every identifier tell you what it holds or does without needing to trace through the logic first.

---

**Exercise 2: Function Refactoring (Python)**

# Refactoring Review: `process_orders`

This function is validating, pricing, shipping, taxing, mutating inventory, and aggregating results, all in one loop body. Here's the breakdown.

## 1. Responsibilities Identified

This single function is doing at least **six distinct jobs**:

1. **Validation** — item exists, quantity available, customer exists
2. **Pricing** — base price + premium discount
3. **Shipping calculation** — domestic/international rules
4. **Tax calculation**
5. **Inventory mutation** — decrementing stock
6. **Aggregation/orchestration** — looping, collecting results, summing revenue

Each of these can change for independent reasons (tax rate changes, shipping rules change, new discount tiers) — that's the classic signal a function should split.

## 2. Suggested Breakdown

```python
def validate_order(order, inventory, customer_data):
    """Returns an error message string, or None if the order is valid."""
    item_id = order['item_id']
    quantity = order['quantity']
    customer_id = order['customer_id']

    if item_id not in inventory:
        return 'Item not in inventory'
    if inventory[item_id]['quantity'] < quantity:
        return 'Insufficient quantity'
    if customer_id not in customer_data:
        return 'Customer not found'
    return None


def calculate_item_price(item_id, quantity, customer_id, inventory, customer_data):
    price = inventory[item_id]['price'] * quantity
    if customer_data[customer_id]['premium']:
        price *= PREMIUM_DISCOUNT_MULTIPLIER
    return price


def calculate_shipping(price, customer_id, customer_data):
    is_domestic = customer_data[customer_id]['location'] == 'domestic'
    if not is_domestic:
        return INTERNATIONAL_SHIPPING
    return DOMESTIC_SHIPPING if price < FREE_SHIPPING_THRESHOLD else 0


def calculate_tax(price):
    return price * TAX_RATE


def build_order_result(order, price, shipping, tax):
    return {
        'order_id': order['order_id'],
        'item_id': order['item_id'],
        'quantity': order['quantity'],
        'customer_id': order['customer_id'],
        'price': price,
        'shipping': shipping,
        'tax': tax,
        'final_price': price + shipping + tax,
    }
```

## 3. Improved Orchestration

The main function becomes a thin loop that reads like a checklist:

```python
PREMIUM_DISCOUNT_MULTIPLIER = 0.9
DOMESTIC_SHIPPING = 5.99
INTERNATIONAL_SHIPPING = 15.99
FREE_SHIPPING_THRESHOLD = 50
TAX_RATE = 0.08


def process_orders(orders, inventory, customer_data):
    processed_orders = []
    error_orders = []
    total_revenue = 0

    for order in orders:
        error = validate_order(order, inventory, customer_data)
        if error:
            error_orders.append({'order_id': order['order_id'], 'error': error})
            continue

        item_id = order['item_id']
        quantity = order['quantity']
        customer_id = order['customer_id']

        price = calculate_item_price(item_id, quantity, customer_id, inventory, customer_data)
        shipping = calculate_shipping(price, customer_id, customer_data)
        tax = calculate_tax(price)

        inventory[item_id]['quantity'] -= quantity
        total_revenue += price + shipping + tax

        processed_orders.append(build_order_result(order, price, shipping, tax))

    return {
        'processed_orders': processed_orders,
        'error_orders': error_orders,
        'total_revenue': total_revenue,
    }
```

Now each helper is independently testable (e.g., you can unit-test `calculate_shipping` without building a fake order list), and the main function reads top-to-bottom as: validate → price → ship → tax → mutate → aggregate.

## 4. Other Issues Worth Flagging

- **Magic numbers everywhere** (`0.9`, `5.99`, `15.99`, `50`, `0.08`) — pulled into named constants above. Makes future rate/threshold changes a one-line edit instead of a hunt through the function.
- **Mutating `inventory` in place** — the function has a side effect on its input, which can surprise callers. Worth at least documenting clearly (or consider returning updated inventory instead, depending on how the rest of your codebase treats mutability).
- **No handling for missing/malformed order dicts** — if `order['item_id']` is missing entirely, you'll get a `KeyError` instead of a clean validation error. Consider validating shape before extracting fields.
- **`error_orders` inconsistency vs. `processed_orders` naming** — `results` was renamed to `processed_orders` for symmetry; small thing, but consistent naming between the two output lists makes the return dict easier to scan.
- **Order of operations risk** — inventory is decremented *before* you know the order is fully done processing (which is fine here since nothing after can fail), but if you later add a step that can fail after the inventory update, you'd get partial state corruption. Worth keeping the mutation as late as possible, as done above.

---

**Exercise 3: Code Duplication Detection (JavaScript)**

# Duplication Review: `calculateUserStatistics`

This code has heavy duplication — the same two patterns (sum-for-average, scan-for-max) repeated three times each, once per field.

## 1. Repeated Patterns Identified

- **Averaging pattern** (appears 3x): loop, accumulate a total, divide by length — identical structure for `age`, `income`, `score`.
- **Max-finding pattern** (appears 3x): initialize to `userData[0][field]`, loop from index 1, compare and replace — identical structure for the same three fields.

That's 6 nearly-identical loops for what's really 2 general operations applied to 3 fields.

## 2. How to Eliminate It

Extract the two patterns into generic helper functions that take a field name (or an accessor function), then loop over the list of fields instead of hand-writing each block.

## 3. Refactored Code

```javascript
function average(items, field) {
  const total = items.reduce((sum, item) => sum + item[field], 0);
  return total / items.length;
}

function maximum(items, field) {
  return items.reduce((max, item) => Math.max(max, item[field]), items[0][field]);
}

function calculateUserStatistics(userData) {
  const fields = ['age', 'income', 'score'];
  const stats = {};

  for (const field of fields) {
    stats[field] = {
      average: average(userData, field),
      highest: maximum(userData, field),
    };
  }

  return stats;
}
```

That's it — 50+ lines down to about 15, with no loss of behavior.

## 4. Benefits

- **Adding a new metric is now a one-word change.** Want `average`/`highest` for a `yearsExperience` field too? Add `'yearsExperience'` to the `fields` array — no new loop to write, no copy-paste risk.
- **Bug fixes only need to happen once.** If there's an edge case (e.g., empty array causing `NaN`, or `undefined` field values), you fix it in `average`/`maximum` and every field benefits immediately. In the original, you'd have to remember to fix it in six places.
- **Each helper is independently testable.** `average([{x:1},{x:3}], 'x')` and `maximum(...)` can be unit-tested in isolation, separate from `calculateUserStatistics`'s orchestration.
- **Intent is clearer.** `average(userData, 'income')` reads as "the average income," while the original's hand-rolled loop requires you to trace the accumulator to confirm what it's computing.
- **Removes manual indexing entirely.** The original uses `for (let i = 0; ...)` with manual off-by-one handling for the max case (`i = 1` because index `0` seeds the initial value). `reduce` removes that entire class of indexing bugs.

## Edge Case to Flag

If `userData` is ever empty, `average` divides by zero (`NaN`) and `maximum` throws on `userData[0]` being `undefined`. That's a pre-existing issue in the original code too — worth adding a guard if empty input is possible in your use case.

---
## Reflection:

Claude worked on a lot of mistakes, duplications, codes that needed refactoring,and improved codes that could not have been easily readable. I learnt a lot from it, and therefore the exercise to be able to change code with AI worked, and there was quality change and improvements that I could not have easily picked up on face value without digging deep into the codes. Therefore, AI was more efficient and saved time as well.
