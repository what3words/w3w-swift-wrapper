Pod::Spec.new do |s|
  s.name        = "W3WSwiftVoiceApi"
  s.version     = "4.0.0"
  s.summary     = "w3w-swift-wrapper allows you to convert a 3 word address to coordinates or to convert coordinates to a 3 word address"
  s.homepage    = "https://github.com/what3words/w3w-swift-wrapper"
  s.license     = { :type => "MIT" }
  s.authors     = { "what3words" => "support@what3words.com" }

  s.requires_arc = true
  s.osx.deployment_target = "10.13"
  s.ios.deployment_target = "11.0"
  s.source   = { :git => "https://github.com/what3words/w3w-swift-wrapper.git", :tag => "v4.0.0" }
  s.source_files = "Sources/W3WSwiftVoiceApi/**/*.swift"
  s.swift_version = '5.0'
  s.dependency 'W3WSwiftCore'
end
