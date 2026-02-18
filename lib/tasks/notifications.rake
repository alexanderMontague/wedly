namespace :notifications do
  desc "Run the wedding reminder scheduling pipeline"
  task process_reminders: :environment do
    WeddingReminderPipelineJob.perform_now
  end
end
