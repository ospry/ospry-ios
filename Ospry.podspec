Pod::Spec.new do |s|
  s.name                  = 'Ospry'
  s.version               = '1.0.0'
  s.summary               = 'Ospry provides simple image hosting for developers.'
  s.homepage              = 'https://ospry.io'
  s.author                = { 'Ryan Brown' => 'ryan@ospry.io' }
  s.source                = { :git => 'https://github.com/ospry/ospry-ios.git', :tag => "v#{s.version}" }
  s.source_files          = 'Ospry/*.{h,m}'
  s.public_header_files   = 'Ospry/*.h'
  s.requires_arc          = true
  s.license               = { :type => 'MIT', :file => 'LICENSE' }
  s.platform              = :ios
  s.ios.deployment_target = '6.0'
  s.frameworks            = 'Foundation', 'AssetsLibrary'

  s.dependency 'ISO8601'
end
