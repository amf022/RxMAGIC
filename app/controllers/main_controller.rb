class MainController < ApplicationController

  def index
    #This is the landing page for the application

  end

  def dashboard
    #This is the function that handles the dashboard page
    render :layout => false
  end

	def about
		#This page displays application details
	end
end
