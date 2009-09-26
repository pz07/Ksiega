class StatsController < ApplicationController
  require 'open_flash_chart'
  require 'stats_utils'
  
  def index
    all
    render :action => 'all'
  end

  def all
     @inout = StatsUtils.getLastInOut

     @graph01 = open_flash_chart_object('graph01', '450','250', '/chart/graph01', true)     
     @graph02 = open_flash_chart_object('graph02', '450','250', '/chart/graph02', true)     
     @graph03 = open_flash_chart_object('graph03', '400','400', '/chart/graph03', true)     
  end

end
