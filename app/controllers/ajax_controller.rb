class AjaxController < ApplicationController

  def getSubCategories
    categories = nil;
    if params["parentCatId"] == '0'
      categories = Category.find(:all, :conditions => "parent_id is null", :order => "name asc")  
    else
      categories = Category.find(:all, :conditions => "parent_id = #{params["parentCatId"]}", :order => "name asc")
    end
    
    retString = ""
    
    for cat in categories
      retString = retString + "#{cat.id}:#{cat.name}:#{cat.children.length}|"
    end
    
    render :text => retString
  end
  
  def changeTransCat
    begin
      trans = Trans.find(params[:transId])
      newCat = Category.find(params[:newCatId])
      
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
      trans = Trans.find(params[:transId])
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
      trans = Trans.find(params[:transId])
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
      trans = Trans.find(params[:transId])
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
      account = Account.find(params[:accountId])
      newAmount = params[:newAmount]
      
      render :text => account.balance.to_s+"|"+(newAmount.to_f - account.balance).to_s
    rescue ActiveRecord::RecordNotFound
      render :text => '-1'
    end;
  end

end