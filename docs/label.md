# Label

> Renders an accessible label associated with a form control.

## Usage

```erb
<%%= render "components/label", text: "Email", for_id: "user_email" %>
<input type="email" id="user_email" data-component="input">
```

## Examples

### Required

`required: true` adds a destructive-colored asterisk after the text.

```erb
<%%= render "components/label", text: "Email", for_id: "user_email", required: true %>
```

### With Block

```erb
<%%= render "components/label", for_id: "user_terms" do %>
  Accept the <a href="/terms">terms</a>
<%% end %>
```

### With Form Builders

The CSS is keyed on the data attribute, so a Rails form builder label
gets the same styling without the partial.

```erb
<%%= f.label :email, data: { component: "label" } %>
<%%= f.label :name, data: { component: "label", required: true } %>
```

## API Reference

### Label

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| text | String | nil | Label text |
| content | String | nil | Captured HTML via capture, or use block |
| for_id | String | nil | id of the associated control, rendered as the for attribute; a for: option is honored too |
| required | Boolean | false | Adds data-required and the asterisk indicator |
| css_classes | String | "" | Additional CSS classes |
| html_options | Hash | {} | Additional HTML attributes, including data |

### Data Attributes

| Attribute | Element | Description |
|-----------|---------|-------------|
| data-component="label" | label | Label styling |
| data-required | label | Shows the required asterisk |

A label placed directly after a disabled control, or one directly followed
by a disabled control, renders dimmed with a not-allowed cursor.
