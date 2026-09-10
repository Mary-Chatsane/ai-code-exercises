## Exercise: Writing Documentation for an API

## API endpoint documentation: python/flask user registration 

```
@app.route('/api/users/register', methods=['POST'])
def register_user():
    """Register a new user"""
    data = request.get_json()

    # Validate required fields
    required_fields = ['username', 'email', 'password']
    for field in required_fields:
        if field not in data:
            return jsonify({
                'error': 'Missing required field',
                'message': f'{field} is required'
            }), 400

    # Check if username or email already exists
    if User.query.filter_by(username=data['username']).first():
        return jsonify({
            'error': 'Username taken',
            'message': 'Username is already in use'
        }), 409

    if User.query.filter_by(email=data['email']).first():
        return jsonify({
            'error': 'Email exists',
            'message': 'An account with this email already exists'
        }), 409

    # Validate email format
    if not re.match(r"^[^@]+@[^@]+\.[^@]+$", data['email']):
        return jsonify({
            'error': 'Invalid email',
            'message': 'Please provide a valid email address'
        }), 400

    # Validate password strength
    if len(data['password']) < 8:
        return jsonify({
            'error': 'Weak password',
            'message': 'Password must be at least 8 characters long'
        }), 400

    # Create new user
    try:
        # Hash password
        password_hash = generate_password_hash(data['password'])

        # Create user object
        new_user = User(
            username=data['username'],
            email=data['email'].lower(),
            password_hash=password_hash,
            created_at=datetime.utcnow(),
            role='user'
        )

        # Add user to database
        db.session.add(new_user)
        db.session.commit()

        # Generate confirmation token
        confirmation_token = generate_confirmation_token(new_user.id)

        # Send confirmation email
        try:
            send_confirmation_email(new_user.email, confirmation_token)
        except Exception as e:
            # Log email error but continue
            app.logger.error(f"Failed to send confirmation email: {str(e)}")

        # Create response without password
        user_data = {
            'id': new_user.id,
            'username': new_user.username,
            'email': new_user.email,
            'created_at': new_user.created_at.isoformat(),
            'role': new_user.role
        }

        return jsonify({
            'message': 'User registered successfully',
            'user': user_data
        }), 201

    except Exception as e:
        db.session.rollback()
        app.logger.error(f"Error registering user: {str(e)}")
        return jsonify({
            'error': 'Server error',
            'message': 'Failed to register user'
        }), 500
```

## Applied Prompt 1 to generate comprehensive endpoint documentation:


# User Registration

**`POST /api/users/register`**

## 1. Purpose
Creates a new user account. Validates required fields, checks for duplicate username/email, validates email format and password strength, hashes the password, persists the user, and attempts to send a confirmation email (non-blocking — registration still succeeds even if the email fails).

## 2. Request

**Authentication:** None required — this is a public, unauthenticated endpoint (it's how new users obtain an account in the first place).

**Body parameters (JSON):**

| Field | Type | Required | Description |
|---|---|---|---|
| `username` | string | Yes | Desired username. Must not already exist. |
| `email` | string | Yes | Email address. Must match a basic pattern (`text@text.text`) and must not already exist. Stored lowercased. |
| `password` | string | Yes | Plaintext password, minimum 8 characters. Hashed before storage; never stored or returned in plaintext. |

No path or query parameters.

## 3. Response Format

**Success — `201 Created`**
```json
{
  "message": "User registered successfully",
  "user": {
    "id": 42,
    "username": "jane_doe",
    "email": "jane@example.com",
    "created_at": "2026-09-10T14:32:00.000000",
    "role": "user"
  }
}
```
Note: `password`/`password_hash` are deliberately excluded from the response.

## 4. Error Responses

| Status | Error | Trigger |
|---|---|---|
| `400` | `Missing required field` | One of `username`, `email`, `password` absent from the request body |
| `400` | `Invalid email` | Email fails the regex `^[^@]+@[^@]+\.[^@]+$` |
| `400` | `Weak password` | Password under 8 characters |
| `409` | `Username taken` | Username already exists in DB |
| `409` | `Email exists` | Email already exists in DB |
| `500` | `Server error` | Any exception during user creation/commit (DB error, etc.) — transaction is rolled back |

## 5. Example Requests

**Example 1 — Success**

Request:
```
POST /api/users/register
Content-Type: application/json

{
  "username": "jane_doe",
  "email": "Jane@Example.com",
  "password": "correcthorsebattery"
}
```

Response `201`:
```json
{
  "message": "User registered successfully",
  "user": {
    "id": 42,
    "username": "jane_doe",
    "email": "jane@example.com",
    "created_at": "2026-09-10T14:32:00.000000",
    "role": "user"
  }
}
```
(Note: email is lowercased on storage — `Jane@Example.com` → `jane@example.com`.)

**Example 2 — Duplicate email**

Request:
```
POST /api/users/register
Content-Type: application/json

{
  "username": "jane_doe2",
  "email": "jane@example.com",
  "password": "anotherpassword123"
}
```

Response `409`:
```json
{
  "error": "Email exists",
  "message": "An account with this email already exists"
}
```

## 6. Special Considerations / Gaps

- **No rate limiting** is implemented in this code — nothing prevents automated/bulk account creation. Worth confirming whether this is handled at a gateway/proxy layer, or is a genuine gap.
- **`data = request.get_json()` has no null/malformed-JSON check** — if the request body isn't valid JSON, `data` could be `None`, and the next line (`if field not in data`) would raise a `TypeError` instead of returning a clean `400`, likely surfacing as a `500`.
- **Email confirmation is fire-and-forget** — if `send_confirmation_email` fails, the error is only logged; the client still gets a `201` with no indication the confirmation email didn't send.
- **Case sensitivity is inconsistent**: email is lowercased before storage/duplicate-checking, but `username` is not — `"Jane"` and `"jane"` could be registered as distinct usernames.
- **New accounts default to `role='user'`** hardcoded — there's no path in this endpoint for creating an admin account.


## Applied Prompt 2 to convert the documentation to a different format: OpenAPI/Swagger 


openapi: 3.0.3
info:
  title: User Registration API
  description: >
    Creates a new user account. Validates required fields, checks for
    duplicate username/email, validates email format and password
    strength, hashes the password, persists the user, and attempts to
    send a confirmation email (non-blocking — registration still
    succeeds even if the email fails).
  version: "1.0.0"

paths:
  /api/users/register:
    post:
      summary: Register a new user
      description: >
        Public, unauthenticated endpoint for creating a new user account.
      operationId: registerUser
      security: []   # No authentication required
      requestBody:
        required: true
        content:
          application/json:
            schema:
              $ref: '#/components/schemas/RegisterRequest'
            examples:
              success:
                summary: Valid registration request
                value:
                  username: jane_doe
                  email: Jane@Example.com
                  password: correcthorsebattery
              duplicateEmail:
                summary: Request that triggers a duplicate-email error
                value:
                  username: jane_doe2
                  email: jane@example.com
                  password: anotherpassword123
      responses:
        '201':
          description: User registered successfully
          content:
            application/json:
              schema:
                $ref: '#/components/schemas/RegisterSuccessResponse'
              examples:
                success:
                  summary: Successful registration
                  value:
                    message: User registered successfully
                    user:
                      id: 42
                      username: jane_doe
                      email: jane@example.com
                      created_at: "2026-09-10T14:32:00.000000"
                      role: user
        '400':
          description: >
            Bad request — missing required field, invalid email format,
            or password too short.
          content:
            application/json:
              schema:
                $ref: '#/components/schemas/ErrorResponse'
              examples:
                missingField:
                  summary: Missing required field
                  value:
                    error: Missing required field
                    message: "email is required"
                invalidEmail:
                  summary: Invalid email format
                  value:
                    error: Invalid email
                    message: Please provide a valid email address
                weakPassword:
                  summary: Password too short
                  value:
                    error: Weak password
                    message: Password must be at least 8 characters long
        '409':
          description: >
            Conflict — username or email already exists.
          content:
            application/json:
              schema:
                $ref: '#/components/schemas/ErrorResponse'
              examples:
                usernameTaken:
                  summary: Username already exists
                  value:
                    error: Username taken
                    message: Username is already in use
                emailExists:
                  summary: Email already registered
                  value:
                    error: Email exists
                    message: An account with this email already exists
        '500':
          description: >
            Server error — an unexpected exception occurred while
            creating the user; the transaction is rolled back.
          content:
            application/json:
              schema:
                $ref: '#/components/schemas/ErrorResponse'
              examples:
                serverError:
                  summary: Unexpected server error
                  value:
                    error: Server error
                    message: Failed to register user

components:
  schemas:
    RegisterRequest:
      type: object
      required:
        - username
        - email
        - password
      properties:
        username:
          type: string
          description: Desired username. Must not already exist. Case-sensitivity is NOT normalized on the server.
          example: jane_doe
        email:
          type: string
          format: email
          description: >
            Email address. Must match pattern ^[^@]+@[^@]+\.[^@]+$.
            Must not already exist. Stored lowercased regardless of
            input casing.
          example: Jane@Example.com
        password:
          type: string
          format: password
          minLength: 8
          description: >
            Plaintext password, minimum 8 characters. Hashed before
            storage; never stored or returned in plaintext.
          example: correcthorsebattery

    RegisterSuccessResponse:
      type: object
      properties:
        message:
          type: string
          example: User registered successfully
        user:
          $ref: '#/components/schemas/UserPublic'

    UserPublic:
      type: object
      description: >
        Public representation of a user. Deliberately excludes
        password/password_hash.
      properties:
        id:
          type: integer
          example: 42
        username:
          type: string
          example: jane_doe
        email:
          type: string
          format: email
          example: jane@example.com
        created_at:
          type: string
          format: date-time
          example: "2026-09-10T14:32:00.000000"
        role:
          type: string
          description: Hardcoded to "user" at registration; no admin-creation path exists on this endpoint.
          example: user

    ErrorResponse:
      type: object
      properties:
        error:
          type: string
          description: Short machine-referenceable error label.
          example: Invalid email
        message:
          type: string
          description: Human-readable explanation of the error.
          example: Please provide a valid email address

  # ---------------------------------------------------------------
  # Known gaps / considerations not expressible in the OpenAPI schema
  # itself — kept here as documentation for maintainers:
  #
  # - No rate limiting is defined or implemented; nothing in the spec
  #   or the underlying code prevents automated/bulk registration.
  # - request.get_json() has no null/malformed-JSON guard server-side;
  #   a malformed body may surface as a 500 rather than a 400.
  # - Confirmation email sending is fire-and-forget; failures are
  #   logged server-side only and do not affect the 201 response or
  #   appear in this spec's response schema.
  # - Email is lowercased before storage/duplicate-checking; username
  #   is not — "Jane" and "jane" can coexist as distinct usernames.
  # --------------------------------------------------------------




