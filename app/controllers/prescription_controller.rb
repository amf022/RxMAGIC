class PrescriptionController < ApplicationController
  def index
    @prescriptions = Prescription.order(created_at: :asc)
  end

  def show
  end

  def edit
  end

  def delete
  end
end
