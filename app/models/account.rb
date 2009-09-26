require 'will_paginate'

class Account < ActiveRecord::Base
  
   def self.all(page)
    paginate :per_page => 10, :page => page
  end
end
