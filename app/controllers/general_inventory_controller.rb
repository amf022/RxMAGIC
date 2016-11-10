class GeneralInventoryController < ApplicationController
  def index
    #List of all general inventory items

    @inventory = GeneralInventory.where("current_quantity > ? and voided = ?",
                                        0, false).pluck(:gn_inventory_id, :gn_identifier,:lot_number,:current_quantity,
                                                        :expiration_date, :rxaui)

    concepts = Rxnconso.where("rxaui in (?)", @inventory.collect{|x| x[5]}.uniq).pluck(:rxaui,:rxcui,:STR)

    @keys= concepts.inject({}) do |result, element|
      result[element[0]] = element[2]  rescue " "
      result
    end

    concept_map = concepts.inject({}) do |result, element|
      result[element[0]] = element[1]  rescue " "
      result
    end

    items = Hash.new(0)
    wellStocked = []
    underStocked = []
    aboutToExpire_items = []
    expired_items = []

    (@inventory || []).each do |item|
      items[concept_map[item[5]]] += item[3]
      expired_items << item[0] if (item[4] <= Date.today)
      aboutToExpire_items << item[0] if (item[4] >= Date.today && item[4] <= Date.today.advance(:months => 2))
    end

    thresholds = Misc.calculate_gn_thresholds


    (thresholds || []).each do |id, details|
      if details["count"] > details["threshold"]
        wellStocked << {"drug_name" => details["name"], "threshold" => details["threshold"],
                         "available" => details["count"], "id" => id}
      elsif details["count"] <= details["threshold"]
        underStocked << {"drug_name" => details["name"], "threshold" => details["threshold"],
                         "available" => details["count"], "id" => id}
      end
    end
    @aboutToExpire = aboutToExpire_items.length
    @underStocked = underStocked.length
    @expired = expired_items.length
    @wellStocked = wellStocked.length

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
      @new_stock_entry.rxaui = Rxnconso.where("STR = ? AND TTY = 'PSN'",
                                              params[:edit_general_inventory][:item]).first.RXAUI rescue nil
      @new_stock_entry.lot_number = params[:edit_general_inventory][:lot_number].upcase
      @new_stock_entry.expiration_date = params[:edit_general_inventory][:expiration_date].to_date rescue nil
      @new_stock_entry.received_quantity = params[:edit_general_inventory][:received_quantity].to_i + (@new_stock_entry.received_quantity - @new_stock_entry.current_quantity)
      @new_stock_entry.current_quantity = params[:edit_general_inventory][:received_quantity].to_i

      if @new_stock_entry.rxaui.blank?
        flash[:errors] = {} if flash[:errors].blank?
        flash[:errors][:missing] = ["Item #{params[:edit_general_inventory][:item]} was not found"]
        redirect_to "/general_inventory"
      else
        GeneralInventory.transaction do
          @new_stock_entry.save
          logger.info "#{current_user.username} edited general inventory item #{params[:edit_general_inventory][:gn_id]}"
        end
      end

      if @new_stock_entry.errors.blank?
        flash[:success] = "#{@new_stock_entry.drug_name} (Lot #: #{@new_stock_entry.lot_number}) was successfully updated."
      else
        flash[:errors] = @new_stock_entry.errors
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
    @new_stock_entry.rxaui = Rxnconso.where("STR = ? AND TTY = 'PSN'", params[:general_inventory][:item]).first.RXAUI rescue nil
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

    thresholds = Misc.calculate_gn_thresholds

    @underStocked =[]

    (thresholds || []).each do |id, details|
      if details["count"] <= details["threshold"]
        @underStocked << {"drug_name" => details["name"], "threshold" => details["threshold"],
                          "available" => details["count"], "id" => id}
      end
    end
  end

  def wellstocked

    #list items that are well stocked.

    thresholds = Misc.calculate_gn_thresholds

    @wellStocked = []

    (thresholds || []).each do |id, details|
      if details["count"] > details["threshold"]
        @wellStocked << {"drug_name" => details["name"], "threshold" => details["threshold"],
                          "available" => details["count"], "id" => id}
      end
    end
  end
end
