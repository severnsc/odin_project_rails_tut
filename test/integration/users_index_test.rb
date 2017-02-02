require 'test_helper'

class UsersIndexTest < ActionDispatch::IntegrationTest

	def setup
		@admin = users(:chris)
		@user = users(:archer)
		@unactivated = users(:krieger)
	end

	test "index as admin including pagination and delete links" do
		log_in_as(@admin)
		get users_path
		assert_template 'users/index'
		assert_select 'div.pagination'
		first_page_of_users = User.where(activated: true).paginate(page: 1)
		first_page_of_users.each do |user|
			assert_select 'a[href=?]', user_path(user), text: user.name
			unless user == @admin
				assert_select 'a[href=?]', user_path(user), text: 'delete'
			end
		end
		assert_difference 'User.count', -1 do
			delete user_path(@user)
		end
	end

	test "index as non-admin" do
		log_in_as(@user)
		get users_path
		assert_select 'a', text: 'delete', count: 0
	end

	test "index only shows activated users" do
		log_in_as(@user)
		get users_path
		assert_select 'a[href=?]', user_path(@unactivated), false
	end

	test "unactivated users shouldn't have show pages" do
		log_in_as(@user)
		get user_path(@unactivated)
		assert_redirected_to root_url
	end
end