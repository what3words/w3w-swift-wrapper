Pod::Spec.new do |s|
  s.name        = "W3WSwiftApi"
  s.version     = "4.0.2"
  s.summary     = "w3w-swift-wrapper allows you to convert a 3 word address to coordinates or to convert coordinates to a 3 word address"
  s.homepage    = "https://github.com/what3words/w3w-swift-wrapper"
  s.license     = { :type => "MIT" }
  s.authors     = { "what3words" => "support@what3words.com" }

  s.osx.deployment_target = "10.13"
  s.ios.deployment_target = "11.0"
  s.source   = { 
    :git => "https://github.com/what3words/w3w-swift-wrapper.git", 
    :tag => "v#{s.version}"
  }
  s.swift_version = '5.0'

  s.default_subspec = 'W3WSwiftApi'
  
  s.subspec 'W3WSwiftApi' do |api|
    api.source_files = 'Sources/W3WSwiftApi/**/*'
    api.dependency 'W3WSwiftCore', '~> 1.1.2'
  end

end
