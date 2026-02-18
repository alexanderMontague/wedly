# Wedly - Rails Wedding Planning Application

A clean, Rails-native wedding planning and RSVP management system built with zero external dependencies.

## Features

- **Public Wedding Website**: Beautiful, mobile-first wedding pages with event schedules
- **RSVP Management**: Household-based RSVP system with meal preferences and dietary restrictions
- **Guest Management**: Complete guest and household management with filtering and search
- **Email Invitations**: SMTP-based invitation system with tracking
- **Reminder Pipeline**: Config-driven email/SMS reminders with idempotent delivery tracking
- **Disposable Camera**: Standalone `/dispo` camera capture flow with shared public gallery
- **Admin Dashboard**: Comprehensive analytics and RSVP tracking
- **Theme Customization**: JSON-based theme configuration for colors and fonts
- **CSV Export**: Export guest lists and RSVP data

## Stack

- **Rails 7.1**: Modern Rails with Turbo support
- **sqlite**: Reliable database with JSON column support
- **Tailwind CSS v4**: Utility-first CSS framework
- **Propshaft**: Modern asset pipeline
- **ERB Views**: Server-rendered templates
- **Action Mailer**: Native email delivery via SMTP
- **Active Job**: Background job processing
- **AWS SDK S3**: Direct object upload for disposable camera photos
- **Bcrypt**: Native password hashing for admin authentication

## Quick Start

### Prerequisites

- Ruby 3.2.0
- sqlite 5.7+
- SMTP credentials (optional, for sending invitations)

### Setup

Run the setup script (one time only):
```bash
./bin/setup
```

This installs dependencies, creates your `.env` file, sets up the database, and builds the initial CSS.

### Start Development Server

```bash
./bin/dev
```

This starts both:
- Rails server on http://localhost:3000
- Tailwind CSS watch process (auto-rebuilds styles when files change)

### Access

- **Public site**: http://localhost:3000
- **Disposable camera**: http://localhost:3000/dispo
- **Disposable gallery**: http://localhost:3000/dispo/gallery
- **Admin login**: http://localhost:3000/admin/login
  - Email: `admin@wedly.com`
  - Password: `password`

## Project Structure

```
app/
├── controllers/
│   ├── admin/           # Admin dashboard and management
│   ├── public/          # Public-facing wedding pages
│   └── concerns/        # Shared controller logic
├── models/              # ActiveRecord models
├── views/
│   ├── admin/          # Admin interface views
│   ├── public/         # Public wedding site views
│   └── layouts/        # Layout templates
├── mailers/            # Email templates
├── jobs/               # Background jobs
└── services/           # Business logic
```

## Key Concepts

### Households
Guests are grouped into households (e.g., "The Smith Family"), allowing multiple people to RSVP together using a single invitation code.

### Invite Codes
Each guest receives a unique 10-character alphanumeric code for RSVP access. No user accounts required.

### Theme Configuration
Customize your wedding site appearance via JSON configuration in the admin settings panel.

### RSVP Workflow
1. Admin creates guests and households
2. Admin sends email invitations
3. Guests click link with their unique code
4. Guests RSVP for their entire household
5. Admin tracks responses in dashboard

## Development

### Styling

The app uses Tailwind CSS v4. The watch process (`./bin/dev`) automatically rebuilds CSS when you make changes.

Custom component classes are available:
- Buttons: `.btn`, `.btn-primary`, `.btn-success`, `.btn-danger`
- Forms: `.form-group`, `.form-control`
- Cards: `.card`, `.card-header`
- Alerts: `.alert-success`, `.alert-error`

You can also use any Tailwind utility classes directly in your views.

Custom colors:
- Primary: `var(--color-primary)` - #C89B7B
- Secondary: `var(--color-secondary)` - #2C3E50

### Running Tests
```bash
rails test
```

### Reminder Cron Pipeline

Wedding reminders are fully configured in `db/weddings.yml` under `notifications.reminders`.

Trigger the scheduler manually:
```bash
bundle exec rails notifications:process_reminders
```

Recommended cron entry (runs every 15 minutes; delivery is idempotent):
```bash
*/15 * * * * cd /path/to/wedly && /usr/bin/env RAILS_ENV=production bundle exec rails notifications:process_reminders
```
You can copy the same entry from `config/cron.example`.

Defaults include reminders at 7 days, 1 day, and day-of wedding date. To enable SMS, set:
- `WEDLY_SMS_MODE=webhook`
- `WEDLY_SMS_WEBHOOK_URL=https://your-sms-dispatch-endpoint`

### Disposable Camera Bucket Setup

Disposable camera photos upload to a shared object bucket and are rendered in `/dispo/gallery`.

Required environment variables:
- `WEDLY_DISPO_BUCKET=your-public-bucket-name`

Optional environment variables:
- `WEDLY_DISPO_REGION=us-east-1` (defaults to `us-east-1`)
- `WEDLY_DISPO_ACCESS_KEY_ID=...` (needed when not using instance role credentials)
- `WEDLY_DISPO_SECRET_ACCESS_KEY=...` (needed when not using instance role credentials)
- `WEDLY_DISPO_ENDPOINT=https://s3-compatible-endpoint` (for S3-compatible storage)
- `WEDLY_DISPO_FORCE_PATH_STYLE=true` (for MinIO/compatibility endpoints)
- `WEDLY_DISPO_PUBLIC_BASE_URL=https://cdn.example.com` (preferred when using CDN/custom domain)

### Database Console
```bash
rails dbconsole
```

### Rails Console
```bash
rails console
```

## Contributing

This is an open-source project designed to be easily forked and customized. Key principles:

- Minimal gem dependencies
- Plain Rails patterns
- No external SaaS services
- Self-hostable
- Easy to understand and modify

## License

MIT License - feel free to use for your own wedding or fork for your needs.

## Support

For issues or questions, please open a GitHub issue.
