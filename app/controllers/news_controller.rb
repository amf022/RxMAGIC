class NewsController < ApplicationController
  def index
    @news = News.where({:resolved => false}).order(created_at: :desc)
  end

  def feed

  end
end
