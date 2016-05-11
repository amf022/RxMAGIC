class News < ActiveRecord::Base
  validates :references, :presence => true
  validates :news_type, :presence => true
  validates :message, :presence => true
end
