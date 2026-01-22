# Combobox

> Displays a searchable dropdown with autocomplete for selecting from a list.

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
    <%%= render "components/combobox/label" do %>Backend<%% end %>
    <%%= render "components/combobox/option", value: "ruby" do %>Ruby<%% end %>
  <%% end %>

  <%%= render "components/combobox/separator" %>

  <%%= render "components/combobox/group" do %>
    <%%= render "components/combobox/label" do %>Frontend<%% end %>
    <%%= render "components/combobox/option", value: "js" do %>JavaScript<%% end %>
  <%% end %>
<%% end %>
```

## API Reference

### Combobox

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| id | String | nil | Custom ID, auto-generated if nil |
| name | String | nil | Form input name |
| value | String | nil | Pre-selected value |
| placeholder | String | "Select..." | Placeholder text |
| css_classes | String | "" | Additional CSS classes |
| html_options | Hash | {} | Additional HTML attributes |

### Combobox Trigger

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| for_id | String | required | ID of content popover |
| placeholder | String | "Select..." | Placeholder text |
| variant | Symbol | :outline | Button variant |
| size | Symbol | :default | Button size |
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
| text | String | nil | Label text, or use block |
| css_classes | String | "" | Additional CSS classes |
| html_options | Hash | {} | Additional HTML attributes |

### Combobox List

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| css_classes | String | "" | Additional CSS classes |
| html_options | Hash | {} | Additional HTML attributes |
