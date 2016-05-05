class NewsController < ApplicationController
  def index
    @news = News.where({:resolved => false}).order(created_at: :desc)
  end

  def feed

  end

  def destroy
    news = News.find(params[:id])
    news.resolved = true
    news.save
    redirect_to "/"
  end
end
