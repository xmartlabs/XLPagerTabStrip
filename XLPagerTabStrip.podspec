Pod::Spec.new do |s|
  s.name             = "XLPagerTabStrip"
  s.version          = "9.0.0"
  s.summary          = "Android PagerTabStrip for iOS and much more."
  s.homepage         = "https://github.com/xmartlabs/XLPagerTabStrip"
  s.license          = { type: 'MIT', file: 'LICENSE' }
  s.author           = { "Martin Barreto" => "martin@xmartlabs.com" }
  s.source           = { git: "https://github.com/xmartlabs/XLPagerTabStrip.git", tag: s.version.to_s }
  s.social_media_url = 'https://twitter.com/xmartlabs'
  s.ios.deployment_target = '9.3'
  s.requires_arc = true
  s.ios.source_files = 'Sources/**/*.{h,m,swift}'
  s.ios.frameworks = 'UIKit', 'Foundation'
  s.resource_bundles = { 'XLPagerTabStrip' => ['Sources/XLPagerTabStrip/Resources/ButtonCell.xib'] }
  s.swift_version = "5.0"
end
