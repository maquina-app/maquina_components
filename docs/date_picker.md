# Date Picker

> Displays a trigger button that opens a popover calendar for date selection.

<!-- preview:default height:320 -->

## Usage

```erb
<%%= render "components/date_picker",
      mode: :single,
      placeholder: "Select a date",
      input_name: "event_date" %>
```

## Examples

### Range Selection

<!-- preview:range height:320 -->

```erb
<%%= render "components/date_picker",
      mode: :range,
      placeholder: "Select date range",
      input_name: "start_date",
      input_name_end: "end_date" %>
```

### With Pre-selected Date

<!-- preview:with_selection height:320 -->

```erb
<%%= render "components/date_picker",
      mode: :single,
      selected: Date.today,
      input_name: "event_date" %>
```

### With Date Constraints

<!-- preview:with_constraints height:320 -->

```erb
<%%= render "components/date_picker",
      min_date: Date.today,
      max_date: Date.today + 30,
      placeholder: "Select within 30 days" %>
```

### Disabled

<!-- preview:disabled height:80 -->

```erb
<%%= render "components/date_picker",
      selected: Date.today,
      disabled: true %>
```

## API Reference

### Date Picker

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| selected | Date, String | nil | Pre-selected date |
| selected_end | Date, String | nil | End date for range mode |
| mode | Symbol | :single | :single or :range |
| min_date | Date, String | nil | Minimum selectable date |
| max_date | Date, String | nil | Maximum selectable date |
| disabled_dates | Array | [] | Array of dates to disable |
| show_outside_days | Boolean | true | Show days from adjacent months |
| week_starts_on | Symbol | :sunday | :sunday or :monday |
| placeholder | String | nil | Placeholder text |
| input_name | String | nil | Name for hidden form input |
| input_name_end | String | nil | End date input name (range mode) |
| id | String | nil | Custom ID, auto-generated if nil |
| disabled | Boolean | false | Whether disabled |
| required | Boolean | false | Mark input as required |
| css_classes | String | "" | Additional CSS classes |
| html_options | Hash | {} | Additional HTML attributes |

## Turbo Drive

The date picker controller automatically closes the popover before Turbo caches the page. No configuration is needed — pressing the browser back button will always show the date picker in its closed state.
