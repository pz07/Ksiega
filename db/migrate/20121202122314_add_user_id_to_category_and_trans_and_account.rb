class AddUserIdToCategoryAndTransAndAccount < ActiveRecord::Migration
  def self.up
    add_column :account, :user_id, :integer, :null => false, :default => -1
    add_index :account, :user_id

    add_column :category, :user_id, :integer, :null => false, :default => -1
    add_index :category, :user_id

    add_column :trans, :user_id, :integer, :null => false, :default => -1
    add_index :trans, :user_id
    
    change_column :trans, :user_id, :integer, :null => true
    change_column :user, :password_salt, :string, :default => nil, :null => true
  end

  def self.down
    remove_column :account, :user_id
    remove_column :category, :user_id
    remove_column :trans, :user_id
  end
end
