# Toast

> Non-intrusive notifications that appear temporarily to provide feedback.

---

## Quick Reference

### Parts

| Partial | Description |
|---------|-------------|
| `components/toaster` | Fixed container that holds all toasts |
| `components/toast` | Individual notification with auto-dismiss |
| `components/toast/title` | Toast title text |
| `components/toast/description` | Optional description text |
| `components/toast/action` | Optional action button/link |

### Helper Methods

| Method | Description |
|--------|-------------|
| `toast_flash_messages` | Render all flash messages as toasts |
| `toast` | Render a single toast with variant |
| `toast_success` | Convenience for success variant |
| `toast_error` | Convenience for error variant |
| `toast_warning` | Convenience for warning variant |
| `toast_info` | Convenience for info variant |

### JavaScript API

| Method | Description |
|--------|-------------|
| `Toast.show(title, options)` | Show a default toast |
| `Toast.success(title, options)` | Show a success toast |
| `Toast.error(title, options)` | Show an error toast |
| `Toast.warning(title, options)` | Show a warning toast |
| `Toast.info(title, options)` | Show an info toast |
| `Toast.dismiss(toastId)` | Dismiss a specific toast |
| `Toast.dismissAll()` | Dismiss all toasts |

### Parameters

#### `_toaster.html.erb`

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `position` | Symbol | `:bottom_right` | Position on screen |
| `css_classes` | String | `""` | Additional CSS classes |
| `**html_options` | Hash | `{}` | HTML attributes |

**Position Values:**
- `:top_left`, `:top_center`, `:top_right`
- `:bottom_left`, `:bottom_center`, `:bottom_right`

#### `_toast.html.erb`

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `variant` | Symbol | `:default` | Toast variant |
| `title` | String | `nil` | Toast title |
| `description` | String | `nil` | Optional description |
| `duration` | Integer | `5000` | Auto-dismiss in ms (0 = no auto-dismiss) |
| `dismissible` | Boolean | `true` | Show close button |
| `css_classes` | String | `""` | Additional CSS classes |
| `**html_options` | Hash | `{}` | HTML attributes |

**Variant Values:**
- `:default` - Neutral style
- `:success` - Green, with check icon
- `:info` - Blue, with info icon
- `:warning` - Yellow/amber, with alert icon
- `:error` - Red, with X icon

#### `toast/_action.html.erb`

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `label` | String | Required | Button/link text |
| `href` | String | `nil` | Link URL (renders `<a>` if present) |
| `method` | Symbol | `nil` | Turbo method (:delete, :patch, etc.) |
| `css_classes` | String | `""` | Additional CSS classes |
| `**html_options` | Hash | `{}` | HTML attributes |

### Data Attributes

**Component Identifiers**

| Attribute | Element | Description |
|-----------|---------|-------------|
| `data-component="toaster"` | Container | Main container identifier |
| `data-component="toast"` | Toast | Individual toast identifier |
| `data-variant="success"` | Toast | Toast variant |
| `data-position="bottom-right"` | Toaster | Container position |

**Stimulus Controllers**

| Attribute | Description |
|-----------|-------------|
| `data-controller="toaster"` | Container controller (JS API) |
| `data-controller="toast"` | Individual toast controller |

**State Attributes**

| Attribute | Description |
|-----------|-------------|
| `data-state="entering"` | Toast is animating in |
| `data-state="visible"` | Toast is visible |
| `data-state="exiting"` | Toast is animating out |

---

## Setup

Add the toaster container to your application layout:

```erb
<%# app/views/layouts/application.html.erb %>
<!DOCTYPE html>
<html>
  <head>...</head>
  <body>
    <%%= yield %>

    <%# Add toaster at the end of body %>
    <%%= render "components/toaster", position: :bottom_right %>
  </body>
</html>
```

---

## Basic Usage

### Flash Messages (Server-Side)

The most common use case is rendering Rails flash messages:

```erb
<%# In your layout or view %>
<%%= render "components/toaster", position: :bottom_right do %>
  <%%= toast_flash_messages %>
<%% end %>
```

In your controller:

```ruby
class UsersController < ApplicationController
  def update
    if @user.update(user_params)
      flash[:success] = "Profile updated successfully!"
      redirect_to @user
    else
      flash[:error] = "Unable to save changes."
      render :edit, status: :unprocessable_entity
    end
  end
end
```

### Single Toast (Server-Side)

```erb
<%%= toast :success, "Profile updated!" %>

<%%= toast :error, "Save failed", description: "Please check your connection." %>

<%%= toast :info, "New version available", duration: 10000 %>
```

### Toast with Action

```erb
<%%= toast :info, "New version available" do %>
  <%%= render "components/toast/action", label: "Refresh", href: root_path %>
<%% end %>
```

### JavaScript API

```javascript
// Basic toasts
Toast.success("Profile saved!")
Toast.error("Something went wrong")
Toast.warning("Session expiring soon")
Toast.info("New notification")

// With options
Toast.success("File uploaded", {
  description: "Your file has been processed.",
  duration: 8000
})

// With action
Toast.info("New comment", {
  description: "John replied to your post.",
  action: { label: "View" }
})

// No auto-dismiss
Toast.warning("Important notice", { duration: 0 })

// Dismiss programmatically
const toastId = Toast.success("Saved!")
Toast.dismiss(toastId)

// Dismiss all
Toast.dismissAll()
```

---

## Examples

### Toaster Positions

```erb
<%# Top right %>
<%%= render "components/toaster", position: :top_right do %>
  <%%= toast_flash_messages %>
<%% end %>

<%# Bottom center %>
<%%= render "components/toaster", position: :bottom_center do %>
  <%%= toast_flash_messages %>
<%% end %>

<%# Top left %>
<%%= render "components/toaster", position: :top_left do %>
  <%%= toast_flash_messages %>
<%% end %>
```

### All Variants

```erb
<%%= toast :default, "Default notification" %>
<%%= toast :success, "Success!", description: "Your changes have been saved." %>
<%%= toast :info, "Did you know?", description: "You can customize your dashboard." %>
<%%= toast :warning, "Warning", description: "Your session will expire in 5 minutes." %>
<%%= toast :error, "Error", description: "Unable to connect to server." %>
```

### With Custom Duration

```erb
<%# Quick notification (3 seconds) %>
<%%= toast :success, "Saved!", duration: 3000 %>

<%# Longer notification (10 seconds) %>
<%%= toast :info, "Please read this carefully", duration: 10000 %>

<%# Persistent (no auto-dismiss) %>
<%%= toast :warning, "Action required", duration: 0 %>
```

### Non-Dismissible

```erb
<%%= toast :info, "Processing...", dismissible: false, duration: 0 %>
```

### Action Buttons

```erb
<%# Link action %>
<%%= toast :info, "New message" do %>
  <%%= render "components/toast/action", label: "View", href: messages_path %>
<%% end %>

<%# Button action with Turbo %>
<%%= toast :warning, "Item pending deletion" do %>
  <%%= render "components/toast/action",
              label: "Undo",
              href: restore_item_path(@item),
              method: :patch %>
<%% end %>

<%# Custom action with data attributes %>
<%%= toast :success, "Form submitted" do %>
  <%%= render "components/toast/action",
              label: "View Results",
              href: results_path,
              data: { turbo_frame: "results" } %>
<%% end %>
```

---

## Real-World Patterns

### Form Submission Feedback

```ruby
# app/controllers/posts_controller.rb
class PostsController < ApplicationController
  def create
    @post = Post.new(post_params)

    if @post.save
      flash[:success] = "Post created successfully!"
      redirect_to @post
    else
      flash.now[:error] = "Unable to create post. Please fix the errors below."
      render :new, status: :unprocessable_entity
    end
  end
end
```

### Turbo Stream Toasts

For Turbo Stream responses, append toasts dynamically:

```erb
<%# app/views/posts/create.turbo_stream.erb %>
<%%= turbo_stream.append "toaster" do %>
  <%%= toast :success, "Post created!", description: "Your post is now live." %>
<%% end %>
```

### JavaScript Event Handling

```erb
<div data-controller="notifications">
  <%%= form_with model: @user,
                 data: { action: "turbo:submit-end->notifications#showResult" } do |f| %>
    <%# form fields %>
  <%% end %>
</div>
```

```javascript
// notifications_controller.js
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  showResult(event) {
    if (event.detail.success) {
      Toast.success("Changes saved!")
    } else {
      Toast.error("Unable to save", {
        description: "Please check the form for errors."
      })
    }
  }
}
```

### Async Operation Feedback

```javascript
async function uploadFile(file) {
  const loadingId = Toast.info("Uploading...", {
    description: file.name,
    duration: 0,
    dismissible: false
  })

  try {
    await performUpload(file)
    Toast.dismiss(loadingId)
    Toast.success("Upload complete!", {
      description: `${file.name} has been uploaded.`
    })
  } catch (error) {
    Toast.dismiss(loadingId)
    Toast.error("Upload failed", {
      description: error.message
    })
  }
}
```

### Flash Type Mapping

The helper automatically maps Rails flash types to toast variants:

| Flash Type | Toast Variant |
|------------|---------------|
| `:notice` | `:success` |
| `:success` | `:success` |
| `:alert` | `:error` |
| `:error` | `:error` |
| `:warning` | `:warning` |
| `:warn` | `:warning` |
| `:info` | `:info` |

### Excluding Flash Types

```erb
<%# Don't show 'notice' as toast (maybe it's displayed elsewhere) %>
<%%= toast_flash_messages exclude: [:notice] %>
```

---

## Behavior

### Auto-Dismiss Timer

- Default duration: 5000ms (5 seconds)
- Timer pauses on hover
- Timer resumes when mouse leaves
- Set `duration: 0` to disable auto-dismiss

### Animation

- Enters from the edge based on position
- Fades out when dismissed
- Smooth transitions for position changes

### Stacking

- New toasts stack based on position (bottom positions stack upward)
- Maximum 5 visible toasts by default
- Oldest toasts are dismissed when limit is reached

---

## Keyboard Interaction

| Key | Action |
|-----|--------|
| `Tab` | Move focus between toast elements |
| `Escape` | Dismiss focused toast |
| `Enter` / `Space` | Activate action button |

---

## Theme Variables

The toast component uses these CSS variables:

```css
/* Base */
var(--popover)
var(--popover-foreground)
var(--border)
var(--foreground)
var(--muted-foreground)

/* Success variant */
var(--success)
var(--success-foreground)

/* Info variant */
var(--info)              /* Falls back to --primary */
var(--info-foreground)   /* Falls back to --primary-foreground */

/* Warning variant */
var(--warning)
var(--warning-foreground)

/* Error variant */
var(--destructive)
var(--destructive-foreground)

/* Interactive */
var(--accent)
var(--accent-foreground)
var(--ring)
```

---

## Accessibility

- Container has `role="region"` with `aria-label="Notifications"`
- Container has `aria-live="polite"` for screen reader announcements
- Individual toasts have `role="alert"`
- Close button has accessible label
- Focus management for keyboard users
- Pause on hover prevents dismissing while reading
- Action buttons are keyboard accessible

---

## File Structure

```
app/views/components/
├── _toaster.html.erb
├── _toast.html.erb
└── toast/
    ├── _title.html.erb
    ├── _description.html.erb
    └── _action.html.erb

app/assets/stylesheets/toast.css
app/javascript/controllers/toaster_controller.js
app/javascript/controllers/toast_controller.js
app/helpers/maquina_components/toast_helper.rb
docs/toast.md
```

---

## Differences from Alert

| Feature | Toast | Alert |
|---------|-------|-------|
| **Positioning** | Fixed, overlays content | Inline, part of flow |
| **Duration** | Temporary, auto-dismiss | Persistent |
| **Stacking** | Multiple can stack | Single at a time |
| **Use Case** | Feedback, notifications | Important messages, errors |
| **JavaScript** | Full API for dynamic creation | Static only |
