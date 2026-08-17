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

### Info

<!-- preview:info height:100 -->

```erb
<%%= render "components/alert", variant: :info, icon: :info do %>
  <%%= render "components/alert/title", text: "Heads up" %>
  <%%= render "components/alert/description", text: "This release normalizes the default radius." %>
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
| variant | Symbol | :default | :default, :destructive, :success, :warning, :info; :error is accepted as an alias of :destructive |
| icon | Symbol | nil | Icon name to display |
| css_classes | String | "" | Additional CSS classes |
| html_options | Hash | {} | Additional HTML attributes |

#### Custom icon markup

`icon:` renders a built-in glyph as the alert's first child, which is what the
variant icon colors key off. If you need your own markup instead — an inline
SVG, an icon font, an `<img>`, or an icon that is not the first child — mark it
with `data-alert-part="icon"` and it picks up the same sizing and per-variant
color:

```erb
<%%= render "components/alert", variant: :success do %>
  <span data-alert-part="icon"><%%= image_tag "check.svg" %></span>
  <%%= render "components/alert/title", text: "Saved" %>
<%% end %>
```

Pass `data: { has_icon: true }` alongside it so the alert reserves the left
padding it normally adds for `icon:`.

### Alert Title

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| text | String | nil | Title text |
| content | String | nil | HTML content via `capture`, or use block |
| css_classes | String | "" | Additional CSS classes |
| html_options | Hash | {} | Additional HTML attributes |

### Alert Description

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| text | String | nil | Description text |
| content | String | nil | HTML content via `capture`, or use block |
| css_classes | String | "" | Additional CSS classes |
| html_options | Hash | {} | Additional HTML attributes |
