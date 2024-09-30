Pod::Spec.new do |s|
  s.name             = 'W3WSwiftVoiceApi'
  s.version          = '4.0.0'
  s.summary          = 'What3Words Swift Voice API wrapper'

  s.description      = <<-DESC
  The What3Words Swift Voice API wrapper provides a convenient interface for interacting with the What3Words Voice API in Swift projects.
                       DESC

  s.homepage         = 'https://github.com/what3words/w3w-swift-wrapper'
  s.license          = { :type => 'MIT'}
  s.author           = { 'what3words' => 'support@what3words.com' }
 s.source   = { :git => "https://github.com/what3words/w3w-swift-wrapper.git", :tag => "v4.0.0", :branch => "task/MT-6899-Core-lib-update-does-not-support-cocoapods" }
  s.source_files = "Sources/**/*.swift"

  s.ios.deployment_target = '11.0'
  s.osx.deployment_target = '10.13'

  s.swift_version = '5.0'

  s.source_files = 'Sources/W3WSwiftVoiceApi/**/*.swift'

  s.dependency 'W3WSwiftCore', '~> 1.1.1'
end