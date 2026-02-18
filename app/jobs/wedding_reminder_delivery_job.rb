class WeddingReminderDeliveryJob < ApplicationJob
  queue_as :default

  def perform(notification_delivery_id)
    delivery = NotificationDelivery.includes(:guest).find(notification_delivery_id)
    return if delivery.status == "sent"

    guest = delivery.guest
    wedding = Wedding.find(delivery.wedding_id)
    config = WeddingReminders::Configuration.new(wedding:)
    rule = config.rules.find { |configured_rule| configured_rule.key == delivery.reminder_key }
    raise "Reminder rule not found for key=#{delivery.reminder_key}" unless rule

    message_builder = WeddingReminders::MessageBuilder.new(wedding:, reminder_rule: rule)

    case delivery.channel
    when "email"
      WeddingReminderMailer.reminder(
        guest:,
        wedding:,
        subject: message_builder.email_subject
      ).deliver_now
    when "sms"
      WeddingReminders::SmsDelivery.deliver!(
        guest:,
        message: message_builder.sms_body(guest),
        reminder_key: rule.key
      )
    else
      raise "Unsupported channel=#{delivery.channel}"
    end

    delivery.mark_sent!
  rescue StandardError => e
    delivery&.mark_failed!(e.message)
    raise
  end
end
