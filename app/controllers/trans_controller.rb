class TransController < ApplicationController
  def index
    list
    render :action => 'list'
  end

  # GETs should be safe (see http://www.w3.org/2001/tag/doc/whenToUseGet.html)
  verify :method => :post, :only => [ :destroy, :create, :update ],
         :redirect_to => { :action => :list }

  def search
   newBackLinks
   setBackLink
    
   @accounts = Account.find(:all)
  end

  def list
    setBackLink
    
    form = params["trans_form"];
    session[:session_form] = form

    redirect_to :action => 'sort'
  end
  
  def sort
    popBackLink if params['backLink'] == nil
    setBackLink
    
    form = session[:session_form]
    conditions = ""
    
    if form
      param = form["name"]
      if param !~ /^\s*$/
        conditions += " name like '%#{param}%' and"
      end
      
      param = form["category_id"]
      conditions += " category_id = #{param} and" if param !~ /^\s*$/

      param = form["source_account_id"]
      if param == 'nil'
        conditions += " source_account_id is null and" if param !~ /^\s*$/
      else
        conditions += " source_account_id = #{param} and" if param !~ /^\s*$/
      end

      param = form["dest_account_id"]
      if param == 'nil'
        conditions += " dest_account_id is null and" if param !~ /^\s*$/
      else
        conditions += " dest_account_id = #{param} and" if param !~ /^\s*$/
      end

      amountFrom = form["amountFrom"]
      conditions += " amount >= #{amountFrom} and" if amountFrom !~ /^\s*$/

      amountTo = form["amountTo"]
      conditions += " amount <= #{amountTo} and" if amountTo !~ /^\s*$/

      dateFrom = form["dateFrom"]
      dateTo = form["dateTo"]
      if dateFrom !~ /^\s*$/ and dateTo !~ /^\s*$/
        conditions += " trans_date between '#{format_db_date(Date.parse(dateFrom))}' and '#{format_db_date(Date.parse(dateTo))}' and"
      else 
        if dateFrom !~ /^\s*$/
          conditions += " trans_date >= '#{format_db_date(Date.parse(dateFrom))}' and"
        end
        if dateTo !~ /^\s*$/
          conditions += " trans_date <= '#{format_db_date(Date.parse(dateTo))}' and"
        end
      end
    end

    if conditions.empty?
      @transs = Trans.search(nil, "trans_date desc, created_on desc", params['page']);
    else
      @transs = Trans.search(conditions.sub(/and$/, ""), "trans_date desc, created_on desc", params['page']);
    end
  end

  def show
    setBackLink
    @trans = Trans.find(params[:id])
  end

  def new
    newBackLinks
    setBackLink
    
    @accounts = Account.find(:all)
    @trans = Trans.new
  end

  def newReturn
    setBackLink

    @accounts = Account.find(:all)
    @baseTrans = Trans.find(params[:id]);

    @trans = Trans.new
  end

  def create
    @trans = Trans.new(params[:trans])
    Trans.transaction do
	if @trans.save
		flash[:notice] = 'Trans was successfully created.'
	
		#modyfikuje saldo konta źródłowego
		sourceAccount = @trans.sourceAccount
		if sourceAccount
			sourceAccount.balance = sourceAccount.balance - @trans.amount
			sourceAccount.save
		end
	
		#modyfikuje saldo konta docelowego
		destAccount = @trans.destAccount
		if destAccount
			destAccount.balance = destAccount.balance + @trans.amount
			destAccount.save
		end
	
		redirect_to :action => 'list'
	else
		@accounts = Account.find(:all)
		@categories = Category.find(:all)
		render :action => 'new'
	end
    end
  end

  def createReturn
    @trans = Trans.new(params[:trans])
    returnTrans = Trans.find(params[:baseTransId])
    
    @trans.name = "zwrot: #{returnTrans.name}"
    @trans.return_trans_id = returnTrans.id
    
     Trans.transaction do
      if @trans.save
        flash[:notice] = 'Trans was successfully created.'
        
        #modyfikuje saldo konta docelowego
        destAccount = @trans.destAccount
        if destAccount
          destAccount.balance = destAccount.balance + @trans.amount
          destAccount.save
        end

        popBackLink
        popBackLink
        redirect_to :action => 'show', :id => returnTrans.id
      else
        @accounts = Account.find(:all)
        @trans_list = Trans.find(:all, :conditions => "return_trans_id is null", :order => "trans_date desc");
        render :action => 'newReturn'
      end
    end
  end

  def delete
	
    Trans.transaction do
    	trans = Trans.find(params[:id])
    	
    	#modyfikuje saldo konta źródłowego
    	sourceAccount = trans.sourceAccount
    	if sourceAccount
    		sourceAccount.balance = sourceAccount.balance + trans.amount
    		sourceAccount.save
    	end
    
    	#modyfikuje saldo konta docelowego
    	destAccount = trans.destAccount
    	if destAccount
    		destAccount.balance = destAccount.balance - trans.amount
    		destAccount.save
    	end

    	trans.destroy
    end

    popBackLink
    popBackLink
    redirect_to :action => 'list'
  end

  def update_cash_form
     @accounts = Account.find(:all)
  end

  def update_cash
    newAmount = params[:amount]
    
    transName = params[:trans_name]
    transDate = params[:trans_date]
    
    if !transName || transName.empty?
      flash[:notice] = 'Podaj nazwę transakcji!'
    elsif !newAmount || newAmount.empty?
      flash[:notice] = 'Podaj kwotę!'
    elsif !transDate || transDate.empty?
      flash[:notice] = 'Podaj datę!'
    else
      
      begin
        account = Account.find(params[:account_id])
        category = Category.find(params[:category_id])

        diff = newAmount.to_f - account.balance

        Trans.transaction do
          new_trans = Trans.new
          new_trans.name = transName
          new_trans.category = category
          new_trans.amount = diff.abs
          new_trans.trans_date = Date.parse(transDate)
          
          if diff >= 0.0
            new_trans.destAccount = account
          else
            new_trans.sourceAccount = account
          end
          
          new_trans.save
          account.update_attributes({:balance => newAmount.to_f})
        end

        redirect_to :controller => 'account', :action => 'list'
        return
      
      rescue ActiveRecord::RecordNotFound
        flash[:notice] = 'Nie znaleziono konta lub kategorii transakcji!'
      end
    end

    redirect_to :action => 'update_cash_form'  
  end
end
