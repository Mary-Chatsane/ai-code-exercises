## Exercise: Writing Documentation for Complex Code

## Selected code: Task_parser.py

import re
from datetime import datetime, timedelta

from models import TaskStatus, TaskPriority, Task


def parse_task_from_text(text):
    """
    Parse free-form text to extract task properties.

    Examples of format it can parse:
    "Buy milk @shopping !2 #tomorrow"
    "Finish report for client XYZ !urgent #friday #work @project"

    Where:
    - Basic text is the task title
    - @tag adds a tag
    - !N sets priority (1=low, 2=medium, 3=high, 4=urgent)
    - !urgent/!high/!medium/!low sets priority by name
    - #date sets a due date
    """
    # Default task properties
    title = text.strip()
    priority = TaskPriority.MEDIUM
    due_date = None
    tags = []

    # Extract priority markers (!N or !name)
    priority_matches = re.findall(r'\s!([1-4]|urgent|high|medium|low)\b', text, re.IGNORECASE)
    if priority_matches:
        priority_text = priority_matches[0].lower()
        # Remove from title
        title = re.sub(r'\s!([1-4]|urgent|high|medium|low)\b', '', title, flags=re.IGNORECASE)

        # Convert to TaskPriority
        if priority_text == '1' or priority_text == 'low':
            priority = TaskPriority.LOW
        elif priority_text == '2' or priority_text == 'medium':
            priority = TaskPriority.MEDIUM
        elif priority_text == '3' or priority_text == 'high':
            priority = TaskPriority.HIGH
        elif priority_text == '4' or priority_text == 'urgent':
            priority = TaskPriority.URGENT

    # Extract tags (@tag)
    tag_matches = re.findall(r'\s@(\w+)', text)
    if tag_matches:
        tags = tag_matches
        # Remove from title
        for tag in tag_matches:
            title = re.sub(r'\s@' + tag + r'\b', '', title)

    # Extract date markers (#date)
    date_matches = re.findall(r'\s#(\w+)', text)
    if date_matches:
        # Remove from title
        for date_str in date_matches:
            title = re.sub(r'\s#' + date_str + r'\b', '', title)

        # Try to parse date references
        for date_str in date_matches:
            date_str = date_str.lower()
            today = datetime.now().replace(hour=0, minute=0, second=0, microsecond=0)

            if date_str in ('today', 'now'):
                due_date = today
                break
            elif date_str == 'tomorrow':
                due_date = today + timedelta(days=1)
                break
            elif date_str in ('next_week', 'nextweek'):
                due_date = today + timedelta(days=7)
                break
            elif date_str in ('monday', 'mon'):
                due_date = get_next_weekday(today, 0)  # 0 = Monday
                break
            elif date_str in ('tuesday', 'tue'):
                due_date = get_next_weekday(today, 1)
                break
            elif date_str in ('wednesday', 'wed'):
                due_date = get_next_weekday(today, 2)
                break
            elif date_str in ('thursday', 'thu'):
                due_date = get_next_weekday(today, 3)
                break
            elif date_str in ('friday', 'fri'):
                due_date = get_next_weekday(today, 4)
                break
            # Try to parse as YYYY-MM-DD
            try:
                due_date = datetime.strptime(date_str, '%Y-%m-%d')
                break
            except ValueError:
                pass

    # Trim excess whitespace from title
    title = re.sub(r'\s+', ' ', title).strip()

    # Create a new task with the extracted properties
    task = Task(title)
    task.priority = priority
    task.due_date = due_date
    task.tags = tags

    return task

def get_next_weekday(current_date, weekday):
    """Get the next occurrence of a specific weekday."""
    days_ahead = weekday - current_date.weekday()
    if days_ahead <= 0:  # Target day already happened this week
        days_ahead += 7
    return current_date + timedelta(days=days_ahead)

---

## Generated documentation using Claude. Applied AI prompt 1: Comprehensive function documentation:

def parse_task_from_text(text):
    """Parse free-form shorthand text into a Task object.

    Extracts a title, priority, tags, and due date from a single line of
    text using inline markers, then strips those markers out of the
    remaining text to produce a clean title.

    Marker syntax:
        - ``@tag``       Adds a tag (e.g. ``@shopping``). Multiple allowed.
        - ``!N`` or ``!name``  Sets priority. N is 1-4 (low/medium/high/urgent)
                          or the name itself (case-insensitive). Only the
                          FIRST priority marker found is used to set
                          priority, but ALL priority markers in the text
                          are stripped from the title.
        - ``#date``      Sets a due date. Accepts: today, now, tomorrow,
                          next_week/nextweek, weekday names (monday..friday,
                          or 3-letter abbreviations mon/tue/wed/thu/fri), or
                          an explicit date in YYYY-MM-DD format. Only the
                          FIRST successfully-parsed date is kept, but ALL
                          date markers found are stripped from the title.

    All markers must be preceded by whitespace to be recognized (a marker
    glued to the start of the string or to another word, e.g. "text!2"
    with no space, will not be detected).

    Args:
        text (str): Free-form input text containing a task title with
            zero or more inline @tag, !priority, and #date markers, e.g.
            "Buy milk @shopping !2 #tomorrow".

    Returns:
        Task: A new Task instance with:
            - title (str): the input text with all recognized markers
              removed and whitespace normalized.
            - priority (TaskPriority): TaskPriority.MEDIUM if no valid
              priority marker was found.
            - due_date (datetime | None): None if no date marker was
              found, or if a date marker was present but unrecognized
              (e.g. "#nextmonth") and no other marker could be parsed.
            - tags (list[str]): empty list if no @tag markers were found.

    Raises:
        No exceptions are raised for malformed input. Unparseable date
        strings are silently ignored (due_date remains None); unrecognized
        priority text is silently ignored (priority remains MEDIUM).

    Example:
        >>> task = parse_task_from_text("Finish report !urgent #friday @work")
        >>> task.title
        'Finish report'
        >>> task.priority
        TaskPriority.URGENT
        >>> task.tags
        ['work']

    Notes / Edge cases:
        - If multiple !priority markers are present (e.g. "!2 !urgent"),
          only the first match sets the priority, but both markers are
          stripped from the title — this can silently discard the
          user's intended override without any warning.
        - Tag matching uses \\w+, so tags containing hyphens or other
          punctuation (e.g. "@high-priority") will only capture the
          part matching \\w+ ("high"), truncating the rest into the title
          or dropping it unpredictably.
        - Tag and date removal use exact case-sensitive substring
          matching for building the removal regex; if the same tag
          text appears elsewhere in the title as a normal word, it is
          NOT removed (removal only targets the "@word" pattern).
        - If a #date marker doesn't match any known keyword and also
          fails YYYY-MM-DD parsing, it is still stripped from the title
          but due_date is left as None with no error or indication to
          the caller that the date was invalid.
        - A title consisting only of markers (e.g. "!2 #tomorrow") will
          result in an empty string being passed to Task(title) — the
          Task constructor's handling of an empty title is not defined
          in this function.
    """


def get_next_weekday(current_date, weekday):
    """Calculate the date of the next occurrence of a given weekday.

    If the target weekday is today, this returns the SAME day (not one
    week later) only if days_ahead calculates to exactly 0 — but since
    days_ahead <= 0 triggers a +7 day adjustment, requesting today's
    own weekday actually returns 7 days from now, not today itself.

    Args:
        current_date (datetime): The reference date to calculate from.
        weekday (int): Target day of the week as an integer, where
            0 = Monday and 6 = Sunday (matches Python's
            datetime.weekday() convention).

    Returns:
        datetime: The date of the next occurrence of the given weekday,
            always strictly in the future relative to current_date
            (never returns current_date itself, even if current_date
            already falls on the target weekday).

    Raises:
        No exceptions raised for valid integer input. Passing a
        non-integer or a value outside 0-6 is not validated and may
        produce an incorrect or unexpected date rather than an error.

    Example:
        >>> from datetime import datetime
        >>> get_next_weekday(datetime(2026, 9, 10), 0)  # a Thursday
        datetime.datetime(2026, 9, 14, 0, 0)  # the following Monday

    Notes / Edge cases:
        - Calling this with weekday == current_date.weekday() does NOT
          return current_date — it returns 7 days later, since
          days_ahead becomes 0, which the "<= 0" check treats the same
          as an already-passed day. This may or may not match the
          caller's intent and is worth confirming with whoever wrote
          the original logic.
    """

---

## Review on the generated documentation 

This is a really good example of why developers shouldn't blindly trust generated documentation.The generated document identified several things that aren't obvious at first glance, but it also introduced interpretations that weren't completely faithful to the code. As a result, the generated documentation is a useful first draft, but it still needs verification against the actual implementation.

---

## Tried Prompt 2 to get a different perspective on the code’s intent and logic: 

1. **High-level intent**

This code implements a shorthand parser — it lets a user type a task in one line of natural-sounding text with embedded markers, instead of filling out separate fields for title/priority/tags/due-date. It's a convenience layer: parse_task_from_text() takes that one string and produces a fully-formed Task object, stripping the markers out so the leftover text becomes a clean title. get_next_weekday() is a small helper used only for resolving weekday-name markers (#monday, #fri, etc.) into actual dates.

2. **Step-by-step logic breakdown**

- *Initialize defaults* — title starts as the full trimmed text; priority defaults to MEDIUM; due_date defaults to None; tags starts empty. Everything below only overrides these defaults if a marker is found.
- *Priority extraction* — regex finds all !N or !name markers. Only the first match sets the priority (via priority_matches[0]), but the re.sub call removes every matching marker from the title, not just the first.
- *Priority conversion* — a manual if/elif chain maps the matched text (already lowercased) to a TaskPriority enum value.
- *Tag extraction* — regex finds all @word markers, capturing only \w+ (letters/digits/underscore — no hyphens or other punctuation). All matched tags are kept, and each is individually stripped from the title via its own re.sub call.
- *Date extraction* — regex finds all #word markers, strips all of them from the title first, then loops through them trying to resolve one into an actual date, stopping (break) at the first one that resolves successfully — via keyword match (today/tomorrow/next_week/weekday names) or by falling through to a YYYY-MM-DD parse attempt.
- *Whitespace cleanup* — collapses any double spaces left behind by marker removal and trims the ends.
- *Task construction* — builds a Task with the extracted title, then sets priority, due_date, and tags as attributes after construction rather than passing them into the constructor.
- *get_next_weekday* — given a reference date and a target weekday number (0=Monday), computes how many days until that weekday next occurs; if the calculation lands on 0 or negative (i.e., today already is that weekday, or it already passed this week), it jumps forward a full week instead.

3. **Assumptions and edge cases**

- Assumes exactly one priority is intended, but doesn't enforce it — multiple ! markers are all stripped from the title, yet only the first sets the actual priority, silently discarding any conflicting override with no warning.
- Assumes tags are alphanumeric only — \w+ can't capture hyphens, so @high-priority becomes tag "high" with "-priority" left orphaned in the title (confirmed by manual trace).
- Assumes markers are preceded by whitespace — every regex uses \s@, \s!, \s#, so a marker glued to the start of the string ("@tag rest" — no leading space) or squished against another marker ("text!2@tag") won't be detected.
- Assumes "today" for a requested weekday means next week, not today — get_next_weekday treats days_ahead == 0 (target weekday is today) the same as "already passed," bumping to +7 days. This may not match user expectation if they type #friday on a Friday.
- Silently swallows invalid dates — if a #date marker doesn't match any keyword and fails YYYY-MM-DD parsing, it's still stripped from the title, but due_date stays None with zero indication to the caller that something was wrong.
- No validation on empty results — if the entire input is just markers (e.g. "!2 #tomorrow"), the resulting title is an empty string, and there's no guard or error for that.
- Tag removal regex has an unescaped-injection risk — re.sub(r'\s@' + tag + r'\b', '', title) inserts the captured tag text directly into a regex pattern. Since \w+ can't capture regex metacharacters, this happens to be safe today, but it's fragile: if the capture pattern were ever loosened, this becomes a regex-injection bug.

4. **Suggested inline comments for complex parts**

#Only the FIRST priority marker sets the actual priority value, but
#ALL priority markers found in the text are stripped from the title —
#so "!2 !urgent" silently keeps priority=LOW and discards the "!urgent"
#override with no warning to the caller.
priority_matches = re.findall(r'\s!([1-4]|urgent|high|medium|low)\b', text, re.IGNORECASE)


#NOTE: \w+ does not match hyphens or other punctuation, so a tag like
#"@high-priority" is captured as just "high", leaving "-priority"
#behind as orphaned text in the title.
tag_matches = re.findall(r'\s@(\w+)', text)


#Multiple #date markers may be present; only the first one that
#successfully resolves to a real date is used (loop breaks on first
#match). Any markers that don't match a known keyword or valid
#YYYY-MM-DD format are still removed from the title, but silently
#leave due_date unset — no error is surfaced to the caller.
for date_str in date_matches:


#If the target weekday IS today's weekday, days_ahead becomes 0,
#which is treated as "already happened this week" — so this jumps
#forward a full 7 days rather than returning today's date.
if days_ahead <= 0:  #Target day already happened this week
    days_ahead += 7

5. **Suggested improvements (without changing behavior)**

- Extract named constants for the weekday mapping (a dict {'monday': 0, 'mon': 0, ...}) instead of seven near-identical elif blocks — same output, less repetition, easier to extend with new day-name aliases.
- Add a warning/log (not an exception, to preserve behavior) when multiple priority markers are found, so the silent-discard edge case becomes visible during development rather than only discoverable by code reading.
- Widen the tag/date regex to allow hyphens ([\w-]+ instead of \w+) if hyphenated tags are actually intended to be supported this would be a behavior change, so it should be flagged as a proposal, not applied silently.
- Pass extracted fields into Task()'s constructor rather than setting attributes after construction, if the constructor supports it — reduces the risk of Task briefly existing in a partially-initialized state.
- Return an unparsed-marker list alongside the Task, or log a debug message, whenever a #date marker fails to resolve — currently that failure is completely invisible to both the caller and any log output.


---

## Combined and compared best elements from both documentation versions:

import re
from datetime import datetime, timedelta

from models import TaskStatus, TaskPriority, Task


def parse_task_from_text(text):
    """Parse free-form shorthand text into a Task object.

    Extracts a title, priority, tags, and due date from a single line of
    text using inline markers, then strips those markers out of the
    remaining text to produce a clean title.

    Marker syntax:
        - ``@tag``       Adds a tag (e.g. ``@shopping``). Multiple allowed.
        - ``!N`` or ``!name``  Sets priority. N is 1-4 (low/medium/high/urgent)
                          or the name itself (case-insensitive).
        - ``#date``      Sets a due date. Accepts: today, now, tomorrow,
                          next_week/nextweek, weekday names (monday..friday,
                          or abbreviations mon/tue/wed/thu/fri), or an
                          explicit date in YYYY-MM-DD format.

    All markers must be preceded by whitespace to be recognized — a marker
    glued to the start of the string or to another marker (e.g. "text!2"
    with no space) will not be detected.

    Args:
        text (str): Free-form input text containing a task title with
            zero or more inline @tag, !priority, and #date markers, e.g.
            "Buy milk @shopping !2 #tomorrow".

    Returns:
        Task: A new Task instance with:
            - title (str): input text with all recognized markers removed
              and whitespace normalized.
            - priority (TaskPriority): TaskPriority.MEDIUM if no valid
              priority marker was found.
            - due_date (datetime | None): None if no date marker was found
              or resolved.
            - tags (list[str]): empty list if no @tag markers were found.

    Raises:
        No exceptions are raised for malformed input. Unparseable dates
        leave due_date as None; unrecognized priority text leaves
        priority as MEDIUM. Both fail silently.

    Example:
        >>> task = parse_task_from_text("Finish report !urgent #friday @work")
        >>> task.title
        'Finish report'
        >>> task.priority
        TaskPriority.URGENT
        >>> task.tags
        ['work']

    Notes / Edge cases:
        - Multiple !priority markers: only the first sets priority, but
          ALL are stripped from the title — a conflicting override is
          silently discarded with no warning.
        - Tag/date capture uses \\w+, which excludes hyphens and other
          punctuation. "@high-priority" is captured as tag "high", and
          "-priority" is left behind as orphaned text in the title (the
          \\b boundary in the removal regex matches at the hyphen, so
          only "@high" gets removed).
        - An unresolvable #date marker (no keyword match, not valid
          YYYY-MM-DD) is still stripped from the title, but due_date
          stays None with no indication to the caller that it failed.
        - A title made entirely of markers (e.g. "!2 #tomorrow") results
          in an empty string passed to Task(title); empty-title handling
          is not defined here.
    """
    # Default task properties
    title = text.strip()
    priority = TaskPriority.MEDIUM
    due_date = None
    tags = []

    # Only the FIRST priority marker sets the actual priority value, but
    # ALL priority markers found in the text are stripped from the title —
    # so "!2 !urgent" silently keeps priority=LOW and discards the
    # "!urgent" override with no warning to the caller.
    priority_matches = re.findall(r'\s!([1-4]|urgent|high|medium|low)\b', text, re.IGNORECASE)
    if priority_matches:
        priority_text = priority_matches[0].lower()
        # Remove from title
        title = re.sub(r'\s!([1-4]|urgent|high|medium|low)\b', '', title, flags=re.IGNORECASE)

        # Convert to TaskPriority
        if priority_text == '1' or priority_text == 'low':
            priority = TaskPriority.LOW
        elif priority_text == '2' or priority_text == 'medium':
            priority = TaskPriority.MEDIUM
        elif priority_text == '3' or priority_text == 'high':
            priority = TaskPriority.HIGH
        elif priority_text == '4' or priority_text == 'urgent':
            priority = TaskPriority.URGENT

    # NOTE: \w+ does not match hyphens or other punctuation, so a tag like
    # "@high-priority" is captured as just "high" — the removal regex's
    # \b boundary matches at the hyphen, so only "@high" is stripped and
    # "-priority" is left behind as orphaned text in the title.
    tag_matches = re.findall(r'\s@(\w+)', text)
    if tag_matches:
        tags = tag_matches
        # Remove from title
        for tag in tag_matches:
            title = re.sub(r'\s@' + tag + r'\b', '', title)

    # Extract date markers (#date)
    date_matches = re.findall(r'\s#(\w+)', text)
    if date_matches:
        # Remove from title
        for date_str in date_matches:
            title = re.sub(r'\s#' + date_str + r'\b', '', title)

        # Multiple #date markers may be present; only the first one that
        # successfully resolves to a real date is used (loop breaks on
        # first match). Any marker that doesn't match a known keyword or
        # valid YYYY-MM-DD format is still removed from the title above,
        # but silently leaves due_date unset — no error is surfaced.
        for date_str in date_matches:
            date_str = date_str.lower()
            today = datetime.now().replace(hour=0, minute=0, second=0, microsecond=0)

            if date_str in ('today', 'now'):
                due_date = today
                break
            elif date_str == 'tomorrow':
                due_date = today + timedelta(days=1)
                break
            elif date_str in ('next_week', 'nextweek'):
                due_date = today + timedelta(days=7)
                break
            elif date_str in ('monday', 'mon'):
                due_date = get_next_weekday(today, 0)  # 0 = Monday
                break
            elif date_str in ('tuesday', 'tue'):
                due_date = get_next_weekday(today, 1)
                break
            elif date_str in ('wednesday', 'wed'):
                due_date = get_next_weekday(today, 2)
                break
            elif date_str in ('thursday', 'thu'):
                due_date = get_next_weekday(today, 3)
                break
            elif date_str in ('friday', 'fri'):
                due_date = get_next_weekday(today, 4)
                break
            # Try to parse as YYYY-MM-DD
            try:
                due_date = datetime.strptime(date_str, '%Y-%m-%d')
                break
            except ValueError:
                pass

    # Trim excess whitespace from title
    title = re.sub(r'\s+', ' ', title).strip()

    # Create a new task with the extracted properties
    task = Task(title)
    task.priority = priority
    task.due_date = due_date
    task.tags = tags

    return task


def get_next_weekday(current_date, weekday):
    """Calculate the date of the next occurrence of a given weekday.

    Args:
        current_date (datetime): The reference date to calculate from.
        weekday (int): Target day of the week, 0 = Monday ... 6 = Sunday
            (matches Python's datetime.weekday() convention).

    Returns:
        datetime: The date of the next occurrence of the given weekday.
            Always strictly in the future relative to current_date — if
            current_date already falls on the target weekday, this
            returns 7 days later, not current_date itself.

    Raises:
        No exceptions raised for valid integer input. A non-integer or
        out-of-range weekday value is not validated and may produce an
        incorrect date rather than an error.

    Example:
        >>> get_next_weekday(datetime(2026, 9, 10), 0)  # a Thursday
        datetime.datetime(2026, 9, 14, 0, 0)  # the following Monday

    Notes / Edge cases:
        - If the target weekday IS today's weekday, days_ahead becomes 0,
          which is treated as "already happened this week" — so this
          jumps forward a full 7 days rather than returning today's date.
          Worth confirming with the team whether this matches intent.
    """
    days_ahead = weekday - current_date.weekday()
    if days_ahead <= 0:  # Target day already happened this week
        days_ahead += 7
    return current_date + timedelta(days=days_ahead)