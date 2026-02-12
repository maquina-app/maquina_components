# Toast

> A succinct message displayed temporarily.

<!-- preview:default height:420 -->

## Usage

```erb
<%%= render "components/toast",
  title: "Scheduled: Catch up",
  description: "Friday, February 10, 2025 at 5:57 PM" %>
```

## Examples

### Success

```erb
<%%= render "components/toast",
  variant: :success,
  title: "Success!",
  description: "Your changes have been saved." %>
```

### Error

```erb
<%%= render "components/toast",
  variant: :error,
  title: "Error",
  description: "There was a problem with your request." %>
```

### Warning

```erb
<%%= render "components/toast",
  variant: :warning,
  title: "Warning",
  description: "Your session is about to expire." %>
```

### With Action

```erb
<%%= render "components/toast",
  title: "Event Created",
  description: "Your event has been scheduled.",
  content: capture { %>
  <%%= render "components/toast/action", label: "Undo", href: "#" %>
<%% } %>
```

## API Reference

### Toast

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| variant | Symbol | :default | :default, :success, :info, :warning, :error |
| title | String | nil | Toast title text |
| description | String | nil | Toast description text |
| icon | Symbol | nil | Icon name (auto-selected by variant) |
| duration | Integer | 5000 | Auto-dismiss time in ms |
| dismissible | Boolean | true | Show close button |
| content | String | nil | HTML content via `capture` (e.g., action buttons) |
| css_classes | String | "" | Additional CSS classes |
| html_options | Hash | {} | Additional HTML attributes |

### Toast Title

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| text | String | nil | Title text |
| content | String | nil | HTML content via `capture` |
| css_classes | String | "" | Additional CSS classes |
| html_options | Hash | {} | Additional HTML attributes |

### Toast Description

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| text | String | nil | Description text |
| content | String | nil | HTML content via `capture` |
| css_classes | String | "" | Additional CSS classes |
| html_options | Hash | {} | Additional HTML attributes |

### Toaster

The toaster is the container that holds and positions toast notifications. Place it once in your layout.

```erb
<%%= render "components/toaster", position: :bottom_right,
      content: toast_flash_messages %>
```

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| position | Symbol | :bottom_right | :top_left, :top_right, :bottom_left, :bottom_right |
| content | String | nil | Pre-rendered toasts (e.g., flash messages) |
| css_classes | String | "" | Additional CSS classes |
| html_options | Hash | {} | Additional HTML attributes |

### Toast Action

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| label | String | required | Button/link text |
| href | String | nil | Link URL (renders button if nil) |
| method | Symbol | nil | HTTP method for Turbo |
| css_classes | String | "" | Additional CSS classes |
| html_options | Hash | {} | Additional HTML attributes |

### Helper Methods

| Method | Description |
|--------|-------------|
| toast_flash_messages(exclude: []) | Renders all flash messages as toasts |
| toast(variant, title, **options) | Renders a single toast |
| toast_success(title, **options) | Shorthand for success variant |
| toast_error(title, **options) | Shorthand for error variant |
| toast_warning(title, **options) | Shorthand for warning variant |
| toast_info(title, **options) | Shorthand for info variant |
