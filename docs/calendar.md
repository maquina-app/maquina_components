# Calendar

> Displays a date picker calendar with single and range selection.

<!-- preview:single height:320 -->

## Usage

```erb
<%%= render "components/calendar" %>
```

### With Selected Date

```erb
<%%= render "components/calendar", selected: Date.today %>
```

## Examples

### Single Selection

<!-- preview:single height:320 -->

```erb
<%%= render "components/calendar",
      mode: :single,
      selected: Date.today %>
```

### Range Selection

<!-- preview:range height:320 -->

```erb
<%%= render "components/calendar",
      mode: :range,
      selected: Date.today,
      selected_end: Date.today + 5 %>
```

### With Date Constraints

<!-- preview:with_constraints height:320 -->

```erb
<%%= render "components/calendar",
      min_date: Date.today,
      max_date: Date.today + 14 %>
```

### Week Starting Monday

<!-- preview:monday_start height:320 -->

```erb
<%%= render "components/calendar",
      week_starts_on: :monday %>
```

### Form Integration

```erb
<%%= form_with model: @event do |f| %>
  <%%= render "components/calendar",
        selected: @event.date,
        input_name: "event[date]" %>
<%% end %>
```

### Range Form Integration

```erb
<%%= render "components/calendar",
      mode: :range,
      input_name: "booking[check_in]",
      input_name_end: "booking[check_out]" %>
```

## API Reference

### Calendar

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| selected | Date, String | nil | Selected start date |
| selected_end | Date, String | nil | Selected end date (range mode) |
| month | Integer | nil | Display month (1-12) |
| year | Integer | nil | Display year |
| mode | Symbol | :single | :single or :range |
| min_date | Date, String | nil | Minimum selectable date |
| max_date | Date, String | nil | Maximum selectable date |
| disabled_dates | Array | [] | Dates to disable |
| show_outside_days | Boolean | true | Show days from adjacent months |
| week_starts_on | Symbol | :sunday | :sunday or :monday |
| cell_size | String | nil | Custom cell size CSS value |
| input_name | String | nil | Hidden input name for forms |
| input_name_end | String | nil | End date hidden input name |
| css_classes | String | "" | Additional CSS classes |
| html_options | Hash | {} | Additional HTML attributes |

### Calendar Header

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| month | Integer | required | Display month |
| year | Integer | required | Display year |
| month_name | String | required | Formatted month name |
| css_classes | String | "" | Additional CSS classes |
| html_options | Hash | {} | Additional HTML attributes |
