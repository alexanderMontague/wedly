namespace :email do
  desc "Send a sample of every transactional email to a recipient. Usage: bin/rails 'email:test[you@example.com]'"
  task :test, [:recipient] => :environment do |_task, args|
    recipient = args[:recipient].presence
    abort "Usage: bin/rails 'email:test[you@example.com]'" unless recipient

    # Surface SMTP failures instead of silently swallowing them (dev sets
    # raise_delivery_errors = false), so this task is a genuine smoke test.
    ActionMailer::Base.raise_delivery_errors = true

    wedding = Wedding.current

    accepted_guest = build_sample_guest(wedding, "Sample", "Guest", recipient)
    accepted_guest.build_rsvp(status: "accepted", meal_choice: wedding.meal_options.first)

    declined_guest = build_sample_guest(wedding, "Sample", "Partner", recipient)
    declined_guest.build_rsvp(status: "declined")

    deliveries = {
      "invitation" => -> { InvitationMailer.invite(accepted_guest) },
      "reminder" => -> { WeddingReminderMailer.reminder(guest: accepted_guest, wedding:, subject: "Sample reminder: #{wedding.title}") },
      "rsvp_confirmation" => -> { RSVPConfirmationMailer.confirmation(guests: [accepted_guest, declined_guest], wedding:) }
    }

    deliveries.each do |name, build_mail|
      print "Sending #{name} sample to #{recipient}... "
      build_mail.call.deliver_now
      puts "ok"
    rescue StandardError => e
      puts "FAILED"
      warn "  #{e.class}: #{e.message}"
    end

    puts "Done."
  end

  def build_sample_guest(wedding, first_name, last_name, email)
    Guest.new(
      first_name:,
      last_name:,
      email:,
      invite_code: "SAMPLECODE",
      wedding_id: wedding.id
    )
  end
end
