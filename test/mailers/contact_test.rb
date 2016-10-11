require 'test_helper'

class ContactTest < ActionMailer::TestCase
  # test "the truth" do
  #   assert true
  # end

  def test_email
    Contact.report_contact
  end
end
