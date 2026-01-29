# Admin Authentication

Wedly uses a simple, hand-rolled authentication system using Rails' `has_secure_password` and bcrypt. No external gems required.

## Overview

- Session-based authentication
- Bcrypt password hashing
- No user registration (admin-created only)
- No external authentication services
- No complex permission systems

## Architecture

### AdminUser Model

```ruby
class AdminUser < ApplicationRecord
  has_secure_password
  
  validates :email, presence: true, uniqueness: true
  validates :password, length: { minimum: 6 }
end
```

### Session Management

Sessions are stored in encrypted cookies:
- Session data includes only `admin_id`
- No sensitive data in session
- Automatic expiration on browser close
- CSRF protection enabled

### Authentication Flow

1. Admin visits `/admin/login`
2. Enters email and password
3. `SessionsController` verifies credentials
4. On success: `session[:admin_id]` is set
5. All admin routes check for valid session
6. Logout clears session

## Initial Setup

### Create First Admin User

During `rails db:seed`:
```bash
rails db:seed
```

This creates:
- Email: `admin@wedly.com`
- Password: `password`

**⚠️ Change this immediately in production!**

### Manual Admin Creation

```bash
rails console

AdminUser.create!(
  email: 'your-email@example.com',
  password: 'your-secure-password',
  name: 'Your Name'
)
```

## Security Features

### Password Requirements

Currently enforced:
- Minimum 6 characters
- Required for new records
- Optional for updates (unless changing)

To add stronger requirements, update `app/models/admin_user.rb`:

```ruby
validates :password, format: {
  with: /\A(?=.*[a-z])(?=.*[A-Z])(?=.*\d)/,
  message: "must include uppercase, lowercase, and number"
}, if: -> { new_record? || password.present? }
```

### Session Security

Configure in `config/initializers/session_store.rb`:

```ruby
Rails.application.config.session_store :cookie_store,
  key: '_wedly_session',
  secure: Rails.env.production?,  # HTTPS only in production
  httponly: true,                  # Not accessible via JavaScript
  same_site: :lax                  # CSRF protection
```

### Rate Limiting

Add to `config/initializers/rack_attack.rb`:

```ruby
class Rack::Attack
  throttle('admin_login', limit: 5, period: 60.seconds) do |req|
    if req.path == '/admin/login' && req.post?
      req.ip
    end
  end
end
```

Then add to `Gemfile` and `config/application.rb`:
```ruby
# Gemfile
gem 'rack-attack'

# config/application.rb
config.middleware.use Rack::Attack
```

## Common Tasks

### Change Admin Password

```bash
rails console

admin = AdminUser.find_by(email: 'admin@wedly.com')
admin.update!(password: 'new-secure-password')
```

### Create Additional Admins

```bash
rails console

AdminUser.create!(
  email: 'second-admin@example.com',
  password: 'secure-password',
  name: 'Second Admin'
)
```

### Delete Admin User

```bash
rails console

AdminUser.find_by(email: 'old-admin@example.com').destroy
```

### Reset Password

Create a rake task in `lib/tasks/admin.rake`:

```ruby
namespace :admin do
  desc "Reset admin password"
  task :reset_password, [:email] => :environment do |t, args|
    admin = AdminUser.find_by!(email: args[:email])
    new_password = SecureRandom.alphanumeric(12)
    admin.update!(password: new_password)
    puts "Password reset for #{admin.email}: #{new_password}"
  end
end
```

Usage:
```bash
rails admin:reset_password[admin@wedly.com]
```

## Customization

### Add Multi-Tenancy

If you want multiple weddings with separate admin access:

```ruby
# Migration
add_reference :admin_users, :wedding, foreign_key: true

# Model
class AdminUser < ApplicationRecord
  belongs_to :wedding, optional: true
  has_secure_password
end

# Controller concern
def current_wedding
  @current_wedding ||= current_admin.wedding || Wedding.first
end
```

### Add Role-Based Access

Add roles to admin users:

```ruby
# Migration
add_column :admin_users, :role, :string, default: 'editor'

# Model
class AdminUser < ApplicationRecord
  ROLES = %w[admin editor viewer].freeze
  validates :role, inclusion: { in: ROLES }
  
  def admin?
    role == 'admin'
  end
end

# Controller
def require_admin_role
  redirect_to admin_root_path unless current_admin.admin?
end
```

### Add Two-Factor Authentication

For high-security needs:

```ruby
# Gemfile
gem 'rotp'
gem 'rqrcode'

# Migration
add_column :admin_users, :otp_secret, :string
add_column :admin_users, :otp_enabled, :boolean, default: false

# Model
class AdminUser < ApplicationRecord
  has_secure_password
  
  def otp_provisioning_uri
    return unless otp_secret
    ROTP::TOTP.new(otp_secret).provisioning_uri(email)
  end
  
  def verify_otp(code)
    return false unless otp_enabled?
    ROTP::TOTP.new(otp_secret).verify(code, drift_behind: 15)
  end
end
```

## Audit Logging

Track admin actions:

```ruby
# Migration
create_table :admin_logs do |t|
  t.references :admin_user, null: false, foreign_key: true
  t.string :action, null: false
  t.string :resource_type
  t.integer :resource_id
  t.json :changes
  t.string :ip_address
  t.timestamps
end

# Model
class AdminLog < ApplicationRecord
  belongs_to :admin_user
end

# Controller concern
after_action :log_admin_action

def log_admin_action
  AdminLog.create!(
    admin_user: current_admin,
    action: action_name,
    resource_type: controller_name,
    resource_id: params[:id],
    ip_address: request.remote_ip
  )
end
```

## Testing Authentication

### RSpec Example

```ruby
require 'rails_helper'

RSpec.describe 'Admin Authentication', type: :request do
  let(:admin) { create(:admin_user) }
  
  describe 'GET /admin/dashboard' do
    context 'when not logged in' do
      it 'redirects to login' do
        get admin_root_path
        expect(response).to redirect_to(admin_login_path)
      end
    end
    
    context 'when logged in' do
      before { sign_in(admin) }
      
      it 'shows dashboard' do
        get admin_root_path
        expect(response).to have_http_status(:success)
      end
    end
  end
end
```

## Security Best Practices

1. **Strong Passwords**: Enforce strong password policies
2. **HTTPS Only**: Use SSL in production
3. **Session Timeout**: Implement automatic logout
4. **Audit Trail**: Log all admin actions
5. **Rate Limiting**: Prevent brute force attacks
6. **Regular Updates**: Keep Rails and gems updated
7. **Environment Variables**: Never commit credentials
8. **Backup**: Regular backups of admin user data

## Troubleshooting

### Locked Out

If you can't log in:

```bash
rails console

# Reset password
admin = AdminUser.first
admin.update!(password: 'temporary-password')
```

### Session Issues

Clear sessions:
```bash
rails console

# Clear all sessions (not applicable with cookie store)
# For database session store:
ActiveRecord::SessionStore::Session.delete_all
```

### Password Not Updating

Ensure you're using `update!` or `save!`:
```ruby
# Wrong
admin.password = 'new-password'
admin.save(validate: false)

# Correct
admin.update!(password: 'new-password')
```

## Production Checklist

- [ ] Change default admin password
- [ ] Use HTTPS only
- [ ] Enable CSRF protection
- [ ] Configure secure session cookies
- [ ] Implement rate limiting
- [ ] Set up audit logging
- [ ] Document admin procedures
- [ ] Create backup admin account
- [ ] Test login/logout flow
- [ ] Verify session expiration
