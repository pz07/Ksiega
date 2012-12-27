require "will_paginate"

class Trans < ActiveRecord::Base
  belongs_to :user, :class_name => 'User', :foreign_key => 'user_id'
	belongs_to :sourceAccount, :class_name => 'Account', :foreign_key => 'source_account_id'
	belongs_to :destAccount, :class_name => 'Account', :foreign_key => 'dest_account_id'
	belongs_to :category, :class_name => 'Category', :foreign_key => 'category_id'

  has_many :return_trans, :class_name => 'Trans', :foreign_key => 'return_trans_id'

	validates_presence_of :name, :message => "could not be empty!"
	validates_presence_of :amount, :message => "could not be empty!"
	validates_presence_of :trans_date, :message => "could not be empty!"
	validates_presence_of :trans_type, :message => "could not be determined!"	
    
  def realAmount
    ra = amount
    if return_trans != nil and return_trans.length > 0
      return_trans.each {|t| ra = ra - t.amount }
    end
    
    return ra
  end
  
  def save
    if self.sourceAccount != nil && self.destAccount != nil
      self.trans_type = :transfer
    end
    if self.sourceAccount != nil && self.destAccount == nil
      self.trans_type = :outcome
    end
    if self.sourceAccount == nil && self.destAccount != nil
      self.trans_type = :income
    end
    
    super
  end
  
  def self.search(user_id, searchCrit, order, page)
    paginate :per_page => 10, :page => page,
             :conditions => searchCrit, :order => order
  end
  
  def trans_type
    ret = read_attribute(:trans_type)
    if ret
      return ret.to_sym
    else
      return nil
    end
  end

  def trans_type=(new_trans_type)
    write_attribute :trans_type, new_trans_type.to_s
  end
end
