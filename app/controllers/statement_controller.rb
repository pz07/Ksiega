require 'csv'
require 'iconv'

class StatementController < ApplicationController
  before_filter :require_user

	def index
		@accounts = get_user_accounts
		@statementTypes = ["ING"]

		render :action => 'form'
	end

	def import
		@categories = CategoryCache.get_from_session(session).get_categories(current_user.id);
		@accounts = get_user_accounts
		
		@account = Account.find_by_id(params[:statement][:account_id])
		@statementType = params[:statement][:type]

		@items = nil

		statementIo = params[:statement][:file]
		if @statementType == "ING"
			@items = readIngStatement(@account, statementIo.read)
		end
		
		render :action => 'import'
	end

	private

		def readIngStatement(account, statementAsString)
			converter = Iconv.new 'UTF-8', 'cp1250'
			#converter.transliterate = true #important to replace offending characters
			#statementAsString = converter.iconv(statementAsString)

			items = []
			statement = CSV.parse(statementAsString, col_sep = ';')

			for i in 5..statement.size
				if statement[i] != nil and statement[i].size == 10
					trans_date = DateTime.strptime(statement[i][1], '%Y-%m-%d')
					trans_amount = statement[i][2].gsub(',', '.').to_f
					
					account_from = nil
					account_to = nil
					default_category = nil
					if trans_amount < 0
						account_from = account
					else
						account_to = account
					end

					reciver = converter.iconv(statement[i][6])
					title = converter.iconv(statement[i][7])
					trans_nr = converter.iconv(statement[i][8]).gsub(/'/, "")

					name = "#{reciver} #{title} (#{trans_nr})"

					items << StatementItem.new(trans_nr, trans_date, trans_amount.abs, account_from, account_to, name)
				end
			end
			
			return items.reverse
		end

		def get_user_accounts()
    		return Account.find_all_by_user_id(current_user.id, :order => "name asc")
  		end
end
