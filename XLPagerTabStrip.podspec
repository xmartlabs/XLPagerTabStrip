Pod::Spec.new do |s|
  s.name             = "XLPagerTabStrip"
  s.version          = "1.0.0"
  s.summary          = "A short description of XLPagerTabStrip."
  s.homepage         = "https://github.com/xmartlabs/XLPagerTabStrip"
  s.license          = { type: 'MIT', file: 'LICENSE' }
  s.author           = { "Xmartlabs SRL" => "swift@xmartlabs.com" }
  s.source           = { git: "https://github.com/xmartlabs/XLPagerTabStrip.git", tag: s.version.to_s }
  s.social_media_url = 'https://twitter.com/xmartlabs'
  s.ios.deployment_target = '8.0'
  s.requires_arc = true
  s.ios.source_files = 'Sources/**/*'
  # s.ios.frameworks = 'UIKit', 'Foundation'
  # s.dependency 'Eureka', '~> 1.0'
end
