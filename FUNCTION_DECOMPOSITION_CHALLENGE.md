## Exercise:Breaking one big function into smaller ones (Function Decomposition Challenge)

**Prompt 1: Function Responsibility Analysis**

**List of responsibilities spotted before using AI**

- Validate input parameters (input validation)
- Process date range (Date range filtering)
- Calculate basic metrics (basic metrics)
- Group data ( Grouping)
- Detailing reports ( Detailed-report  logic)

**Distinct responsibilities in the current function by Claude**

- Input validation — checking sales_data, report_type, output_format
- Date range filtering — parsing dates, filtering by range
- Filter application — applying arbitrary key/value filters
- Empty-data handling — short-circuit when nothing matches
- Basic metrics — total, average, max, min sale
- Grouping — bucketing by product/category/customer/region + per-group averages
- Report assembly — building the base report_data dict
- Detailed-report logic — per-transaction enrichment (pre-tax, profit, margin)
- Forecast logic — monthly aggregation, growth rates, 3-month projection
- Chart data prep — time series + pie chart data
- Output dispatch — routing to the right _generate_*_report function

** Decomposition strategy + code mapping by Claude**

Claude suggested a decomposition plan,which parts should be separate, and what those functions should be called. 

| New function | Original code moved |
|---|---|
| `_validate_inputs` | the three `raise ValueError` blocks |
| `_filter_by_date_range` | date_range parsing + filtering loop |
| `_apply_filters` | the `filters` loop |
| `_calculate_summary_metrics` | total/avg/max/min block |
| `_group_sales` | grouping loop + per-group averages |
| `_build_grouping_section` | the `report_data['grouping']` block |
| `_add_transaction_details` | the `report_type == 'detailed'` block |
| `_calculate_forecast` | the entire `report_type == 'forecast'` block |
| `_build_charts` | the `include_charts` block |
| `_dispatch_output` | the final `if output_format ==` chain |

**Helper functions**

4 helper functions and what it would do:

- _generate_empty_report(report_type, output_format) — generates a minimal report when no data matches the filters
- _generate_html_report(report_data, include_charts) — generates the HTML output
- _generate_excel_report(report_data, include_charts) — generates the Excel output
- _generate_pdf_report(report_data, include_charts) — generates the PDF output

**Prompt 2: Single-Responsibility Extraction**

 Extracted one helper function: `_generate_empty_report(report_type, output_format) — generates a minimal report when no data matches the filters` and made use of the above mentioned Prompt. 

**Code related to this responsibility**

```python
# Check if we have data after filtering
if not sales_data:
    print("Warning: No data matches the specified criteria")
    # Return empty report structure based on format
    if output_format == 'json':
        return {"message": "No data matches the specified criteria", "data": []}
    else:
        # For other formats, generate a minimal report file
        return _generate_empty_report(report_type, output_format)
```

This is really two things tangled together: *detecting* the empty-data case, and *deciding what to return* for it (including the JSON short-circuit, which currently bypasses `_generate_empty_report` entirely). Both belong to the same responsibility — "produce the right empty-report response" — so it makes sense to pull the whole thing into one function.

## 2. New function

```python
def _handle_empty_data(report_type, output_format):
    """
    Produce the appropriate empty-report response when no sales data
    matches the given filters/date range.
    """
    print("Warning: No data matches the specified criteria")

    if output_format == 'json':
        return {"message": "No data matches the specified criteria", "data": []}

    return _generate_empty_report(report_type, output_format)
```

## 3. Modified original function

```python
sales_data = filtered_data  # (after date range + filters applied)

# Check if we have data after filtering
if not sales_data:
    return _handle_empty_data(report_type, output_format)

# Calculate basic metrics
total_sales = sum(sale['amount'] for sale in sales_data)
...
```

The `if not sales_data:` check itself stays in the main function (it's a control-flow guard, not part of the empty-report logic), but everything inside it collapses to a single delegated call.

## 4. Naming and parameters

- **Name**: `_handle_empty_data` — reads as "this is what happens when there's no data," which is clearer than `_generate_empty_report` alone, since the function now also owns the JSON branch and the warning message, not just file generation.
- **Parameters**: `report_type` and `output_format` — the only two things it needs to decide what to return. `sales_data` isn't passed since it's guaranteed empty inside this function; passing it would just invite dead code checking a condition already known to be true.
- The original `_generate_empty_report(report_type, output_format)` stub stays as-is, called only for non-JSON formats, same as before.

**What the split improved**
The split improved readability. The function now has a sequence of named steps instead of 250 line blocks all with different concerns through nested `If` blocks. Concerns can now be tested in isolation. I saw no need to use Prompt 3 for logic simplification because the split was to improve the structure of the code,not change the logic. As a result, there would not be any logic duplication. 

**Below is the pasted sales report refactored by Clause after applying `Prompt 1: Function Responsibility Analysis` for easy reference**

"""
Refactored sales report generator.

Each concern from the original monolithic function now lives in its own
function. `generate_sales_report` is a thin orchestrator that delegates
to them in sequence.
"""

from datetime import datetime


# ---------------------------------------------------------------------------
# Validation
# ---------------------------------------------------------------------------

def _validate_inputs(sales_data, report_type, output_format):
    """Validate the top-level arguments. Raises ValueError on bad input."""
    if not sales_data or not isinstance(sales_data, list):
        raise ValueError("Sales data must be a non-empty list")

    if report_type not in ('summary', 'detailed', 'forecast'):
        raise ValueError("Report type must be 'summary', 'detailed', or 'forecast'")

    if output_format not in ('pdf', 'excel', 'html', 'json'):
        raise ValueError("Output format must be 'pdf', 'excel', 'html', or 'json'")


# ---------------------------------------------------------------------------
# Filtering
# ---------------------------------------------------------------------------

def _filter_by_date_range(sales_data, date_range):
    """Filter sales to those within date_range['start']..date_range['end']."""
    if not date_range:
        return sales_data

    if 'start' not in date_range or 'end' not in date_range:
        raise ValueError("Date range must include 'start' and 'end' dates")

    start_date = datetime.strptime(date_range['start'], '%Y-%m-%d')
    end_date = datetime.strptime(date_range['end'], '%Y-%m-%d')

    if start_date > end_date:
        raise ValueError("Start date cannot be after end date")

    return [
        sale for sale in sales_data
        if start_date <= datetime.strptime(sale['date'], '%Y-%m-%d') <= end_date
    ]


def _apply_filters(sales_data, filters):
    """Apply an arbitrary dict of {field: value_or_list} filters."""
    if not filters:
        return sales_data

    for key, value in filters.items():
        if isinstance(value, list):
            sales_data = [sale for sale in sales_data if sale.get(key) in value]
        else:
            sales_data = [sale for sale in sales_data if sale.get(key) == value]

    return sales_data


# ---------------------------------------------------------------------------
# Metrics
# ---------------------------------------------------------------------------

def _calculate_summary_metrics(sales_data):
    """Return total, average, max, and min sale info for the dataset."""
    total_sales = sum(sale['amount'] for sale in sales_data)
    avg_sale = total_sales / len(sales_data)
    max_sale = max(sales_data, key=lambda x: x['amount'])
    min_sale = min(sales_data, key=lambda x: x['amount'])

    return {
        'total_sales': total_sales,
        'transaction_count': len(sales_data),
        'average_sale': avg_sale,
        'max_sale': {
            'amount': max_sale['amount'],
            'date': max_sale['date'],
            'details': max_sale,
        },
        'min_sale': {
            'amount': min_sale['amount'],
            'date': min_sale['date'],
            'details': min_sale,
        },
    }


# ---------------------------------------------------------------------------
# Grouping
# ---------------------------------------------------------------------------

def _group_sales(sales_data, grouping):
    """Bucket sales by the given field and compute per-group totals/averages."""
    grouped_data = {}

    for sale in sales_data:
        key = sale.get(grouping, 'Unknown')
        if key not in grouped_data:
            grouped_data[key] = {'count': 0, 'total': 0, 'items': []}

        grouped_data[key]['count'] += 1
        grouped_data[key]['total'] += sale['amount']
        grouped_data[key]['items'].append(sale)

    for key in grouped_data:
        grouped_data[key]['average'] = grouped_data[key]['total'] / grouped_data[key]['count']

    return grouped_data


def _build_grouping_section(grouped_data, grouping, total_sales):
    """Build the report_data['grouping'] section from pre-computed group data."""
    groups = {
        key: {
            'count': data['count'],
            'total': data['total'],
            'average': data['average'],
            'percentage': (data['total'] / total_sales) * 100,
        }
        for key, data in grouped_data.items()
    }
    return {'by': grouping, 'groups': groups}


# ---------------------------------------------------------------------------
# Report-type-specific sections
# ---------------------------------------------------------------------------

def _add_transaction_details(sales_data):
    """Build the enriched transaction list used by 'detailed' reports."""
    transactions = []

    for sale in sales_data:
        transaction = dict(sale)

        if 'tax' in sale and 'amount' in sale:
            transaction['pre_tax'] = sale['amount'] - sale['tax']

        if 'cost' in sale and 'amount' in sale:
            transaction['profit'] = sale['amount'] - sale['cost']
            transaction['margin'] = (transaction['profit'] / sale['amount']) * 100

        transactions.append(transaction)

    return transactions


def _calculate_forecast(sales_data):
    """Aggregate sales by month, compute growth rates, and project 3 months out."""
    monthly_sales = {}
    for sale in sales_data:
        sale_date = datetime.strptime(sale['date'], '%Y-%m-%d')
        month_key = f"{sale_date.year}-{sale_date.month:02d}"
        monthly_sales[month_key] = monthly_sales.get(month_key, 0) + sale['amount']

    sorted_months = sorted(monthly_sales.keys())
    growth_rates = []

    for i in range(1, len(sorted_months)):
        prev_amount = monthly_sales[sorted_months[i - 1]]
        curr_amount = monthly_sales[sorted_months[i]]
        if prev_amount > 0:
            growth_rates.append(((curr_amount - prev_amount) / prev_amount) * 100)

    avg_growth_rate = sum(growth_rates) / len(growth_rates) if growth_rates else 0

    forecast = {}
    if sorted_months:
        last_month = sorted_months[-1]
        last_amount = monthly_sales[last_month]
        year, month = map(int, last_month.split('-'))

        for _ in range(3):
            month += 1
            if month > 12:
                month = 1
                year += 1
            forecast_month = f"{year}-{month:02d}"
            last_amount = last_amount * (1 + (avg_growth_rate / 100))
            forecast[forecast_month] = last_amount

    return {
        'monthly_sales': monthly_sales,
        'growth_rates': {
            sorted_months[i]: growth_rates[i - 1] for i in range(1, len(sorted_months))
        },
        'average_growth_rate': avg_growth_rate,
        'projected_sales': forecast,
    }


# ---------------------------------------------------------------------------
# Charts
# ---------------------------------------------------------------------------

def _build_charts(sales_data, grouped_data, grouping):
    """Build chart-ready data: sales-over-time, and a group pie chart if applicable."""
    date_sales = {}
    for sale in sales_data:
        date_sales[sale['date']] = date_sales.get(sale['date'], 0) + sale['amount']

    time_chart = {'labels': [], 'data': []}
    for date in sorted(date_sales.keys()):
        time_chart['labels'].append(date)
        time_chart['data'].append(date_sales[date])

    charts_data = {'sales_over_time': time_chart}

    if grouping and grouped_data:
        pie_chart = {'labels': [], 'data': []}
        for key, data in grouped_data.items():
            pie_chart['labels'].append(key)
            pie_chart['data'].append(data['total'])
        charts_data['sales_by_' + grouping] = pie_chart

    return charts_data


# ---------------------------------------------------------------------------
# Output dispatch
# ---------------------------------------------------------------------------

def _dispatch_output(report_data, output_format, include_charts):
    """Route the assembled report_data to the correct output generator."""
    if output_format == 'json':
        return report_data
    elif output_format == 'html':
        return _generate_html_report(report_data, include_charts)
    elif output_format == 'excel':
        return _generate_excel_report(report_data, include_charts)
    elif output_format == 'pdf':
        return _generate_pdf_report(report_data, include_charts)


# ---------------------------------------------------------------------------
# Main orchestrator
# ---------------------------------------------------------------------------

def generate_sales_report(sales_data, report_type='summary', date_range=None,
                           filters=None, grouping=None, include_charts=False,
                           output_format='pdf'):
    """
    Generate a comprehensive sales report based on provided data and parameters.

    Parameters:
    - sales_data: List of sales transactions
    - report_type: 'summary', 'detailed', or 'forecast'
    - date_range: Dict with 'start' and 'end' dates
    - filters: Dict of filters to apply
    - grouping: How to group data ('product', 'category', 'customer', 'region')
    - include_charts: Whether to include charts/visualizations
    - output_format: 'pdf', 'excel', 'html', or 'json'

    Returns:
    - Report data or file path depending on output_format
    """
    _validate_inputs(sales_data, report_type, output_format)

    sales_data = _filter_by_date_range(sales_data, date_range)
    sales_data = _apply_filters(sales_data, filters)

    if not sales_data:
        print("Warning: No data matches the specified criteria")
        if output_format == 'json':
            return {"message": "No data matches the specified criteria", "data": []}
        return _generate_empty_report(report_type, output_format)

    summary = _calculate_summary_metrics(sales_data)

    grouped_data = _group_sales(sales_data, grouping) if grouping else {}

    report_data = {
        'report_type': report_type,
        'date_generated': datetime.now().strftime('%Y-%m-%d %H:%M:%S'),
        'date_range': date_range,
        'filters': filters,
        'summary': summary,
    }

    if grouping:
        report_data['grouping'] = _build_grouping_section(
            grouped_data, grouping, summary['total_sales']
        )

    if report_type == 'detailed':
        report_data['transactions'] = _add_transaction_details(sales_data)

    if report_type == 'forecast':
        report_data['forecast'] = _calculate_forecast(sales_data)

    if include_charts:
        report_data['charts'] = _build_charts(sales_data, grouped_data, grouping)

    return _dispatch_output(report_data, output_format, include_charts)


# ---------------------------------------------------------------------------
# Existing helper functions (unchanged, not implemented here)
# ---------------------------------------------------------------------------

def _generate_empty_report(report_type, output_format):
    pass


def _generate_html_report(report_data, include_charts):
    pass


def _generate_excel_report(report_data, include_charts):
    pass


def _generate_pdf_report(report_data, include_charts):
    pass



