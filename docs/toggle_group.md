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

```erb
<%%= render "components/toggle_group", type: :single, size: :lg do %>
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

## API Reference

### Toggle Group

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| type | Symbol | :single | :single or :multiple selection |
| variant | Symbol | :default | :default or :outline |
| size | Symbol | :default | :sm, :default, :lg |
| value | String/Array | nil | Initial selected value(s) |
| disabled | Boolean | false | Disable all items |
| css_classes | String | "" | Additional CSS classes |
| html_options | Hash | {} | Additional HTML attributes |

### Toggle Group Item

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| value | String | required | Value when selected |
| pressed | Boolean | false | Initial pressed state |
| disabled | Boolean | false | Disable this item |
| aria_label | String | nil | Accessible label for icon-only items |
| css_classes | String | "" | Additional CSS classes |
| html_options | Hash | {} | Additional HTML attributes |
