# Toggle Group

> A group of two-state buttons that can be toggled on or off.

<!-- preview:default height:200 -->

## Usage

```erb
<%%= render "components/toggle_group", type: :single, value: "center" do %>
  <%%= render "components/toggle_group/item", value: "left", aria_label: "Align left" do %>
    <%%= icon_for :align_left, class: "size-4" %>
  <%% end %>
  <%%= render "components/toggle_group/item", value: "center", aria_label: "Align center", pressed: true do %>
    <%%= icon_for :align_center, class: "size-4" %>
  <%% end %>
  <%%= render "components/toggle_group/item", value: "right", aria_label: "Align right" do %>
    <%%= icon_for :align_right, class: "size-4" %>
  <%% end %>
<%% end %>
```

## Examples

### Multiple Selection

```erb
<%%= render "components/toggle_group", type: :multiple, value: ["bold", "italic"] do %>
  <%%= render "components/toggle_group/item", value: "bold", aria_label: "Bold", pressed: true do %>
    <%%= icon_for :bold, class: "size-4" %>
  <%% end %>
  <%%= render "components/toggle_group/item", value: "italic", aria_label: "Italic", pressed: true do %>
    <%%= icon_for :italic, class: "size-4" %>
  <%% end %>
  <%%= render "components/toggle_group/item", value: "underline", aria_label: "Underline" do %>
    <%%= icon_for :underline, class: "size-4" %>
  <%% end %>
<%% end %>
```

### Outline Variant

```erb
<%%= render "components/toggle_group", type: :single, variant: :outline do %>
  <%%= render "components/toggle_group/item", value: "list", aria_label: "List view" do %>
    <%%= icon_for :list, class: "size-4" %>
  <%% end %>
  <%%= render "components/toggle_group/item", value: "grid", aria_label: "Grid view" do %>
    <%%= icon_for :grid, class: "size-4" %>
  <%% end %>
<%% end %>
```

### With Text Labels

The group's `value` is the source of truth: on connect the controller
re-syncs every item from it, so an item marked `pressed: true` that is not
in `value` turns off. Keep the two in agreement (`pressed` only sets the
markup rendered before JavaScript runs).

```erb
<%%= render "components/toggle_group", type: :single, size: :lg, value: "day" do %>
  <%%= render "components/toggle_group/item", value: "day", pressed: true do %>
    Day
  <%% end %>
  <%%= render "components/toggle_group/item", value: "week" do %>
    Week
  <%% end %>
  <%%= render "components/toggle_group/item", value: "month" do %>
    Month
  <%% end %>
<%% end %>
```

### Using the Helpers

The builder form collects items and renders them inside the group, marking
items pressed from the group's `value`:

```erb
<%%= toggle_group type: :multiple, variant: :outline, value: ["bold"] do |group| %>
  <%% group.item value: "bold", icon: :bold, aria_label: "Toggle bold" %>
  <%% group.item value: "italic", icon: :italic, aria_label: "Toggle italic" %>
  <%% group.item value: "underline", aria_label: "Underline" do %>
    <%%= icon_for :underline, class: "size-4" %>
  <%% end %>
<%% end %>
```

For data-driven groups, pass an array of item hashes:

```erb
<%%= toggle_group_simple type: :single, value: "center", items: [
  { value: "left", icon: :align_left, aria_label: "Align left" },
  { value: "center", icon: :align_center, aria_label: "Align center" },
  { value: "right", icon: :align_right, aria_label: "Align right" }
] %>
```

### Disabled

Pass `disabled: true` to the group to disable every item. The group gets
`aria-disabled="true"`, and the controller sets `disabled` on each item, so
items rendered directly from partials leave the tab order and ignore clicks
and keys. The helpers also render each item with `disabled`, so it works
before JavaScript loads.

```erb
<%%= render "components/toggle_group", type: :single, value: "left", disabled: true do %>
  <%%= render "components/toggle_group/item", value: "left", aria_label: "Align left", pressed: true do %>
    <%%= icon_for :align_left, class: "size-4" %>
  <%% end %>
  <%%= render "components/toggle_group/item", value: "right", aria_label: "Align right" do %>
    <%%= icon_for :align_right, class: "size-4" %>
  <%% end %>
<%% end %>
```

### Listening for Changes

```erb
<%%= render "components/toggle_group", type: :single, value: "day",
      data: { action: "toggle-group:change->calendar#changeView" } do %>
  <%# items %>
<%% end %>
```

## API Reference

### Toggle Group

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| type | Symbol | :single | :single or :multiple selection |
| variant | Symbol | :default | :default or :outline |
| size | Symbol | :default | :sm, :default, :lg |
| value | String/Array | nil | Initial selected value(s); drives each item's pressed state once the controller connects |
| disabled | Boolean | false | Disables the whole group: sets aria-disabled="true" on the group, and the controller sets disabled on every item (the helpers also render each item disabled) |
| css_classes | String | "" | Additional CSS classes |
| html_options | Hash | {} | Additional HTML attributes |

### Toggle Group Item

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| value | String | required | Value when selected, rendered as data-value |
| pressed | Boolean | false | Initial pressed state (data-state="on", aria-pressed); overridden by the group's value on connect |
| disabled | Boolean | false | Disable this item |
| aria_label | String | nil | Accessible label for icon-only items |
| css_classes | String | "" | Additional CSS classes |
| html_options | Hash | {} | Additional HTML attributes |

### Helper Methods

| Method | Description |
|--------|-------------|
| toggle_group(type: :single, variant: :default, size: :default, value: nil, disabled: false, css_classes: "", **html_options, &block) | With a one-argument block, yields a builder; otherwise renders the block as the group's content |
| group.item(value:, label: nil, icon: nil, disabled: false, aria_label: nil, **options, &block) | Builder item. Renders the block, or the icon (via icon_for) followed by the label. Pressed when value is in the group's value; disabled when it or the group is. Extra options are HTML attributes |
| toggle_group_simple(items:, type: :single, variant: :default, size: :default, value: nil, disabled: false, css_classes: "", **html_options) | Renders items from hashes with :value, :label, :icon, :disabled, :aria_label |

## JavaScript

The group carries `data-controller="toggle-group"`; each item is an `item`
target wired to `click->toggle-group#toggle` and
`keydown->toggle-group#handleKeydown`.

| Value | Type | Default | Description |
|-------|------|---------|-------------|
| type | String | "single" | single or multiple, from the type local |
| selected | Array | [] | Selected values, from the value local |

| Action | Description |
|--------|-------------|
| toggle | Toggles the clicked item. In single mode clicking the pressed item clears the selection |
| handleKeydown | Arrow keys move focus between enabled items (wrapping), Home and End jump to the first and last. Does nothing in a disabled group |

On every change the controller dispatches one `toggle-group:change` event
from the group element (bubbling) with `detail: { type, value }`, where value
is a string or null in single mode and an array in multiple mode.

When the group has `aria-disabled="true"`, the controller sets `disabled` on
every item target as it connects, including items added later.

The controller also exposes `select(value)`, `deselect(value)`, `clear()`,
and `getValue()` for use from other controllers via outlets.
