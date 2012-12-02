class User < ActiveRecord::Base
   is_gravtastic :email, :filetype => :png, :default => "identicon", :size => 120
   
   acts_as_authentic do |c| 
     c.openid_required_fields = [:email,"http://axschema.org/contact/email"]
   end
   
   private
   
  def map_openid_registration(registration)
    # email by sreg
    unless registration["email"].nil? && registration["email"].blank? 
            self.email = registration["email"] 
    end
      
    # email by ax
    unless registration['http://axschema.org/contact/email'].nil? && registration['http://axschema.org/contact/email'].first.blank?
            self.email = registration['http://axschema.org/contact/email'].first
    end
  end
end
