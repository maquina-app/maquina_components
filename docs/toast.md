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

### Info

```erb
<%%= render "components/toast",
  variant: :info,
  title: "Information",
  description: "New features are available." %>
```

### Persistent

A duration of 0 disables auto-dismiss; the toast stays until closed.

```erb
<%%= render "components/toast", title: "Upload complete", duration: 0 %>
```

### With Action

A button action (no `href`) is wired to `toast#handleAction`: clicking it
dispatches `toast:action` and dismisses the toast. A `data: { action: ... }`
you pass is added after it. A link action (`href`) just navigates.

```erb
<%%= render "components/toast",
  title: "Message archived",
  duration: 0,
  content: capture { %>
  <%%= render "components/toast/action", label: "Undo",
        data: { action: "click->inbox#undo" } %>
<%% } %>
```

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
| variant | Symbol | :default | :default, :success, :info, :warning, :error; :destructive is accepted as an alias of :error |
| title | String | nil | Toast title text |
| description | String | nil | Toast description text |
| icon | Symbol | nil | Built-in icon name; when nil it is picked by variant (:success → :circle_check, :info → :info, :warning → :triangle_alert, :error → :circle_x, :default → none) |
| duration | Integer | 5000 | Auto-dismiss time in ms; 0 disables auto-dismiss |
| dismissible | Boolean | true | Show close button |
| content | String | nil | HTML content via `capture` (e.g., action buttons), rendered after the description. The partial does not yield, so a block is ignored |
| css_classes | String | "" | Additional CSS classes |
| html_options | Hash | {} | Additional HTML attributes |

### Toast Title

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| text | String | nil | Title text |
| content | String | nil | HTML content via `capture`, or use block |
| css_classes | String | "" | Additional CSS classes |
| html_options | Hash | {} | Additional HTML attributes |

### Toast Description

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| text | String | nil | Description text |
| content | String | nil | HTML content via `capture`, or use block |
| css_classes | String | "" | Additional CSS classes |
| html_options | Hash | {} | Additional HTML attributes |

### Toaster

The toaster is the container that holds and positions toast notifications. Place it once in your layout. It always renders with `id="toaster"`, so Turbo Streams can append to it.

```erb
<%%= render "components/toaster", position: :bottom_right,
      content: toast_flash_messages %>
```

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| position | Symbol | :bottom_right | :top_left, :top_center, :top_right, :bottom_left, :bottom_center, :bottom_right |
| content | String | nil | Pre-rendered toasts (e.g., flash messages). The partial does not yield |
| css_classes | String | "" | Additional CSS classes |
| html_options | Hash | {} | Additional HTML attributes |

### Toast Action

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| label | String | required | Button/link text |
| href | String | nil | Link URL. When nil, renders a `<button type="button">` wired to `toast#handleAction` |
| method | Symbol | nil | Sets `data-turbo-method` on the element; only meaningful with href |
| css_classes | String | "" | Additional CSS classes |
| html_options | Hash | {} | Additional HTML attributes |

### Helper Methods

| Method | Description |
|--------|-------------|
| toast_flash_messages(exclude: []) | Renders all flash messages as toasts. notice/success → :success, alert/error → :error, warning/warn → :warning, info → :info, anything else → :default. Blank messages are skipped |
| toast(variant, title, description: nil, **options) | Renders a single toast; options go to the toast partial (icon, duration, dismissible, content, css_classes, HTML attributes) |
| toast_success(title, **options) | Shorthand for success variant |
| toast_error(title, **options) | Shorthand for error variant |
| toast_warning(title, **options) | Shorthand for warning variant |
| toast_info(title, **options) | Shorthand for info variant |

## JavaScript

### Toast Controller

Every toast carries `data-controller="toast"`. It moves `data-state` from
`entering` to `visible` about 200ms after connect, pauses the countdown
while the pointer is over the toast, and on dismiss sets `exiting` and
removes the element 150ms later.

| Value | Type | Default | Description |
|-------|------|---------|-------------|
| duration | Number | 5000 | Auto-dismiss time in ms; 0 or less disables it |
| dismissible | Boolean | true | Set from the dismissible local |

| Action | Description |
|--------|-------------|
| toast#dismiss | Plays the exit animation and removes the toast (wired to the close button) |
| toast#handleAction | Dispatches `toast:action` (bubbles, `detail: { toastId }`) and dismisses the toast. Wired on every action button: those built by the JavaScript API and those rendered by the action partial without `href` |

### Toaster Controller

The toaster carries `data-controller="toaster"` and, on connect, exposes a
global `window.Toast` API that appends toasts to the toaster.

| Value | Type | Default | Description |
|-------|------|---------|-------------|
| maxVisible | Number | 5 | Oldest toasts are dismissed beyond this count. Set with `data: { toaster_max_visible_value: 3 }` |

```javascript
const id = Toast.success("Message saved!")
Toast.error("Something went wrong", { description: "Please try again" })
Toast.info("New update available", { duration: 10000 })
Toast.warning("Session expiring soon")
Toast.destructive("Deleted")              // alias of error
Toast.show("Custom message", { variant: "default", dismissible: false })
Toast.show("Event created", {
  action: { label: "Undo", onClick: (event) => undo(event.detail.toastId) }
})
Toast.dismiss(id)
Toast.dismissAll()
```

| Option | Default | Description |
|--------|---------|-------------|
| description | "" | Secondary text |
| variant | "default" | default, success, info, warning, error (destructive maps to error; unknown values fall back to default) |
| duration | 5000 | Auto-dismiss time in ms, 0 to disable |
| dismissible | true | Show close button |
| action | null | `{ label, onClick }` renders an action button. Clicking it calls `onClick` (if given) with the `toast:action` event, fires `toast:action`, and dismisses the toast |

Each method except dismiss and dismissAll returns the new toast's id.
Listen for the action with `document.addEventListener("toast:action", (e) => e.detail.toastId)`.
