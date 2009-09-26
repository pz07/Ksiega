# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper
  require 'format_utils'

	def date_time_format(d = Date.now)
		d.strftime("%d-%m-%Y %H:%M")
	end 

	def date_format(d = Date.now)
		d.strftime("%d-%m-%Y")
  end

	def date_month_format(d)
		return FormatUtils.date_month_format(d)
  end
end
