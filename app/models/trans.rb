require 'will_paginate'

class Trans < ActiveRecord::Base
	belongs_to :sourceAccount, :class_name => 'Account', :foreign_key => 'source_account_id'
	belongs_to :destAccount, :class_name => 'Account', :foreign_key => 'dest_account_id'
	belongs_to :category, :class_name => 'Category', :foreign_key => 'category_id'

  has_many :return_trans, :class_name => 'Trans', :foreign_key => 'return_trans_id'

	validates_presence_of :name, :message => "Podaj opis transakcji!"
	validates_presence_of :amount, :message => "Podaj kwotę!"
	validates_presence_of :trans_date, :message => "Podaj datę!"	
    
  def realAmount
    ra = amount
    if return_trans != nil and return_trans.length > 0
      return_trans.each {|t| ra = ra - t.amount }
    end
    
    return ra
  end
  
  def self.search(searchCrit, order, page)
    paginate :per_page => 10, :page => page,
             :conditions => searchCrit, :order => order
  end
end
