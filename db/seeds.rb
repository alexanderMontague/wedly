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
                    wedding_id: wedding.id,
                    name: "Ceremony",
                    datetime: wedding.date&.to_datetime&.change(hour: 15) || DateTime.new(2026, 9, 5, 15, 0),
                    location: [wedding.venue["name"], wedding.venue["city"],
                               wedding.venue["region"]].compact.join(", "),
                    description: "Join us for our wedding ceremony"
                  },
                  {
                    wedding_id: wedding.id,
                    name: "Reception",
                    datetime: wedding.date&.to_datetime&.change(hour: 18) || DateTime.new(2026, 9, 5, 18, 0),
                    location: [wedding.venue["name"], wedding.venue["city"],
                               wedding.venue["region"]].compact.join(", "),
                    description: "Dinner and dancing to follow"
                  }
                ])
end

Rails.logger.debug "Creating sample household and guests..."
if wedding.households.empty?
  household = Household.create!(
    wedding_id: wedding.id,
    name: "The Smith Family"
  )
  Guest.create!(
    wedding_id: wedding.id,
    household: household,
    first_name: "Robert",
    last_name: "Smith",
    email: "robert.smith@example.com",
    address: "123 Main St, Toronto, ON M5V 1A1",
    phone_number: "+1-555-0100"
  )
  Guest.create!(
    wedding_id: wedding.id,
    household: household,
    first_name: "Sarah",
    last_name: "Smith",
    email: "sarah.smith@example.com"
  )

  household_monty = Household.create!(
    wedding_id: wedding.id,
    name: "The Montague Family"
  )
  household_monty.guests.create!(
    wedding_id: wedding.id,
    household: household_monty,
    first_name: "Steve",
    last_name: "Montague",
    email: "steve@perspective.ca"
  )
  household_monty.guests.create!(
    wedding_id: wedding.id,
    household: household_monty,
    first_name: "Kelly",
    last_name: "Montague",
    email: "kelly@metrolandmedia.ca"
  )

  household_emary = Household.create!(
    wedding_id: wedding.id,
    name: "The Emary Family"
  )
  household_emary.guests.create!(
    wedding_id: wedding.id,
    household: household_emary,
    first_name: "James",
    last_name: "Emary",
    email: "james@emary.ca"
  )
  household_emary.guests.create!(
    wedding_id: wedding.id,
    household: household_emary,
    first_name: "Janet",
    last_name: "Emary"
  )

  household_liam = Household.create!(
    wedding_id: wedding.id
  )
  household_liam.guests.create!(
    wedding_id: wedding.id,
    household: household_liam,
    first_name: "Liam",
    last_name: "Bettinson"
  )
end

Rails.logger.debug "✓ Seed data created successfully!"
Rails.logger.debug "Admin login: admin@wedly.com / password"
