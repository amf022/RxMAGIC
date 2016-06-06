class NewsController < ApplicationController
  def index
    @news = News.where({:resolved => false}).order(created_at: :desc)
  end

  def feed

  end

  def manage_notice
    result = News.resolve(params[:reference],params[:type],params[:resolution])
    render :text => result.to_s
  end

  def alert_add_to_activity_sheet
    result = News.find(params[:id])
    unless result.blank?
      result.resolved = true
      result.resolution = 'Added to activity sheet'
      result.date_resolved = Date.today
      result.save
    end
    redirect_to "/"
  end

  def destroy
    news = News.find(params[:id])
    news.resolved = true
    news.resolution = "Ignored"
    news.date_resolved = Date.today
    news.save
    redirect_to "/"
  end
end
