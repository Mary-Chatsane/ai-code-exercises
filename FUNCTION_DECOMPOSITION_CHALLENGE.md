## Exercise:Breaking one big function into smaller ones (Function Decomposition Challenge)

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

