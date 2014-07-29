class StatementItem

	attr_accessor :trans_nr, :trans_date, :trans_amount, :account_from, :account_to, :name, :default_category

	def initialize(trans_nr, trans_date, trans_amount, account_from, account_to, name)
		@trans_nr = trans_nr
		@trans_date = trans_date
		@trans_amount = trans_amount
		@account_from = account_from
		@account_to = account_to
		@name = name
    end      
end