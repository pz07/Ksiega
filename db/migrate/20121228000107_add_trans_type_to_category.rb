class AddTransTypeToCategory < ActiveRecord::Migration
  def self.up
    add_column :category, :trans_type, :string
    
    User.all.each do |user|
      incomes = Category.new
      
      incomes.trans_type = :income
      incomes.name = 'incomes'
      incomes.parent = nil
      incomes.user = user
      
      incomes.save
      
      outcomes = Category.new
      
      outcomes.trans_type = :outcome
      outcomes.name = 'outcomes'
      outcomes.parent = nil
      outcomes.user = user
      
      outcomes.save
      
      outcomes = Category.find_by_trans_type(:outcome.to_s)
      Category.find_all_by_user_id_and_parent_id_and_trans_type(user.id, nil, nil).each do |category|
        category.update_attributes!(:parent_id => outcomes.id)
      end  
    end
  end

  def self.down
    outcomes = Category.find_by_trans_type(:outcome)
    if outcomes
      Category.find_all_by_parent_id(outcomes.id).each do |category|
        category.update_attributes!(:parent_id => nil)
      end
    end
    
    remove_column :category, :trans_type
  end
end

