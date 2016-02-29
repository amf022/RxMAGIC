class RxnconsoController < ApplicationController


  def index
    respond_to do |format|
      format.html
      format.json { @items = Rxnconso.search(params[:term]) }
    end
  end

end
