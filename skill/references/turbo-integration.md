# Turbo Integration

Patterns for using maquina_components with Turbo Drive, Frames, Streams, and Morphing.

---

## Turbo Decision Framework

| Scenario | Approach | Why |
|----------|----------|-----|
| Full page navigation | **Turbo Drive** (default) | Fast, no configuration needed |
| Inline editing | **Turbo Frame** | Scoped replacement, preserves page state |
| Modal/dialog content | **Turbo Frame** | Isolated, lazy-loaded |
| Real-time updates | **Turbo Stream** via broadcast | Push from server |
| Form submission feedback | **Turbo Stream** response | Multiple DOM updates |
| Full page refresh with state | **Morph** | Preserves scroll, form state |
| List item updates | **Turbo Stream** | Targeted prepend/append/replace |

---

## Turbo Drive (Default)

All navigation uses Turbo Drive automatically. Components work without changes.

### Disable for Specific Links

```erb
<%# External link %>
<%= link_to "External", "https://example.com", data: { turbo: false } %>

<%# File download %>
<%= link_to "Download", export_path, data: { turbo: false } %>
```

### Loading States

Add progress indicator:

```erb
<%# In layout %>
<div class="turbo-progress-bar"></div>
```

```css
.turbo-progress-bar {
  position: fixed;
  top: 0;
  left: 0;
  height: 3px;
  background: var(--primary);
  z-index: 9999;
  transition: width 300ms ease;
}
```

---

## Turbo Frames

### Basic Frame Pattern

```erb
<%# Wrap content that updates independently %>
<%= turbo_frame_tag "booking_#{@booking.id}" do %>
  <%= render "bookings/card", booking: @booking %>
<% end %>
```

### Inline Editing

```erb
<%# Show view %>
<%= turbo_frame_tag dom_id(@service) do %>
  <%= render "components/card" do %>
    <%= render "components/card/content" do %>
      <div class="flex justify-between">
        <div>
          <h3 class="font-medium"><%= @service.name %></h3>
          <p class="text-muted-foreground"><%= format_money(@service.price_cents) %></p>
        </div>
        <%= link_to edit_service_path(@service), 
            data: { component: "button", variant: "ghost", size: "icon-sm" } do %>
          <%= icon_for :edit, class: "size-4" %>
        <% end %>
      </div>
    <% end %>
  <% end %>
<% end %>

<%# Edit view (same frame ID) %>
<%= turbo_frame_tag dom_id(@service) do %>
  <%= render "components/card" do %>
    <%= render "components/card/content" do %>
      <%= form_with model: @service, data: { component: "form" } do |f| %>
        <div class="space-y-4">
          <div data-form-part="group">
            <%= f.label :name, data: { component: "label" } %>
            <%= f.text_field :name, data: { component: "input" }, autofocus: true %>
          </div>
          
          <div data-form-part="actions">
            <%= f.submit t(".save"), data: { component: "button", variant: "primary", size: "sm" } %>
            <%= link_to t(".cancel"), service_path(@service), 
                data: { component: "button", variant: "ghost", size: "sm" } %>
          </div>
        </div>
      <% end %>
    <% end %>
  <% end %>
<% end %>
```

### Lazy Loading Frames

```erb
<%# Load content when frame enters viewport %>
<%= turbo_frame_tag "activity_feed", src: activity_feed_path, loading: :lazy do %>
  <div class="animate-pulse space-y-2">
    <div class="h-4 bg-muted rounded w-3/4"></div>
    <div class="h-4 bg-muted rounded w-1/2"></div>
  </div>
<% end %>
```

### Modal with Frame

```erb
<%# Trigger %>
<%= link_to new_booking_path, 
    data: { turbo_frame: "modal" } do %>
  <%= icon_for :plus, class: "size-4 mr-1" %>New Booking
<% end %>

<%# Modal container in layout %>
<%= turbo_frame_tag "modal" %>

<%# Modal content (new.html.erb) %>
<%= turbo_frame_tag "modal" do %>
  <dialog data-controller="dialog" data-dialog-open-value="true" open
          class="fixed inset-0 z-50 bg-black/50 flex items-center justify-center">
    <div class="bg-card rounded-lg shadow-lg w-full max-w-md mx-4">
      <%= render "components/card" do %>
        <%= render "components/card/header" do %>
          <%= render "components/card/title", text: t(".title") %>
        <% end %>
        <%= render "components/card/content" do %>
          <%= render "bookings/form", booking: @booking %>
        <% end %>
      <% end %>
    </div>
  </dialog>
<% end %>
```

### Frame Navigation Targets

```erb
<%# Navigate frame from link outside it %>
<%= link_to "View Details", booking_path(@booking), 
    data: { turbo_frame: "booking_details" } %>

<%# Target frame updates %>
<%= turbo_frame_tag "booking_details" do %>
  <%# This content gets replaced %>
<% end %>
```

### Breaking Out of Frames

```erb
<%# Link breaks out to full page %>
<%= link_to "Full Page", booking_path(@booking), data: { turbo_frame: "_top" } %>

<%# Or in the frame response %>
<%= turbo_frame_tag dom_id(@booking), target: "_top" do %>
  <%# Clicking links here navigates full page %>
<% end %>
```

---

## Turbo Streams

### Controller Response

```ruby
# app/controllers/bookings_controller.rb
def create
  @booking = current_account.bookings.build(booking_params)
  
  if @booking.save
    respond_to do |format|
      format.turbo_stream
      format.html { redirect_to bookings_path, notice: t(".created") }
    end
  else
    render :new, status: :unprocessable_entity
  end
end
```

```erb
<%# app/views/bookings/create.turbo_stream.erb %>

<%# Add to list %>
<%= turbo_stream.prepend "bookings_list" do %>
  <%= render "bookings/row", booking: @booking %>
<% end %>

<%# Update counter %>
<%= turbo_stream.replace "bookings_count" do %>
  <%= render "bookings/count", count: current_account.bookings.today.count %>
<% end %>

<%# Show flash %>
<%= turbo_stream.replace "flash" do %>
  <%= render "components/alert", variant: :success do %>
    <%= render "components/alert/description", text: t(".created") %>
  <% end %>
<% end %>

<%# Clear form (if using frame) %>
<%= turbo_stream.replace "new_booking_form" do %>
  <%= turbo_frame_tag "new_booking_form" do %>
    <%= render "bookings/form", booking: Booking.new %>
  <% end %>
<% end %>
```

### Stream Actions Reference

| Action | Usage |
|--------|-------|
| `append` | Add to end of container |
| `prepend` | Add to beginning of container |
| `replace` | Replace entire element |
| `update` | Replace element's innerHTML |
| `remove` | Remove element |
| `before` | Insert before element |
| `after` | Insert after element |
| `morph` | Morph element (preserves state) |
| `refresh` | Trigger page refresh |

### Multiple Stream Updates

```erb
<%# Multiple updates in one response %>
<%= turbo_stream.prepend "bookings", @booking %>
<%= turbo_stream.replace "stats" do %>
  <%= render "dashboard/stats" %>
<% end %>
<%= turbo_stream.remove "empty_state" if @booking.account.bookings.count == 1 %>
```

### Inline Stream Helper

```ruby
# In controller
def complete
  @booking.complete!
  
  respond_to do |format|
    format.turbo_stream do
      render turbo_stream: [
        turbo_stream.replace(dom_id(@booking), partial: "bookings/row", locals: { booking: @booking }),
        turbo_stream.replace("flash", partial: "shared/flash", locals: { notice: t(".completed") })
      ]
    end
    format.html { redirect_to @booking }
  end
end
```

---

## Broadcasts (Real-time)

### Model Broadcasts

```ruby
# app/models/booking.rb
class Booking < ApplicationRecord
  after_create_commit -> { broadcast_prepend_to account, :bookings }
  after_update_commit -> { broadcast_replace_to account, :bookings }
  after_destroy_commit -> { broadcast_remove_to account, :bookings }
end
```

### Subscribe in View

```erb
<%# Subscribe to broadcasts %>
<%= turbo_stream_from current_account, :bookings %>

<%# Container for broadcasts %>
<div id="bookings">
  <%= render @bookings %>
</div>
```

### Custom Broadcast

```ruby
# In model or job
Turbo::StreamsChannel.broadcast_replace_to(
  [account, :dashboard],
  target: "stats",
  partial: "dashboard/stats",
  locals: { account: account }
)
```

### Broadcast with Morph

```ruby
# Preserve form state during broadcast
after_update_commit -> {
  broadcast_replace_to account, :bookings,
    target: dom_id(self),
    partial: "bookings/row",
    locals: { booking: self },
    method: :morph
}
```

---

## Morphing

### Page Refresh with Morph

```ruby
# Controller
def update
  if @booking.update(booking_params)
    redirect_to @booking, notice: t(".updated")
  else
    render :edit, status: :unprocessable_entity
  end
end
```

```erb
<%# Layout: Enable morphing %>
<html>
<head>
  <%= turbo_refreshes_with method: :morph, scroll: :preserve %>
</head>
```

### Exclude Elements from Morph

```erb
<%# Keep element unchanged during morph %>
<div data-turbo-permanent id="sidebar_state">
  <%# This won't be morphed %>
</div>

<%# Video/audio players %>
<video data-turbo-permanent id="player">...</video>
```

### Stream Morph Action

```erb
<%# Morph specific element %>
<%= turbo_stream.morph dom_id(@booking) do %>
  <%= render "bookings/card", booking: @booking %>
<% end %>
```

---

## Form Patterns with Turbo

### Standard Form Submission

```erb
<%= form_with model: @booking, data: { component: "form" } do |f| %>
  <%# Standard Turbo form - submits via Fetch, handles response %>
<% end %>
```

### Form with Frame Target

```erb
<%# Form updates specific frame %>
<%= form_with model: @booking, 
    data: { component: "form", turbo_frame: "booking_details" } do |f| %>
<% end %>
```

### Disable Turbo for Form

```erb
<%# Needed for file uploads in some cases %>
<%= form_with model: @booking, data: { turbo: false } do |f| %>
<% end %>
```

### Confirmation Dialog

```erb
<%= button_to booking_path(@booking), 
    method: :delete,
    data: { 
      component: "button", 
      variant: "destructive",
      turbo_confirm: t(".confirm_delete"),
      turbo_method: :delete
    } do %>
  <%= icon_for :trash, class: "size-4 mr-1" %><%= t(".delete") %>
<% end %>
```

### Submit Button Loading State

Turbo automatically adds `aria-busy="true"` to forms during submission. Use Tailwind's `group-aria-busy:` modifier for loading states without JavaScript.

```erb
<%# Add `group` class to form %>
<%= form_with model: @booking, class: "group", data: { component: "form" } do |f| %>
  <%# ... fields ... %>
  
  <%= f.button type: :submit, data: { component: "button", variant: "primary" } do %>
    <span class="group-aria-busy:hidden"><%= t(".save") %></span>
    <svg class="hidden group-aria-busy:block animate-spin size-5" 
         fill="none" viewBox="0 0 24 24">
      <circle class="opacity-25" cx="12" cy="12" r="10" 
              stroke="currentColor" stroke-width="4"></circle>
      <path class="opacity-75" fill="currentColor" 
            d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4zm2 5.291A7.962 7.962 0 014 12H0c0 3.042 1.135 5.824 3 7.938l3-2.647z"></path>
    </svg>
  <% end %>
<% end %>
```

For simple text-only loading:

```erb
<%= f.submit t(".save"), 
    data: { 
      component: "button", 
      variant: "primary",
      turbo_submits_with: t(".saving")
    } %>
```

### Form with Validation Errors

```ruby
# Controller
def create
  @booking = current_account.bookings.build(booking_params)
  
  if @booking.save
    respond_to do |format|
      format.turbo_stream
      format.html { redirect_to @booking }
    end
  else
    # Returns 422, Turbo replaces form with errors
    render :new, status: :unprocessable_entity
  end
end
```

---

## Component-Specific Patterns

### Card with Frame Content

```erb
<%= render "components/card" do %>
  <%= render "components/card/header" do %>
    <%= render "components/card/title", text: t(".recent_activity") %>
  <% end %>
  <%= render "components/card/content" do %>
    <%= turbo_frame_tag "activity_list", src: activities_path, loading: :lazy do %>
      <%# Loading skeleton %>
      <div class="space-y-3">
        <% 3.times do %>
          <div class="animate-pulse flex gap-3">
            <div class="h-8 w-8 bg-muted rounded-full"></div>
            <div class="flex-1 space-y-2">
              <div class="h-4 bg-muted rounded w-3/4"></div>
              <div class="h-3 bg-muted rounded w-1/2"></div>
            </div>
          </div>
        <% end %>
      </div>
    <% end %>
  <% end %>
<% end %>
```

### Table with Broadcast Updates

```erb
<%= turbo_stream_from current_account, :bookings %>

<%= render "components/table" do %>
  <%= render "components/table/header" do %>
    <%= render "bookings/table_header" %>
  <% end %>
  <%= render "components/table/body", id: "bookings_list" do %>
    <% @bookings.each do |booking| %>
      <%= render "bookings/table_row", booking: booking %>
    <% end %>
  <% end %>
<% end %>
```

### Dropdown with Turbo Actions

```erb
<%= render "components/dropdown_menu" do %>
  <%= render "components/dropdown_menu/trigger" do %>Actions<% end %>
  <%= render "components/dropdown_menu/content" do %>
    <%# Regular navigation %>
    <%= render "components/dropdown_menu/item", href: edit_booking_path(@booking) do %>
      <%= icon_for :edit, class: "size-4" %> Edit
    <% end %>
    
    <%# Turbo method %>
    <%= render "components/dropdown_menu/item", 
        href: complete_booking_path(@booking),
        method: :patch do %>
      <%= icon_for :check, class: "size-4" %> Complete
    <% end %>
    
    <%# Turbo confirm %>
    <%= render "components/dropdown_menu/item",
        href: booking_path(@booking),
        method: :delete,
        variant: :destructive,
        data: { turbo_confirm: t(".confirm_delete") } do %>
      <%= icon_for :trash, class: "size-4" %> Delete
    <% end %>
  <% end %>
<% end %>
```

### Alert Dismissal with Stream

```erb
<%# Show alert %>
<div id="flash">
  <%= render "components/alert", variant: :success do %>
    <%= render "components/alert/description", text: notice %>
    <button type="button" 
            data-action="click->dismiss#remove"
            class="absolute top-2 right-2">
      <%= icon_for :x, class: "size-4" %>
    </button>
  <% end %>
</div>

<%# Auto-dismiss after delay %>
<%= turbo_stream.remove "flash", delay: 5000 %>
```

### Empty State Handling

```erb
<%# Container with conditional empty state %>
<div id="bookings_container">
  <% if @bookings.any? %>
    <div id="bookings_list">
      <%= render @bookings %>
    </div>
  <% else %>
    <div id="empty_state">
      <%= render "bookings/empty_state" %>
    </div>
  <% end %>
</div>
```

```erb
<%# create.turbo_stream.erb %>
<%= turbo_stream.remove "empty_state" %>
<%= turbo_stream.prepend "bookings_list", @booking %>
```

```erb
<%# destroy.turbo_stream.erb %>
<%= turbo_stream.remove dom_id(@booking) %>
<% if current_account.bookings.none? %>
  <%= turbo_stream.update "bookings_container" do %>
    <div id="empty_state">
      <%= render "bookings/empty_state" %>
    </div>
  <% end %>
<% end %>
```

---

## Performance Tips

### Debounce Search Input

```erb
<%= form_with url: search_path, method: :get, 
    data: { controller: "debounce", turbo_frame: "results" } do |f| %>
  <%= f.search_field :q, 
      data: { 
        component: "input",
        action: "input->debounce#search"
      },
      placeholder: t(".search") %>
<% end %>
```

```javascript
// debounce_controller.js
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  search() {
    clearTimeout(this.timeout)
    this.timeout = setTimeout(() => {
      this.element.requestSubmit()
    }, 300)
  }
}
```

### Prefetch Links

```erb
<%# Prefetch on hover %>
<%= link_to booking_path(@booking), data: { turbo_prefetch: true } do %>
  View Details
<% end %>
```

### Preload Frames

```erb
<%# Preload important frames %>
<%= turbo_frame_tag "booking_form", src: new_booking_path, loading: :eager do %>
  <%# Loading state %>
<% end %>
```
