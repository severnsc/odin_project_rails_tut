require 'test_helper'

class UsersEditTest < ActionDispatch::IntegrationTest
  
  def setup
  	@user = users(:chris)
  end

  test "unsuccessful edit" do
  	log_in_as(@user)
  	get edit_user_path(@user)
  	assert_template 'users/edit'
  	patch user_path(@user), params: {user:{name: "",
  										   email: "foo@bar",
  										   password: "123",
  										   password_confirmation:"456"}}
	assert_template 'users/edit'  										   
  end

  test "successful edit" do
  	log_in_as(@user)
  	get edit_user_path(@user)
  	assert_template 'users/edit'
  	name = "Foo Bar"
  	email = "foo@bar.com"
  	patch user_path(@user), params:{user:{name: name,
  										  email: email,
  										  password: "",
  										  password_confirmation: ""}}
	assert_not flash.empty?
	assert_redirected_to @user
	@user.reload
	assert_equal name, @user.name
	assert_equal email, @user.email  										  
  end

  test "successful edit with friendly forward" do
    get edit_user_path(@user)
    assert_not flash.empty?
    assert_redirected_to login_url
    log_in_as(@user)
    assert_redirected_to edit_user_url(@user)
    name = "Foo Bar"
    email = "foo@bar.com"
    patch user_path(@user), params: {user:{name:name,
                                           email:email}}
    assert_not flash.empty?
    assert_redirected_to @user
    assert_nil session[:forwarding_url]
    @user.reload
    assert_equal name, @user.name
    assert_equal email, @user.email                                           
  end
end