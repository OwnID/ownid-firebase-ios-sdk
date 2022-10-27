Pod::Spec.new do |s|
  s.name             = 'ownid-firebase-ios-sdk'
  s.version          = '2.0.0'
  s.summary          = 'ownid-firebase-ios-sdk'

  s.description      = <<-DESC
  ownid-firebase-ios-sdk
                       DESC

  s.homepage         = 'https://ownid.com'
  s.license          = 'Apache 2.0'
  s.authors          = 'OwnID, Inc'

  #, :tag => s.version.to_s
  s.source           = { :git => 'https://github.com/OwnID/ownid-firebase-ios-sdk.git' }
  s.module_name   = 'OwnIDFirebaseSDK'
  s.ios.deployment_target = '13.0'
  s.swift_version = '5.1.1'

  s.source_files = 'Core/**/*'
  s.dependency 'ownid-core-ios-sdk'
  s.dependency 'FirebaseAuth'
  s.dependency 'FirebaseFirestore'
end
