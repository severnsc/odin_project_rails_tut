require 'test_helper'

class UserTest < ActiveSupport::TestCase
  
  def setup
  	@user = User.new(name: "Example User", email: "user@example.com", password: "foobar12", password_confirmation: "foobar12")
  end

  test "should be valid" do
  	assert @user.valid?
  end

  test "name should be present" do
  	@user.name = "    "
  	assert_not @user.valid?
  end

  test "email should be present" do
  	@user.email = "     "
  	assert_not @user.valid?
  end

  test "name should not be too long" do
  	@user.name = "a" * 51
  	assert_not @user.valid?
  end

  test "email should not be too long" do
  	@user.email = "a" * 244 + "@example.com"
  	assert_not @user.valid?
  end

  test "email validation should accept valid email addresses" do
  	valid_addresses = %w[user@example.com USER@foo.com A_US-ER@foo.bar.org first.last@foo.jp alice+bob@baz.cn]
  	valid_addresses.each do |valid|
  		@user.email = valid
  		assert @user.valid?, "#{valid.inspect} should be valid"
  	end
  end

  test "email validation should not accept invalid email addresses" do
  	invalid_addresses = %w[user@example,com user_at_foo.org user.name@example. foo@bar_baz.com foo@bar+baz.com foo@bar..com]
  	invalid_addresses.each do |invalid|
  		@user.email = invalid
  		assert_not @user.valid?, "#{invalid.inspect} should not be valid"
  	end
  end

  test "email addresses should be unique" do
  	duplicate_user = @user.dup
  	duplicate_user.email = @user.email.upcase
  	@user.save
  	assert_not duplicate_user.valid?
  end

  test "email addresses should be saved as all lower case" do
  	mixed_case_email = "FoO@ExAmPlE.CoM"
  	@user.email = mixed_case_email
  	@user.save
  	assert_equal mixed_case_email.downcase, @user.email
  end

  test "password should be present" do
    @user.password = @user.password_confirmation = " " * 8
    assert_not @user.valid?
  end

  test "password should have a minimum of 8 characters" do
    @user.password = @user.password_confirmation = "a" * 6
    assert_not @user.valid?
  end

  test "authenticated? should return false for a user with a nil digest" do
    assert_not @user.authenticated?('password', '')
  end

  test "associated microposts deleted when user is deleted" do
    @user.save
    @user.microposts.create!(content: "Lorem impsum")
    assert_difference 'Micropost.count', -1 do
      @user.destroy
    end
  end

  test "should follow and unfollow other user" do
    chris = users(:chris)
    archer = users(:archer)
    assert_not chris.following?(archer)
    chris.follow(archer)
    assert chris.following?(archer)
    assert archer.followers.include?(chris)
    chris.unfollow(archer)
    assert_not chris.following?(archer)
  end

  test "feed should have the right microposts" do
    chris = users(:chris)
    archer = users(:archer)
    lana = users(:lana)
    lana.microposts.each do |post|
      assert chris.feed.include?(post)
    end
    chris.microposts.each do |post|
      assert chris.feed.include?(post)
    end
    archer.microposts.each do |post|
      assert_not chris.feed.include?(post)
    end
  end
end