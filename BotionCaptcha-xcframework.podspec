
Pod::Spec.new do |s|
  s.name         = "BotionCaptcha-xcframework"
  s.version      = "1.0.1"
  s.summary      = "Botion SDK"
  s.homepage     = "https://www.botion.com"
  s.license      = { :type => 'MIT', :file => 'LICENSE' }


  s.author = { 'botion' => 'mobile@botion.com' }
  s.source = { :git => 'https://github.com/BotionTeam/botion-xcframework-support.git', :tag => s.version.to_s, :submodules => true } 
  s.ios.deployment_target = '9.0'

  s.frameworks = 'WebKit'

  s.pod_target_xcconfig = { 'BUILD_LIBRARY_FOR_DISTRIBUTION' => 'YES', 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'i386'}

  s.subspec 'Main' do |dm|
    dm.vendored_frameworks = 'SDK/BotionCaptcha.xcframework'
    dm.resources = 'SDK/BotionCaptcha.bundle'
  end

end
