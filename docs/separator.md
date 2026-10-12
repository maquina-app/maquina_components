# Separator

> Visually or semantically separates content.

<!-- preview:default height:140 -->

## Usage

```erb
<%%= render "components/separator" %>
```

## Examples

### Vertical

Use inside a flex row, for example between header actions.

<!-- preview:vertical height:60 -->

```erb
<div class="flex h-8 items-center">
  <span>Docs</span>
  <%%= render "components/separator", orientation: :vertical %>
  <span>Source</span>
</div>
```

### Spacing

A horizontal separator spans the full width of its container and has no
horizontal margin. Add vertical spacing with `css_classes:` (for example
`"my-4"`), or an inset with a margin plus `"w-auto"` (for example
`"mx-4 w-auto"`). A vertical separator keeps a small inline margin (`mx-2`)
so the items it divides do not touch.

## API Reference

### Separator

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| orientation | Symbol | :horizontal | :horizontal, :vertical |
| css_classes | String | "" | Additional CSS classes |
| html_options | Hash | {} | Additional HTML attributes, including data |
