class GeneralInventoryController < ApplicationController
  def index
    #List of all general inventory items

    @inventory = GeneralInventory.select("rxaui, sum(current_quantity) as current_quantity").where("voided = ?", false).group("rxaui")

    @keys= Hash[*Rxnconso.where("rxaui in (?)", @inventory.collect{|x| x.rxaui}.uniq).pluck(:rxaui,:STR).flatten(1)]

    thresholds = DrugThreshold.where("voided = ?", false).pluck(:rxcui, :threshold)

    @expired = GeneralInventory.where("voided = ? AND current_quantity > ? AND expiration_date <= ? ", false,0,
                                      Date.today.strftime('%Y-%m-%d')).pluck(:gn_identifier)

    @aboutToExpire = GeneralInventory.where("voided = ? AND current_quantity > ? AND expiration_date  BETWEEN ? AND ?",false,0,
                                            Date.today.strftime('%Y-%m-%d'),
                                            Date.today.advance(:months => 2).end_of_month.strftime('%Y-%m-%d'))

    @underStocked = []

    @wellStocked = []


    items = Hash[*GeneralInventory.find_by_sql("SELECT (SELECT RXCUI FROM RXNCONSO where RXAUI = gn.rxaui LIMIT 1) as rxcui,
                                          sum(gn.current_quantity) as current_quantity from general_inventories gn where
                                          voided = false group by rxcui").collect{|x| [x.rxcui, x.current_quantity]}.flatten(1)]


    (thresholds || []).each do |threshold|

      if items[threshold[0]].blank?
        @underStocked << threshold[0]
      elsif items[threshold[0]] <= threshold[1]
        @underStocked << threshold[0]
      else
        @wellStocked << threshold[0]
      end
    end

    @wellStocked = @wellStocked + (items.keys - thresholds.collect{|x| x[0]})
  end

  def view_drug
    @inventory = GeneralInventory.where("current_quantity > ? and voided = ? and rxaui = ?",
                                        0, false, params[:id]).pluck(:gn_inventory_id, :gn_identifier,:lot_number,
                                                                     :current_quantity, :expiration_date)
  end

  def new

  end

  def edit
    #Code block to edit a change to general inventory items

    @new_stock_entry = GeneralInventory.find(params[:edit_general_inventory][:inventory_id])

    if @new_stock_entry.blank?
      flash[:errors] = {} if flash[:errors].blank?
      flash[:errors][:missing] = ["Item could not be found"]
    else
      @new_stock_entry.lot_number = params[:edit_general_inventory][:lot_number].upcase
      @new_stock_entry.expiration_date = params[:edit_general_inventory][:expiration_date].to_date rescue nil

      if (@new_stock_entry.received_quantity - @new_stock_entry.current_quantity) > params[:edit_general_inventory][:received_quantity].to_f
        flash[:errors]["counts"] = [" The number of items that have already been dispensed from this bottle is more than the received quantity."]
      else
        @new_stock_entry.current_quantity = params[:edit_general_inventory][:received_quantity].to_i - (@new_stock_entry.received_quantity - @new_stock_entry.current_quantity)
	@new_stock_entry.received_quantity = params[:edit_general_inventory][:received_quantity]
        
	GeneralInventory.transaction do
          @new_stock_entry.save
          logger.info "#{current_user.username} edited general inventory item #{params[:edit_general_inventory][:gn_id]}"
        end
        if @new_stock_entry.errors.blank?
          flash[:success] = "#{@new_stock_entry.drug_name} (Lot #: #{@new_stock_entry.lot_number}) was successfully updated."
        else
          flash[:errors] = @new_stock_entry.errors
        end
      end

    end

    redirect_to "/general_inventory"

  end

  def destroy
    #Delete an item from general inventory

    item = GeneralInventory.void_item(params[:general_inventory][:gn_id],params[:general_inventory][:reason])
    if item.blank?
      flash[:errors] = {} if flash[:errors].blank?
      flash[:errors][:missing] = ["Item with bottle id #{params[:general_inventory][:gn_id]} could not be found"]
    elsif item.errors.blank?
      flash[:success] = "#{item.drug_name} #{item.lot_number} was successfully deleted."
      news = News.where("refers_to = ? AND resolved = ?",
                        params[:general_inventory][:gn_id], false).first
      unless news.blank?
        news.resolved = true
        news.resolution = "Item was voided"
        news.date_resolved= Date.today
        news.save
        logger.info "#{current_user.username} voided general inventory item #{params[:general_inventory][:gn_id]}"
      end
    else
      flash[:errors] = item.errors
    end

    redirect_to "/general_inventory"
  end

  def create

    # Create a new record for general inventory
    name = params[:general_inventory][:item]
    @new_stock_entry = GeneralInventory.new
    @new_stock_entry.rxaui = Rxnconso.where("STR = ?", params[:general_inventory][:item]).first.RXAUI rescue nil
    @new_stock_entry.current_quantity = params[:general_inventory][:received_quantity]
    @new_stock_entry.lot_number = params[:general_inventory][:lot_number].upcase
    @new_stock_entry.expiration_date = params[:general_inventory][:expiration_date].to_date rescue nil
    @new_stock_entry.received_quantity = params[:general_inventory][:received_quantity]

    if @new_stock_entry.rxaui.blank?
      flash[:errors] = {} if flash[:errors].blank?
      flash[:errors][:missing] = ["Item #{name} was not found"]
      redirect_to "/general_inventory"
    else
      GeneralInventory.transaction do
        @new_stock_entry.save
      end

      if @new_stock_entry.errors.blank?
        #print barcode for new bottles
        flash[:success] = "#{name} was successfully added to inventory."
        print_and_redirect("/print_bottle_barcode/#{@new_stock_entry.gn_identifier}", "/general_inventory")
      else
        flash[:errors] = @new_stock_entry.errors
        redirect_to "/general_inventory"
      end
    end
  end

  def expired_items
    #This funtion retrieves all the expired items

    items = GeneralInventory.where("voided = ? AND current_quantity > ? AND expiration_date <= ? ", false,0, Date.today.strftime('%Y-%m-%d'))

    @expired = view_context.expired_items(items)
  end

  def expiring_items
    #this function retrieves all the items that will expire in the next two months

    items = GeneralInventory.where("voided = ? AND current_quantity > ? AND expiration_date  BETWEEN ? AND ?",false,0,
                                                    Date.today.strftime('%Y-%m-%d'),
                                                    Date.today.advance(:months => 2).end_of_month.strftime('%Y-%m-%d'))

    @expired = view_context.expired_items(items)
  end

  def understocked
    #List items that are understocked

    thresholds = DrugThreshold.where("voided = ?", false)
    @underStocked = []

    items = GeneralInventory.where("voided = ?", false).group(:rxaui).sum(:current_quantity)

    (thresholds || []).each do |threshold|
      if items[threshold.rxaui].blank?
        @underStocked << {
            "drug_name" => threshold.drug_name,
            "threshold" => threshold.threshold,
            "available" => 0,
            "rxaui" => threshold.rxaui
        }
      elsif items[threshold.rxaui] <= threshold.threshold
        @underStocked << {
            "drug_name" => threshold.drug_name,
            "threshold" => threshold.threshold,
            "available" => items[threshold.rxaui],
            "rxaui" => threshold.rxaui
        }
      end
    end
  end

  def wellstocked

    #list items that are well stocked.

    thresholds = Hash[*DrugThreshold.where("voided = ?", false).pluck(:rxaui, :threshold).flatten(1)]

    @wellStocked = []

    items = GeneralInventory.select("rxaui,SUM(current_quantity) as current_quantity").where("voided = ? AND current_quantity > 0", false).group("rxaui")
    (items || []).each do |item|

      if !thresholds[item.rxaui].blank?
        if item.current_quantity <= thresholds[item.rxaui]
          next
        end
      end

      @wellStocked << {
          "drug_name" => item.drug_name,
          "threshold" => (thresholds[item.rxaui].blank? ? "Unspecified" : thresholds[item.rxaui]),
          "available" => item.current_quantity
      }
    end
  end
end
