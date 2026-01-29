# SMTP Setup Guide

Wedly uses Action Mailer with standard SMTP for sending invitation emails. This guide covers setup for popular email providers.

## Configuration

Email settings are configured via environment variables in your `.env` file:

```bash
SMTP_ADDRESS=smtp.example.com
SMTP_PORT=587
SMTP_USERNAME=your-email@example.com
SMTP_PASSWORD=your-password
APP_HOST=your-domain.com  # For generating invitation links
```

## Provider Setup

### Gmail

#### 1. Enable 2-Factor Authentication
1. Go to [Google Account Security](https://myaccount.google.com/security)
2. Enable 2-Step Verification

#### 2. Create App Password
1. Visit [App Passwords](https://myaccount.google.com/apppasswords)
2. Select "Mail" and "Other (Custom name)"
3. Enter "Wedly" as the name
4. Click "Generate"
5. Copy the 16-character password

#### 3. Configure .env
```bash
SMTP_ADDRESS=smtp.gmail.com
SMTP_PORT=587
SMTP_USERNAME=your-email@gmail.com
SMTP_PASSWORD=your-16-char-app-password
APP_HOST=your-domain.com
```

#### Limitations
- 500 emails per day for free Gmail accounts
- 2000 emails per day for Google Workspace accounts

### SendGrid

#### 1. Create SendGrid Account
1. Sign up at [SendGrid](https://sendgrid.com)
2. Verify your email address
3. Complete sender identity verification

#### 2. Create API Key
1. Go to Settings > API Keys
2. Click "Create API Key"
3. Choose "Restricted Access"
4. Enable "Mail Send" permissions
5. Copy the API key

#### 3. Configure .env
```bash
SMTP_ADDRESS=smtp.sendgrid.net
SMTP_PORT=587
SMTP_USERNAME=apikey
SMTP_PASSWORD=your-sendgrid-api-key
APP_HOST=your-domain.com
```

#### Benefits
- 100 emails per day (free tier)
- Detailed analytics
- Better deliverability
- No daily limits on paid plans

### Amazon SES

#### 1. Set Up AWS Account
1. Create AWS account at [aws.amazon.com](https://aws.amazon.com)
2. Navigate to Amazon SES console
3. Verify your domain or email address

#### 2. Create SMTP Credentials
1. In SES console, go to "SMTP Settings"
2. Click "Create My SMTP Credentials"
3. Download and save credentials

#### 3. Request Production Access
By default, SES starts in sandbox mode (limited recipients).
1. Go to "Sending Statistics"
2. Click "Request Production Access"
3. Fill out the request form

#### 4. Configure .env
```bash
SMTP_ADDRESS=email-smtp.us-east-1.amazonaws.com
SMTP_PORT=587
SMTP_USERNAME=your-smtp-username
SMTP_PASSWORD=your-smtp-password
APP_HOST=your-domain.com
```

#### Benefits
- Very low cost ($0.10 per 1000 emails)
- High deliverability
- Scalable for large guest lists

### Mailgun

#### 1. Create Mailgun Account
1. Sign up at [Mailgun](https://mailgun.com)
2. Verify your email
3. Add and verify your domain

#### 2. Get SMTP Credentials
1. Go to Sending > Domain Settings
2. Click on your domain
3. Note the SMTP credentials

#### 3. Configure .env
```bash
SMTP_ADDRESS=smtp.mailgun.org
SMTP_PORT=587
SMTP_USERNAME=postmaster@your-domain.com
SMTP_PASSWORD=your-mailgun-password
APP_HOST=your-domain.com
```

#### Benefits
- 5000 emails per month (free tier)
- Good deliverability
- Email validation API

### Custom SMTP Server

If you have your own mail server:

```bash
SMTP_ADDRESS=mail.yourdomain.com
SMTP_PORT=587
SMTP_USERNAME=noreply@yourdomain.com
SMTP_PASSWORD=your-password
APP_HOST=yourdomain.com
```

## Testing Email Configuration

### From Rails Console

```bash
rails console

# Test email delivery
InvitationMailer.invite(Guest.first).deliver_now

# Check for errors
```

### Create a Test Guest

```bash
rails console

wedding = Wedding.first
household = Household.create!(wedding: wedding, name: "Test Family")
guest = Guest.create!(
  wedding: wedding,
  household: household,
  first_name: "Test",
  last_name: "User",
  email: "your-test-email@example.com",
  invite_code: "TEST123456"
)

# Send test invitation
InvitationMailer.invite(guest).deliver_now
```

### Check Logs

```bash
# Development
tail -f log/development.log | grep "InvitationMailer"

# Production
tail -f log/production.log | grep "InvitationMailer"
```

## Troubleshooting

### Authentication Failed

**Error**: `535 Authentication failed`

**Solutions**:
- Verify username and password are correct
- For Gmail, ensure you're using an App Password
- Check if 2FA is required
- Verify SMTP settings match provider documentation

### Connection Refused

**Error**: `Connection refused`

**Solutions**:
- Check SMTP_ADDRESS is correct
- Verify SMTP_PORT (usually 587 or 465)
- Check firewall isn't blocking outbound SMTP
- Try different port (587, 465, or 25)

### TLS/SSL Issues

**Error**: `SSL_connect returned=1 errno=0`

**Solutions**:
Add to `config/environments/production.rb`:

```ruby
config.action_mailer.smtp_settings = {
  address: ENV["SMTP_ADDRESS"],
  port: ENV["SMTP_PORT"],
  user_name: ENV["SMTP_USERNAME"],
  password: ENV["SMTP_PASSWORD"],
  authentication: :plain,
  enable_starttls_auto: true,
  openssl_verify_mode: 'none'  # Only if absolutely necessary
}
```

### Emails Going to Spam

**Solutions**:
1. **Verify Domain**: Set up SPF, DKIM, and DMARC records
2. **Sender Reputation**: Use established email service
3. **Content**: Avoid spam trigger words
4. **Warm Up**: Start with small batches
5. **Authentication**: Ensure proper SMTP authentication

### Rate Limiting

**Error**: `550 Daily sending quota exceeded`

**Solutions**:
- Upgrade to paid plan
- Spread invitations over multiple days
- Switch to provider with higher limits
- Implement batch sending with delays

## Domain Authentication

For better deliverability, configure SPF and DKIM records:

### SPF Record
Add TXT record to your DNS:
```
v=spf1 include:_spf.google.com ~all  # For Gmail
v=spf1 include:sendgrid.net ~all     # For SendGrid
```

### DKIM Record
Follow your provider's instructions to add DKIM keys to DNS.

## Best Practices

1. **Test First**: Always test with your own email before sending to guests
2. **Batch Sending**: For large guest lists, send in batches
3. **Monitor**: Check delivery rates and spam reports
4. **Fallback**: Have backup SMTP provider configured
5. **Content**: Keep emails simple and personal
6. **Timing**: Send during business hours for better deliverability
7. **Unsubscribe**: Include unsubscribe option for compliance

## Email Delivery Monitoring

Track invitation delivery status in the admin panel:

1. Go to Admin > Invitations
2. View sent/opened statistics
3. Check individual invitation status
4. Resend failed invitations

## Production Checklist

- [ ] SMTP credentials configured in production .env
- [ ] Domain verified with email provider
- [ ] SPF/DKIM records added to DNS
- [ ] Test email sent successfully
- [ ] APP_HOST set to production domain
- [ ] SSL/TLS enabled
- [ ] Rate limits understood
- [ ] Monitoring configured
