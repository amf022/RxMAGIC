class NewsController < ApplicationController
  def index
    @news = News.where({:resolved => false}).order(created_at: :desc)
  end

  def feed

  end

  def manage_notice
    result = News.resolve(params[:reference],params[:type],params[:resolution])
    logger.info "Alert #{params[:reference]} resolved by user #{session[:user]}"
    render :text => result.to_s
  end

  def alert_add_to_activity_sheet
    result = News.find(params[:id])
    unless result.blank?
      result.resolved = true
      result.resolution = 'Added to activity sheet'
      result.date_resolved = Date.today
      result.save
      logger.info "Alert #{params[:id]} resolved by user #{session[:user]}"
    end
    redirect_to "/"
  end

  def destroy
    news = News.find(params[:id])
    news.resolved = true
    news.resolution = "Ignored"
    news.date_resolved = Date.today
    news.save
    logger.info "Alert #{params[:id]} ignored by user #{session[:user]}"
    redirect_to "/"
  end
end
