Pod::Spec.new do |s|
  s.name        = "W3WSwiftCore"
  s.version     = "1.1.1"
  s.summary     = "w3w-swift-core contains the core types used by many of the what3words Swift libraries, as well as some utility classes for things like networking, audio and localisation"
  s.homepage    = "https://github.com/what3words/w3w-swift-core"
  s.license     = { :type => "MIT" }
  s.authors     = { "what3words" => "support@what3words.com" }

  s.requires_arc = true
  s.osx.deployment_target = "10.13"
  s.ios.deployment_target = "11.0"
  s.source   = { :git => "https://github.com/what3words/w3w-swift-core.git", :tag => "v1.1.0", :branch => "task/MT-6899-Core-lib-update-does-not-support-cocoapods"}
  s.source_files = "Sources/**/*.swift"
  s.swift_version = '5.0'
end