class ChartController < ApplicationController
  before_filter :require_user

  require 'open_flash_chart'
  require 'stats_utils'
  require 'format_utils'

  def graph01
    length = 7
    if params[:length]
      length = params[:length].to_i
    end

    inoutData = StatsUtils.getLastInOut(current_user.id, length)
    
    inData = Array.new
    outData = Array.new
    labels = Array.new
    
    keys = inoutData.keys.sort{|a, b| a <=> b} 
    maxValue = 0;
    for key in keys
      labels.push(FormatUtils.date_month_format(key))
      
      value = inoutData[key]
      inData.push(value[0])
      outData.push(value[1])
      
      maxValue = [maxValue, value[0], value[1]].max
    end
    
    maxValue = maxValue + (500 - maxValue % 500)
    
    g = Graph.new
    g.title( 'Przychody i wydatki', '{color: #7E97A6; font-size: 20; text-align: center}' )
    g.set_bg_color('#FFFFFF')

    g.set_data(inData)
    g.line_hollow( 2, 4, '#818D9D', 'wydatki', 10 )
    
    g.set_data(outData)
    g.line_hollow( 2, 4, '#164166', 'przychodzy', 10 )
    
    g.set_y_max(maxValue)
    g.set_x_axis_color('#818D9D', '#F0F0F0' )
    g.set_y_axis_color( '#818D9D', '#ADB5C7' )
    g.set_y_legend( 'Kwota', 12, '#164166' )
    
    g.set_x_labels(labels)
    g.set_x_label_style(8, '#164166', 0, 0, '#818D9D' )
    
    g.set_y_label_steps(maxValue / 500)

    puts g.render
    
    render :text => g.render
  end

  def graph02
    length = 7
    if params[:length]
      length = params[:length].to_i
    end

    inoutData = StatsUtils.getLastInOut(current_user.id, length)
    
    labels = Array.new
    data = Array.new
    
    keys = inoutData.keys.sort{|a, b| a <=> b} 
    
    maxValue = 0
    minValue = 0
    for key in keys
      labels.push(FormatUtils.date_month_format(key))
      
      value = inoutData[key]
      data.push(value[0] - value[1])
    
      maxValue = [maxValue, value[0] - value[1]].max
      minValue = [minValue, value[0] - value[1]].min
    end
    
    minValue = minValue - minValue % 500
    maxValue = maxValue + (500 - maxValue % 500)
    
    g = Graph.new;
    g.title( 'Salda miesięczne', '{color: #7E97A6; font-size: 20; text-align: center}' );
    g.set_bg_color('#FFFFFF')

    g.set_data(data)

    g.bar_glass(55, '#164166', '#818D9D');
    g.set_x_labels(labels);
    g.set_x_label_style(8, '#164166', 0, 0, '#818D9D' )

    g.set_x_axis_color('#818D9D', '#F0F0F0' )
    g.set_y_axis_color( '#818D9D', '#ADB5C7' )
    
    g.set_y_min( minValue );
    g.set_y_max( maxValue );
    g.set_y_label_steps( (maxValue - minValue) / 500 );
    g.set_y_legend( 'Różnica dochody/rozchody', 12, '#164166' );
    
    render :text => g.render;
  end
  
  def graph03
    parentCat = nil
    
    parentCatId = params["parentCatId"]
    if parentCatId != nil
      tempParentCat = Category.find_by_id_and_user_id(parentCatId, current_user.id)
      if tempParentCat == nil or tempParentCat.parent == nil
        crit = "parent_id is null"
      else
        crit = "parent_id = #{tempParentCat.parent.id}"
        parentCat = tempParentCat.parent
      end
    else
      catId = params["categoryId"]
      crit = ""
      if catId == nil
        crit = "parent_id is null";
      else
        parentCat = Category.find_by_id_and_user_id(catId, current_user.id)
        if parentCat == nil
          crit = "parent_id is null";
        else
          crit = "parent_id = #{catId}"  
        end
      end
    end
    
    #parametry daty
    dateFrom = params["dateFrom"]
    dateTo = params["dateTo"]
    
    cats = Category.find_all_by_user_id(current_user.id, :conditions => crit)
    
    labels = Array.new
    values = Array.new
    links = Array.new
    
    for cat in cats
      amount = category_trans_amount(cat, dateFrom, dateTo)
      if amount > 0
        labels.push cat.name
        values.push amount
        links.push "javascript:reload(#{cat.id});"
      end
    end
    
    g = Graph.new;
    g.set_bg_color('#FFFFFF')
    
    g.pie(60,'#FFFFFF','{font-size: 7px; color: #404040;}',false,1)
    g.pie_values( values, labels, links)
    g.pie_slice_colors( ['#d01f3c','#356aa0','#C79810'] )
    g.set_tool_tip( '#x_label#: #val#' )

    title = nil
    if parentCat == nil
      title = "Kategorie główne"
    else
      title = "Kategoria: #{parentCat.name}"
    end
  
    g.title(title, '{color: #7E97A6; font-size: 20; text-align: center}' )

    render :text => g.render
  end
  
  private
    
    def category_trans_amount(cat, dateFrom = nil, dateTo = nil)
      amount = 0;
      
      crit = "category_id = #{cat.id} and return_trans_id is null and (source_account_id is null or dest_account_id is null)"
      if dateFrom != nil
        crit = crit + " and trans_date >= '#{format_db_date(Date.parse(dateFrom))}'"
      end
      if dateTo != nil
        crit = crit + " and trans_date <= '#{format_db_date(Date.parse(dateTo))}'"
      end
      
      trans = Trans.find_all_by_user_id(current_user.id, :conditions => crit)
      for t in trans
        amount = amount + t.realAmount
      end
      
      for child in cat.children
        amount = amount + category_trans_amount(child, dateFrom, dateTo)
      end
      
      return amount
    end
    
end