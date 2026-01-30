# Wedly Architecture

Technical architecture documentation for developers.

## Technology Stack

### Backend
- **Rails 7.1**: Web framework
- **MySQL**: Primary database
- **Bcrypt**: Password hashing
- **Action Mailer**: Email delivery
- **Active Job**: Background processing

### Frontend
- **ERB**: Server-side templates
- **Turbo**: SPA-like navigation (optional)
- **Vanilla JavaScript**: Minimal client-side logic
- **CSS**: Inline styles in layouts

### Infrastructure
- **Puma**: Application server
- **Nginx**: Reverse proxy (production)
- **SMTP**: Email delivery (any provider)

## Design Principles

### 1. Rails-Native
No external authentication gems or email SDKs. Uses built-in Rails features exclusively.

### 2. Minimal Dependencies
Only essential gems:
- `rails`
- `mysql2`
- `puma`
- `bcrypt`
- `turbo-rails`
- `bootsnap`

### 3. No External Services
- No Auth0, Devise, or authentication SaaS
- No SendGrid SDK (direct SMTP only)
- No hosted solutions
- 100% self-hostable

### 4. Transparent & Auditable
- Hand-rolled authentication (visible in code)
- Standard Rails patterns
- No magic or black boxes
- Easy to understand and modify

### 5. Single Wedding Focus
- Site is designed for one wedding (e.g., `alex-and-britt-wedding.ca`)
- Clean URLs without slugs or identifiers
- Wedding configuration in `config/wedding.yml`
- Accessible via `Wedding.current` singleton

## Data Model

### Core Entities

```
Wedding (1) ──────┬─────── (n) Event
                  │
                  ├─────── (n) Household
                  │               │
                  └───────────── (n) Guest
                                  │
                                  ├─ (1) RSVP
                                  └─ (n) Invitation

AdminUser (authentication only)
```

### Wedding
Primary entity representing the wedding event. This is a **singleton** - the site is designed for a single wedding.

**Configuration:**
Wedding details are configured in `config/wedding.yml` and loaded via `Wedding.current`.

**Fields:**
- `title` - Display name
- `date` - Wedding date
- `location` - Venue location
- `settings` - JSON (RSVP deadline, meal options)

**Class Methods:**
- `Wedding.current` - Returns the singleton wedding instance
- `Wedding.config` - Returns the YAML configuration

**Associations:**
- `has_many :events`
- `has_many :households`
- `has_many :guests`

### Event
Individual events within the wedding (ceremony, reception, etc.)

**Fields:**
- `wedding_id` - Foreign key
- `name` - Event name
- `datetime` - When it happens
- `location` - Where it happens
- `description` - Additional details

**Associations:**
- `belongs_to :wedding`

### Household
Groups guests who receive same invitation (families, couples, +1s)

**Fields:**
- `wedding_id` - Foreign key
- `name` - Display name ("The Smith Family")

**Associations:**
- `belongs_to :wedding`
- `has_many :guests`

**Why Households?**
- Families RSVP together
- Single invitation per household
- Shared invite link
- Simplified guest management

### Guest
Individual attendee

**Fields:**
- `wedding_id` - Foreign key
- `household_id` - Foreign key
- `first_name` - First name
- `last_name` - Last name
- `email` - Email address
- `invite_code` - Unique 10-char code
- `address` - Mailing address
- `phone_number` - Contact number

**Associations:**
- `belongs_to :wedding`
- `belongs_to :household`
- `has_one :rsvp`
- `has_many :invitations`

**Invite Code:**
- Auto-generated on create
- 10 alphanumeric characters
- Used for RSVP access
- Acts as authentication token

### RSVP
Guest response to invitation

**Fields:**
- `guest_id` - Foreign key
- `status` - pending|accepted|declined
- `meal_choice` - Selected meal
- `dietary_restrictions` - Allergies, etc.
- `notes` - Additional comments

**Associations:**
- `belongs_to :guest`

**Status Flow:**
```
pending → accepted
        → declined
```

### Invitation
Tracks email delivery to guest

**Fields:**
- `guest_id` - Foreign key
- `sent_at` - When sent
- `opened_at` - When opened (future feature)
- `status` - pending|sent|opened|bounced

**Associations:**
- `belongs_to :guest`

**Purpose:**
- Track who received invitations
- Enable resending
- Monitor delivery
- Future: Track opens/clicks

### AdminUser
Admin access to management panel

**Fields:**
- `email` - Login email (unique)
- `password_digest` - Bcrypt hash
- `name` - Display name

**Authentication:**
- `has_secure_password` (Rails built-in)
- Session-based (cookie)
- No registration endpoint
- Created via console or seed

## Application Structure

### Namespaces

#### Admin Namespace
Protected controllers for wedding management.

**Controllers:**
- `Admin::DashboardController` - Overview stats
- `Admin::EventsController` - Event CRUD
- `Admin::GuestsController` - Guest management
- `Admin::HouseholdsController` - Household management
- `Admin::InvitationsController` - Send invitations
- `Admin::SettingsController` - Wedding config
- `Admin::SessionsController` - Login/logout

**Authentication:**
- `AdminAuthentication` concern
- Checks `session[:admin_id]`
- Redirects to login if missing

#### Public Namespace
Guest-facing controllers.

**Controllers:**
- `Public::WeddingsController` - Wedding info page
- `Public::RSVPsController` - RSVP form and submission

**No Authentication:**
- Uses invite code in URL
- Find guest by code
- No session required

### Services

#### RSVPService
Handles RSVP form submission.

**Purpose:**
- Encapsulate business logic
- Keep controllers thin
- Transaction safety
- Error handling

**Pattern:**
```ruby
result = RSVPService.submit!(
  household: household,
  rsvp_params: params
)

if result[:success]
  # Handle success
else
  # Handle error with result[:error]
end
```

### Jobs

#### InvitationJob
Background job for sending emails.

**Queue:** default

**Purpose:**
- Async email delivery
- Retry on failure
- Track sending status

**Pattern:**
```ruby
InvitationJob.perform_later(guest_id)
```

### Mailers

#### InvitationMailer
Email templates for invitations.

**Methods:**
- `invite(guest)` - Send invitation email

**Templates:**
- HTML version (`invite.html.erb`)
- Plain text version (`invite.text.erb`)

**Configuration:**
- SMTP settings in environment configs
- From address from ENV
- Subject includes wedding title

## Authentication System

### Hand-Rolled Implementation

No Devise, no external gems. Clean Rails patterns.

**Components:**
1. `AdminUser` model with `has_secure_password`
2. `SessionsController` for login/logout
3. `AdminAuthentication` concern for protection
4. Session cookie stores `admin_id`

**Flow:**
```
1. Admin visits /admin/login
2. Submits email/password
3. SessionsController verifies
4. Sets session[:admin_id]
5. All admin routes check session
6. Logout clears session
```

**Security Features:**
- Bcrypt password hashing (built-in)
- CSRF protection (Rails default)
- HTTP-only cookies
- Secure cookies in production
- No password reset (console only)

**Why Hand-Rolled?**
- Transparent implementation
- No gem updates needed
- Easier to audit
- Simpler to customize
- Educational value

## Routing Structure

### Public Routes
```ruby
root 'public/weddings#show'           # Wedding info at /
get '/rsvp/:code' => 'public/rsvps#edit'
patch '/rsvp/:code' => 'public/rsvps#update'
get '/rsvp/:code/thanks' => 'public/rsvps#thanks'
```

### Admin Routes
```ruby
namespace :admin do
  get '/login' => 'sessions#new'
  post '/login' => 'sessions#create'
  delete '/logout' => 'sessions#destroy'

  root 'dashboard#index'

  resources :events
  resources :guests do
    get :export, on: :collection
  end
  resources :households
  resources :invitations, only: [:index, :create]
  resource :settings, only: [:show, :update]
end
```

## Configuration Management

### Wedding Settings
Stored in Wedding `settings` JSON field.

**Structure:**
```json
{
  "rsvp_deadline": "2026-05-15",
  "meal_options": [
    "Chicken",
    "Beef",
    "Vegetarian"
  ]
}
```

**Usage:**
- RSVP deadline validation
- Meal choice options in form
- Configurable per wedding

## Email System

### SMTP Configuration
Configured via environment variables.

**Required Variables:**
- `SMTP_ADDRESS` - SMTP server
- `SMTP_PORT` - Usually 587
- `SMTP_USERNAME` - Login
- `SMTP_PASSWORD` - Password

**Supported Providers:**
- Gmail (with app password)
- SendGrid (SMTP, not SDK)
- Amazon SES
- Mailgun
- Any SMTP server

**Why SMTP?**
- No SDK dependencies
- Provider agnostic
- Standard protocol
- Easy to switch
- Self-hosted option

### Email Flow
```
1. Admin selects guests
2. Creates InvitationJob per guest
3. Job runs asynchronously
4. Creates Invitation record
5. Sends email via SMTP
6. Updates Invitation status
7. Retries on failure
```

## View Architecture

### Layouts

#### application.html.erb
Base layout (rarely used directly).

#### admin.html.erb
Admin panel layout with:
- Navigation bar
- Alert messages
- Shared admin styles

#### admin_auth.html.erb
Login page layout (centered form).

#### public.html.erb
Public wedding site layout with:
- Wedding-specific theming
- Elegant design
- Mobile-responsive

### Partials
- `admin/events/_form.html.erb` - Event form
- `admin/guests/_form.html.erb` - Guest form
- `admin/households/_form.html.erb` - Household form

### Styling Approach
- Inline CSS in layouts
- No separate CSS files (initially)
- Easy to customize
- Self-contained
- No build step required

## State Management

### Guest RSVP State
```
pending → accepted (with meal choice)
        → declined (no meal choice)
```

### Invitation State
```
pending → sent → opened
              → bounced
```

### Admin Session State
```
logged out → logged in (session exists)
          → logged out (session cleared)
```

## Security Considerations

### Authentication
- Bcrypt password hashing (cost factor 12)
- Session-based authentication
- HTTP-only cookies
- Secure cookies in production
- CSRF protection enabled

### Authorization
- Simple: logged in = full access
- Future: role-based permissions
- Guest access: invite code only

### Data Protection
- SQL injection: Active Record escaping
- XSS: ERB auto-escaping
- CSRF: Rails protection
- Mass assignment: Strong parameters

### Email Security
- STARTTLS for SMTP
- App passwords (not account passwords)
- From address validation
- Rate limiting (future feature)

## Scalability

### Current Design
Single-server architecture suitable for:
- Hundreds of weddings
- Thousands of guests
- Standard traffic patterns

### Scaling Options

**Vertical:**
- Increase server resources
- Optimize database queries
- Add caching layer

**Horizontal:**
- Multiple app servers
- Load balancer
- Separate database server
- Redis for sessions

### Performance

**Database:**
- Indexed foreign keys
- Indexed invite codes
- Efficient queries with `includes`

**Caching:**
- Fragment caching for stats
- Russian doll caching for lists
- HTTP caching for public pages

## Testing Strategy

### Test Structure
```
test/
├── controllers/
├── models/
├── mailers/
├── jobs/
└── integration/
```

### Testing Tools
- Minitest (Rails default)
- Fixtures for test data
- Capybara for integration
- Factory pattern in helpers

### Test Coverage
Focus on:
- Authentication flows
- RSVP submission
- Email sending
- Authorization
- Business logic in services

## Deployment Architecture

### Production Stack
```
Internet
  ↓
Nginx (SSL termination, static assets)
  ↓
Puma (Rails application)
  ↓
MySQL (database)
  ↓
SMTP Server (email delivery)
```

### Environment Variables
Separate configs for:
- `development` - Local development
- `test` - Automated testing
- `production` - Live deployment

### Asset Pipeline
- Precompiled assets in production
- Fingerprinting for cache busting
- Served directly by Nginx

## Extensibility

### Easy to Add
- Photo galleries (Active Storage)
- Gift registry links
- Save-the-dates
- Seating charts
- Multi-language support
- Custom RSVP questions
- Guest check-in app

### Modification Points
- Views: Customize appearance
- Services: Add business logic
- Jobs: Add async processing
- Mailers: New email types
- Models: Additional fields

### Plugin Architecture
Rails engines could add:
- Payment processing
- Video streaming
- Guest messaging
- Photo sharing

## Code Quality

### Rails Best Practices
- Fat models, thin controllers
- Services for complex logic
- Concerns for shared behavior
- Background jobs for async work
- Strong parameters for security

### Ruby Style
- 2-space indentation
- Meaningful variable names
- Short methods (<10 lines)
- Single responsibility
- DRY principle

### Comments
- Minimal comments
- Self-documenting code
- README for overview
- Inline docs for complex logic

## Future Enhancements

### Phase 2 Features
- Save-the-date emails
- Photo gallery (Active Storage)
- Guest messaging system
- Seating chart management
- Gift registry integration
- Mobile check-in app

### Phase 3 Features
- Multi-wedding support
- Wedding website builder
- Template marketplace
- Vendor management
- Budget tracking
- Timeline planning

### Enterprise Features
- White-label option
- Multi-tenancy
- API for integrations
- Webhook system
- Advanced analytics
- A/B testing

## Contributing

### Code Standards
- Follow Rails conventions
- Write tests for new features
- Update documentation
- Keep dependencies minimal
- Maintain backward compatibility

### Architecture Principles
1. **Keep it simple**
2. **Rails-native first**
3. **No external services**
4. **Easy to fork**
5. **Self-hostable**
6. **Open source friendly**

---

**This architecture prioritizes simplicity, transparency, and long-term maintainability over clever abstractions or trendy patterns.**
