class CategoryCache
  
  def initialize
    @categories = nil
  end
  
  def get_categories(user_id)
    if @categories == nil
      init_categories user_id
    end
    
    return @categories
  end
  
  def get_categories_by_parent_id(user_id, parent_id = nil)
    categories_by_parent = []
    self.get_categories(user_id).each {|category|
        if  (category.parent_id == nil and parent_id == nil) or (category.parent_id == Integer(parent_id))
          categories_by_parent << category
        end
    }
    
    return categories_by_parent
  end
  
  def refresh
    @categories = nil
  end
  
  def CategoryCache.get_from_session(session)
    cache = session[:category_cache_key]
    if not cache
      cache = CategoryCache.new
      session[:category_cache_key] = cache
    end
    
    return cache
  end
  
  private
  
    def init_categories(user_id)
      @categories = Category.find_all_by_user_id(user_id, :order => "parent_id asc, name asc")
      
      @categories.each do |cat|
        cat.full_name = find_full_name(@categories, cat)
      end
      
      @categories = @categories.sort_by { |a| a.full_name}
    end
    
    def find_full_name(categories, cat)
      if cat.parent_id
        parent = categories.find { |c| c.id == cat.parent_id}
        parent_full_name = find_full_name(categories, parent) 
        return "#{parent_full_name} => #{cat.name}"
      else
        return cat.name 
      end
    end
  
end