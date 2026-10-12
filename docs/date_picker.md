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

### Size and Full Width

```erb
<%%= render "components/date_picker",
      size: :sm,
      full_width: true,
      input_name: "due_on",
      data: { action: "date-picker:change->filters#apply" } %>
```

`size:` sets `data-size` (`:sm`, `:default`, `:lg`) and `full_width: true` sets `data-full-width`. Other HTML attributes and `data:` land on the wrapper.

## API Reference

### Date Picker

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| selected | Date, String | nil | Pre-selected date |
| selected_end | Date, String | nil | End date for range mode |
| mode | Symbol | :single | :single or :range |
| min_date | Date, String | nil | Minimum selectable date |
| max_date | Date, String | nil | Maximum selectable date |
| disabled_dates | Array | [] | Dates (Date or ISO string) to disable; kept when navigating months |
| show_outside_days | Boolean | true | Show days from adjacent months; kept when navigating months |
| week_starts_on | Symbol | :sunday | :sunday or :monday |
| placeholder | String | nil | Trigger text when empty, also restored after clear(); falls back to "Select date" or "Select date range" |
| input_name | String | nil | Renders a hidden input for the start date |
| input_name_end | String | nil | Renders a hidden input for the end date; range mode only |
| id | String | nil | Wrapper id; defaults to date-picker-{input_name}, popover id is {id}-popover |
| disabled | Boolean | false | Disables the trigger button |
| required | Boolean | false | Adds required to the start date hidden input |
| size | Symbol | :default | Trigger size: :sm, :default or :lg (data-size) |
| full_width | Boolean | false | Stretches the wrapper and trigger to the container width (data-full-width) |
| css_classes | String | "" | Additional CSS classes |
| html_options | Hash | {} | Applied to the wrapper; data: merges with the component's (controller and action concatenate) |

The popover renders the [calendar](calendar.md) component, so calendar day states and styling apply.

Events and programmatic methods are listed under [Stimulus Controller](#stimulus-controller).

### Helper Methods

| Method | Description |
|--------|-------------|
| date_picker_data_attrs(mode: :single, selected: nil, selected_end: nil) | data: hash for a hand-built date picker element |
| date_picker_format(date, format = :long) | Localized date; :short or :long (:full is the same as :long) |
| date_picker_format_range(start_date, end_date, format = :short) | "start - end", or "start - ..." without an end |
| date_picker_locale_data | The I18n date formats and month/day names the controller formats with |

The trigger text is rendered with date_picker_format (single) and date_picker_format_range (range). The partial passes the locale's `date.formats` patterns and month/day names to the controller as `data-date-picker-locale-value`, so a date picked in the browser reads exactly like one rendered by the server (for example "March 05, 2026" with the default English locale), and connecting the controller never changes the text.

## Stimulus Controller

### date-picker

Attached to the wrapper (`data-controller="date-picker"`). The trigger opens the
popover natively through `popovertarget`; the controller keeps the hidden inputs,
the trigger text and `aria-expanded` in sync with the calendar inside it.

| Value | Type | Default | Description |
|-------|------|---------|-------------|
| mode | String | "single" | single or range |
| selected | String | "" | Selected start date, ISO 8601 |
| selectedEnd | String | "" | Selected end date, ISO 8601 (range mode) |
| format | String | "long" | Display format for a single date (long or short); the partial does not set it. Ranges always use short |
| placeholder | String | "" | Trigger text for an empty single date: the placeholder local, or "Select date" ("Select date range" in range mode) |
| placeholderRange | String | "" | Trigger text for an empty range; the partial sets it only in range mode, to the same text. Falls back to "Select date range" |
| locale | Object | {} | I18n date formats and month/day names from `date_picker_locale_data` |

| Target | Element |
|--------|---------|
| trigger | The trigger button (receives `aria-expanded`) |
| display | The trigger text span |
| popover | The popover element (`popover`, `role="dialog"`) |
| calendar | The calendar root inside the popover (focused on open) |
| input | Hidden input for the start date, present when `input_name` is set |
| inputEnd | Hidden input for the end date, present when `input_name_end` is set |

| Action | Description |
|--------|-------------|
| handleChange | Bound on the calendar as `calendar:change->date-picker#handleChange`; updates the inputs and text, closes the popover after one date (single) or both dates (range), and dispatches `date-picker:change` |
| handleNavigate | Bound on the calendar as `calendar:navigate->date-picker#handleNavigate`; re-dispatches it as `date-picker:navigate` |

| Event | Detail | Description |
|-------|--------|-------------|
| date-picker:change | selected, selectedEnd | Selection changed; dates are ISO strings or null |
| date-picker:navigate | month, year, selected, selectedEnd | The calendar's visible month changed |

Both events bubble and fire once per change.

For programmatic use the controller also exposes `openPopover()`,
`closePopover()`, `toggle()`, `clear()` (clears through the calendar, so
`date-picker:change` fires once), `getValue()` (returns
`{ selected, selectedEnd }`) and `setValue(selected, selectedEnd)` (updates the
inputs and text and dispatches `date-picker:change`; it does not move the
calendar's own selection).

## Turbo Drive

The date picker controller automatically closes the popover before Turbo caches the page. No configuration is needed — pressing the browser back button will always show the date picker in its closed state.
