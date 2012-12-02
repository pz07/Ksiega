class AccountController < ApplicationController
	before_filter :require_user
  
	def index
		list
		render :action => 'list'
	end

	def list
    newBackLinks
    setBackLink
     
		@accounts = Account.find_all_by_user_id(current_user.id, :order => "name")
	end

	def show
    setBackLink 
		@account = Account.find_by_id_and_user_id(params[:id], current_user.id)
	end

	def new
    setBackLink 
		@account = Account.new
	end

	def create
		@account = Account.new(params[:account])
		@account.user_id = current_user.id
		
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
		@account = Account.find_by_id_and_user_id(params[:id], current_user.id)
	end

	def update
    @account = Account.find_by_id_and_user_id(params[:id], current_user.id)
		if @account.update_attributes(params[:account])
			flash['notice'] = 'Konto zostało uaktualnione';
      
			redirect_to :action => 'show', :id => @account
	   else
      popBackLink
			render :action => 'edit'
		end
	end

	def destroy
    Account.find_by_id_and_user_id(params[:id], current_user.id).destroy

    setBackLink 
		redirect_to :action => 'back'
	end

end
