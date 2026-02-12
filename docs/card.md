# Card

> Displays content in a contained box with optional header and footer.

<!-- preview:default height:220 -->

## Usage

```erb
<%%= render "components/card" do %>
  <%%= render "components/card/header" do %>
    <%%= render "components/card/title", text: "Card Title" %>
    <%%= render "components/card/description", text: "Card description." %>
  <%% end %>
  <%%= render "components/card/content" do %>
    <p>Card content goes here.</p>
  <%% end %>
  <%%= render "components/card/footer" do %>
    <button data-component="button" data-variant="primary">Save</button>
  <%% end %>
<%% end %>
```

## Examples

### Simple Card

<!-- preview:simple height:100 -->

```erb
<%%= render "components/card" do %>
  <%%= render "components/card/content", spacing: :full do %>
    <p>A simple card with just content.</p>
  <%% end %>
<%% end %>
```

### With Header Action

<!-- preview:with_header height:180 -->

```erb
<%%= render "components/card" do %>
  <%%= render "components/card/header", layout: :row do %>
    <div>
      <%%= render "components/card/title", text: "Team Members" %>
      <%%= render "components/card/description", text: "Manage your team." %>
    </div>
    <%%= render "components/card/action" do %>
      <button data-component="button" data-variant="primary" data-size="sm">Add</button>
    <%% end %>
  <%% end %>
  <%%= render "components/card/content" do %>
    <p class="text-sm text-muted-foreground">No members yet.</p>
  <%% end %>
<%% end %>
```

### With Footer

<!-- preview:with_footer height:220 -->

```erb
<%%= render "components/card" do %>
  <%%= render "components/card/header" do %>
    <%%= render "components/card/title", text: "Settings" %>
  <%% end %>
  <%%= render "components/card/content" do %>
    <p>Configure your preferences.</p>
  <%% end %>
  <%%= render "components/card/footer", align: :end do %>
    <button data-component="button" data-variant="outline">Cancel</button>
    <button data-component="button" data-variant="primary">Save</button>
  <%% end %>
<%% end %>
```

## API Reference

### Card

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| css_classes | String | "" | Additional CSS classes |
| html_options | Hash | {} | Additional HTML attributes |

### Card Header

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| layout | Symbol | :column | :column or :row |
| css_classes | String | "" | Additional CSS classes |
| html_options | Hash | {} | Additional HTML attributes |

### Card Title

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| text | String | nil | Title text |
| content | String | nil | HTML content via `capture` |
| size | Symbol | :default | :default or :sm |
| css_classes | String | "" | Additional CSS classes |
| html_options | Hash | {} | Additional HTML attributes |

### Card Description

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| text | String | nil | Description text |
| content | String | nil | HTML content via `capture` |
| css_classes | String | "" | Additional CSS classes |
| html_options | Hash | {} | Additional HTML attributes |

### Card Action

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| css_classes | String | "" | Additional CSS classes |
| html_options | Hash | {} | Additional HTML attributes |

### Card Content

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| spacing | Symbol | :default | :default or :full (when no header) |
| css_classes | String | "" | Additional CSS classes |
| html_options | Hash | {} | Additional HTML attributes |

### Card Footer

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| align | Symbol | :start | :start, :center, :end, :between |
| spacing | Symbol | :default | :default or :full (when no content) |
| css_classes | String | "" | Additional CSS classes |
| html_options | Hash | {} | Additional HTML attributes |
