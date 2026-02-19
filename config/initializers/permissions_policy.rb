Rails.application.config.permissions_policy do |policy|
  policy.camera      :self
  policy.gyroscope   :none
  policy.microphone  :none
  policy.usb         :none
  policy.fullscreen  :self
  policy.payment     :self
end
