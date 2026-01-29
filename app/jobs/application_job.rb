class ApplicationJob < ActiveJob::Base
  retry_on StandardError, wait: 5.seconds, attempts: 3
end
