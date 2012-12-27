class AddTypeToTrans < ActiveRecord::Migration
  def self.up
    add_column :trans, :trans_type, :string
    
    Trans.all.each do |trans|
      if trans.sourceAccount == nil
        trans.update_attributes!(:trans_type => :income)
      elsif trans.destAccount == nil
        trans.update_attributes!(:trans_type => :outcome)
      else
        trans.update_attributes!(:trans_type => :transfer)
      end
    end
    
    change_column :trans, :trans_type, :string, :null => false
  end

  def self.down
    remove_column :trans, :trans_type
  end
end
