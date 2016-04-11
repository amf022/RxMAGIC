class MainController < ApplicationController

  def index
    #This is the landing page for the application
    @alerts = News.where({:resolved => false}).order(created_at: :desc)
  end

  def dashboard
    #This is the function that handles the dashboard page
    render :layout => false
  end

	def about
		#This page displays application details
	end
end
