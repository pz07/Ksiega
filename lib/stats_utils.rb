class StatsUtils

  def StatsUtils.getLastInOut(mountsCount=7 )
    #dochody i przychody przez ostatnie mountsCount miesięcy
    inout = Hash.new

    d_now = Date.today
    d_first = (d_now.-(d_now.mday() -1));
    d_min = d_first.<<(mountsCount)

    for i in 1..(mountsCount)
      inout[d_first<<(i-1)] = [0, 0]
    end

    transes = Trans.find(:all, :conditions => "trans_date >= '#{d_min}' and trans_date <= '#{d_now}' and return_trans_id is null", :order => "trans_date desc")
    
    mon = nil
    transes.each do |t|
      cur = (t.trans_date.-(t.trans_date.mday() -1))
      ar = inout[cur]
      
      if ar != nil
        if mon != t.trans_date.mon
          mon = t.trans_date.mon 
        end
    
        if t.sourceAccount == nil
          ar[0] = ar[0] + t.realAmount
        end
        if t.destAccount == nil
         ar[1] = ar[1] + t.realAmount
        end
      end
    end
    
    return inout
  end

end