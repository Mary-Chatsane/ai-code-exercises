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
 Extracted one helper function: `_generate_empty_report(report_type, output_format) — generates a minimal report when no data matches the filters`
