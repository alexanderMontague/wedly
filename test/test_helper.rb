ENV["RAILS_ENV"] ||= "test"
require_relative "../config/environment"
require "rails/test_help"

module ActiveSupport
  class TestCase
    fixtures :all

    def sign_in_admin(admin)
      post admin_login_path, params: { email: admin.email, password: "password" }
    end
  end
end
