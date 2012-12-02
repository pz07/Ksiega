require "will_paginate"

class Account < ActiveRecord::Base
   belongs_to :user, :class_name => 'User', :foreign_key => 'user_id'
end
