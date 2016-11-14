class RxnconsoController < ApplicationController

  def index
    respond_to do |format|
      format.html
      format.json { @items = Rxnconso.search(params[:term]) }
    end
  end

  def suggestions

    @items = Rxnconso.where("STR like ? and TTY in ('PSN', 'SCD')", "#{params[:term]}%").limit(10).collect{|x| x.STR.humanize.gsub(/\b('?[a-z])/) { $1.capitalize }}.uniq

    render :text => @items
  end

  def threshold_suggestions
    @items = Rxnconso.where("STR like ? and TTY = 'SCDC'", "%#{params[:term]}%").limit(10).collect{|x| x.STR.humanize.gsub(/\b('?[a-z])/) { $1.capitalize }}
    render :text => @items
  end

  def map_drug

    if request.post?
      map_to = Rxnconso.where("STR = ? and TTY in ('PSN', 'SCD')", "#{params[:rxnconso][:matching_drug]}").first
      if  map_to.blank?
        item = News.where.("refers_to = ?",params[:rxnconso][:ndc_code]).first
        flash[:errors] = {} if flash[:errors].blank?
        flash[:errors][:missing_reference] = ["Could not find corresponding drug"]
        redirect_to "/drug_mapping/#{item.id}"
      else
        new_code = NdcCodeMatch.create({:missing_code => params[:rxnconso][:ndc_code], :rxaui => map_to.RXAUI,
                                        :name => params[:rxnconso][:matching_drug]})
        if new_code.errors.blank?
          new_prescriptions = Hl7Error.where("code = ? AND voided = ?", params[:rxnconso][:ndc_code], false)

          (new_prescriptions || []).each do |prescription|
            new_prescription = Prescription.new
            new_prescription.patient_id = prescription.patient_id
            new_prescription.rxaui = map_to.RXAUI
            new_prescription.directions = prescription.directions
            new_prescription.quantity = prescription.quantity
            new_prescription.amount_dispensed = 0
            new_prescription.provider_id = prescription.provider_id
            new_prescription.date_prescribed = prescription.date_prescribed
            new_prescription.save
            prescription.voided = true
            prescription.save

          end

          news = News.where("refers_to = ? AND resolved = ? AND news_type = ?",params[:rxnconso][:ndc_code],
                            false,"Missing Reference")
          unless news.blank?
            (news || []).each do |news_item|
              news_item.resolved = true
              news_item.date_resolved= Date.today
              news_item.resolution = "Mapping created"
              news_item.save
            end
          end

          flash[:success] = "Mapping successfully created for #{params[:rxnconso][:matching_drug]}."
        end
        redirect_to "/"
      end
    else
      @code = News.find(params[:id]).refers_to rescue nil
      if !@code.blank?
        errors = Hl7Error.where("code = ?", @code)
        @name = errors.first.drug_name
        start_index = @name.index("(")
        end_index = @name.index(")")
        if start_index.blank?
          search_term = @name
        else
          search_term = (@name[0..(start_index - 1)] + @name[(end_index + 1)..(@name.length - 1)]).squish
        end
        @options = Rxnconso.select("RXAUI, STR").where("STR like ? AND TTY in ('PSN', 'SCD','SY')", "#{search_term}%").limit(10)
        @count = errors.length
      end

    end
  end

  def drug_mapping

  end
end
