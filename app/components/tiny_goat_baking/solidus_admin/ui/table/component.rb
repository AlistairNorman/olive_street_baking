# frozen_string_literal: true

class TinyGoatBaking::SolidusAdmin::UI::Table::Component < SolidusAdmin::UI::Table::Component
  BREAKPOINT_CLASSES = {
    md: {cell: "hidden md:table-cell", col: "hidden md:table-column"},
    lg: {cell: "hidden lg:table-cell", col: "hidden lg:table-column"},
    xl: {cell: "hidden xl:table-cell", col: "hidden xl:table-column"},
    "2xl": {cell: "hidden 2xl:table-cell", col: "hidden 2xl:table-column"}
  }.freeze

  def self.stimulus_id = superclass.stimulus_id

  def initialize(data:, **options)
    @header_breakpoints = {}.compare_by_identity
    columns = data.fetch(:columns).map do |column|
      next column unless column.is_a?(Hash) && column.key?(:visible_from)

      breakpoint = BREAKPOINT_CLASSES.fetch(column[:visible_from])
      @header_breakpoints[column[:header]] = breakpoint
      col_class = [breakpoint[:col], column.dig(:col, :class)].compact.join(" ")
      column.except(:visible_from).merge(col: (column[:col] || {}).merge(class: col_class))
    end

    super(data: data.merge(columns:), **options)
  end

  def render_header_cell(cell, **attributes)
    hide_below_breakpoint(super, @header_breakpoints[cell])
  end

  def render_data_cell(column, data)
    hide_below_breakpoint(super, @header_breakpoints[column.header])
  end

  private

  def hide_below_breakpoint(cell, breakpoint)
    return cell unless breakpoint

    cell.sub(/\A<(th|td) class="/, "<\\1 class=\"#{breakpoint[:cell]} ").html_safe
  end
end
