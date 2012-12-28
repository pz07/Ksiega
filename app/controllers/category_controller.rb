class CategoryController < ApplicationController
  before_filter :require_user

	def index
		list
		render :action => 'list'
	end

	def list
	  @categories = CategoryCache.get_from_session(session).get_categories_by_parent_id(current_user.id, nil);
  end

	def changeName
    begin
      cat = Category.find_by_id_and_user_id(params[:catId], current_user.id)
      if cat.update_attribute :name, params[:newName]
        render :text => cat.name
      else
        render :text => '-2'
      end
      
      CategoryCache.get_from_session(session).refresh
    rescue ActiveRecord::RecordNotFound
      render :text => '-1'
    rescue ActiveRecord::StatementInvalid
      render :text => '-2'
    end;
  end

  def newCat
    begin
      parent = nil
      if params[:parentId] != '0'
        parent = Category.find_by_id_and_user_id(params[:parentId], current_user.id)  
      end
      
      newCat = Category.new
      
      newCat.name = params[:name]
      newCat.parent = parent
      newCat.user = current_user
      
      if newCat.save
        render :text => newCat.name
      else
        render :text => '-2'
      end
      
      CategoryCache.get_from_session(session).refresh
    rescue ActiveRecord::RecordNotFound
      render :text => '-1'
    rescue ActiveRecord::StatementInvalid
      render :text => '-2'
    end;
  end
  
  def delCat
    begin
      cat = Category.find_by_id_and_user_id(params[:catId], current_user.id)
      
      if cat.parent_id == nil
        render :text => -1
        return
      end
      
      Trans.update_all("category_id = null", "category_id = #{cat.id}")
      
      cat.destroy
      
      render :text => '0'
      
      CategoryCache.get_from_session(session).refresh
    rescue ActiveRecord::RecordNotFound
      render :text => '-1'
    rescue ActiveRecord::StatementInvalid
      render :text => '-2'
    end;
  end
  
  def changeParent
    begin
      cat = Category.find_by_id_and_user_id(params[:catId], current_user.id)
  
      newParent = nil
      if params[:newParentId] != '0'
        newParent = Category.find_by_id_and_user_id(params[:newParentId], current_user.id)
      end
      
      if newParent && (cat.id == newParent.id || cat.isChild(newParent.id))
        render :text => '-2'
      else
        cat.parent = newParent
         if cat.save
          render :text => params[:newParentId]
         else
          render :text => '-3'
         end
      end
      
      CategoryCache.get_from_session(session).refresh
    rescue ActiveRecord::RecordNotFound
      render :text => '-1'
    end
  end

end
