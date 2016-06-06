class News < ActiveRecord::Base
  validates :refers_to, :presence => true
  validates :news_type, :presence => true
  validates :message, :presence => true

  def self.resolve(key,type,action)
    #This function handles all resolution of news items
    news = News.where("refers_to = ? AND resolved = ? AND news_type = ?",key, false,type).first
    unless news.blank?
      news.resolved = true
      news.date_resolved= Date.today
      news.resolution = action
      return news.save
    end
    return false
  end
end
