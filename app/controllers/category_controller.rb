class CategoryController < ApplicationController
  
	def index
		list
		render :action => 'list'
	end

	def list
  end

	def changeName
    begin
      cat = Category.find(params[:catId])
      if cat.update_attribute :name, params[:newName]
        render :text => cat.name
      else
        render :text => '-2'
      end
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
        parent = Category.find(params[:parentId])  
      end
      
      newCat = Category.new
      
      newCat.name = params[:name]
      newCat.parent = parent
      
      if newCat.save
        render :text => newCat.name
      else
        render :text => '-2'
      end
    rescue ActiveRecord::RecordNotFound
      render :text => '-1'
    rescue ActiveRecord::StatementInvalid
      render :text => '-2'
    end;
  end
  
  def delCat
    begin
      cat = Category.find(params[:catId])
      cat.destroy
      
      render :text => '0'
    rescue ActiveRecord::RecordNotFound
      render :text => '-1'
    rescue ActiveRecord::StatementInvalid
      render :text => '-2'
    end;
  end
  
  def changeParent
    begin
      cat = Category.find(params[:catId])
  
      newParent = nil
      if params[:newParentId] != '0'
        newParent = Category.find(params[:newParentId])
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
    rescue ActiveRecord::RecordNotFound
      render :text => '-1'
    end
  end

end
