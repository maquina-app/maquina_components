# frozen_string_literal: true

module PreviewsHelper
  GAPS = {
    1 => "gap-1", 2 => "gap-2", 3 => "gap-3",
    4 => "gap-4", 6 => "gap-6", 8 => "gap-8"
  }.freeze

  GRID_COLS = {
    1 => "grid-cols-1", 2 => "grid-cols-2",
    3 => "grid-cols-3", 4 => "grid-cols-4"
  }.freeze

  MAX_WIDTHS = {
    sm: "max-w-sm", md: "max-w-md",
    lg: "max-w-lg", xl: "max-w-xl"
  }.freeze

  def preview_row(gap: 2, wrap: true, &block)
    classes = ["flex", "items-center", GAPS[gap] || "gap-2"]
    classes << "flex-wrap" if wrap
    content_tag(:div, class: classes.join(" "), &block)
  end

  def preview_stack(gap: 4, &block)
    content_tag(:div, class: "flex flex-col #{GAPS[gap] || "gap-4"}", &block)
  end

  def preview_grid(cols: 2, gap: 4, &block)
    content_tag(:div, class: "grid #{GRID_COLS[cols] || "grid-cols-2"} #{GAPS[gap] || "gap-4"}", &block)
  end

  def preview_section(title = nil, &block)
    content_tag(:div, class: "space-y-3") do
      safe_join([
        (content_tag(:h4, title, class: "text-sm font-medium text-muted-foreground") if title),
        capture(&block)
      ].compact)
    end
  end

  def preview_container(width: :md, &block)
    content_tag(:div, class: MAX_WIDTHS[width.to_sym] || "max-w-md", &block)
  end
end
