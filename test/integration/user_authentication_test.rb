require "test_helper"

class UserAuthenticationTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:one)
  end

  test "user can log in and log out" do
    # Login
    sign_in @user
    get root_path
    assert_response :success
    assert_select "a", ref: "logout"

    # Logout
    sign_out @user
    get root_path
    assert_response :success
    assert_select "a", ref: "login"
  end
end
