class UserRoleController < ApplicationController
  def index
  end

  def show
  end

  def new
  end

  def edit
  end

  def create
    user = UserRole.where(username: params[:user_role][:user_name]).first_or_initialize
    user.first_name = params[:user_role][:first_name]
    user.last_name = params[:user_role][:last_name]
    user.user_role = params[:user_role][:user_role]

    if user.save
      redirect_to "/"
    else
      flash[:error] = user.errors
      redirect_to "/user_role/new"
    end
  end
end
