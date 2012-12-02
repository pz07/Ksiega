class Category < ActiveRecord::Base
  belongs_to :user, :class_name => 'User', :foreign_key => 'user_id'
	belongs_to :parent, :class_name => 'Category', :foreign_key => 'parent_id'
  has_many :children, :class_name => 'Category', :foreign_key => 'parent_id'
	
	validates_presence_of :name, :message => "Podaj nazwę kategorii!"
  
  def self.all(page)
    paginate :per_page => 10, :page => page
  end
  
  def isChild(childId)
    if children.length > 0
      children.each do |ch|
        if ch.id == childId
          return true
        else
          return ch.isChild(childId)  
        end
      end
    else
      return false
    end
  end
  
  def getPath()
    if parent
      return parent.getPath + ' & ' + name
    else
      return name
    end
  end

end
