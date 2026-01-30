# RSVP Flow Documentation

Complete guide to how the RSVP system works in Wedly.

## Overview

The RSVP system is designed around households, not individual guests. This allows multiple family members to RSVP together using a single invitation code.

## Data Model

```
Wedding
  └── Household (e.g., "The Smith Family")
      └── Guest (John Smith)
          ├── RSVP (John's response)
          └── Invitation (email sent to John)
      └── Guest (Jane Smith)
          └── RSVP (Jane's response)
```

## Key Concepts

### Households

Households group guests who receive the same invitation:
- Families (parents and children)
- Couples
- Individual guests
- Plus-ones

**Example:**
```ruby
household = Household.create!(
  wedding: wedding,
  name: "The Smith Family"
)

# Add family members
Guest.create!(
  wedding: wedding,
  household: household,
  first_name: "John",
  last_name: "Smith",
  email: "john.smith@example.com"
)

Guest.create!(
  wedding: wedding,
  household: household,
  first_name: "Jane",
  last_name: "Smith"
  # No email - will use John's invitation
)
```

### Invite Codes

Each guest receives a unique 10-character alphanumeric code:
- Auto-generated on guest creation
- Used to access RSVP form
- No password required
- Cannot be changed (for tracking)

**Format:** `ABCD123456`

### RSVP Status

Three possible statuses:
- `pending`: Not yet responded
- `accepted`: Attending the wedding
- `declined`: Not attending

## User Flow

### 1. Admin Creates Guests

```ruby
# Admin creates household
household = Household.create!(
  wedding: @wedding,
  name: "The Johnson Family"
)

# Admin adds guests to household
Guest.create!(
  wedding: @wedding,
  household: household,
  first_name: "Robert",
  last_name: "Johnson",
  email: "robert@example.com"
)
```

### 2. Admin Sends Invitations

From Admin > Invitations:
1. Select guests to invite
2. Click "Send Invitations"
3. System queues background jobs
4. Emails sent via SMTP
5. Status tracked in Invitations table

**Email includes:**
- Wedding details
- Event information
- Unique RSVP link: `/rsvp/ABCD123456`

### 3. Guest Receives Email

Email contains:
- Personal greeting
- Wedding date and location
- RSVP button with unique link
- Plain text link as backup

### 4. Guest Clicks RSVP Link

URL: `https://yourwedding.com/rsvp/ABCD123456`

System:
1. Finds guest by invite code
2. Loads household members
3. Shows RSVP form for entire household

### 5. Guest Completes RSVP

Form shows:
- All household members
- Attending/declining radio buttons
- Meal preferences (if accepting)
- Dietary restrictions field
- Notes field

**Per guest:**
- ✓ Attending / ✗ Not attending
- Meal choice (if attending)
- Dietary restrictions
- Special notes

### 6. Guest Submits RSVP

On submit:
1. Validates all responses
2. Saves RSVP for each household member
3. Clears meal choices for declined guests
4. Redirects to thank you page
5. Updates admin dashboard stats

### 7. Admin Views Responses

Admin can see:
- Dashboard with stats
- Guest list with RSVP status
- Individual response details
- Meal choice summary
- Dietary restrictions

## Technical Implementation

### Routes

```ruby
namespace :public do
  get '/rsvp/:code', to: 'rsvps#edit', as: :rsvp
  patch '/rsvp/:code', to: 'rsvps#update'
  get '/rsvp/:code/thanks', to: 'rsvps#thanks', as: :rsvp_thanks
end
```

### Controller

```ruby
class Public::RSVPsController < ApplicationController
  def edit
    @guest = Guest.find_by!(invite_code: params[:code])
    @household = @guest.household
    @guests = @household.guests.includes(:rsvp)
  end

  def update
    result = RSVPService.submit!(
      household: @guest.household,
      rsvp_params: params[:rsvps]
    )
    # Handle result
  end
end
```

### Service

```ruby
class RSVPService
  def self.submit!(household:, rsvp_params:)
    ActiveRecord::Base.transaction do
      rsvp_params.each do |guest_id, attributes|
        guest = household.guests.find(guest_id)
        guest.rsvp.update!(
          status: attributes[:status],
          meal_choice: attributes[:status] == 'accepted' ? attributes[:meal_choice] : nil,
          dietary_restrictions: attributes[:dietary_restrictions],
          notes: attributes[:notes]
        )
      end
    end
  end
end
```

## Advanced Features

### Conditional Meal Selection

Meal choices only shown if guest accepts:

```javascript
// In view
const acceptedRadio = document.getElementById('guest_1_accepted');
const mealChoice = document.getElementById('meal_choice_1');

acceptedRadio.addEventListener('change', function() {
  mealChoice.style.display = 'block';
});
```

### Household RSVP Tracking

Track if entire household responded:

```ruby
class Household < ApplicationRecord
  def all_responded?
    guests.all? { |g| g.rsvp.status != 'pending' }
  end

  def response_rate
    total = guests.count
    responded = guests.count { |g| g.rsvp.status != 'pending' }
    (responded.to_f / total * 100).round(1)
  end
end
```

### Deadline Enforcement

Add RSVP deadline check:

```ruby
# In Wedding model
def rsvp_open?
  return true if rsvp_deadline.nil?
  Date.current <= rsvp_deadline
end

# In controller
def edit
  @guest = Guest.find_by!(invite_code: params[:code])

  unless @guest.wedding.rsvp_open?
    redirect_to root_path,
                alert: "RSVP deadline has passed"
  end
end
```

### Plus-One Management

Handle plus-ones (guest brings unnamed guest):

```ruby
# Migration
add_column :guests, :plus_one_allowed, :boolean, default: false
add_column :guests, :plus_one_name, :string

# View
<% if guest.plus_one_allowed? %>
  <%= rsvp_f.text_field :plus_one_name,
                        placeholder: "Name of your guest" %>
<% end %>
```

### Partial Household Responses

Allow some household members to attend while others decline:

```ruby
# Already supported by design!
# Each guest has independent RSVP record
household.guests.map(&:rsvp_status)
# => ["accepted", "declined", "pending"]
```

## Customization

### Custom Meal Options

Configure in Admin > Settings:

```ruby
# In Wedding settings
{
  meal_options: [
    "Filet Mignon",
    "Grilled Salmon",
    "Vegetarian Pasta",
    "Vegan Option",
    "Child's Meal"
  ]
}
```

### Additional RSVP Fields

Add custom fields:

```ruby
# Migration
add_column :rsvps, :transportation_needed, :boolean, default: false
add_column :rsvps, :song_request, :string

# Update form and controller to handle new fields
```

### RSVP Reminders

Send reminder emails:

```ruby
# lib/tasks/rsvp.rake
namespace :rsvp do
  desc "Send reminders to pending RSVPs"
  task send_reminders: :environment do
    wedding = Wedding.first
    deadline = wedding.rsvp_deadline

    next unless deadline && deadline - 7.days <= Date.current

    wedding.guests.rsvp_pending.with_email.each do |guest|
      ReminderMailer.rsvp_reminder(guest).deliver_later
    end
  end
end
```

## Reporting

### Summary Statistics

```ruby
class Wedding < ApplicationRecord
  def rsvp_summary
    total = guests.count
    accepted = guests.rsvp_accepted.count
    declined = guests.rsvp_declined.count
    pending = guests.rsvp_pending.count

    {
      total: total,
      accepted: accepted,
      declined: declined,
      pending: pending,
      response_rate: ((total - pending).to_f / total * 100).round(1),
      acceptance_rate: accepted > 0 ? (accepted.to_f / (accepted + declined) * 100).round(1) : 0
    }
  end

  def meal_summary
    guests.rsvp_accepted
          .where.not(rsvps: { meal_choice: nil })
          .group('rsvps.meal_choice')
          .count
  end

  def dietary_restrictions_list
    guests.rsvp_accepted
          .where.not(rsvps: { dietary_restrictions: [nil, ''] })
          .map { |g| "#{g.full_name}: #{g.rsvp.dietary_restrictions}" }
  end
end
```

### Export for Caterer

```ruby
# In Admin::GuestsController
def export_meal_counts
  @wedding = current_wedding

  csv = CSV.generate do |csv|
    csv << ['Meal Choice', 'Count']
    @wedding.meal_summary.each do |meal, count|
      csv << [meal, count]
    end
  end

  send_data csv, filename: "meal-counts-#{Date.today}.csv"
end
```

## Troubleshooting

### Guest Can't Find Invite Code

**Solution:** Admin can look up code in Admin > Guests

### Wrong Guest Information

**Solution:** Admin can edit guest details and resend invitation

### Need to Change RSVP

**Solution:** Guest can use same invite code to update their RSVP

### Household Member Missing

**Solution:** Admin adds guest to household, system auto-assigns code

### Duplicate RSVPs

**Prevention:** Transaction-based updates prevent race conditions

## Security Considerations

1. **Invite Code Entropy**: 10 characters = 3.7 trillion combinations
2. **No Enumeration**: Invalid codes show 404, not error message
3. **Rate Limiting**: Consider adding rate limits on RSVP endpoints
4. **No Authentication**: Intentionally simple - code is the key

## Best Practices

1. **Test First**: Create test guests and verify flow
2. **Clear Instructions**: Include RSVP instructions in email
3. **Deadline Reminder**: Send reminder 2 weeks before deadline
4. **Mobile-Friendly**: Test RSVP form on mobile devices
5. **Print Backup**: Keep printed guest list as backup
6. **Follow-Up**: Contact guests who haven't responded
7. **Data Validation**: Ensure meal counts match accepted guests

## Common Workflows

### Adding Late Guests

```ruby
# 1. Create household
household = Household.create!(wedding: @wedding, name: "Late Addition")

# 2. Add guest
guest = Guest.create!(
  wedding: @wedding,
  household: household,
  first_name: "Late",
  last_name: "Guest",
  email: "late@example.com"
)

# 3. Send invitation
InvitationJob.perform_later(guest.id)
```

### Handling No-Shows

Track guests who RSVP'd but didn't attend:

```ruby
# Migration
add_column :rsvps, :attended, :boolean

# After wedding, mark attendance
Guest.rsvp_accepted.each do |guest|
  # Admin manually marks who actually attended
  guest.rsvp.update(attended: true/false)
end
```

### Post-Wedding Analysis

```ruby
wedding.guests.rsvp_accepted.where(rsvps: { attended: false }).count
# Count no-shows

wedding.guests.rsvp_declined.count
# Count declined invites

wedding.guests.rsvp_accepted.where(rsvps: { attended: true }).count
# Actual attendance
```
