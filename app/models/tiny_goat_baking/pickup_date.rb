# frozen_string_literal: true

module TinyGoatBaking
  module PickupDate
    FORMATS = ["%a, %b %d, %Y", "%b %d, %Y"].freeze

    def self.display(pickup_date)
      "#{pickup_date.strftime('%A, %B')} #{pickup_date.day.ordinalize}, #{pickup_date.year}"
    end

    def self.parse(name)
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
end
