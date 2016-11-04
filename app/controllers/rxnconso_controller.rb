class RxnconsoController < ApplicationController

  def index
    respond_to do |format|
      format.html
      format.json { @items = Rxnconso.search(params[:term]) }
    end
  end

  def suggestions

    @items = Rxnconso.where("STR like ? and TTY = 'PSN'", "%#{params[:term]}%").limit(10).collect{|x| x.STR.humanize.gsub(/\b('?[a-z])/) { $1.capitalize }}
    render :text => @items
  end

  def threshold_suggestions
    @items = Rxnconso.where("STR like ? and TTY = 'SCDC'", "%#{params[:term]}%").limit(10).collect{|x| x.STR.humanize.gsub(/\b('?[a-z])/) { $1.capitalize }}
    render :text => @items
  end
end
