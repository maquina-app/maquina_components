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

### Month and Year Dropdowns

For dates far from today, such as a birth date or an expiry years away,
`caption_layout: :dropdown` replaces the caption with a month select and a year select.
Both are native selects styled like the form [select](form.md):
- They can't hold an invalid value.
- With focus on the year select, typing "1987" jumps straight there.
- Phones show their native picker.

The month names are abbreviated so both selects fit beside the arrows in a 7-cell header.

<!-- preview:dropdown height:320 -->

```erb
<%%= render "components/calendar",
      caption_layout: :dropdown,
      selected: @person.born_on,
      input_name: "person[born_on]" %>
```

The year select lists 100 years back to 10 ahead of the current year.
- `min_date` and `max_date` set those bounds instead, and months wholly outside them are disabled.
- `years:` sets an explicit span, for example `years: 1950..2010`.
- The displayed year is always listed.
- The arrows and keyboard navigation stop at the first and last listed year.

### Required Dates

By default, clicking the selected day clears it. That's right for an optional
date but not for a required one, so `deselectable: false` turns it off:
- **Single mode:** a click on the selected day keeps it and dispatches nothing.
- **Range mode:** clicking the start date again makes a one-day range (start and
  end on that day) instead of clearing.

The [date picker](date_picker.md#required-date) sets this from `required:`.

```erb
<%%= render "components/calendar",
      deselectable: false,
      selected: @shift.date,
      input_name: "shift[date]" %>
```

### With a Footer

A block renders below the grid as `data-calendar-part="footer"`, for actions such
as Clear and Done. The footer only adds spacing; style its contents yourself.

<!-- preview:with_footer height:390 -->

```erb
<%%= render "components/calendar", selected: @event.date do %>
  <div class="flex">
    <button type="button" data-component="button" data-variant="outline" data-size="sm"
            data-action="event-date#clear">Clear</button>
    <button type="button" class="ms-auto" data-component="button" data-variant="primary" data-size="sm"
            data-action="event-date#done">Done</button>
  </div>
<%% end %>
```

## API Reference

### Calendar

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| selected | Date, String | nil | Selected start date; also sets the displayed month |
| selected_end | Date, String | nil | Selected end date (range mode) |
| month | Integer | nil | Display month (1-12); defaults to the selected or current month |
| year | Integer | nil | Display year; defaults to the selected or current year |
| mode | Symbol | :single | :single or :range |
| min_date | Date, String | nil | Minimum selectable date; also disables the previous-month button |
| max_date | Date, String | nil | Maximum selectable date; also disables the next-month button |
| disabled_dates | Array | [] | Dates (Date or ISO string) to disable; kept when navigating months |
| show_outside_days | Boolean | true | Show days from adjacent months; when false their cells stay empty, kept when navigating months |
| week_starts_on | Symbol | :sunday | :sunday or :monday |
| caption_layout | Symbol | :label | :label (the month and year as text) or :dropdown (month and year selects) |
| years | Range | nil | Years in the year select (dropdown only); defaults to 100 back and 10 ahead of the current year, and min_date/max_date set the bounds when given |
| deselectable | Boolean | true | false: a click on the selected day keeps it (single), and the start clicked again makes a one-day range (range) |
| cell_size | String | nil | CSS length written to --cell-size (default 2rem); combined with any style: you pass |
| input_name | String | nil | Renders a hidden input for the start date |
| input_name_end | String | nil | Renders a hidden input for the end date; range mode only |
| css_classes | String | "" | Additional CSS classes |
| html_options | Hash | {} | Additional HTML attributes; data merges with the component's, style: is joined with cell_size |

A block, when given, renders after the grid as `data-calendar-part="footer"`.

Month navigation rebuilds the grid in the browser. The partial passes `data-calendar-disabled-dates-value` (ISO date array) and `data-calendar-show-outside-days-value` to the controller so every month renders with the same rules as the first one.

### Inside a Popover

When the calendar sits inside a `[popover]` element (the [date picker](date_picker.md),
or your own popover opened by a `popovertarget` button), the controller sets
`data-side="top"` or `data-side="bottom"` on the calendar root each time the popover
opens and after every month change. It compares the popover's position with the
button that opened it.

A popover flipped above its trigger stays pinned at its bottom edge, and months
take 4 to 6 rows. So with `data-side="top"` the header moves to the bottom
(weekdays, grid, footer, then header). The month arrows stay next to the trigger
and don't move while you navigate. The DOM order doesn't change; only the visual
order does. A calendar outside a popover never gets `data-side`.

### Calendar Header

Rendered by the calendar; holds the previous/next buttons and the caption.

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| month | Integer | required | Display month |
| year | Integer | required | Display year |
| month_name | String | required | Caption text |
| caption_layout | Symbol | :label | :dropdown renders the month and year selects instead of the caption |
| years | Range | nil | Year select options (dropdown only) |
| month_options | Array | nil | `[name, month, disabled]` for the month select (dropdown only), from calendar_month_options |
| css_classes | String | "" | Additional CSS classes |
| html_options | Hash | {} | Additional HTML attributes |

### Calendar Week

Rendered by the calendar, one per grid row.

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| days | Array | required | Seven Date objects |
| display_month | Integer | required | Month being shown; other days get data-outside |
| selected_date | Date | nil | Selected start date |
| selected_end_date | Date | nil | Selected end date |
| mode | Symbol | :single | :single or :range |
| min_date | Date | nil | Minimum selectable date |
| max_date | Date | nil | Maximum selectable date |
| disabled_dates | Array | [] | Date objects to disable |
| show_outside_days | Boolean | true | Render days outside display_month; when false an empty data-calendar-part="outside-day" cell holds the column |
| css_classes | String | "" | Additional CSS classes |
| html_options | Hash | {} | Additional HTML attributes |

### Day States

| Attribute | Description |
|-----------|-------------|
| data-today | Today's date |
| data-outside | Day from an adjacent month |
| data-state="selected" | Selected day (single mode) |
| data-state="range-start" | First day of a range |
| data-state="range-middle" | Day inside a range |
| data-state="range-end" | Last day of a range |
| disabled | Outside min_date/max_date or in disabled_dates |

Events and programmatic methods are listed under [Stimulus Controller](#stimulus-controller).

### Helper Methods

| Method | Description |
|--------|-------------|
| calendar_to_date(value) | Date from a Date, Time, DateTime or ISO string; nil when blank or unparseable |
| calendar_month_data(date, week_starts_on = :sunday) | Hash with month, year, first_of_month, last_of_month, weeks, week_starts_on |
| calendar_month_name(date, format = :long) | Localized "%B %Y", or "%b %Y" with :short |
| calendar_year_range(display_year, min_date: nil, max_date: nil, years: nil) | Years for the dropdown caption: years (default 100 back and 10 ahead), with min_date/max_date setting the bounds when given; always includes display_year |
| calendar_month_options(year, min_date: nil, max_date: nil) | `[abbr_name, month, disabled]` for months 1-12; disabled when wholly outside min_date/max_date |
| calendar_date_in_range?(date, start_date, end_date) | True when date is between both ends, inclusive |
| calendar_weekday_names(week_starts_on = :sunday, format = :short) | Weekday names; :short, :narrow or :long |
| calendar_data_attrs(mode: :single, selected: nil, selected_end: nil, month: nil, year: nil) | data: hash for a hand-built calendar element |

## Stimulus Controller

### calendar

Attached to the calendar root (`data-controller="calendar"`). The partial renders
every value from its locals.

| Value | Type | Default | Description |
|-------|------|---------|-------------|
| month | Number | 0 | Displayed month (1-12), from the month local or the selected/current month |
| year | Number | 0 | Displayed year |
| selected | String | "" | Selected start date, ISO 8601 |
| selectedEnd | String | "" | Selected end date, ISO 8601 (range mode) |
| minDate | String | "" | Minimum selectable date, ISO 8601; also disables the previous-month button |
| maxDate | String | "" | Maximum selectable date, ISO 8601; also disables the next-month button |
| mode | String | "single" | single or range |
| weekStartsOn | String | "sunday" | sunday or monday |
| disabledDates | Array | [] | ISO dates to disable, applied to every month the controller builds |
| showOutsideDays | Boolean | true | Render days from adjacent months when rebuilding the grid |
| deselectable | Boolean | true | When false, a click can't empty the selection; rendered only when false |
| startYear | Number | — | First year in the year select; set only with caption_layout: :dropdown. Navigation stops at its January |
| endYear | Number | — | Last year in the year select; set only with caption_layout: :dropdown. Navigation stops at its December |

| Target | Element |
|--------|---------|
| day | Each day button (rendered by `calendar/week`, and by the controller when it rebuilds the grid) |
| input | Hidden input for the start date, present when `input_name` is set |
| inputEnd | Hidden input for the end date, present when `input_name_end` is set |
| prevButton | Previous-month button in `calendar/header` |
| nextButton | Next-month button in `calendar/header` |
| monthSelect | Month select in `calendar/header` (caption_layout: :dropdown) |
| yearSelect | Year select in `calendar/header` (caption_layout: :dropdown) |
| grid | Declared but not rendered; the controller finds the grid by `data-calendar-part="grid"` |
| caption | Declared but not rendered; the controller finds the caption by `data-calendar-part="caption"` |

| Action | Description |
|--------|-------------|
| previousMonth / nextMonth | Bound on the header buttons; rebuild the grid for the new month and dispatch `calendar:navigate`. Disabled at min_date/max_date and at the ends of the year select |
| selectMonth / selectYear | Bound on the month and year selects (`change`); show that month and dispatch `calendar:navigate`. A year change keeps the month unless min_date/max_date rule it out that year, in which case it moves to the nearest allowed month |
| selectDay | Bound on each day (`click`). Single mode toggles the day, unless `deselectable` is false: then a click on the selected day does nothing. Range mode sets the start, then the end (a date before the start swaps them; the start again clears, or makes a one-day range when `deselectable` is false), and a third click starts a new range. A one-day range renders as `data-state="selected"` |
| handleKeydown | Bound on each day (`keydown`). Arrow keys move by a day or a week, Home and End jump to the first and last day of the month; moving past the month navigates to the next or previous one. Disabled days are not focused |

| Event | Detail | Description |
|-------|--------|-------------|
| calendar:change | mode, selected, selectedEnd | A day was selected or cleared; dates are ISO strings or null. The hidden inputs are already updated |
| calendar:navigate | month, year, selected, selectedEnd | The visible month changed |

Both events bubble and fire once per change.

Inside a popover the controller also listens for the popover's `toggle` event and sets
`data-side` (see [Inside a Popover](#inside-a-popover)).

For programmatic use the controller also exposes `getValue()` (returns
`{ selected, selectedEnd }`), `select(date)` (a Date or ISO string; follows the
range rules in range mode) and `clear()`. `select` and `clear` dispatch
`calendar:change`.
