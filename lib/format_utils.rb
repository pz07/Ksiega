class FormatUtils
  
  def FormatUtils.date_month_format(d)
    if d
      case d.mon
        when 1 
        ret = "sty #{d.year}"
        when 2 
        ret = "lut #{d.year}"
        when 3 
        ret = "mar #{d.year}"
        when 4 
        ret = "kwi #{d.year}"
        when 5 
        ret = "maj #{d.year}"
        when 6 
        ret = "cze #{d.year}"
        when 7 
        ret = "lip #{d.year}"
        when 8 
        ret = "sie #{d.year}"
        when 9 
        ret = "wrze #{d.year}"
        when 10 
        ret = "paź #{d.year}"
        when 11 
        ret = "lis #{d.year}"
        when 12 
        ret = "gru #{d.year}"
      end 
      
      return ret;
    else
      return ""
    end
  end
  
end