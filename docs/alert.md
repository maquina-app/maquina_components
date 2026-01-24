# Alert

> Displays a callout for important messages and feedback.

<!-- preview:default height:100 -->

## Usage

```erb
<%%= render "components/alert", icon: :info do %>
  <%%= render "components/alert/title", text: "Heads up!" %>
  <%%= render "components/alert/description", text: "You can add components using the CLI." %>
<%% end %>
```

## Examples

### Destructive

<!-- preview:destructive height:100 -->

```erb
<%%= render "components/alert", variant: :destructive, icon: :triangle_alert do %>
  <%%= render "components/alert/title", text: "Error" %>
  <%%= render "components/alert/description", text: "Your session has expired." %>
<%% end %>
```

### Success

<!-- preview:success height:100 -->

```erb
<%%= render "components/alert", variant: :success, icon: :check_circle do %>
  <%%= render "components/alert/title", text: "Success" %>
  <%%= render "components/alert/description", text: "Your changes have been saved." %>
<%% end %>
```

### Warning

<!-- preview:warning height:100 -->

```erb
<%%= render "components/alert", variant: :warning, icon: :triangle_alert do %>
  <%%= render "components/alert/title", text: "Warning" %>
  <%%= render "components/alert/description", text: "This action cannot be undone." %>
<%% end %>
```

## API Reference

### Alert

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| variant | Symbol | :default | :default, :destructive, :success, :warning |
| icon | Symbol | nil | Icon name to display |
| css_classes | String | "" | Additional CSS classes |
| html_options | Hash | {} | Additional HTML attributes |

### Alert Title

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| text | String | nil | Title text, or use block |
| css_classes | String | "" | Additional CSS classes |
| html_options | Hash | {} | Additional HTML attributes |

### Alert Description

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| text | String | nil | Description text, or use block |
| css_classes | String | "" | Additional CSS classes |
| html_options | Hash | {} | Additional HTML attributes |
