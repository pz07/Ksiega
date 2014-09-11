class StatsController < ApplicationController
  before_filter :require_user
  
  require 'open_flash_chart'
  require 'stats_utils'
  
  def index
    all
    render :action => "all"
  end

  def all
    @inout = StatsUtils.getLastInOut(current_user.id)

    @graph01 = open_flash_chart_object('graph01', '450','250', '/chart/graph01', true)     
    @graph02 = open_flash_chart_object('graph02', '450','250', '/chart/graph02', true)     
    @graph03 = open_flash_chart_object('graph03', '400','400', '/chart/graph03', true)     
  end

  def inout
    length = 13 
    if params[:length]
      length = params[:length].to_i
    end

    @graph01 = open_flash_chart_object('graph01', '100%','250', '/chart/graph01?length=' + length.to_s, true)     
    @graph02 = open_flash_chart_object('graph02', '100%','250', '/chart/graph02?length=' + length.to_s, true)     
  end

end
