# Calendar

> A date picker calendar component with single and range selection modes.

---

## Quick Reference

### Parts

| Partial | Description |
|---------|-------------|
| `components/calendar` | Main calendar container with grid |
| `components/calendar/header` | Navigation with prev/next buttons |
| `components/calendar/week` | Week row with 7 day buttons |

### Helper Methods

| Method | Description |
|--------|-------------|
| `calendar_month_data(date, week_starts_on)` | Generate month data for custom rendering |
| `calendar_month_name(date, format)` | Format month name with year |
| `calendar_date_in_range?(date, start, end)` | Check if date is within range |
| `calendar_data_attrs(...)` | Generate data attributes for Rails helpers |
| `calendar_weekday_names(week_starts_on, format)` | Get weekday names array |

### Parameters

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `selected` | Date, String, nil | `nil` | Currently selected date |
| `selected_end` | Date, String, nil | `nil` | End date for range selection |
| `month` | Integer, nil | `nil` | Display month (1-12), defaults to selected or current |
| `year` | Integer, nil | `nil` | Display year, defaults to selected or current |
| `mode` | Symbol | `:single` | Selection mode: `:single` or `:range` |
| `min_date` | Date, String, nil | `nil` | Minimum selectable date |
| `max_date` | Date, String, nil | `nil` | Maximum selectable date |
| `disabled_dates` | Array | `[]` | Array of dates to disable |
| `show_outside_days` | Boolean | `true` | Show days from adjacent months |
| `week_starts_on` | Symbol | `:sunday` | First day of week: `:sunday` or `:monday` |
| `cell_size` | String, nil | `nil` | Custom cell size (e.g., "2.5rem") |
| `input_name` | String, nil | `nil` | Name for hidden input (form integration) |
| `input_name_end` | String, nil | `nil` | Name for end date hidden input |
| `css_classes` | String | `""` | Additional CSS classes |
| `**html_options` | Hash | `{}` | HTML attributes passthrough |

### Selection Modes

| Mode | Description |
|------|-------------|
| `:single` | Select a single date, click again to deselect |
| `:range` | Select start and end dates for a range |

### Data Attributes

**Component Identifiers**

| Attribute | Element | Description |
|-----------|---------|-------------|
| `data-component="calendar"` | Container | Main component identifier |
| `data-calendar-part="header"` | Header div | Navigation section |
| `data-calendar-part="weekdays"` | Weekdays div | Day name headers |
| `data-calendar-part="grid"` | Grid div | Calendar grid container |
| `data-calendar-part="week"` | Week div | Row of days |
| `data-calendar-part="day"` | Button | Individual day button |

**State Attributes**

| Attribute | Description |
|-----------|-------------|
| `data-state="selected"` | Single selection active |
| `data-state="range-start"` | First date in range |
| `data-state="range-end"` | Last date in range |
| `data-state="range-middle"` | Date within range |
| `data-today` | Current date indicator |
| `data-outside` | Day from adjacent month |
| `data-date="YYYY-MM-DD"` | ISO date value |

**Stimulus Values**

| Attribute | Description |
|-----------|-------------|
| `data-calendar-mode-value` | Selection mode (single/range) |
| `data-calendar-month-value` | Current display month |
| `data-calendar-year-value` | Current display year |
| `data-calendar-selected-value` | Selected date ISO string |
| `data-calendar-selected-end-value` | End date ISO string |
| `data-calendar-min-date-value` | Minimum date ISO string |
| `data-calendar-max-date-value` | Maximum date ISO string |

---

## Basic Usage

```erb
<%%= render "components/calendar" %>
```

With a pre-selected date:

```erb
<%%= render "components/calendar", selected: Date.current %>
```

---

## Examples

### Single Selection

```erb
<%%= render "components/calendar",
  mode: :single,
  selected: @event.date %>
```

### Range Selection

```erb
<%%= render "components/calendar",
  mode: :range,
  selected: @booking.check_in,
  selected_end: @booking.check_out %>
```

### With Date Constraints

```erb
<%%= render "components/calendar",
  min_date: Date.current,
  max_date: Date.current + 90.days %>
```

### Week Starting Monday

```erb
<%%= render "components/calendar",
  week_starts_on: :monday %>
```

### Hide Outside Days

```erb
<%%= render "components/calendar",
  show_outside_days: false %>
```

### Custom Cell Size

```erb
<%%= render "components/calendar",
  cell_size: "2.5rem" %>
```

Responsive sizing with Tailwind:

```erb
<%%= render "components/calendar",
  css_classes: "[--cell-size:2rem] md:[--cell-size:2.5rem] lg:[--cell-size:3rem]" %>
```

### With Disabled Dates

```erb
<%%= render "components/calendar",
  disabled_dates: @unavailable_dates %>
```

### Form Integration

```erb
<%%= form_with model: @event do |f| %>
  <%%= render "components/calendar",
    selected: @event.event_date,
    input_name: "event[event_date]",
    min_date: Date.current %>

  <%%= f.submit "Save", data: { component: "button", variant: "primary" } %>
<%% end %>
```

Range selection in a form:

```erb
<%%= form_with model: @booking do |f| %>
  <%%= render "components/calendar",
    mode: :range,
    selected: @booking.check_in,
    selected_end: @booking.check_out,
    input_name: "booking[check_in]",
    input_name_end: "booking[check_out]",
    min_date: Date.current %>

  <%%= f.submit "Book", data: { component: "button", variant: "primary" } %>
<%% end %>
```

---

## Real-World Patterns

### Event Date Picker

A simple date picker for selecting an event date:

```erb
<div class="space-y-4">
  <h3 class="text-lg font-medium">Select Event Date</h3>

  <%%= render "components/calendar",
    selected: @event.scheduled_for,
    min_date: Date.current,
    max_date: Date.current + 1.year,
    input_name: "event[scheduled_for]" %>
</div>
```

### Booking Calendar

A range calendar for hotel or rental bookings:

```erb
<div class="space-y-4">
  <div class="flex items-center justify-between">
    <h3 class="text-lg font-medium">Select Dates</h3>
    <div class="text-sm text-muted-foreground">
      <span data-calendar-display="start">Check-in</span>
      <span class="mx-2">-</span>
      <span data-calendar-display="end">Check-out</span>
    </div>
  </div>

  <%%= render "components/calendar",
    mode: :range,
    selected: @booking.check_in,
    selected_end: @booking.check_out,
    min_date: Date.current,
    disabled_dates: @booked_dates,
    input_name: "booking[check_in]",
    input_name_end: "booking[check_out]" %>
</div>
```

### Inline Calendar with Events

Display a calendar with event indicators:

```erb
<div data-controller="calendar-events"
     data-calendar-events-dates-value="<%%= @event_dates.to_json %>">
  <%%= render "components/calendar",
    selected: @current_date,
    data: { "calendar-events-target": "calendar" } %>

  <div data-calendar-events-target="eventList" class="mt-4">
    <!-- Events for selected date rendered here -->
  </div>
</div>
```

### Date Filter for Reports

A calendar used as a date filter:

```erb
<%%= form_with url: reports_path, method: :get, class: "space-y-4" do |f| %>
  <div class="flex gap-4">
    <div>
      <label class="text-sm font-medium">Start Date</label>
      <%%= render "components/calendar",
        selected: params[:start_date],
        input_name: "start_date",
        max_date: Date.current %>
    </div>

    <div>
      <label class="text-sm font-medium">End Date</label>
      <%%= render "components/calendar",
        selected: params[:end_date],
        input_name: "end_date",
        min_date: params[:start_date],
        max_date: Date.current %>
    </div>
  </div>

  <%%= f.submit "Apply Filter", data: { component: "button" } %>
<%% end %>
```

---

## JavaScript Events

The calendar emits events for integration with other components:

### change Event

Fired when selection changes:

```javascript
document.addEventListener("calendar:change", (event) => {
  const { mode, selected, selectedEnd } = event.detail
  console.log("Selected:", selected)
  if (mode === "range") {
    console.log("End:", selectedEnd)
  }
})
```

### navigate Event

Fired when navigating between months:

```javascript
// In a Stimulus controller
calendarNavigate(event) {
  const { month, year, selected, selectedEnd } = event.detail
  // Fetch events for the new month via Turbo
  this.loadEvents(month, year)
}
```

---

## Keyboard Navigation

| Key | Action |
|-----|--------|
| Arrow Left | Previous day |
| Arrow Right | Next day |
| Arrow Up | Same day previous week |
| Arrow Down | Same day next week |
| Home | First day of month |
| End | Last day of month |
| Enter / Space | Select focused day |

---

## Theme Variables

This component uses these CSS variables:

```css
var(--background)
var(--foreground)
var(--primary)
var(--primary-foreground)
var(--accent)
var(--accent-foreground)
var(--muted-foreground)
var(--border)
var(--ring)
```

---

## Customization

### Custom Cell Size

Set the `--cell-size` CSS variable:

```erb
<%%= render "components/calendar",
  css_classes: "[--cell-size:3rem]" %>
```

Or in your CSS:

```css
[data-component="calendar"] {
  --cell-size: 3rem;
}
```

### Adding Custom Day Styling

To highlight specific dates, use CSS:

```css
/* Highlight weekends */
[data-calendar-part="day"][data-date$="-06"],
[data-calendar-part="day"][data-date$="-07"] {
  color: var(--destructive);
}

/* Custom event indicator */
[data-calendar-part="day"][data-has-event]::after {
  content: "";
  position: absolute;
  bottom: 2px;
  left: 50%;
  transform: translateX(-50%);
  width: 4px;
  height: 4px;
  border-radius: 50%;
  background-color: var(--primary);
}
```

### Changing Selection Colors

Override the selection styles:

```css
[data-calendar-part="day"][data-state="selected"],
[data-calendar-part="day"][data-state="range-start"],
[data-calendar-part="day"][data-state="range-end"] {
  background-color: var(--accent);
  color: var(--accent-foreground);
}
```

---

## Accessibility

- Uses semantic button elements for days
- Proper ARIA attributes for selection state (`aria-selected`)
- Current date marked with `aria-current="date"`
- Grid structure with `role="grid"` and `role="row"`
- Full keyboard navigation support
- Focus visible states for keyboard users
- Navigation buttons have accessible labels
- Color contrast meets WCAG AA requirements

---

## File Structure

```
app/views/components/
├── _calendar.html.erb
└── calendar/
    ├── _header.html.erb
    └── _week.html.erb

app/assets/stylesheets/calendar.css
app/javascript/controllers/calendar_controller.js
app/helpers/maquina_components/calendar_helper.rb
docs/calendar.md
```

---

## Integration with Turbo

For server-side month navigation with Turbo Frames:

```erb
<%%= turbo_frame_tag "calendar" do %>
  <%%= render "components/calendar",
    month: params[:month]&.to_i,
    year: params[:year]&.to_i,
    selected: @selected_date,
    data: {
      action: "calendar:navigate->turbo#navigate"
    } %>
<%% end %>
```

With a Stimulus controller to handle navigation:

```javascript
// turbo_controller.js
navigate(event) {
  const { month, year } = event.detail
  const url = new URL(window.location)
  url.searchParams.set("month", month)
  url.searchParams.set("year", year)

  Turbo.visit(url, { frame: "calendar" })
}
```
