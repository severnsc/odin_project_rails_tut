require 'test_helper'

class UsersEditTest < ActionDispatch::IntegrationTest
  
  def setup
  	@user = users(:chris)
  end

  test "unsuccessful edit" do
  	get edit_user_path(@user)
  	assert_template 'users/edit'
  	patch user_path(@user), params: {user:{name: "",
  										   email: "foo@bar",
  										   password: "123",
  										   password_confirmation:"456"}}
	assert_template 'users/edit'  										   
  end
end
