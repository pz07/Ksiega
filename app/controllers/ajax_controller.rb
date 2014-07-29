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

  def addTrans
    begin
      accountFrom = Account.find_by_id_and_user_id(params[:accountFromId], current_user.id)
      accountTo = Account.find_by_id_and_user_id(params[:accountToId], current_user.id)
      category = nil
      if params[:categoryId]
        category = Category.find_by_user_id_and_id(current_user.id, params[:categoryId])
      end

      amount = params[:amount].to_f
      name = params[:name]
      date = Date.strptime(params[:date], "%d-%m-%Y")
      
      trans = Trans.new()
      trans.user_id = current_user.id
      trans.sourceAccount = accountFrom
      trans.destAccount = accountTo
      trans.name = name
      trans.amount = amount
      trans.trans_date = date
      trans.category = category

      Trans.transaction do
        if trans.save
          #modyfikuje saldo konta źródłowego
          sourceAccount = trans.sourceAccount
          if sourceAccount
            sourceAccount.balance = sourceAccount.balance - trans.amount
            sourceAccount.save
          end
      
          #modyfikuje saldo konta docelowego
          destAccount = trans.destAccount
          if destAccount
            destAccount.balance = destAccount.balance + trans.amount
            destAccount.save
          end
      
          render :text => "/trans/show/#{trans.id}"
        else
          render :text => '-2'
        end
      end
    rescue ActiveRecord::RecordNotFound
      render :text => '-1'
    end;
  end

  def checkTrans
    id = params[:id]
    amount = params[:amount].to_f
    date = Date.strptime(params[:date], "%d-%m-%Y")
    accountFromId = params[:accountFromId].to_i if not params[:accountFromId].empty?
    accountToId = params[:accountToId].to_i if not params[:accountToId].empty?

    transes = Trans.find(:all, :conditions => ["name like ?","%#{id}%"])
    if transes and not transes.empty?
      transesStr = (transes.map {|t| "<a href='/trans/show/#{t.id}'>#{t.id}</a>"}).join("&nbsp;&nbsp;")
      render :text => "<span style='color: red'>Found transaction(s) containing trans id: #{transesStr}</span>"
      return
    end

    conditions = ["amount = ? and trans_date >= ? and trans_date <= ?",  amount, date - 7.days, date + 7.days]
    if accountFromId
      conditions[0] << " and source_account_id = ?"
      conditions << accountFromId
    else
      conditions[0] << " and source_account_id is null"
    end

    if accountToId
      conditions[0] << " and dest_account_id = ?"
      conditions << accountToId
    else
      conditions[0] << " and dest_account_id is null"
    end

    transes = Trans.find(:all, :conditions => conditions)
    if transes and not transes.empty?
      transesStr = (transes.map {|t| "<a href='/trans/show/#{t.id}'>#{t.id}</a>"}).join("&nbsp;&nbsp;")
      render :text => "<span style='color: red'>Found recent transaction(s) with the same amount and accounts: #{transesStr}</span>"
      return
    end

    render :text => '<span style="color: green">No similar transaction found</span>'    
  end

end