# Builds in-memory sample records for exercising mailers without touching the
# database. Shared by ActionMailer previews (/rails/mailers) and the
# `email:test` rake task so sample content stays consistent in one place.
module EmailSampleData
  module_function

  def accepted_guest(email: "sample.guest@example.com")
    build_guest("Sample", "Guest", email).tap do |guest|
      guest.build_rsvp(status: "accepted", meal_choice: Wedding.current.meal_options.first)
    end
  end

  def declined_guest(email: "sample.partner@example.com")
    build_guest("Sample", "Partner", email).tap do |guest|
      guest.build_rsvp(status: "declined")
    end
  end

  def build_guest(first_name, last_name, email)
    Guest.new(
      first_name:,
      last_name:,
      email:,
      invite_code: "SAMPLECODE",
      wedding_id: Wedding.current.id
    )
  end
end
