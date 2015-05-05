class User < ActiveRecord::Base
   is_gravtastic :email, :filetype => :png, :default => "identicon", :size => 120
   has_many :categories, :class_name => 'Category', :foreign_key => 'user_id'
   has_many :accounts, :class_name => 'Account', :foreign_key => 'user_id'
   
   acts_as_authentic do |c|      
   end
   
  private
   
  def map_openid_registration(registration)
    outcomes = Category.new
      
    outcomes.trans_type = :outcome
    outcomes.name = 'outcomes'
    outcomes.parent = nil
    
    incomes = Category.new
      
    incomes.trans_type = :income
    incomes.name = 'incomess'
    incomes.parent = nil
      
    account = Account.new
    
    account.name = "cash"
    account.balance = 0
    
    self.categories<<(outcomes)
    self.categories<<(incomes)
    
    self.accounts<<(account)
  end
end
