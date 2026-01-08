# Form Patterns

Building forms with maquina_components, validation, error handling, and common form patterns.

---

## Form Fundamentals

### Basic Form Structure

```erb
<%= form_with model: @user, data: { component: "form" } do |f| %>
  <fieldset data-component="fieldset">
    <legend data-component="legend"><%= t(".account_info") %></legend>
    
    <div data-form-part="group">
      <%= f.label :name, data: { component: "label", required: true } %>
      <%= f.text_field :name, data: { component: "input" }, 
          placeholder: t(".name_placeholder") %>
      <% if @user.errors[:name].any? %>
        <p data-form-part="error"><%= @user.errors[:name].first %></p>
      <% end %>
    </div>
    
    <div data-form-part="group">
      <%= f.label :email, data: { component: "label", required: true } %>
      <%= f.email_field :email, data: { component: "input" },
          placeholder: t(".email_placeholder") %>
      <p data-form-part="description"><%= t(".email_hint") %></p>
      <% if @user.errors[:email].any? %>
        <p data-form-part="error"><%= @user.errors[:email].first %></p>
      <% end %>
    </div>
  </fieldset>
  
  <div data-form-part="actions">
    <%= f.submit t(".save"), data: { component: "button", variant: "primary" } %>
    <%= link_to t(".cancel"), users_path, data: { component: "button", variant: "outline" } %>
  </div>
<% end %>
```

### Field Group Pattern

Every form field should be wrapped in a group:

```erb
<div data-form-part="group">
  <%= f.label :field_name, data: { component: "label" } %>
  <%= f.text_field :field_name, data: { component: "input" } %>
  <p data-form-part="description">Optional help text</p>
  <% if @model.errors[:field_name].any? %>
    <p data-form-part="error"><%= @model.errors[:field_name].first %></p>
  <% end %>
</div>
```

### Required Fields

```erb
<%# Add required indicator to label %>
<%= f.label :name, data: { component: "label", required: true } %>

<%# Also add HTML required attribute for browser validation %>
<%= f.text_field :name, data: { component: "input" }, required: true %>
```

---

## Input Best Practices

**Every input should include appropriate HTML5 attributes** for validation, accessibility, and optimal mobile experience.

### Required Attributes Checklist

| Attribute | When to Use | Example |
|-----------|-------------|---------|
| `type` | Always — use correct type for data | `email`, `tel`, `url`, `number`, `date` |
| `required` | Mandatory fields | `required: true` |
| `maxlength` | Text inputs — prevents overflow | `maxlength: 100` |
| `minlength` | When minimum length matters | `minlength: 2` |
| `pattern` | Custom format validation | `pattern: "[A-Z]{2}[0-9]{4}"` |
| `min` / `max` | Number/date ranges | `min: 0, max: 100` |
| `step` | Number increments | `step: 0.01` for money |
| `inputmode` | Mobile keyboard optimization | `inputmode: "numeric"` |
| `autocomplete` | Autofill hints | `autocomplete: "email"` |

### Complete Input Examples

```erb
<%# Name - text with sensible limits %>
<%= f.text_field :name,
    data: { component: "input" },
    required: true,
    minlength: 2,
    maxlength: 100,
    autocomplete: "name" %>

<%# Email - correct type, maxlength per RFC %>
<%= f.email_field :email,
    data: { component: "input" },
    required: true,
    maxlength: 254,
    autocomplete: "email" %>

<%# Phone - pattern for flexibility, tel keyboard %>
<%= f.phone_field :phone,
    data: { component: "input" },
    required: true,
    maxlength: 20,
    pattern: "[+]?[0-9\\s\\-()]+",
    inputmode: "tel",
    autocomplete: "tel" %>

<%# Money - number with cents precision %>
<%= f.number_field :price,
    data: { component: "input" },
    required: true,
    min: 0,
    max: 999999.99,
    step: 0.01,
    inputmode: "decimal" %>

<%# URL - correct type, sensible max %>
<%= f.url_field :website,
    data: { component: "input" },
    maxlength: 2000,
    autocomplete: "url",
    placeholder: "https://" %>

<%# Postal code - pattern for format %>
<%= f.text_field :postal_code,
    data: { component: "input" },
    required: true,
    maxlength: 10,
    pattern: "[0-9]{5}",
    inputmode: "numeric",
    autocomplete: "postal-code" %>

<%# Date - with range limits %>
<%= f.date_field :birthdate,
    data: { component: "input" },
    required: true,
    min: 100.years.ago.to_date,
    max: Date.current %>

<%# Password - minimum length for security %>
<%= f.password_field :password,
    data: { component: "input" },
    required: true,
    minlength: 8,
    maxlength: 128,
    autocomplete: "new-password" %>
```

### Common Maxlength Values

| Field Type | Recommended Maxlength | Rationale |
|------------|----------------------|-----------|
| Name | 100 | Handles long names |
| Email | 254 | RFC 5321 limit |
| Phone | 20 | E.164 with formatting |
| URL | 2000 | Browser URL limits |
| Short text | 255 | Standard varchar |
| Description | 1000-5000 | Reasonable for textarea |
| Slug/username | 50 | URL-friendly |
| Password | 128 | Security + practicality |

### Why These Attributes Matter

1. **`type`** — Triggers correct mobile keyboard, enables browser validation
2. **`required`** — Prevents empty submissions before hitting server
3. **`maxlength`** — Prevents database overflow, guides user expectations
4. **`pattern`** — Custom validation without JavaScript
5. **`inputmode`** — Shows optimal keyboard on mobile (numeric, tel, email)
6. **`autocomplete`** — Enables browser autofill, improves UX

---

## Form Field Components

### Text Inputs

```erb
<%# Standard text field %>
<%= f.text_field :name, data: { component: "input" } %>

<%# With placeholder %>
<%= f.text_field :name, data: { component: "input" }, placeholder: t(".placeholder") %>

<%# Email %>
<%= f.email_field :email, data: { component: "input" } %>

<%# Password %>
<%= f.password_field :password, data: { component: "input" } %>

<%# Phone (with pattern for LATAM) %>
<%= f.phone_field :phone, data: { component: "input" }, 
    pattern: "[+]?[0-9]{10,15}",
    placeholder: "+52 55 1234 5678" %>

<%# Number %>
<%= f.number_field :quantity, data: { component: "input" }, min: 0, step: 1 %>

<%# URL %>
<%= f.url_field :website, data: { component: "input" }, placeholder: "https://" %>
```

### Input Sizes

```erb
<%# Small - for compact UIs %>
<%= f.text_field :code, data: { component: "input", size: "sm" } %>

<%# Default %>
<%= f.text_field :name, data: { component: "input" } %>

<%# Large - for prominent inputs %>
<%= f.text_field :search, data: { component: "input", size: "lg" } %>
```

### Textarea

```erb
<%= f.text_area :description, data: { component: "textarea" }, rows: 4 %>

<%# With character count (needs Stimulus controller) %>
<div data-controller="character-count" data-form-part="group">
  <%= f.label :bio, data: { component: "label" } %>
  <%= f.text_area :bio, data: { 
        component: "textarea",
        character_count_target: "input",
        action: "input->character-count#update"
      }, 
      rows: 4, 
      maxlength: 500 %>
  <p data-form-part="description">
    <span data-character-count-target="count">0</span>/500
  </p>
</div>
```

### Select

```erb
<%# Basic select %>
<%= f.select :status, status_options, {}, data: { component: "select" } %>

<%# With blank option %>
<%= f.select :category_id, 
    category_options, 
    { include_blank: t(".select_category") }, 
    data: { component: "select" } %>

<%# Collection select %>
<%= f.collection_select :service_id, @services, :id, :name,
    { include_blank: t(".select_service") },
    data: { component: "select" } %>

<%# Grouped options %>
<%= f.grouped_collection_select :location_id, 
    @regions, :locations, :name, :id, :name,
    { include_blank: t(".select_location") },
    data: { component: "select" } %>
```

### Checkbox

```erb
<%# Single checkbox with label %>
<div data-form-part="group" data-layout="inline">
  <%= f.check_box :active, data: { component: "checkbox" } %>
  <%= f.label :active, t(".active_label"), data: { component: "label" } %>
</div>

<%# Checkbox with description %>
<div data-form-part="group">
  <div data-layout="inline" class="flex items-start gap-2">
    <%= f.check_box :terms, data: { component: "checkbox" }, class: "mt-1" %>
    <div>
      <%= f.label :terms, t(".terms_label"), data: { component: "label" } %>
      <p data-form-part="description"><%= t(".terms_hint") %></p>
    </div>
  </div>
</div>
```

### Checkbox Group

```erb
<div data-form-part="group">
  <%= f.label :notification_types, t(".notification_types"), data: { component: "label" } %>
  
  <div class="space-y-2 mt-2">
    <% Notification::TYPES.each do |type| %>
      <div data-layout="inline" class="flex items-center gap-2">
        <%= check_box_tag "user[notification_types][]", type, 
            @user.notification_types.include?(type),
            data: { component: "checkbox" }, 
            id: "notification_#{type}" %>
        <%= label_tag "notification_#{type}", t(".notification_types.#{type}"), 
            data: { component: "label" } %>
      </div>
    <% end %>
  </div>
</div>
```

### Radio Buttons

```erb
<div data-form-part="group">
  <%= f.label :plan, t(".select_plan"), data: { component: "label" } %>
  
  <div class="space-y-2 mt-2">
    <% Plan.all.each do |plan| %>
      <div data-layout="inline" class="flex items-center gap-2">
        <%= f.radio_button :plan_id, plan.id, data: { component: "radio" } %>
        <%= f.label "plan_id_#{plan.id}", data: { component: "label" } do %>
          <span class="font-medium"><%= plan.name %></span>
          <span class="text-muted-foreground">- <%= format_money(plan.price_cents) %>/mes</span>
        <% end %>
      </div>
    <% end %>
  </div>
</div>
```

### Radio Card Group

More visual radio selection:

```erb
<div data-form-part="group">
  <%= f.label :plan, t(".select_plan"), data: { component: "label" } %>
  
  <div class="grid gap-4 md:grid-cols-3 mt-2">
    <% Plan.all.each do |plan| %>
      <label class="relative cursor-pointer">
        <%= f.radio_button :plan_id, plan.id, class: "peer sr-only" %>
        <div class="rounded-lg border-2 border-muted p-4 
                    peer-checked:border-primary peer-checked:bg-primary/5
                    hover:border-primary/50 transition-colors">
          <div class="font-semibold"><%= plan.name %></div>
          <div class="text-2xl font-bold mt-2">
            <%= format_money(plan.price_cents) %>
            <span class="text-sm font-normal text-muted-foreground">/mes</span>
          </div>
          <ul class="mt-4 space-y-2 text-sm">
            <% plan.features.each do |feature| %>
              <li class="flex items-center gap-2">
                <%= icon_for :check, class: "size-4 text-primary" %>
                <%= feature %>
              </li>
            <% end %>
          </ul>
        </div>
      </label>
    <% end %>
  </div>
</div>
```

### Switch (Toggle)

```erb
<div data-form-part="group" data-layout="inline">
  <%= f.check_box :email_notifications, data: { component: "switch" } %>
  <%= f.label :email_notifications, data: { component: "label" } do %>
    <span class="font-medium"><%= t(".email_notifications") %></span>
    <span class="block text-sm text-muted-foreground"><%= t(".email_notifications_hint") %></span>
  <% end %>
</div>
```

### File Upload

```erb
<div data-form-part="group">
  <%= f.label :avatar, data: { component: "label" } %>
  <%= f.file_field :avatar, data: { component: "input" }, 
      accept: "image/png,image/jpeg,image/webp" %>
  <p data-form-part="description"><%= t(".avatar_hint") %></p>
</div>

<%# With preview (needs Stimulus controller) %>
<div data-form-part="group" data-controller="file-preview">
  <%= f.label :avatar, data: { component: "label" } %>
  
  <div class="flex items-center gap-4">
    <div class="h-16 w-16 rounded-full bg-muted overflow-hidden">
      <% if @user.avatar.attached? %>
        <%= image_tag @user.avatar, class: "h-full w-full object-cover", 
            data: { file_preview_target: "preview" } %>
      <% else %>
        <div data-file-preview-target="preview" 
             class="h-full w-full flex items-center justify-center">
          <%= icon_for :user, class: "size-8 text-muted-foreground" %>
        </div>
      <% end %>
    </div>
    
    <%= f.file_field :avatar, data: { 
          component: "input",
          file_preview_target: "input",
          action: "change->file-preview#update"
        }, 
        accept: "image/*",
        class: "max-w-xs" %>
  </div>
</div>
```

### Input with Prefix/Suffix

```erb
<%# Price input %>
<div data-form-part="group">
  <%= f.label :price, data: { component: "label" } %>
  <div data-component="input-group">
    <span data-input-group-part="prefix">$</span>
    <%= f.number_field :price, data: { component: "input" }, 
        step: "0.01", min: 0, placeholder: "0.00" %>
  </div>
</div>

<%# Domain input %>
<div data-form-part="group">
  <%= f.label :subdomain, data: { component: "label" } %>
  <div data-component="input-group">
    <%= f.text_field :subdomain, data: { component: "input" }, 
        placeholder: "mi-negocio" %>
    <span data-input-group-part="suffix">.haab.mx</span>
  </div>
</div>

<%# Search with icon %>
<div data-form-part="group">
  <div data-component="input-group">
    <span data-input-group-part="prefix">
      <%= icon_for :search, class: "size-4 text-muted-foreground" %>
    </span>
    <%= f.search_field :query, data: { component: "input" }, 
        placeholder: t(".search_placeholder") %>
  </div>
</div>
```

---

## Validation & Error Handling

### ✅ Recommended: Inline Errors + Flash

**Always prefer inline field errors with a brief flash notification** over an alert containing a list of all errors. This approach is more accessible and helps users fix problems field by field.

```erb
<%# Controller sets flash on validation failure %>
<%# flash.now[:alert] = t("errors.please_fix") %>

<%= form_with model: @user, data: { component: "form" } do |f| %>
  <div data-form-part="group">
    <%= f.label :name, data: { component: "label", required: true } %>
    <%= f.text_field :name, 
        data: { component: "input" },
        required: true,
        minlength: 2,
        maxlength: 100,
        aria: { 
          invalid: @user.errors[:name].any?,
          describedby: ("name-error" if @user.errors[:name].any?)
        } %>
    <% if @user.errors[:name].any? %>
      <p data-form-part="error" id="name-error"><%= @user.errors[:name].first %></p>
    <% end %>
  </div>
  
  <div data-form-part="group">
    <%= f.label :email, data: { component: "label", required: true } %>
    <%= f.email_field :email, 
        data: { component: "input" },
        required: true,
        maxlength: 254,
        aria: { 
          invalid: @user.errors[:email].any?,
          describedby: ("email-error" if @user.errors[:email].any?)
        } %>
    <% if @user.errors[:email].any? %>
      <p data-form-part="error" id="email-error"><%= @user.errors[:email].first %></p>
    <% end %>
  </div>
  
  <div data-form-part="actions">
    <%= f.submit t(".save"), data: { component: "button", variant: "primary" } %>
  </div>
<% end %>
```

### ❌ Avoid: Alert with Error List

```erb
<%# Don't do this - users have to match errors to fields %>
<% if @user.errors.any? %>
  <%= render "components/alert", variant: :destructive do %>
    <%= render "components/alert/title", text: t("errors.validation_failed") %>
    <%= render "components/alert/description" do %>
      <ul class="list-disc pl-4">
        <% @user.errors.full_messages.each do |message| %>
          <li><%= message %></li>
        <% end %>
      </ul>
    <% end %>
  <% end %>
<% end %>
```

### Error Display Pattern

```erb
<%# In the form field group %>
<div data-form-part="group">
  <%= f.label :email, data: { component: "label" } %>
  <%= f.email_field :email, data: { component: "input" }, 
      aria: { invalid: @user.errors[:email].any?, describedby: "email-error" } %>
  <% if @user.errors[:email].any? %>
    <p data-form-part="error" id="email-error"><%= @user.errors[:email].first %></p>
  <% end %>
</div>
```

### Form-Level Error Alert

```erb
<%= form_with model: @user, data: { component: "form" } do |f| %>
  <% if @user.errors.any? %>
    <%= render "components/alert", variant: :destructive do %>
      <%= render "components/alert/title", text: t("errors.form_errors") %>
      <%= render "components/alert/description" do %>
        <%= t("errors.fix_errors", count: @user.errors.count) %>
      <% end %>
    <% end %>
  <% end %>
  
  <%# Form fields... %>
<% end %>
```

### Field Error Helper

Create a helper to reduce repetition:

```ruby
# app/helpers/form_helper.rb
module FormHelper
  def form_field(form, field, options = {}, &block)
    model = form.object
    has_error = model.errors[field].any?
    
    content_tag :div, data: { form_part: "group" } do
      concat form.label(field, data: { component: "label", required: options[:required] })
      concat capture(&block)
      
      if options[:description]
        concat content_tag(:p, options[:description], data: { form_part: "description" })
      end
      
      if has_error
        concat content_tag(:p, model.errors[field].first, data: { form_part: "error" })
      end
    end
  end
end
```

```erb
<%# Usage %>
<%= form_field f, :email, required: true, description: t(".email_hint") do %>
  <%= f.email_field :email, data: { component: "input" } %>
<% end %>
```

### Client-Side Validation

Use HTML5 validation attributes:

```erb
<%= f.text_field :name, data: { component: "input" },
    required: true,
    minlength: 2,
    maxlength: 100 %>

<%= f.email_field :email, data: { component: "input" },
    required: true,
    pattern: "[a-z0-9._%+-]+@[a-z0-9.-]+\\.[a-z]{2,}$" %>

<%= f.number_field :quantity, data: { component: "input" },
    required: true,
    min: 1,
    max: 100 %>
```

---

## Form Actions

### Standard Actions

```erb
<div data-form-part="actions">
  <%= f.submit t(".save"), data: { component: "button", variant: "primary" } %>
  <%= link_to t(".cancel"), back_path, data: { component: "button", variant: "outline" } %>
</div>
```

### Actions Aligned Right

```erb
<div data-form-part="actions" data-align="end">
  <%= f.submit t(".save"), data: { component: "button", variant: "primary" } %>
</div>
```

### Actions with Space Between

```erb
<div data-form-part="actions" data-align="between">
  <%= link_to t(".back"), previous_path, data: { component: "button", variant: "ghost" } %>
  
  <div class="flex gap-2">
    <%= f.submit t(".save_draft"), 
        data: { component: "button", variant: "outline" },
        name: "draft", value: "1" %>
    <%= f.submit t(".publish"), 
        data: { component: "button", variant: "primary" } %>
  </div>
</div>
```

---

## Loading States

Turbo automatically adds `aria-busy="true"` to forms during submission. Use this with Tailwind's `group-aria-busy:` modifier for loading states — no JavaScript required.

### ✅ Recommended: aria-busy Spinner Pattern

```erb
<%# Add `group` class to form to enable group-aria-busy targeting %>
<%= form_with model: @booking, class: "group", data: { component: "form" } do |f| %>
  <%# ... form fields ... %>
  
  <div data-form-part="actions">
    <%= f.button type: :submit, data: { component: "button", variant: "primary" } do %>
      <%# Text shown normally, hidden when busy %>
      <span class="group-aria-busy:hidden"><%= t(".save") %></span>
      
      <%# Spinner hidden normally, shown when busy %>
      <svg class="hidden group-aria-busy:block animate-spin size-5" 
           fill="none" viewBox="0 0 24 24">
        <circle class="opacity-25" cx="12" cy="12" r="10" 
                stroke="currentColor" stroke-width="4"></circle>
        <path class="opacity-75" fill="currentColor" 
              d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4zm2 5.291A7.962 7.962 0 014 12H0c0 3.042 1.135 5.824 3 7.938l3-2.647z"></path>
      </svg>
    <% end %>
  </div>
<% end %>
```

### How It Works

1. **Turbo sets `aria-busy="true"`** on the form element during submission
2. **`group` class** on form enables Tailwind's group modifier targeting
3. **`group-aria-busy:hidden`** hides text when form is submitting
4. **`group-aria-busy:block`** shows spinner when form is submitting
5. **Turbo removes `aria-busy`** when navigation completes, reverting styles

### Button with Icon and Spinner

```erb
<%= f.button type: :submit, data: { component: "button", variant: "primary" } do %>
  <span class="group-aria-busy:hidden flex items-center gap-2">
    <%= icon_for :save, class: "size-4" %>
    <%= t(".save") %>
  </span>
  <span class="hidden group-aria-busy:flex items-center gap-2">
    <svg class="animate-spin size-4" fill="none" viewBox="0 0 24 24">
      <circle class="opacity-25" cx="12" cy="12" r="10" 
              stroke="currentColor" stroke-width="4"></circle>
      <path class="opacity-75" fill="currentColor" 
            d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4zm2 5.291A7.962 7.962 0 014 12H0c0 3.042 1.135 5.824 3 7.938l3-2.647z"></path>
    </svg>
    <%= t(".saving") %>
  </span>
<% end %>
```

### Disable Form Elements During Submission

```erb
<%= form_with model: @booking, class: "group", data: { component: "form" } do |f| %>
  <div data-form-part="group">
    <%= f.label :name, data: { component: "label" } %>
    <%# Input disabled while submitting %>
    <%= f.text_field :name, 
        data: { component: "input" },
        class: "group-aria-busy:opacity-50 group-aria-busy:pointer-events-none" %>
  </div>
  
  <div data-form-part="actions">
    <%# Cancel link disabled while submitting %>
    <%= link_to t(".cancel"), back_path, 
        data: { component: "button", variant: "outline" },
        class: "group-aria-busy:opacity-50 group-aria-busy:pointer-events-none" %>
    
    <%= f.button type: :submit, 
        data: { component: "button", variant: "primary" },
        class: "group-aria-busy:opacity-75" do %>
      <span class="group-aria-busy:hidden"><%= t(".save") %></span>
      <span class="hidden group-aria-busy:inline"><%= t(".saving") %></span>
    <% end %>
  </div>
<% end %>
```

### Alternative: data-turbo-submits-with

For simple text replacement without a spinner:

```erb
<%= f.submit t(".save"), 
    data: { 
      component: "button", 
      variant: "primary",
      turbo_submits_with: t(".saving")
    } %>
```

**When to use each:**
- **`aria-busy` pattern** — When you need spinners, icons, or complex loading states
- **`data-turbo-submits-with`** — For simple text replacement ("Save" → "Saving...")

---

## Common Form Patterns

### Login Form

```erb
<%= form_with url: session_path, data: { component: "form" } do |f| %>
  <div data-form-part="group">
    <%= f.label :phone, t(".phone"), data: { component: "label" } %>
    <%= f.phone_field :phone, data: { component: "input" },
        required: true,
        autofocus: true,
        autocomplete: "tel",
        placeholder: "+52 55 1234 5678" %>
  </div>
  
  <div data-form-part="actions">
    <%= f.submit t(".continue"), 
        data: { component: "button", variant: "primary" },
        class: "w-full" %>
  </div>
<% end %>
```

### Search/Filter Form

```erb
<%= form_with url: bookings_path, method: :get, data: { 
      component: "form",
      controller: "auto-submit",
      turbo_frame: "bookings_list"
    } do |f| %>
  
  <div class="flex flex-wrap gap-4">
    <div data-component="input-group" class="flex-1 min-w-[200px]">
      <span data-input-group-part="prefix">
        <%= icon_for :search, class: "size-4 text-muted-foreground" %>
      </span>
      <%= f.search_field :q, data: { 
            component: "input",
            action: "input->auto-submit#debounce"
          },
          value: params[:q],
          placeholder: t(".search_placeholder") %>
    </div>
    
    <%= f.select :status, status_filter_options,
        { include_blank: t(".all_statuses") },
        data: { 
          component: "select",
          action: "change->auto-submit#submit"
        } %>
    
    <%= f.select :date_range, date_range_options,
        {},
        data: { 
          component: "select",
          action: "change->auto-submit#submit"
        } %>
  </div>
<% end %>
```

### Settings Form (Multiple Sections)

```erb
<%= form_with model: @settings, data: { component: "form" } do |f| %>
  <div class="space-y-8">
    <%# Section 1: Profile %>
    <fieldset data-component="fieldset">
      <legend data-component="legend"><%= t(".profile") %></legend>
      
      <div class="space-y-4">
        <div data-form-part="group">
          <%= f.label :business_name, data: { component: "label" } %>
          <%= f.text_field :business_name, data: { component: "input" } %>
        </div>
        
        <div data-form-part="group">
          <%= f.label :description, data: { component: "label" } %>
          <%= f.text_area :description, data: { component: "textarea" }, rows: 3 %>
        </div>
      </div>
    </fieldset>
    
    <%# Section 2: Notifications %>
    <fieldset data-component="fieldset">
      <legend data-component="legend"><%= t(".notifications") %></legend>
      
      <div class="space-y-4">
        <div data-form-part="group" data-layout="inline">
          <%= f.check_box :email_reminders, data: { component: "switch" } %>
          <%= f.label :email_reminders, data: { component: "label" } do %>
            <span class="font-medium"><%= t(".email_reminders") %></span>
          <% end %>
        </div>
        
        <div data-form-part="group" data-layout="inline">
          <%= f.check_box :sms_reminders, data: { component: "switch" } %>
          <%= f.label :sms_reminders, data: { component: "label" } do %>
            <span class="font-medium"><%= t(".sms_reminders") %></span>
          <% end %>
        </div>
      </div>
    </fieldset>
    
    <div data-form-part="actions" data-align="end">
      <%= f.submit t(".save_settings"), data: { component: "button", variant: "primary" } %>
    </div>
  </div>
<% end %>
```

### Nested Form (has_many)

```erb
<%= form_with model: @service, data: { component: "form" } do |f| %>
  <div data-form-part="group">
    <%= f.label :name, data: { component: "label" } %>
    <%= f.text_field :name, data: { component: "input" } %>
  </div>
  
  <%# Nested pricing tiers %>
  <fieldset data-component="fieldset">
    <legend data-component="legend"><%= t(".pricing_tiers") %></legend>
    
    <div data-controller="nested-form" class="space-y-4">
      <div data-nested-form-target="container">
        <%= f.fields_for :pricing_tiers do |tier| %>
          <%= render "services/pricing_tier_fields", f: tier %>
        <% end %>
      </div>
      
      <template data-nested-form-target="template">
        <%= f.fields_for :pricing_tiers, PricingTier.new, child_index: "NEW_RECORD" do |tier| %>
          <%= render "services/pricing_tier_fields", f: tier %>
        <% end %>
      </template>
      
      <button type="button"
              data-action="nested-form#add"
              data-component="button"
              data-variant="outline"
              data-size="sm">
        <%= icon_for :plus, class: "size-4 mr-1" %><%= t(".add_tier") %>
      </button>
    </div>
  </fieldset>
  
  <div data-form-part="actions">
    <%= f.submit t(".save"), data: { component: "button", variant: "primary" } %>
  </div>
<% end %>
```

### Date/Time Selection for Bookings

```erb
<div class="grid gap-4 md:grid-cols-2">
  <%# Date picker %>
  <div data-form-part="group">
    <%= f.label :date, data: { component: "label" } %>
    <%= f.date_field :date, data: { component: "input" },
        min: Date.current,
        max: 3.months.from_now.to_date %>
  </div>
  
  <%# Time slots - loaded via Turbo Frame %>
  <div data-form-part="group">
    <%= f.label :time_slot, data: { component: "label" } %>
    <%= turbo_frame_tag "time_slots" do %>
      <%= f.select :time_slot, [],
          { include_blank: t(".select_date_first") },
          data: { component: "select" }, disabled: true %>
    <% end %>
  </div>
</div>
```

---

## Money Input Pattern

For Haab (storing cents, displaying currency):

```erb
<%# In the form %>
<div data-form-part="group">
  <%= f.label :price, data: { component: "label" } %>
  <div data-component="input-group">
    <span data-input-group-part="prefix">$</span>
    <%= number_field_tag :price_display, 
        (@service.price_cents.to_f / 100 if @service.price_cents),
        data: { 
          component: "input",
          controller: "money-input",
          money_input_target: "display"
        },
        step: "0.01",
        min: 0,
        placeholder: "0.00" %>
    <%= f.hidden_field :price_cents, data: { money_input_target: "cents" } %>
  </div>
  <p data-form-part="description"><%= t(".price_hint") %></p>
</div>
```

```javascript
// money_input_controller.js
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["display", "cents"]
  
  connect() {
    this.displayTarget.addEventListener("input", () => this.update())
  }
  
  update() {
    const dollars = parseFloat(this.displayTarget.value) || 0
    this.centsTarget.value = Math.round(dollars * 100)
  }
}
```
