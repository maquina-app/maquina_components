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

  # ===== Specimen helpers =====
  # Specimen pages are dense grids of one component in many states or one token
  # role across many components. They read better with captions than with prose.

  def specimen_section(title, note: nil, &block)
    content_tag(:section, class: "space-y-3") do
      safe_join([
        content_tag(:h3, title, class: "text-sm font-semibold tracking-tight"),
        (content_tag(:p, note, class: "text-xs text-muted-foreground") if note),
        capture(&block)
      ].compact)
    end
  end

  def specimen_grid(&block)
    content_tag(:div, class: "flex flex-wrap items-end gap-x-6 gap-y-4", &block)
  end

  def specimen_cell(label, &block)
    content_tag(:div, class: "flex flex-col items-start gap-1.5") do
      safe_join([
        capture(&block),
        content_tag(:span, label, class: "text-[11px] leading-none text-muted-foreground")
      ])
    end
  end
end
