#curl --data "jobs=4&failing=0" http://queue_who.dev/reports/

class ReportsController < ApplicationController
  before_filter :set_app

  def create
    @previous = @app.reports.sort(:created_at => -1).first

    %w{action controller}.each {|key| params.delete key }
    @current = @app.reports.create(params)

    if @previous && @current.failing > @previous.failing
      render :text => 'panic'
    else
      render :text => @current['created_at']
    end
  end

  private
    def set_app
      @app = App.first
    end
end
