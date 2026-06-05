ENV["RAILS_ENV"] ||= "test"
require_relative "../config/environment"
require "rails/test_help"

module ActiveSupport
  class TestCase
    fixtures :all

    def sign_in_admin(admin)
      post admin_login_path, params: { email: admin.email, password: "password" }
    end

    def with_env(overrides)
      original = overrides.keys.index_with { |key| ENV.fetch(key, nil) }
      overrides.each { |key, value| value.nil? ? ENV.delete(key) : ENV[key] = value }
      yield
    ensure
      original.each { |key, value| value.nil? ? ENV.delete(key) : ENV[key] = value }
    end
  end
end
