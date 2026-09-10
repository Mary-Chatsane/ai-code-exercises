## Exercise: Writing a README and User Guide for a Project

## Selected project:

Project name: ScrapeMaster
Description: A flexible web scraping framework with scheduling and data processing

Key features:
- Define scrapers using a simple configuration format
- Scheduled scraping jobs
- Proxy rotation and user agent switching
- CAPTCHA handling
- Data extraction using CSS selectors or XPath
- Export to various formats (CSV, JSON, Database)
- Webhook notifications

Technologies used: Python, Scrapy, BeautifulSoup, SQLAlchemy, Celery
Installation requirements: Python 3.7+, Redis, pip

Project structure:
/scrapemaster - Main package
/scrapemaster/scrapers - Scraper definitions
/scrapemaster/extractors - Data extraction tools
/scrapemaster/processors - Data processing pipelines
/scrapemaster/exporters - Data export modules
/scrapemaster/scheduler - Job scheduling
/scrapemaster/utils - Utility functions
/config - Configuration files
/examples - Example scrapers

## Applied Prompt to generate a comprehensive README file below:

---
# Scrapemaster

A flexible web scraping framework with built-in scheduling and data processing — define scrapers with simple configuration, run them on a schedule, and export clean data wherever you need it.

## Features

- **Simple configuration format** — define scrapers declaratively without writing boilerplate crawl logic
- **Scheduled scraping jobs** — run scrapers on a recurring schedule via Celery
- **Proxy rotation and user agent switching** — reduce blocking and rate-limiting
- **CAPTCHA handling** — pluggable interface for integrating third-party CAPTCHA-solving services
- **Flexible data extraction** — pull data using CSS selectors or XPath
- **Multiple export formats** — CSV, JSON, or directly into a database
- **Webhook notifications** — get notified when a job completes, fails, or finds new data

## Requirements

- Python 3.7+
- Redis (used as the Celery broker for job scheduling)
- pip

## Installation

```bash
# Clone the repository
git clone https://github.com/yourusername/scrapemaster.git
cd scrapemaster

# Install dependencies
pip install -r requirements.txt

# Make sure Redis is running
redis-server
```

## Basic Usage

Define a scraper in a configuration file:

```yaml
# config/example_scraper.yaml
name: quotes_scraper
start_urls:
  - https://example.com/quotes
selectors:
  quote: ".quote-text"
  author: ".quote-author"
export:
  format: csv
  path: output/quotes.csv
schedule:
  interval: daily
  time: "02:00"
```

Run it from the command line:

```bash
python -m scrapemaster run config/example_scraper.yaml
```

Or trigger it programmatically:

```python
from scrapemaster import Scraper

scraper = Scraper.from_config("config/example_scraper.yaml")
results = scraper.run()

print(f"Scraped {len(results)} items")
```

To register it on the scheduler instead of running once:

```python
from scrapemaster.scheduler import register_job

register_job("config/example_scraper.yaml")
```

## Project Structure

```
/scrapemaster            - Main package
/scrapemaster/scrapers   - Scraper definitions
/scrapemaster/extractors - Data extraction tools (CSS/XPath)
/scrapemaster/processors - Data processing pipelines
/scrapemaster/exporters  - Data export modules (CSV, JSON, DB)
/scrapemaster/scheduler  - Job scheduling (Celery-based)
/scrapemaster/utils      - Utility functions
/config                  - Configuration files
/examples                - Example scrapers
```

## Configuration Options

Scraper configs are YAML files with the following common fields:

| Field | Type | Description |
|---|---|---|
| `name` | string | Unique identifier for the scraper |
| `start_urls` | list | URLs to begin scraping from |
| `selectors` | dict | CSS or XPath selectors mapped to field names |
| `export.format` | string | `csv`, `json`, or `database` |
| `export.path` | string | Output file path (for `csv`/`json`) |
| `schedule.interval` | string | `hourly`, `daily`, `weekly`, or a cron expression |
| `proxy.enabled` | boolean | Enable proxy rotation |
| `user_agent.rotate` | boolean | Enable user agent switching |
| `webhook.url` | string | Endpoint to notify on job completion |

See `/config` for full example configurations covering proxy setup, database export, and webhook payloads.

## Troubleshooting

**Redis connection errors**
Ensure Redis is running (`redis-server`) and reachable at the host/port configured in your Celery settings. Check `REDIS_URL` in your environment or config file.

**Scraper returns no data**
Verify your CSS/XPath selectors against the live page — site markup changes frequently and is the most common cause of empty results. Use `scrapemaster debug <config>` to preview matched elements.

**Scheduled jobs not running**
Confirm the Celery worker and beat scheduler are both running:
```bash
celery -A scrapemaster worker --loglevel=info
celery -A scrapemaster beat --loglevel=info
```

**Frequent blocking/CAPTCHAs**
Enable proxy rotation and user agent switching in your config. If CAPTCHAs persist, configure a CAPTCHA-solving service under the `captcha` config block.

**Export/database errors**
Check that your SQLAlchemy connection string is correct and the target table schema matches your extractor's output fields.

## Contributing

Contributions are welcome. To contribute:

1. Fork the repository and create a feature branch
2. Write tests for any new functionality
3. Ensure existing tests pass (`pytest`)
4. Submit a pull request with a clear description of the change

Please open an issue first for significant changes so we can discuss the approach before you invest time in implementation.

## License

This project is licensed under the MIT License. See the `LICENSE` file for details.

----
## README review:

Claude pointed out that: the technologies listed (Scrapy, BeautifulSoup, SQLAlchemy, Celery) don't appear explicitly in the README body — and that Claude folded them in implicitly (Celery for scheduling, SQLAlchemy for DB export) rather than listing them as a standalone "Built With" section. Pointing out that That a "Built With" or "Tech Stack" section is such a common README convention that it's a reasonable addition even though it wasn't explicitly requested — it's the kind of thing "comprehensive" could be read to include.

---

## Applied Prompt 2 to create a step-by-step guide for one of the project’s features:


# Step-by-Step Guide: Defining Scrapers Using Scrapemaster's Configuration Format

## Prerequisites

Before you start, make sure you have:

- Scrapemaster installed (`pip install -r requirements.txt`)
- Python 3.7+ and Redis running (see the main README's Installation section)
- A text editor for writing YAML files
- The target website's URL, and permission/legal clearance to scrape it (always check the site's `robots.txt` and terms of service first)

No coding experience is required for this guide — configuration files use plain YAML syntax.

## Step 1: Create Your Config File

Inside the `/config` directory, create a new `.yaml` file. Name it after what you're scraping — this becomes your scraper's identity.

```bash
touch config/my_first_scraper.yaml
```

**Common mistake:** Placing the file outside `/config`. Scrapemaster looks in this directory by default when you reference a scraper by name elsewhere in the app.

## Step 2: Name Your Scraper

Open the file and add a `name` field. This is how you'll refer to the scraper later (in logs, schedules, and CLI commands).

```yaml
name: quotes_scraper
```

**Tip:** Use lowercase with underscores, no spaces — this avoids issues if the name is ever used in a file path or database key.

## Step 3: Define Your Start URL(s)

Add a `start_urls` list — one or more pages Scrapemaster should begin crawling from.

```yaml
name: quotes_scraper
start_urls:
  - https://example.com/quotes
```

**Common mistake:** Forgetting `https://` or `http://` at the start of the URL — the scraper will fail silently or throw a connection error without it.

## Step 4: Inspect the Page and Identify Your Data

Before writing selectors, open the target page in your browser and use "Inspect Element" (right-click → Inspect) to find the CSS class or tag wrapping the data you want.

**[Screenshot placeholder: browser dev tools open, highlighting a `.quote-text` element]**

For example, if quotes are wrapped in `<span class="quote-text">`, your selector is `.quote-text`.

## Step 5: Add Your Selectors

Add a `selectors` block mapping a field name you choose to the CSS selector (or XPath) that captures it.

```yaml
name: quotes_scraper
start_urls:
  - https://example.com/quotes
selectors:
  quote: ".quote-text"
  author: ".quote-author"
```

You can use XPath instead of CSS if you prefer — just prefix the selector:

```yaml
selectors:
  quote:
    xpath: "//span[@class='quote-text']/text()"
```

**Common mistake:** Copying a selector that's too specific (e.g., includes an auto-generated ID that changes on every page load). Test with the simplest, most general selector that still uniquely identifies your data.

## Step 6: Choose Your Export Format

Add an `export` block. For a first scraper, CSV is the simplest to inspect afterward.

```yaml
export:
  format: csv
  path: output/quotes.csv
```

**Note:** The `path` is relative to your project root — Scrapemaster will create the `output/` folder if it doesn't already exist.

## Step 7: Run It Once to Test

Before scheduling anything, run the scraper manually to confirm it works:

```bash
python -m scrapemaster run config/my_first_scraper.yaml
```

**[Code block placeholder: expected terminal output showing "Scraped N items" and export confirmation]**

Open `output/quotes.csv` and confirm the data looks right — correct columns, no empty rows, no garbled text.

## Step 8: (Optional) Add Scheduling Once It's Working

Only add this after Step 7 succeeds. Add a `schedule` block:

```yaml
schedule:
  interval: daily
  time: "02:00"
```

Then register it with the scheduler:

```bash
python -m scrapemaster.scheduler register config/my_first_scraper.yaml
```

---

## Troubleshooting

**Scraper runs but exports an empty file**
Your selectors likely don't match anything on the page. Re-inspect the live page — markup may differ slightly from what you expected, or content may be loaded dynamically via JavaScript (Scrapemaster's basic mode won't see JS-rendered content).

**"Connection refused" or timeout errors**
Check the URL is correct and reachable in a normal browser first. If the site is blocking automated requests, you may need proxy rotation or user agent switching (a separate feature guide).

**YAML syntax errors on run**
YAML is indentation-sensitive — use spaces, not tabs, and keep consistent indentation (2 spaces is the convention used in these examples). A common culprit is a missing colon or inconsistent list dashes.

**Selectors match the wrong elements**
If your selector grabs more than one class of element on the page, add a more specific parent selector, e.g. `.quote-block .quote-text` instead of just `.quote-text`.

**File not found when running the command**
Double-check the path you passed matches the actual file location relative to where you're running the command from — use the full relative path from your project root (`config/my_first_scraper.yaml`), not just the filename.


---
## Applied Prompt 3 to create an FAQ document for the project:

# Scrapemaster Configuration FAQ

## Getting Started

**Where do I put my scraper's config file?**
Inside the `/config` directory in your project root. Scrapemaster looks there by default when you reference a scraper by name.

**Do I need to know Python to write a scraper?**
No — configuration files use YAML, a plain-text format for structured data. You define what to scrape and how to export it declaratively; no crawl code required for basic use cases.

**What's the minimum a config file needs?**
Three things: a `name`, at least one URL under `start_urls`, and a `selectors` block mapping field names to CSS or XPath selectors.

## Features and Functionality

**Can I use both CSS and XPath in the same config?**
Yes. Default selectors are treated as CSS; to use XPath instead for a specific field, nest it under an `xpath` key:
```yaml
selectors:
  quote:
    xpath: "//span[@class='quote-text']/text()"
```

**What export formats are supported?**
CSV, JSON, or direct database export — set via the `export.format` field in your config.

**Can I schedule a scraper to run automatically?**
Yes, add a `schedule` block with an `interval` (e.g. `daily`) and `time`, then register it with the scheduler. Test the scraper manually first before scheduling it.

## Troubleshooting

**My scraper ran successfully but the export file is empty — why?**
This almost always means your selectors didn't match anything on the page. Re-inspect the live page's HTML — markup can differ from what you expected, or the content might be loaded dynamically via JavaScript, which basic scraping won't capture.

**I'm getting YAML errors when I run my scraper. What's wrong?**
YAML is indentation-sensitive. Use spaces (not tabs), and keep indentation consistent — 2 spaces per level is the convention. A missing colon or inconsistent list dashes (`-`) are the most common culprits.

**My config file isn't being found when I run the command.**
Make sure you're passing the correct relative path from your project root (e.g. `config/my_scraper.yaml`), not just the filename, and that you're running the command from the project root itself.

**I get a connection error or timeout — is my selector wrong?**
Not necessarily — check the URL is reachable in a normal browser first. Connection errors happen before selectors are even evaluated; they usually mean a bad URL, network issue, or the site blocking automated requests.

## Selector Accuracy and Data Extraction

**How do I find the right CSS selector for the data I want?**
Open the page in your browser, right-click the element, and choose "Inspect." Look at the class or tag wrapping the data, then use the simplest selector that uniquely identifies it.

**My selector is matching too many elements. What should I do?**
Make it more specific by adding a parent selector, e.g. `.quote-block .quote-text` instead of just `.quote-text`.

**My selector matches nothing at all. What went wrong?**
Common causes: the selector is too specific (e.g., tied to an auto-generated ID that changes between page loads), the site's markup has changed since you wrote it, or the content is rendered by JavaScript after the initial page load and isn't present in the raw HTML Scrapemaster fetches.

**Should I prefer CSS selectors or XPath?**
CSS selectors are simpler and sufficient for most cases. Reach for XPath when you need to select based on text content, navigate to parent elements, or handle more complex relationships CSS can't express.



