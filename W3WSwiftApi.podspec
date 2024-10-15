Pod::Spec.new do |s|
  s.name        = "W3WSwiftApi"
  s.version     = "4.0.0"
  s.summary     = "w3w-swift-wrapper allows you to convert a 3 word address to coordinates or to convert coordinates to a 3 word address"
  s.homepage    = "https://github.com/what3words/w3w-swift-wrapper"
  s.license     = { :type => "MIT" }
  s.authors     = { "what3words" => "support@what3words.com" }

  s.osx.deployment_target = "10.13"
  s.ios.deployment_target = "11.0"
  s.source   = { 
    :git => "https://github.com/what3words/w3w-swift-wrapper.git", 
    :tag => "v#{s.version}",
    :branch => "task/MT-6899-Core-lib-update-does-not-support-cocoapods"
  }
  s.swift_version = '5.0'

  # Dependencies
  s.dependency 'W3WSwiftCore', '~> 1.1.2'
  #s.dependency 'W3WSwiftVoiceApi'
  s.source_files = 'Sources/W3WSwiftApi/**/*'
 

  # Define subspecs
 # s.subspec 'W3WSwiftVoiceApi' do |ss|
  #  ss.source_files = 'Sources/W3WSwiftVoiceApi/**/*' # Adjust this if needed
 # end

 # s.subspec 'W3WSwiftApi' do |ss|
 #   ss.source_files = 'Sources/W3WSwiftApi/**/*' # Adjust this if needed
   # ss.dependency 'W3WSwiftApi/W3WSwiftVoiceApi' # This allows W3WSwiftApi to use W3WSwiftVoiceApi
   # ss.dependency 'W3WSwiftCore' # If W3WSwiftApi also needs W3WSwiftCore
 # end

  # Default subspecs
 # s.default_subspecs = ['W3WSwiftApi'] # Set the default subspec if needed
end