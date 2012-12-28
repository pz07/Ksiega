class User < ActiveRecord::Base
   is_gravtastic :email, :filetype => :png, :default => "identicon", :size => 120
   has_many :categories, :class_name => 'Category', :foreign_key => 'user_id'
   has_many :accounts, :class_name => 'Account', :foreign_key => 'user_id'
   
   acts_as_authentic do |c| 
     c.openid_required_fields = [:email,"http://axschema.org/contact/email"]
   end
   
  private
   
  def map_openid_registration(registration)
    # email by sreg
    unless registration["email"].nil? && registration["email"].blank? 
            self.email = registration["email"] 
    end
      
    # email by ax
    unless registration['http://axschema.org/contact/email'].nil? && registration['http://axschema.org/contact/email'].first.blank?
            self.email = registration['http://axschema.org/contact/email'].first
    end

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
