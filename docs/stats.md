# Stats

> Displays key metrics as cards in a responsive grid.

<!-- preview:default height:160 -->

## Usage

```erb
<%%= render "components/stats/stats_grid", columns: 4, cards: [
  { title: "Total Revenue", value: "$1,250.00", icon: :dollar, subtitle: "Trending up this month" },
  { title: "New Customers", value: "1,234", icon: :users },
  { title: "Active Accounts", value: "45,678", icon: :check_circle },
  { title: "Growth Rate", value: "4.5%", icon: :chart_bar }
] %>
```

## Examples

### Single card

<!-- preview:card height:140 -->

```erb
<%%= render "components/stats/stats_card",
  title: "Open Tickets",
  value: "12",
  icon: :circle_alert,
  icon_classes: "text-amber-500",
  subtitle: "3 urgent" %>
```

### With action

<!-- preview:with_action height:160 -->

```erb
<%%= render "components/stats/stats_grid",
  columns: 3,
  cards: [
    { title: "Messages", value: "128", icon: :message_square },
    { title: "Tasks Done", value: "87", icon: :clipboard_list },
    { title: "Automations", value: "9", icon: :lightning_bolt }
  ],
  action: link_to("View report", "#", data: { component: "button", variant: "outline" }),
  action_position: :end %>
```

## API Reference

### Stats Grid

Partial: `components/stats/stats_grid`. Each hash in `cards` is passed to the stats card partial as its locals.

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| cards | Array | [] | Hashes of stats_card parameters |
| columns | Integer | 3 | Grid columns from the sm breakpoint up, 1-6 |
| action | String | nil | Captured HTML rendered beside the grid |
| action_position | Symbol | :end | :start, :end |
| css_classes | String | "" | Additional CSS classes |
| container_class | String | "" | Legacy alias of css_classes, used when css_classes is blank |
| html_options | Hash | {} | Additional HTML attributes, including data |

### Stats Card

Partial: `components/stats/stats_card`.

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| title | String | required | Metric label |
| value | String | required | Metric value |
| icon | Symbol | nil | Icon name resolved with icon_for (your app's icons first, then built-ins); legacy kebab-case strings such as "chart-bar" map to built-ins; any other value renders as custom HTML |
| subtitle | String | nil | Secondary line under the value |
| icon_classes | String | "" | Classes for the icon area, e.g. a color utility |
| value_classes | String | "" | Classes for the value, e.g. a color utility |
| css_classes | String | "" | Additional CSS classes |
| container_class | String | "" | Legacy alias of css_classes |
| icon_class | String | "" | Legacy alias of icon_classes |
| value_class | String | "" | Legacy alias of value_classes |
| html_options | Hash | {} | Additional HTML attributes, including data |
