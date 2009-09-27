
#fixed za http://www.highdots.com/forums/ruby-rails-talk/quote_ident-283323.html
def PGconn.quote_ident(name)
  %("#{name}")
end