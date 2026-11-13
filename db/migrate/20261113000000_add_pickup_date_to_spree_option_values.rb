class AddPickupDateToSpreeOptionValues < ActiveRecord::Migration[8.1]
  FORMATS = ["%a, %b %d, %Y", "%b %d, %Y"].freeze

  def up
    add_column :spree_option_values, :pickup_date, :date

    pickup_date_names = select_rows(<<~SQL.squish)
      SELECT spree_option_values.id, spree_option_values.name
      FROM spree_option_values
      JOIN spree_option_types ON spree_option_types.id = spree_option_values.option_type_id
      WHERE spree_option_types.name = 'Pickup Date'
    SQL

    unreadable = pickup_date_names.filter_map do |id, name|
      pickup_date = parse(name)
      next name unless pickup_date

      execute "UPDATE spree_option_values SET pickup_date = #{quote(pickup_date)} WHERE id = #{Integer(id)}"
      nil
    end

    raise "Couldn't tell which date these pickup dates are, fix their names and migrate again: #{unreadable.join('; ')}" if unreadable.any?
  end

  def down
    remove_column :spree_option_values, :pickup_date
  end

  private

  def parse(name)
    FORMATS.each do |format|
      pickup_date = Date.strptime(name.to_s.strip, format)
      weekday = name[/\A(\w+),/, 1]
      return weekday.nil? || [pickup_date.strftime("%a"), pickup_date.strftime("%A")].include?(weekday) ? pickup_date : nil
    rescue Date::Error
      next
    end

    nil
  end
end
