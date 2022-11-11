# This script builds an XCFramework for this package against
# the what3words core SDK. used, only in very specific
# circumstances. It currently is used to make XCFramework builds
# for internal what3words use via CircleCI

# remove any old builds
if [ -d "build" ]
then
    rm -r build
fi

# remove any previous project
if [ -d "w3w-swift-wrapper.xcodeproj" ]
then
    rm -r w3w-swift-wrapper.xcodeproj
fi

cp -R AltBuild/w3w-swift-wrapper.xcodeproj ./

# make the frameworks for each architecture
xcodebuild archive -project w3w-swift-wrapper.xcodeproj -scheme w3w-swift-wrapper-Package -sdk iphoneos -archivePath build/W3WSwiftApiIosDevice SKIP_INSTALL=NO BUILD_LIBRARY_FOR_DISTRIBUTION=YES
xcodebuild archive -project w3w-swift-wrapper.xcodeproj -scheme w3w-swift-wrapper-Package -sdk iphonesimulator -archivePath build/W3WSwiftApiIosSimulator SKIP_INSTALL=NO BUILD_LIBRARY_FOR_DISTRIBUTION=YES
xcodebuild archive -project w3w-swift-wrapper.xcodeproj -scheme w3w-swift-wrapper-Package -sdk macosx -archivePath build/W3WSwiftApiMacOSDevice SKIP_INSTALL=NO BUILD_LIBRARY_FOR_DISTRIBUTION=YES
xcodebuild archive -project w3w-swift-wrapper.xcodeproj -scheme w3w-swift-wrapper-Package -sdk appletvos -archivePath build/W3WSwiftApitvOSDevice SKIP_INSTALL=NO BUILD_LIBRARY_FOR_DISTRIBUTION=YES
xcodebuild archive -project w3w-swift-wrapper.xcodeproj -scheme w3w-swift-wrapper-Package -sdk appletvsimulator -archivePath build/W3WSwiftApitvOSSimulator SKIP_INSTALL=NO BUILD_LIBRARY_FOR_DISTRIBUTION=YES
xcodebuild archive -project w3w-swift-wrapper.xcodeproj -scheme w3w-swift-wrapper-Package -sdk watchos -archivePath build/W3WSwiftApiwatchOSDevice SKIP_INSTALL=NO BUILD_LIBRARY_FOR_DISTRIBUTION=YES
xcodebuild archive -project w3w-swift-wrapper.xcodeproj -scheme w3w-swift-wrapper-Package -sdk watchsimulator -archivePath build/W3WSwiftApiwatchOSSimulator SKIP_INSTALL=NO BUILD_LIBRARY_FOR_DISTRIBUTION=YES

# package the frameworks into an XCFramework
xcodebuild -create-xcframework \
 -framework build/W3WSwiftApiIosDevice.xcarchive/Products/Library/Frameworks/W3WSwiftApi.framework \
 -framework build/W3WSwiftApiIosSimulator.xcarchive/Products/Library/Frameworks/W3WSwiftApi.framework \
 -framework build/W3WSwiftApiMacOSDevice.xcarchive/Products/Library/Frameworks/W3WSwiftApi.framework \
 -framework build/W3WSwiftApitvOSDevice.xcarchive/Products/Library/Frameworks/W3WSwiftApi.framework \
 -framework build/W3WSwiftApitvOSSimulator.xcarchive/Products/Library/Frameworks/W3WSwiftApi.framework \
 -framework build/W3WSwiftApiwatchOSDevice.xcarchive/Products/Library/Frameworks/W3WSwiftApi.framework \
 -framework build/W3WSwiftApiwatchOSSimulator.xcarchive/Products/Library/Frameworks/W3WSwiftApi.framework \
-output build/W3WSwiftApi.xcframework

