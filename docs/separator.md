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

## API Reference

### separator

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| orientation | Symbol | :horizontal | :horizontal, :vertical |
| css_classes | String | "" | Additional CSS classes |
| html_options | Hash | {} | Additional HTML attributes, including data |
