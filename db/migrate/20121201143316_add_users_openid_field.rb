class AddUsersOpenidField < ActiveRecord::Migration
  def self.up
    add_column :user, :openid_identifier, :string
    add_index :user, :openid_identifier

    change_column :user, :crypted_password, :string, :default => nil, :null => true
    change_column :user, :password_salt, :string, :default => nil, :null => true
  end

  def self.down
    remove_column :user, :openid_identifier

    [:login, :crypted_password, :password_salt].each do |field|
      User.all(:conditions => "#{field} is NULL").each { |user| user.update_attribute(field, "") if user.send(field).nil? }
      change_column :user, field, :string, :default => "", :null => false
    end
  end
end
