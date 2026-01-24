# Badge

> Displays a small label for status, tags, or counts.

<!-- preview:default height:60 -->

## Usage

```erb
<%%= render "components/badge" do %>
  Badge
<%% end %>
```

## Examples

### Variants

<!-- preview:variants height:60 -->

```erb
<%%= render "components/badge", variant: :primary do %>Primary<%% end %>
<%%= render "components/badge", variant: :secondary do %>Secondary<%% end %>
<%%= render "components/badge", variant: :destructive do %>Destructive<%% end %>
<%%= render "components/badge", variant: :success do %>Success<%% end %>
<%%= render "components/badge", variant: :warning do %>Warning<%% end %>
<%%= render "components/badge", variant: :outline do %>Outline<%% end %>
```

### Sizes

<!-- preview:sizes height:60 -->

```erb
<%%= render "components/badge", size: :sm do %>Small<%% end %>
<%%= render "components/badge", size: :md do %>Medium<%% end %>
<%%= render "components/badge", size: :lg do %>Large<%% end %>
```

### With Icons

<!-- preview:with_icons height:60 -->

```erb
<%%= render "components/badge", variant: :success do %>
  <%%= icon_for :check, class: "size-3" %>
  Verified
<%% end %>

<%%= render "components/badge", variant: :warning do %>
  <%%= icon_for :clock, class: "size-3" %>
  Pending
<%% end %>
```

## API Reference

### Badge

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| variant | Symbol | :default | :default, :primary, :secondary, :destructive, :success, :warning, :outline |
| size | Symbol | :md | :sm, :md, :lg |
| css_classes | String | "" | Additional CSS classes |
| html_options | Hash | {} | Additional HTML attributes |
