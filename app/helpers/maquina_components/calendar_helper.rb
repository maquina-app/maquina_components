# frozen_string_literal: true

module MaquinaComponents
  # Calendar Helper
  #
  # Provides utility methods for working with calendar and date picker data.
  #
  # @example Generate month data
  #   calendar_month_data(Date.current, :sunday)
  #
  # @example Check if date is in range
  #   calendar_date_in_range?(date, start_date, end_date)
  #
  module CalendarHelper
    # Coerce a Date, Time, DateTime or ISO string to a Date
    #
    # @param value [Date, Time, DateTime, String, nil]
    # @return [Date, nil] nil for blank or unparseable input
    def calendar_to_date(value)
      case value
      when Date, Time, DateTime then value.to_date
      when String then Date.parse(value)
      end
    rescue ArgumentError
      nil
    end

    # Generate calendar month data
    #
    # @param date [Date] Any date within the target month
    # @param week_starts_on [Symbol] :sunday or :monday
    # @return [Hash] Month metadata and weeks array
    def calendar_month_data(date, week_starts_on = :sunday)
      first_of_month = date.beginning_of_month
      last_of_month = date.end_of_month

      # Calculate start of calendar grid
      week_start = (week_starts_on == :monday) ? 1 : 0
      days_before = (first_of_month.wday - week_start) % 7
      calendar_start = first_of_month - days_before.days

      # Calculate end of calendar grid (6 weeks max)
      total_days = days_before + last_of_month.day
      weeks_needed = (total_days / 7.0).ceil
      weeks_needed = [weeks_needed, 6].min
      calendar_end = calendar_start + (weeks_needed * 7 - 1).days

      # Build weeks array
      weeks = (calendar_start..calendar_end).each_slice(7).to_a

      {
        month: date.month,
        year: date.year,
        first_of_month: first_of_month,
        last_of_month: last_of_month,
        weeks: weeks,
        week_starts_on: week_starts_on
      }
    end

    # Format month name with year
    #
    # @param date [Date] Any date within the target month
    # @param format [Symbol] :long (%B %Y) or :short (%b %Y)
    # @return [String] Formatted month name
    def calendar_month_name(date, format = :long)
      case format
      when :short
        I18n.l(date, format: "%b %Y")
      else
        I18n.l(date, format: "%B %Y")
      end
    end

    # Years offered by the caption's year select (caption_layout: :dropdown)
    #
    # min_date/max_date set the bounds when present; otherwise years applies,
    # 100 years back to 10 ahead by default. Given both, the narrower bound
    # wins. The displayed year is always included.
    #
    # @param display_year [Integer] Year the calendar shows
    # @param min_date [Date, nil] Minimum selectable date
    # @param max_date [Date, nil] Maximum selectable date
    # @param years [Range, nil] Explicit span of years
    # @return [Range]
    def calendar_year_range(display_year, min_date: nil, max_date: nil, years: nil)
      first, last = (years || ((Date.current.year - 100)..(Date.current.year + 10))).minmax
      first = min_date.year if min_date && (years.nil? || min_date.year > first)
      last = max_date.year if max_date && (years.nil? || max_date.year < last)

      [first, display_year].min..[last, display_year].max
    end

    # Options for the caption's month select: abbreviated localized names
    # (the full ones do not fit beside the year in a 7-cell header), with the
    # months wholly outside min_date/max_date disabled for that year
    #
    # @param year [Integer] Year the months belong to
    # @param min_date [Date, nil] Minimum selectable date
    # @param max_date [Date, nil] Maximum selectable date
    # @return [Array<Array(String, Integer, Boolean)>] [name, month, disabled]
    def calendar_month_options(year, min_date: nil, max_date: nil)
      I18n.t("date.abbr_month_names").drop(1).each_with_index.map do |name, index|
        first_of_month = Date.new(year, index + 1, 1)
        disabled = (min_date && first_of_month.end_of_month < min_date) ||
          (max_date && first_of_month > max_date)

        [name, index + 1, !!disabled]
      end
    end

    # Check if a date falls within a range
    #
    # @param date [Date] The date to check
    # @param start_date [Date, nil] Range start (inclusive)
    # @param end_date [Date, nil] Range end (inclusive)
    # @return [Boolean]
    def calendar_date_in_range?(date, start_date, end_date)
      return false unless start_date && end_date
      date.between?(start_date, end_date)
    end

    # Generate data attributes hash for calendar
    #
    # @param mode [Symbol] :single or :range
    # @param selected [Date, String, nil] Selected date
    # @param selected_end [Date, String, nil] End date for range
    # @param month [Integer, nil] Display month
    # @param year [Integer, nil] Display year
    # @return [Hash] Data attributes for use with content_tag
    def calendar_data_attrs(mode: :single, selected: nil, selected_end: nil, month: nil, year: nil)
      selected_str = case selected
      when Date, Time, DateTime then selected.to_date.iso8601
      when String then selected
      end

      selected_end_str = case selected_end
      when Date, Time, DateTime then selected_end.to_date.iso8601
      when String then selected_end
      end

      display_date = selected_str ? Date.parse(selected_str) : Date.current
      display_month = month || display_date.month
      display_year = year || display_date.year

      {
        data: {
          controller: "calendar",
          component: "calendar",
          "calendar-mode-value": mode,
          "calendar-month-value": display_month,
          "calendar-year-value": display_year,
          "calendar-selected-value": selected_str,
          "calendar-selected-end-value": selected_end_str
        }.compact
      }
    end

    # Get weekday names based on week start
    #
    # @param week_starts_on [Symbol] :sunday or :monday
    # @param format [Symbol] :short (Mo, Tu) or :narrow (M, T) or :long (Monday)
    # @return [Array<String>]
    def calendar_weekday_names(week_starts_on = :sunday, format = :short)
      names = case format
      when :narrow
        %w[S M T W T F S]
      when :long
        I18n.t("date.day_names")
      else
        %w[Su Mo Tu We Th Fr Sa]
      end

      (week_starts_on == :monday) ? names.rotate(1) : names
    end

    # Generate data attributes hash for date picker
    #
    # @param mode [Symbol] :single or :range
    # @param selected [Date, String, nil] Selected date
    # @param selected_end [Date, String, nil] End date for range
    # @return [Hash] Data attributes for use with content_tag
    def date_picker_data_attrs(mode: :single, selected: nil, selected_end: nil)
      selected_str = case selected
      when Date, Time, DateTime then selected.to_date.iso8601
      when String then selected
      end

      selected_end_str = case selected_end
      when Date, Time, DateTime then selected_end.to_date.iso8601
      when String then selected_end
      end

      {
        data: {
          controller: "date-picker",
          component: "date-picker",
          "date-picker-mode-value": mode,
          "date-picker-selected-value": selected_str,
          "date-picker-selected-end-value": selected_end_str
        }.compact
      }
    end

    # Format date for display in date picker
    #
    # @param date [Date, String, nil] Date to format
    # @param format [Symbol] :short, :long, or :full
    # @return [String, nil]
    def date_picker_format(date, format = :long)
      return nil unless date

      date = Date.parse(date) if date.is_a?(String)

      case format
      when :short
        I18n.l(date, format: :short)
      when :full
        I18n.l(date, format: :long)
      else
        I18n.l(date, format: :long)
      end
    rescue ArgumentError
      nil
    end

    # The I18n date data date_picker_format reads, for the date picker
    # controller to format client-side exactly as the server does. Formats a
    # locale defines as a Proc are left out; the controller then falls back
    # to Intl.DateTimeFormat for them.
    #
    # @return [Hash] strftime patterns and localized month/day names
    def date_picker_locale_data
      {
        formats: {
          long: I18n.t("date.formats.long", default: nil),
          short: I18n.t("date.formats.short", default: nil)
        }.select { |_, pattern| pattern.is_a?(String) },
        month_names: I18n.t("date.month_names"),
        abbr_month_names: I18n.t("date.abbr_month_names"),
        day_names: I18n.t("date.day_names"),
        abbr_day_names: I18n.t("date.abbr_day_names")
      }
    end

    # Format date range for display
    #
    # @param start_date [Date, String, nil] Start date
    # @param end_date [Date, String, nil] End date
    # @param format [Symbol] :short or :long
    # @return [String, nil]
    def date_picker_format_range(start_date, end_date, format = :short)
      start_str = date_picker_format(start_date, format)
      end_str = date_picker_format(end_date, format)

      return nil unless start_str

      if end_str
        "#{start_str} - #{end_str}"
      else
        "#{start_str} - ..."
      end
    end
  end
end
