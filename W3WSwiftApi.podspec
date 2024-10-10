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
    :tag => "v#{s.version}",
    :branch => "task/MT-6899-Core-lib-update-does-not-support-cocoapods"
  }
  s.swift_version = '5.0'
  s.default_subspec = 'Core'

  #s.source_files = 'Sources/W3WSwiftApi/**/*.swift'
  s.dependency 'W3WSwiftCore', '~> 1.1.1'

 

   s.subspec 'Core' do |sc|
  #  sc.dependency 'W3WSwiftApi/W3WSwiftApi'
   # sc.dependency 'W3WSwiftApi/W3WSwiftVoiceApi'
   # sc.dependency 'W3WSwiftCore'
     sc.source_files = 'Sources/W3WSwiftApi/**/*.swift'
   end


  #s.subspec 'W3WSwiftApi' do |ss|
   # ss.source_files = 'Sources/W3WSwiftApi/**/*.swift'
   #ss.framework   = 'W3WSwiftApi'
   # ss.dependency 'W3WSwiftCore' 
   # ss.dependency 'W3WSwiftApi/W3WSwiftVoiceApi'
    #ss.framework   = 'Foundation'

     #ss.private_header_files = 'Sources/W3WSwiftApi//**/*_Private.h'
  #end 

  s.subspec 'Voice' do |sv|
    sv.source_files = 'Sources/W3WSwiftVoiceApi/**/*.swift'
    sv.dependency 'W3WSwiftCore'
    #ss.framework   = 'Foundation'

  
  end


 s.pod_target_xcconfig = { 
    'SWIFT_INCLUDE_PATHS' => '$(SRCROOT)/W3WSwiftApi/Source/',
    'OTHER_SWIFT_FLAGS' => '-Xcc -fmodule-map-file=$(SRCROOT)/W3WSwiftApi/Sources/W3WSwiftVoiceApi/module.modulemap'
  }

  s.preserve_paths = 'W3WSwiftApi/Sources/W3WSwiftVoiceApi/module.modulemap'

end
