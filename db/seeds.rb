Rails.logger.debug "Creating default admin user..."
AdminUser.create!(
  email: "admin@wedly.com",
  password: "password",
  name: "Admin User"
)

Rails.logger.debug "Creating sample wedding..."
wedding = Wedding.create!(
  slug: "john-and-jane-2026",
  title: "John & Jane's Wedding",
  date: Date.new(2026, 6, 15),
  location: "Sunset Gardens, California",
  theme_config: {
    colors: {
      primary: "#C89B7B",
      secondary: "#8B7355"
    },
    font: "serif",
    layout: "classic"
  },
  settings: {
    rsvp_deadline: Date.new(2026, 5, 15),
    meal_options: %w[Chicken Beef Vegetarian Vegan]
  }
)

Rails.logger.debug "Creating events..."
Event.create!([
                {
                  wedding: wedding,
                  name: "Ceremony",
                  datetime: DateTime.new(2026, 6, 15, 15, 0),
                  location: "Sunset Gardens Chapel",
                  description: "Join us for our wedding ceremony"
                },
                {
                  wedding: wedding,
                  name: "Reception",
                  datetime: DateTime.new(2026, 6, 15, 18, 0),
                  location: "Sunset Gardens Ballroom",
                  description: "Dinner and dancing to follow"
                }
              ])

Rails.logger.debug "Creating sample household and guests..."
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
  invite_code: SecureRandom.alphanumeric(10).upcase,
  address: "123 Main St, San Francisco, CA 94105",
  phone_number: "+1-555-0100"
)

guest2 = Guest.create!(
  wedding: wedding,
  household: household,
  first_name: "Sarah",
  last_name: "Smith",
  email: "sarah.smith@example.com",
  invite_code: SecureRandom.alphanumeric(10).upcase
)

Rails.logger.debug "✓ Seed data created successfully!"
Rails.logger.debug "Admin login: admin@wedly.com / password"
Rails.logger.debug { "Guest RSVP codes: #{guest1.invite_code}, #{guest2.invite_code}" }
