require "test_helper"

class PagesControllerTest < ActionDispatch::IntegrationTest
  test "should get services" do
    get pages_services_url
    assert_response :success
  end
end
