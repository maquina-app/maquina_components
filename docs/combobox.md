# Combobox

> Displays a searchable dropdown with autocomplete for selecting from a list.

The trigger renders its own up/down chevron, and the search field inside the
popover carries a focus ring like any other form control.

<!-- preview:default height:320 -->

## Usage

```erb
<%%= render "components/combobox", placeholder: "Select..." do |combobox_id| %>
  <%%= render "components/combobox/trigger", for_id: combobox_id, placeholder: "Select..." %>

  <%%= render "components/combobox/content", id: combobox_id do %>
    <%%= render "components/combobox/input", placeholder: "Search..." %>

    <%%= render "components/combobox/list" do %>
      <%%= render "components/combobox/option", value: "one" do %>Option One<%% end %>
      <%%= render "components/combobox/option", value: "two" do %>Option Two<%% end %>
    <%% end %>

    <%%= render "components/combobox/empty" %>
  <%% end %>
<%% end %>
```

### Using Helper

```erb
<%%= combobox_simple placeholder: "Select framework...",
      name: "framework",
      options: [
        { value: "rails", label: "Ruby on Rails" },
        { value: "phoenix", label: "Phoenix" }
      ] %>
```

### In a Form

```erb
<%%= form_with model: @project do |f| %>
  <%%= combobox_simple name: "project[framework]",
        value: @project.framework,
        placeholder: "Select framework...",
        options: [
          { value: "rails", label: "Ruby on Rails" },
          { value: "phoenix", label: "Phoenix" }
        ] %>
  <%%= f.submit "Save", data: { component: "button" } %>
<%% end %>
```

With `name:` the combobox renders `<input type="hidden" name="project[framework]" data-combobox-target="hiddenInput">`. The controller writes the selected value into it on select, empties it when the selected option is clicked again, and fires a bubbling `change` event on it so form listeners see the update.

## Examples

### With Selection

<!-- preview:with_selection height:320 -->

```erb
<%%= render "components/combobox/option", value: "active", selected: true do %>Active<%% end %>
<%%= render "components/combobox/option", value: "archived", disabled: true do %>Archived<%% end %>
```

### With Groups

<!-- preview:with_groups height:320 -->

```erb
<%%= render "components/combobox/list" do %>
  <%%= render "components/combobox/group" do %>
    <%%= render "components/combobox/label", text: "Backend" %>
    <%%= render "components/combobox/option", value: "ruby" do %>Ruby<%% end %>
  <%% end %>

  <%%= render "components/combobox/separator" %>

  <%%= render "components/combobox/group" do %>
    <%%= render "components/combobox/label", text: "Frontend" %>
    <%%= render "components/combobox/option", value: "js" do %>JavaScript<%% end %>
  <%% end %>
<%% end %>
```

## API Reference

### Combobox

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| id | String | nil | ID yielded to the block for the content popover; defaults to combobox-{name}, or combobox-default |
| name | String | nil | Renders a hidden input with this name and the current value, so the selection submits with the surrounding form; also used for the default id |
| value | String | nil | Pre-selected value; the matching option's text becomes the trigger label |
| placeholder | String | "Select..." | Trigger label restored when the selection is cleared |
| css_classes | String | "" | Additional CSS classes |
| html_options | Hash | {} | Additional HTML attributes |

### Combobox Trigger

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| for_id | String | required | ID of content popover |
| placeholder | String | "Select..." | Placeholder text |
| variant | Symbol | :outline | Button variant: :default, :primary, :secondary, :destructive, :outline, :ghost, :link |
| size | Symbol | :default | Button size: :default, :sm, :lg, :icon, :"icon-sm", :"icon-lg" |
| css_classes | String | "" | Additional CSS classes |
| html_options | Hash | {} | Additional HTML attributes |

### Combobox Content

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| id | String | required | Popover ID |
| align | Symbol | :start | :start, :center, :end |
| width | Symbol | :default | :sm, :default, :md, :lg, :full |
| css_classes | String | "" | Additional CSS classes |
| html_options | Hash | {} | Additional HTML attributes |

### Combobox Input

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| placeholder | String | "Search..." | Search placeholder |
| css_classes | String | "" | Additional CSS classes |
| html_options | Hash | {} | Additional HTML attributes |

### Combobox Option

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| value | String | required | Option value |
| selected | Boolean | false | Whether selected |
| disabled | Boolean | false | Whether disabled |
| css_classes | String | "" | Additional CSS classes |
| html_options | Hash | {} | Additional HTML attributes |

### Combobox Empty

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| text | String | "No results found." | Empty state message |
| content | String | nil | HTML content via capture |
| css_classes | String | "" | Additional CSS classes |
| html_options | Hash | {} | Additional HTML attributes |

### Combobox Group

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| css_classes | String | "" | Additional CSS classes |
| html_options | Hash | {} | Additional HTML attributes |

### Combobox Label

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| text | String | nil | Label text |
| content | String | nil | HTML content via capture, or use a block |
| css_classes | String | "" | Additional CSS classes |
| html_options | Hash | {} | Additional HTML attributes |

### Combobox List

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| css_classes | String | "" | Additional CSS classes |
| html_options | Hash | {} | Additional HTML attributes |

### Combobox Separator

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| css_classes | String | "" | Additional CSS classes |
| html_options | Hash | {} | Additional HTML attributes |

Events are listed under [Stimulus Controller](#stimulus-controller).

### Helper Methods

| Method | Description |
|--------|-------------|
| combobox(id: nil, name: nil, value: nil, placeholder: "Select...", css_classes: "", **html_options) { \|cb\| } | Builder; cb.trigger, cb.content { \|content\| }, content.input, content.list { \|list\| }, content.empty, list.option, list.group, list.label, list.separator |
| combobox_simple(options:, placeholder: "Select...", search_placeholder: "Search...", empty_text: "No results found.", value: nil, name: nil, trigger_options: {}, content_options: {}) | Renders a full combobox from hashes with value, label and optional disabled |

## Stimulus Controller

### combobox

Attached to the combobox root (`data-controller="combobox"`). The content panel
is a native popover opened by the trigger's `popovertarget`, so light dismiss
works without JavaScript; the controller handles filtering, selection, keyboard
navigation and `aria-expanded`.

| Value | Type | Default | Description |
|-------|------|---------|-------------|
| value | String | "" | Selected value, from the value local; changing it updates the options, the trigger label and the hidden input |
| name | String | "" | Field name, from the name local (the hidden input carries the name; the controller does not read it) |
| placeholder | String | "Select..." | Trigger label restored when the selection is cleared |

| Target | Element |
|--------|---------|
| trigger | The `combobox/trigger` button (receives `aria-expanded`) |
| label | The trigger's text span |
| content | The `combobox/content` popover |
| input | The `combobox/input` search field (focused and cleared on open) |
| option | Each `combobox/option` |
| empty | The `combobox/empty` message, shown when no option matches |
| hiddenInput | The hidden form input, rendered when `name:` is set |

| Action | Description |
|--------|-------------|
| toggle | Bound on the trigger as `combobox#toggle`; a no-op hook, since the popover opens through `popovertarget` |
| filter | Bound on the search field (`input`); hides options whose text does not contain the query and toggles the empty message |
| select | Bound on each option (`click`); selects it, or clears the selection when it is already selected, then closes the popover |
| keydown | Keyboard handler for custom wiring; the same handling is attached to the content panel on connect |

Inside the open panel, <kbd>↑</kbd>/<kbd>↓</kbd>/<kbd>Home</kbd>/<kbd>End</kbd> move
focus between visible, enabled options, <kbd>Enter</kbd> selects the focused option
and <kbd>Escape</kbd> closes the popover.

| Event | Detail | Description |
|-------|--------|-------------|
| combobox:change | value, label | An option was selected; clicking the selected option clears it (value "", label null). The hidden input is already updated when this fires |

`combobox:change` bubbles. The hidden input also fires a bubbling native
`change` event whenever its value changes, so form listeners (autosave,
validation) see the update.
