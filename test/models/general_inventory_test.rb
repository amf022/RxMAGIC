require 'test_helper'

class GeneralInventoryTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end

  test "Blank model" do
    new_entry = GeneralInventory.new
    assert_not new_entry.save
  end

end
