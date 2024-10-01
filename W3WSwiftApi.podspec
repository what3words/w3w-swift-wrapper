Pod::Spec.new do |s|
  s.name        = "W3WSwiftApi"
  s.version     = "4.0.0"
  s.summary     = "w3w-swift-wrapper allows you to convert a 3 word address to coordinates or to convert coordinates to a 3 word address"
  s.homepage    = "https://github.com/what3words/w3w-swift-wrapper"
  s.license     = { :type => "MIT" }
  s.authors     = { "what3words" => "support@what3words.com" }

  s.requires_arc = true
  s.osx.deployment_target = "10.13"
  s.ios.deployment_target = "11.0"
  s.source   = { 
    :git => "https://github.com/what3words/w3w-swift-wrapper.git", 
    :tag => "v4.0.0", 
    :branch => "task/MT-6899-Core-lib-update-does-not-support-cocoapods",
    :submodules => true 
  }
  s.source_files = "Sources/**/*.swift"
  s.swift_version = '5.0'

# Include W3WSwiftCore directly
  s.preserve_paths = 'Sources/W3WSwiftCore'
  s.prepare_command = <<-CMD
    git submodule add -b task/MT-6899-Core-lib-update-does-not-support-cocoapods https://github.com/what3words/w3w-swift-core.git Sources/W3WSwiftCore
    cd Sources/W3WSwiftCore
    git checkout task/MT-6899-Core-lib-update-does-not-support-cocoapods
  CMD

end