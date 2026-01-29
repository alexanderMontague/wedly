# Wedly - Rails Wedding Planning Application

A clean, Rails-native wedding planning and RSVP management system built with zero external dependencies.

## Features

- **Public Wedding Website**: Beautiful, mobile-first wedding pages with event schedules
- **RSVP Management**: Household-based RSVP system with meal preferences and dietary restrictions
- **Guest Management**: Complete guest and household management with filtering and search
- **Email Invitations**: SMTP-based invitation system with tracking
- **Admin Dashboard**: Comprehensive analytics and RSVP tracking
- **Theme Customization**: JSON-based theme configuration for colors and fonts
- **CSV Export**: Export guest lists and RSVP data

## Stack

- **Rails 7.1**: Modern Rails with Turbo support
- **MySQL**: Reliable database with JSON column support
- **Tailwind CSS v4**: Utility-first CSS framework
- **Propshaft**: Modern asset pipeline
- **ERB Views**: Server-rendered templates
- **Action Mailer**: Native email delivery via SMTP
- **Active Job**: Background job processing
- **Bcrypt**: Native password hashing for admin authentication

## Quick Start

### Prerequisites

- Ruby 3.2.0
- MySQL 5.7+
- SMTP credentials (optional, for sending invitations)

### Setup

Run the setup script (one time only):
```bash
./setup
```

This installs dependencies, creates your `.env` file, sets up the database, and builds the initial CSS.

### Start Development Server

```bash
./bin/dev
```

This starts both:
- Rails server on http://localhost:3000
- Tailwind CSS watch process (auto-rebuilds styles when files change)

**Quick alternative:** If you only need Rails without CSS watching, use `./start`

### Access

- **Public site**: http://localhost:3000
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
