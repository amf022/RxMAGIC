class PmapInventoryController < ApplicationController

  def index
    @inventory = PmapInventory.where("current_quantity > 0 and voided = ?", false).order(date_received: :asc)

    @in_stock = PmapInventory.select("patient_id, rxaui, count(rxaui) as count").where("current_quantity > 0
                                      and voided = ?",false).group(:patient_id,:rxaui).length

    @aboutToExpire = PmapInventory.where("voided = ? AND current_quantity > ? AND expiration_date  BETWEEN ? AND ?",false,0,
                                            Date.today.strftime('%Y-%m-%d'),
                                            Date.today.advance(:months => 2).end_of_month.strftime('%Y-%m-%d')).length

    @expired = PmapInventory.where("voided = ? AND current_quantity > ? AND expiration_date <= ? ",
                                      false,0, Date.today.strftime('%Y-%m-%d')).pluck(:pap_identifier).length

    @underutilized = News.where({:resolved => false, :news_type => "under utilized item"}).length

  end

  def show

    @item = PmapInventory.find(params[:id]) rescue nil

    if @item.blank?
      redirect_to "/reorders"
    else
      @inventory = PmapInventory.where("voided = ? AND current_quantity > 0 AND patient_id = ? AND rxaui = ?",
                                       false, @item.patient_id, @item.rxaui).order(date_received: :asc)
      @prescriptions = Prescription.where("voided = ? AND patient_id = ? AND rxaui = ?", false, @item.patient_id,
                                          @item.rxaui).order(date_prescribed: :asc)
      @patient = @item.patient
    end
  end

  def edit

    @entry = PmapInventory.find_by_pap_identifier(params[:pmap_inventory][:pmap_inventory_id])

    if @entry.blank?
      flash[:errors] = {} if flash[:errors].blank?
      flash[:errors][:missing] = ["Item not found"]
    else
      @entry.received_quantity = params[:pmap_inventory][:amount_received].to_i + (@entry.received_quantity - @entry.current_quantity)
      @entry.current_quantity = params[:pmap_inventory][:amount_received].to_i
      @entry.lot_number = params[:pmap_inventory][:lot_number]
      @entry.expiration_date = params[:pmap_inventory][:expiry_date].to_date rescue nil
      @entry.manufacturer = params[:pmap_inventory][:manufacturer]
      if @entry.save
        flash[:success] = "#{@entry.bottle_id}  was successfully updated."
        logger.info "Pmap Item #{@entry.bottle_id} was edited by #{current_user.username}"
      else
        flash[:errors] = @entry.errors
      end

    end

    redirect_to "/pmap_inventory"
  end

  def create

    @new_stock_entry = PmapInventory.new

    @new_stock_entry.lot_number = params[:pmap_inventory][:lot_number].upcase
    @new_stock_entry.expiration_date = params[:pmap_inventory][:expiration_date].to_date rescue nil
    @new_stock_entry.reorder_date = params[:pmap_inventory][:reorder_date].to_date rescue nil
    @new_stock_entry.manufacturer = params[:pmap_inventory][:manufacturer]
    @new_stock_entry.received_quantity = params[:pmap_inventory][:received_quantity]
    @new_stock_entry.current_quantity = params[:pmap_inventory][:received_quantity]
    @new_stock_entry.rxaui = Rxnconso.where("STR = ?", params[:pmap_inventory][:item]).first.RXAUI rescue nil
    @new_stock_entry.patient_id = params[:pmap_inventory][:patient_id]

    if @new_stock_entry.rxaui.blank?
      flash[:errors] = {} if flash[:errors].blank?
      flash[:errors][:missing] = "Item #{params[:pmap_inventory][:item]} was not found"
      redirect_to "/patient/#{params[:pmap_inventory][:patient_id]}"
    else
      PmapInventory.transaction do
        @new_stock_entry.save
      end

      if @new_stock_entry.errors.blank?
        #print barcode for new bottles
        if params[:pmap_inventory][:inventory_id].blank?
          flash[:success] = "#{params[:pmap_inventory][:item]} was successfully added to inventory."
          logger.info "Pmap Item #{@new_stock_entry.id} was created by #{current_user.username}"
          print_and_redirect("/print_bottle_barcode/#{@new_stock_entry.pap_identifier}", "/patient/#{params[:pmap_inventory][:patient_id]}")
        else
          flash[:success] = "#{params[:pmap_inventory][:item]} (Lot #: #{@new_stock_entry.lot_number}) was successfully updated."
          redirect_to "/patient/#{params[:pmap_inventory][:patient_id]}"
        end
      else
        flash[:errors] = @new_stock_entry.errors
        redirect_to "/patient/#{params[:pmap_inventory][:patient_id]}"
      end
    end
  end

  def destroy
    #Delete an item from pmap inventory

    item = PmapInventory.void_item(params[:pmap_inventory][:pmap_id],params[:pmap_inventory][:reason])
    if item.blank?
      flash[:errors] = {} if flash[:errors].blank?
      flash[:errors][:missing] = ["Item was not found"]
    elsif item.errors.blank?
      flash[:success] = "#{item.drug_name} #{item.lot_number} was successfully deleted."
      news = News.where("refers_to = ? AND resolved = ?",
                        params[:pmap_inventory][:pmap_id], false).first
      unless news.blank?
        news.resolved = true
        news.resolution = "Item was voided"
        news.date_resolved= Date.today
        news.save
      end
      logger.info "Pmap Item #{params[:pmap_inventory][:pmap_id]} was deleted by #{current_user.username}"
    else
      flash[:errors] = item.errors
    end

    redirect_to "/pmap_inventory"
  end

  def move_inventory
    #Move pmap item to general inventory

    result = PmapInventory.move_to_general(params[:id])

    if result.blank?
      flash[:errors] = {} if flash[:errors].blank?
      flash[:errors][:missing] = ["Item with bottle ID #{params[:id]} was not found"]
    elsif result.errors.blank?
      News.resolve(params[:id],"under utilized item","Moved to general inventory")
      flash[:success] = " #{result.drug_name} #{result.lot_number} was successfully moved to general inventory."
    else
      flash[:errors] = result.errors
    end

    redirect_to "/pmap_inventory"
  end

  def reorders
    reorders = PmapInventory.where("reorder_date between ? AND ? AND voided = ?",
                                   Date.today.beginning_of_week.strftime("%Y-%m-%d"),
                                   Date.today.end_of_week.strftime("%Y-%m-%d"),false )

    @reorders = view_context.reorders(reorders)
  end

  def detailed_search
    reorders = PmapInventory.where("reorder_date between ? AND ? AND voided = ?",
                                   params[:pmap_inventory][:startDate].to_date.strftime("%Y-%m-%d"),
                                   params[:pmap_inventory][:endDate].to_date.strftime("%Y-%m-%d"),false )

    @reorders = view_context.reorders(reorders)

    render "reorders"

  end

  def expired_items
    @expired = PmapInventory.select("patient_id, rxaui,pap_identifier, date_received, expiration_date,current_quantity").where("voided = ? AND current_quantity > ? AND expiration_date <= ? ",
                                   false,0, Date.today.strftime('%Y-%m-%d'))

  end

  def about_to_expire
    @aboutToExpire = PmapInventory.where("voided = ? AND current_quantity > ? AND expiration_date  BETWEEN ? AND ?",false,0,
                                         Date.today.strftime('%Y-%m-%d'),
                                         Date.today.advance(:months => 2).end_of_month.strftime('%Y-%m-%d'))

  end
end
