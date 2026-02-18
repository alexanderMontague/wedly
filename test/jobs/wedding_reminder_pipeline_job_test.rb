require "test_helper"

class WeddingReminderPipelineJobTest < ActiveJob::TestCase
  include ActiveSupport::Testing::TimeHelpers

  setup do
    clear_enqueued_jobs
    clear_performed_jobs

    wedding = Wedding.current
    household = Household.create!(wedding_id: wedding.id, name: "Reminder Household")
    Guest.create!(
      wedding_id: wedding.id,
      household: household,
      first_name: "Alex",
      last_name: "Guest",
      email: "alex.guest@example.com",
      phone_number: "+15550001234"
    )
  end

  test "enqueues one delivery per guest and reminder channel" do
    travel_to(Time.find_zone!("America/Toronto").local(2026, 8, 29, 10, 5)) do
      WeddingReminderPipelineJob.perform_now
    end

    assert_equal 1, NotificationDelivery.count
    assert_equal "week_before", NotificationDelivery.first.reminder_key
    assert_equal "email", NotificationDelivery.first.channel
    assert_enqueued_jobs 1, only: WeddingReminderDeliveryJob
  end

  test "does not enqueue duplicate deliveries across repeated runs" do
    travel_to(Time.find_zone!("America/Toronto").local(2026, 8, 29, 10, 5)) do
      WeddingReminderPipelineJob.perform_now
      WeddingReminderPipelineJob.perform_now
    end

    assert_equal 1, NotificationDelivery.count
    assert_enqueued_jobs 1, only: WeddingReminderDeliveryJob
  end
end
