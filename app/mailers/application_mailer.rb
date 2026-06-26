class ApplicationMailer < ActionMailer::Base
  DIVIDER_IMAGE = "divider-leaf.png".freeze

  default from: ENV.fetch("SMTP_USERNAME", "noreply@wedly.com")
  layout "mailer"
  helper ApplicationHelper
  helper WeddingHelper
  before_action :attach_inline_assets

  private

  # Inline (CID) attachment so the botanical divider renders across clients that
  # strip inline SVG (Gmail, Outlook), unlike an embedded <svg> or data URI.
  def attach_inline_assets
    path = Rails.root.join("app/assets/images/botanical", DIVIDER_IMAGE)
    attachments.inline[DIVIDER_IMAGE] = File.binread(path)
  end
end
