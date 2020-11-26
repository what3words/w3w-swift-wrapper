Pod::Spec.new do |s|
  s.name        = "W3WSwiftApi"
  s.version     = "3.6.0"
  s.summary     = "w3w-swift-wrapper allows you to convert a 3 word address to coordinates or to convert coordinates to a 3 word address"
  s.homepage    = "https://github.com/what3words/w3w-swift-wrapper"
  s.license     = { :type => "MIT" }
  s.authors     = { "what3words" => "support@what3words.com" }

  s.requires_arc = true
  s.osx.deployment_target = "10.10"
  s.ios.deployment_target = "9.0"
  s.source   = { :git => "https://github.com/what3words/w3w-swift-wrapper.git", :branch => "master" }
  s.source_files = "Sources/**/*.swift"
  s.swift_version = '5.0'
end
