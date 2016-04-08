module PatientHelper
  def patients(patientData)
    results = []
    (patientData || []).each do |patient|
      results << {"first_name" => patient[0].titleize,
                          "last_name" => patient[1].titleize,
                          "gender" => (patient[2] == "M" ? "Male" : "Female"),
                          "birthdate" => (patient[3].strftime('%b-%d-%Y') rescue ""),
                          "state" => (patient[4].upcase rescue ""),
                          "city" => (patient[5].titleize rescue ""),
                          "id" => patient[6]}
    end

    return results
  end

end
