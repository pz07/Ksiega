class AjaxController < ApplicationController
  before_filter :require_user

  def getSubCategories
    categories = CategoryCache.get_from_session(session).get_categories_by_parent_id(current_user.id, params["parentCatId"]);
    
    retString = ""
    
    for cat in categories
      retString = retString + "#{cat.id}:#{cat.name}:#{cat.children.length}|"
    end
    
    render :text => retString
  end
  
  def changeTransCat
    begin
      trans = Trans.find_by_id_and_user_id(params[:transId], current_user.id)
      newCat = Category.find_by_user_id_and_id(current_user.id, params[:newCatId])
      
      trans.category = newCat
      if trans.save
        render :text => newCat.getPath()
      else
        render :text => '-2'
      end
    rescue ActiveRecord::RecordNotFound
      render :text => '-1'
    end;
  end
  
  def changeTransName
    begin
      trans = Trans.find_by_id_and_user_id(params[:transId], current_user.id)
      newName = params[:newName]
      
      trans.name = newName
      if trans.save
        render :text => trans.name
      else
        render :text => '-2'
      end
    rescue ActiveRecord::RecordNotFound
      render :text => '-1'
    end;
  end
  
  def changeTransAmount
    begin
      trans = Trans.find_by_id_and_user_id(params[:transId], current_user.id)
      newAmount = params[:newAmount].to_f
      
      Trans.transaction do
        diff = newAmount - trans.amount

        #modyfikuje saldo konta źródłowego
        sourceAccount = trans.sourceAccount
        if sourceAccount
          sourceAccount.balance = sourceAccount.balance - diff
          sourceAccount.save
        end
  
        #modyfikuje saldo konta docelowego
        destAccount = trans.destAccount
        if destAccount
          destAccount.balance = destAccount.balance + diff
          destAccount.save
        end
        
        trans.amount = newAmount
        if trans.save
          render :text => sprintf("%.2f", trans.realAmount)
        else
          render :text => '-2'
        end    
      end
    rescue ActiveRecord::RecordNotFound
      render :text => '-1'
    end;
  end
  
  def changeTransDate
    begin
      trans = Trans.find_by_id_and_user_id(params[:transId], current_user.id)
      newDate = params[:newDate]
      
      trans.trans_date = newDate
      if trans.save
        render :text => trans.trans_date.strftime("%d-%m-%Y")
      else
        render :text => '-2'
      end
    rescue ActiveRecord::RecordNotFound
      render :text => '-1'
    end;
  end
  
  def getAccountInfo
    begin
      account = Account.find_by_id_and_user_id(params[:accountId], current_user.id)
      newAmount = params[:newAmount]
      
      render :text => account.balance.to_s+"|"+(newAmount.to_f - account.balance).to_s
    rescue ActiveRecord::RecordNotFound
      render :text => '-1'
    end;
  end

end