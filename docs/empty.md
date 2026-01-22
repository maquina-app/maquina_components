# Empty

> Displays a placeholder when there's no data to show.

<!-- preview:default height:200 -->

## Usage

```erb
<%%= render "components/empty" do %>
  <%%= render "components/empty/header" do %>
    <%%= render "components/empty/media", icon: :inbox %>
    <%%= render "components/empty/title", text: "No messages" %>
    <%%= render "components/empty/description", text: "Messages you receive will appear here." %>
  <%% end %>
<%% end %>
```

## Examples

### With Action

<!-- preview:with_action height:220 -->

```erb
<%%= render "components/empty" do %>
  <%%= render "components/empty/header" do %>
    <%%= render "components/empty/media", icon: :folder %>
    <%%= render "components/empty/title", text: "No projects yet" %>
    <%%= render "components/empty/description", text: "Get started by creating your first project." %>
  <%% end %>
  <%%= render "components/empty/content" do %>
    <button data-component="button" data-variant="primary">Create project</button>
  <%% end %>
<%% end %>
```

### Outline Variant

<!-- preview:outline height:200 -->

```erb
<%%= render "components/empty", variant: :outline do %>
  <%%= render "components/empty/header" do %>
    <%%= render "components/empty/media", icon: :upload %>
    <%%= render "components/empty/title", text: "Drop files here" %>
  <%% end %>
<%% end %>
```

### Compact Size

<!-- preview:compact height:160 -->

```erb
<%%= render "components/empty", size: :compact do %>
  <%%= render "components/empty/header" do %>
    <%%= render "components/empty/media", icon: :search %>
    <%%= render "components/empty/title", text: "No results found" %>
  <%% end %>
<%% end %>
```

## API Reference

### Empty

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| variant | Symbol | :default | :default or :outline |
| size | Symbol | :default | :default or :compact |
| css_classes | String | "" | Additional CSS classes |
| html_options | Hash | {} | Additional HTML attributes |

### Empty Header

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| css_classes | String | "" | Additional CSS classes |
| html_options | Hash | {} | Additional HTML attributes |

### Empty Media

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| icon | Symbol | nil | Icon name, or use block |
| variant | Symbol | :icon | :icon or :avatar |
| css_classes | String | "" | Additional CSS classes |
| html_options | Hash | {} | Additional HTML attributes |

### Empty Title

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| text | String | nil | Title text, or use block |
| css_classes | String | "" | Additional CSS classes |
| html_options | Hash | {} | Additional HTML attributes |

### Empty Description

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| text | String | nil | Description text, or use block |
| css_classes | String | "" | Additional CSS classes |
| html_options | Hash | {} | Additional HTML attributes |

### Empty Content

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| css_classes | String | "" | Additional CSS classes |
| html_options | Hash | {} | Additional HTML attributes |
