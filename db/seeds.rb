Rails.logger.debug "Creating default admin user..."
AdminUser.find_or_create_by!(email: "admin@wedly.com") do |admin|
  admin.password = "password"
  admin.name = "Admin User"
end

Rails.logger.debug "Creating wedding from config..."
wedding = Wedding.current

Rails.logger.debug "Creating sample events..."
if wedding.events.empty?
  Event.create!([
    {
      wedding: wedding,
      name: "Ceremony",
      datetime: wedding.date&.to_datetime&.change(hour: 15) || DateTime.new(2026, 9, 5, 15, 0),
      location: wedding.location,
      description: "Join us for our wedding ceremony"
    },
    {
      wedding: wedding,
      name: "Reception",
      datetime: wedding.date&.to_datetime&.change(hour: 18) || DateTime.new(2026, 9, 5, 18, 0),
      location: wedding.location,
      description: "Dinner and dancing to follow"
    }
  ])
end

Rails.logger.debug "Creating sample household and guests..."
if wedding.households.empty?
  household = Household.create!(
    wedding: wedding,
    name: "The Smith Family"
  )

  guest1 = Guest.create!(
    wedding: wedding,
    household: household,
    first_name: "Robert",
    last_name: "Smith",
    email: "robert.smith@example.com",
    address: "123 Main St, Toronto, ON M5V 1A1",
    phone_number: "+1-555-0100"
  )

  guest2 = Guest.create!(
    wedding: wedding,
    household: household,
    first_name: "Sarah",
    last_name: "Smith",
    email: "sarah.smith@example.com"
  )

  Rails.logger.debug { "Guest RSVP codes: #{guest1.invite_code}, #{guest2.invite_code}" }
end

Rails.logger.debug "✓ Seed data created successfully!"
Rails.logger.debug "Admin login: admin@wedly.com / password"
