require 'test_helper'

class DrugThresholdControllerTest < ActionController::TestCase
  test "should get index" do
    get :index
    assert_response :success
  end

end
