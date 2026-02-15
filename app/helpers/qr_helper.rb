# frozen_string_literal: true

module QrHelper
  def qr_code_svg(url, color: "78716c", fill: "fafaf9", **_options)
    qr = RQRCode::QRCode.new(url, level: :m)
    qr.as_svg(
      module_size: 3,
      standalone: true,
      viewbox: true,
      color: color,
      fill: fill,
      offset: 12,
      shape_rendering: "geometricPrecision"
    ).html_safe
  end
end
