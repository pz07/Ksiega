class AccountController < ApplicationController
	def index
		list
		render :action => 'list'
	end

	def list
    newBackLinks
    setBackLink
     
		@accounts = Account.all(params['page'])
	end

	def show
    setBackLink 
		@account = Account.find(params[:id])
    
    @inTranss_pages, @inTranss = paginate(:Transs, :parameter => 'pageIn', :conditions => "dest_account_id = #{@account.id}", :order => "trans_date desc")
    @outTranss_pages, @outTranss = paginate(:Transs, :parameter => 'pageOut', :conditions => "source_account_id = #{@account.id}", :order => "trans_date desc")
	end

	def new
    setBackLink 
		@account = Account.new
	end

	def create
		@account = Account.new(params[:account])
		if @account.save
			flash['notice'] = 'Dodano nowe konto.'
      
      redirect_to :action => 'back'
		else
      popBackLink
			render :action => 'new'
		end
	end

	def edit
    setBackLink 
		@account = Account.find(params[:id])
	end

	def update
		@account = Account.find(params[:id])
		if @account.update_attributes(params[:account])
			flash['notice'] = 'Konto zostało uaktualnione';
      
			redirect_to :action => 'show', :id => @account
	   else
      popBackLink
			render :action => 'edit'
		end
	end

	def destroy
		Account.find(params[:id]).destroy

    setBackLink 
		redirect_to :action => 'back'
	end

end
