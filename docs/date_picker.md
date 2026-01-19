# Date Picker

> A date picker component combining a trigger button with a popover calendar using the native Popover API.

---

## Quick Reference

### Parts

| Partial | Description |
|---------|-------------|
| `components/date_picker` | Complete date picker with trigger and popover |

### Helper Methods

| Method | Description |
|--------|-------------|
| `date_picker_data_attrs(...)` | Generate data attributes for custom implementations |
| `date_picker_format(date, format)` | Format a date for display |
| `date_picker_format_range(start, end, format)` | Format a date range for display |

### Parameters

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `selected` | Date, String, nil | `nil` | Currently selected date |
| `selected_end` | Date, String, nil | `nil` | End date for range selection |
| `mode` | Symbol | `:single` | Selection mode: `:single` or `:range` |
| `min_date` | Date, String, nil | `nil` | Minimum selectable date |
| `max_date` | Date, String, nil | `nil` | Maximum selectable date |
| `disabled_dates` | Array | `[]` | Array of dates to disable |
| `show_outside_days` | Boolean | `true` | Show days from adjacent months |
| `week_starts_on` | Symbol | `:sunday` | First day of week: `:sunday` or `:monday` |
| `placeholder` | String, nil | `nil` | Placeholder text when no date selected |
| `input_name` | String, nil | `nil` | Name for hidden input (form integration) |
| `input_name_end` | String, nil | `nil` | Name for end date hidden input |
| `id` | String, nil | `nil` | Custom ID (auto-generated if nil) |
| `disabled` | Boolean | `false` | Disable the trigger button |
| `required` | Boolean | `false` | Mark hidden input as required |
| `css_classes` | String | `""` | Additional CSS classes |
| `**html_options` | Hash | `{}` | HTML attributes passthrough |

### Selection Modes

| Mode | Description |
|------|-------------|
| `:single` | Select a single date, closes popover after selection |
| `:range` | Select start and end dates, closes after both selected |

### Data Attributes

**Component Identifiers**

| Attribute | Element | Description |
|-----------|---------|-------------|
| `data-component="date-picker"` | Container | Main component identifier |
| `data-date-picker-part="trigger"` | Button | Trigger button |
| `data-date-picker-part="popover"` | Div | Popover container |

**State Attributes**

| Attribute | Description |
|-----------|-------------|
| `aria-expanded` | On trigger, indicates popover state |
| `aria-haspopup="dialog"` | Indicates trigger opens a dialog |
| `popover` | Native popover attribute |
| `popovertarget` | Links trigger to popover |

**Stimulus Values**

| Attribute | Description |
|-----------|-------------|
| `data-date-picker-mode-value` | Selection mode (single/range) |
| `data-date-picker-selected-value` | Selected date ISO string |
| `data-date-picker-selected-end-value` | End date ISO string |

---

## Basic Usage

```erb
<%%= render "components/date_picker" %>
```

With a pre-selected date:

```erb
<%%= render "components/date_picker", selected: Date.current %>
```

---

## Examples

### Single Date Selection

```erb
<%%= render "components/date_picker",
  mode: :single,
  selected: @event.date,
  placeholder: "Pick a date" %>
```

### Range Selection

```erb
<%%= render "components/date_picker",
  mode: :range,
  selected: @booking.check_in,
  selected_end: @booking.check_out,
  placeholder: "Select dates" %>
```

### With Date Constraints

```erb
<%%= render "components/date_picker",
  min_date: Date.current,
  max_date: Date.current + 90.days,
  placeholder: "Select a date within 90 days" %>
```

### Form Integration

```erb
<%%= form_with model: @event do |f| %>
  <div class="space-y-2">
    <%%= f.label :scheduled_at, "Event Date" %>
    <%%= render "components/date_picker",
      selected: @event.scheduled_at,
      input_name: "event[scheduled_at]",
      min_date: Date.current,
      required: true %>
  </div>

  <%%= f.submit "Save", data: { component: "button", variant: "primary" } %>
<%% end %>
```

### Range in Form

```erb
<%%= form_with model: @booking do |f| %>
  <div class="space-y-2">
    <%%= f.label :dates, "Booking Dates" %>
    <%%= render "components/date_picker",
      mode: :range,
      selected: @booking.check_in,
      selected_end: @booking.check_out,
      input_name: "booking[check_in]",
      input_name_end: "booking[check_out]",
      min_date: Date.current %>
  </div>

  <%%= f.submit "Book", data: { component: "button", variant: "primary" } %>
<%% end %>
```

### Disabled State

```erb
<%%= render "components/date_picker",
  selected: @event.locked_date,
  disabled: true %>
```

### Week Starting Monday

```erb
<%%= render "components/date_picker",
  week_starts_on: :monday %>
```

---

## Real-World Patterns

### Event Scheduling

A date picker for scheduling events:

```erb
<div class="space-y-4">
  <div>
    <label class="text-sm font-medium">Event Date</label>
    <%%= render "components/date_picker",
      selected: @event.scheduled_for,
      input_name: "event[scheduled_for]",
      min_date: Date.current,
      max_date: Date.current + 1.year,
      placeholder: "When should this event occur?" %>
  </div>
</div>
```

### Hotel Booking

A range date picker for check-in/check-out:

```erb
<div class="flex flex-col gap-4 p-4 border rounded-lg">
  <h3 class="font-medium">Select Your Stay</h3>

  <%%= render "components/date_picker",
    mode: :range,
    selected: params[:check_in],
    selected_end: params[:check_out],
    input_name: "check_in",
    input_name_end: "check_out",
    min_date: Date.current,
    disabled_dates: @unavailable_dates,
    placeholder: "Check-in - Check-out" %>

  <p class="text-sm text-muted-foreground">
    Minimum 1 night stay required
  </p>
</div>
```

### Filter by Date

A date picker used as a filter control:

```erb
<%%= form_with url: reports_path, method: :get, class: "flex items-center gap-4" do %>
  <div class="flex items-center gap-2">
    <label class="text-sm font-medium">From</label>
    <%%= render "components/date_picker",
      selected: params[:from_date],
      input_name: "from_date",
      max_date: Date.current,
      placeholder: "Start date" %>
  </div>

  <div class="flex items-center gap-2">
    <label class="text-sm font-medium">To</label>
    <%%= render "components/date_picker",
      selected: params[:to_date],
      input_name: "to_date",
      min_date: params[:from_date],
      max_date: Date.current,
      placeholder: "End date" %>
  </div>

  <button type="submit" data-component="button" data-variant="primary">
    Apply Filter
  </button>
<%% end %>
```

### Birthday Picker

A date picker for selecting birth dates:

```erb
<%%= render "components/date_picker",
  selected: @user.date_of_birth,
  input_name: "user[date_of_birth]",
  max_date: Date.current - 13.years,
  placeholder: "Select your birth date" %>
```

---

## JavaScript API

### Events

The date picker emits events for integration:

**change Event**

Fired when selection changes:

```javascript
document.addEventListener("date-picker:change", (event) => {
  const { selected, selectedEnd } = event.detail
  console.log("Selected:", selected)
  console.log("End:", selectedEnd)
})
```

**navigate Event**

Fired when navigating between months in the calendar:

```javascript
document.addEventListener("date-picker:navigate", (event) => {
  const { month, year } = event.detail
  // Load events for the new month
})
```

### Programmatic Control

Access the controller via Stimulus:

```javascript
// Get the controller
const element = document.querySelector("[data-controller='date-picker']")
const controller = application.getControllerForElementAndIdentifier(element, "date-picker")

// Methods
controller.openPopover()
controller.closePopover()
controller.toggle()
controller.clear()
controller.getValue()  // { selected: "2025-01-15", selectedEnd: null }
controller.setValue("2025-01-15", "2025-01-20")
```

---

## Native Popover API Benefits

This component uses the native HTML Popover API which provides:

- Light dismiss (clicking outside closes the popover)
- Top layer rendering (no z-index issues)
- Built-in focus management
- Escape key to close
- No JavaScript required for open/close
- Accessible by default

Browser support: Chrome 114+, Edge 114+, Safari 17+, Firefox 125+

---

## Theme Variables

This component uses these CSS variables:

```css
var(--background)
var(--foreground)
var(--input)
var(--ring)
var(--accent)
var(--muted-foreground)
var(--border)
var(--destructive)
```

---

## Customization

### Size Variants

Add a `data-size` attribute to the container:

```erb
<div data-component="date-picker" data-size="sm">
  <%%= render "components/date_picker", ... %>
</div>
```

Or customize via CSS:

```css
/* Small trigger */
[data-component="date-picker"].date-picker-sm [data-date-picker-part="trigger"] {
  @apply h-8 px-2 text-xs;
  min-width: 160px;
}

/* Large trigger */
[data-component="date-picker"].date-picker-lg [data-date-picker-part="trigger"] {
  @apply h-11 px-4 text-base;
  min-width: 240px;
}
```

### Full Width

```erb
<%%= render "components/date_picker",
  css_classes: "w-full",
  data: { "full-width": true } %>
```

### Custom Placeholder

```erb
<%%= render "components/date_picker",
  placeholder: "When do you want to travel?" %>
```

### Custom Trigger Styling

```css
/* Custom trigger appearance */
[data-component="date-picker"].custom-trigger [data-date-picker-part="trigger"] {
  background-color: var(--primary);
  color: var(--primary-foreground);
  border: none;
}
```

---

## Accessibility

- Trigger uses `aria-haspopup="dialog"` to announce popover
- `aria-expanded` updates dynamically on trigger
- Popover has `role="dialog"` and `aria-modal="true"`
- Calendar inside popover is fully keyboard navigable
- Focus moves to calendar when popover opens
- Escape key closes popover
- Light dismiss for mouse users
- Color contrast meets WCAG AA requirements

---

## File Structure

```
app/views/components/_date_picker.html.erb
app/assets/stylesheets/date_picker.css
app/javascript/controllers/date_picker_controller.js
docs/date_picker.md
```

---

## Comparison: Calendar vs Date Picker

| Feature | Calendar | Date Picker |
|---------|----------|-------------|
| Display | Always visible (inline) | Hidden until triggered |
| Use case | Dashboard widgets, scheduling views | Form inputs, filters |
| Popover | No | Yes (native Popover API) |
| Trigger button | No | Yes |
| Form integration | Via `input_name` params | Via `input_name` params |

Use **Calendar** when you want the calendar always visible.
Use **Date Picker** when you want a compact trigger that opens a calendar.
