![what3words](https://circleci.com/gh/what3words/w3w-swift-wrapper.svg?style=shield&branch=master)

# <img valign='top' src="https://what3words.com/assets/images/w3w_square_red.png" width="64" height="64" alt="what3words">&nbsp;w3w-swift-wrapper 

A swift library to use the what3words [REST API](https://docs.what3words.com/api/v3/), and the what3words [VoiceAPI](https://developer.what3words.com/voice-api).  

# Overview

The what3words Swift API wrapper gives you programmatic access to 

* convert a 3 word address to coordinates 
* convert coordinates to a 3 word address
* autosuggest functionality which takes a slightly incorrect 3 word address, and suggests a list of valid 3 word addresses
* obtain a section of the 3m x 3m what3words grid for a bounding box.
* determine the currently support 3 word address languages.
* autosuggest functionality to convert a spoken 3 word address (via voiceAPI) to a list of valid 3 word addresses

The main API swift wrapper object is `What3WordsV3` and provides the above functionality.  There is also a higher level `W3WAutosuggestHelper` that does a lot of the work of calling the API for text field autosuggest functionality.  This is particularly helpful if you want to add what3words to your existing autocomplete code. A tutorial can be found [here](Documentation/tutorial-as-helper.md).

Even higher level UI functionality can be found in our UI components library, [w3w-swift-components](https://github.com/what3words/w3w-swift-components), found on GitHub.  Notably our `W3WAutosuggestTextField` inherits `UITextField` and adds three word address autocomplete functionality.

#### TLDR: 

You can find a short tutorial [here](Documentation/tutorial.md) that will show you how to get minimally set up and running.

#### Objective-C

This package also contains an Objective-C compatible version, `What3WordsObjC` - see the `ObjectiveC` project in [Examples/ObjectiveC/ObjectiveC.xcodeproj](./Examples/ObjectiveC/ObjectiveC.xcodeproj)

# OS Requirements

This package works with:
 
 * macOS version 10.11 or higher
 * iOS version 9 or higher
 * tvOS version 9 or higher
 * watchOS version 2 or higher


# Authentication

To use this library you’ll need a what3words API key, which can be signed up for [here](https://what3words.com/select-plan).  If you wish to use the Voice API calls then you must add a Voice API plan to your [account](https://accounts.what3words.com/billing).


# Installation

#### Swift Package Manager

You can install this with [Swift Package Manager](https://developer.apple.com/documentation/xcode/adding_package_dependencies_to_your_app) by adding the URL below to Swift Packages under your project settings:

```
https://github.com/what3words/w3w-swift-wrapper.git
```

#### CocoaPods (iOS 9+, OS X 10.10+)

You can use CocoaPods to install w3w-swift-wrapper by adding it to the target in your Podfile:

```
pod 'W3WSwiftApi', :git => 'https://github.com/what3words/w3w-swift-wrapper.git'
```

#### XCFramework

There is a `build.sh` script can be run to build this code as an XCFramework.  This uses the included `w3w-swift-wrapper.xcodeproj`.

## Usage

### Import

In any file you use the what3words API in, import the following:

```swift
import W3WSwiftApi
import CoreLocation
```

##### Note:

* If you are using CocoaPods use `import what3words` instead.
* If you are using this package's Voice API features on device, you should include Microphone permissions:

<img src="Documentation/plist2.png" width="75%">


### Initialise

Use the following code with your API key to initialise the API:

```swift
let api = What3WordsV3(apiKey: "YourApiKey")
```
In the case that you run our Enterprise Suite API Server yourself, you may specify the URL to your own server like so:

```swift
let api = What3WordsV3(apiKey: "YourApiKey", apiUrl: "https://api.yourserver.com")
```

Additionally, if you run the Enterprise Suite API Server there is another optional `setup()` parameter: `customHeaders`.  Use this if you need to send custom headers to your own server:

```swift
let api = What3WordsV3(apiKey: "YourApiKey", apiUrl: "https://api.yourserver.com", customHeaders: ["x-header-1":"value-1", "x-header-2":"value-2"])
```

# Functions

Each call takes a completion block as the last parameter. This allows Swift's trailing closure syntax to be used.  The closure's parameters contain the results.  If there was a problem with any call, it will be indicated by the [error object](#errors).

## Convert To 3 Word Address

Convert coordinates, expressed as latitude and longitude to a 3 word address. This function takes the latitude and longitude as a [CLLocationCoordinate2D](https://developer.apple.com/documentation/corelocation/cllocationcoordinate2d) object. The values returned from the `convertTo3wa` method are described in the [API documentation](https://docs.what3words.com/api/v3/#convert-to-3wa).

##### Code Example:

```swift
let coords = CLLocationCoordinate2D(latitude: 51.4243877, longitude: -0.34745)
api.convertTo3wa(coordinates: coords, language: "en") { square, error in
    print(square?.words ?? "")
}
```


## Convert To Coordinates

Convert a 3 word address to a position, expressed as coordinates of latitude and longitude. This function takes the words parameter as a string of 3 words `'table.book.chair'`. The values returned from the `convertToCoordinates` method are described in the [API documentation](https://docs.what3words.com/api/v3/#convert-to-coords).

##### Code Example:
```swift
api.convertToCoordinates(words: "filled.count.soap") { square, error in
  print(square?.coordinates ?? "")
}
```

## AutoSuggest

Returns a list of 3 word addresses based on user input and other parameters.

This method provides corrections for the following types of input error:

* typing errors
* spelling errors
* misremembered words (e.g. singular vs. plural)
* words in the wrong order

The `autosuggest` method determines possible corrections to the supplied 3 word address string based on the probability of the input errors listed above and returns a ranked list of suggestions. This method can also take into consideration the geographic proximity of possible corrections to a given location to further improve the suggestions returned.

* voice

If you have a VoiceAPI enabled account, you may also call `autosuggest` with audio data for voice recognition.  In order for this to work, you must add a Voice API plan to [your account](https://accounts.what3words.com/billing).
  There is a minimal [example of this below](#voice-example), but detailed information can be found [here](Documentation/README.voiceAPI.md)

### Input 3 word address

You will only receive results back if the partial 3 word address string you submit contains the first two words and at least the first character of the third word; otherwise an error message will be returned.

To check if your address string meets this criteria, we provide a simple function that employs our regex to help you recognise the three word addresses.  It is called `isPossible3wa`, but please note that it only indicates if the input is three potential words separated by two w3w separators.  It WILL NOT tell you if it is a real three word address in world.  The following `if` evaluates to `true`.

```
if api.isPossible3wa(text: "xxx.xxx.x") {
  print("Input is in the form of a three word address")
} else {
  print("Input is NOT in the form of a three word address")
}
```

Or if you prefer, you can simply use our regex. Example code can be found in our [regex documentation](https://developer.what3words.com/tutorial/detecting-if-text-is-in-the-format-of-a-3-word-address).


### Clipping

We provide various `clip` policies to allow you to filter by a geographic area. We recommend that you use the clipping to give a more targeted set of results to your user. You can clip by country, or by geographical box, circle or polygon.  Do this via the `W3WOptions` and pass it into the autosuggest call (see example below).

### Focus

If you know your user’s current location, we also ***strongly*** recommend that you use focus to return results which are likely more relevant.  Do this via the `W3WOptions` and pass it into the autosuggest call (see example below)


The values returned from the `autosuggest` method are described in the [what3words REST API documentation](https://developer.what3words.com/public-api/docs#autosuggest).

### Usage

The first parameter is the partial three words, or voice data.  The second optional parameter is the options for the autosuggest function.  The last parameter is the completion block.

#### Example One
```swift
api.autosuggest(text: "filled.count.soa") { (suggestions, error) in
  for suggestion in suggestions ?? [] {
    print("\(suggestion.words ?? "") is near \(suggestion.nearestPlace ?? "")")
  }
}
```

#### Example Two
Focus on one particular place using a single option:

```swift
let coords = CLLocationCoordinate2D(latitude: 51.4243877, longitude: -0.34745)
api.autosuggest(text: "flottons.annulons.garço", options: W3WOption.focus(coords)) { (suggestions, error) in
  print(suggestions ?? "")
}
```


#### Example Three
Focus on (51.4243877,-0.34745), and clip to the UK using the multiple options object:
 
```swift
let coords = CLLocationCoordinate2D(latitude: 51.4243877, longitude: -0.34745)
let options = W3WOptions().focus(coords).clipToCountry("GB")
api.autosuggest(text: "flottons.annulons.garço", options: options) { (suggestions, error) in
  print(suggestions ?? "")
}
```


<a name="voice-example"></a>
#### VoiceAPI Example

The what3words Voice API allows a user to say three words into any application or service, with it returning a configurable list of what3words address suggestions, all through a single API call.

In order for this to work, you must add a Voice API plan to [your account](https://accounts.what3words.com/billing).

This example instantiates a `W3WMicrophone` which provides an audio stream to `autosuggest(audio:)` which begins recording when `autosuggest` is called.  For information on `W3WMicrophone` and customizing your own `W3WAudioStream` for `autosuggest(audio:)` see the [VoiceAPI README](Documentation/README.voiceAPI.md). 

```swift
// make a microphone
let microphone = W3WMicrophone()

// call autosuggest
api.autosuggest(audio: microphone, language: "en") { suggestions, error in
  for suggestion in suggestions ?? [] {
    print(suggestion.words ?? "no suggestions")
  }
}
```

Also, `W3WMicrophone` has a callback closure `W3WMicrophone.volumeUpdate: (Double) -> ()` that provides amplitude information useful for animating user feedback.  See the the [Voice API example](./Examples/VoiceAPI/VoiceAPI.xcodeproj), and more information is avialable in the [VoiceAPI README](Documentation/README.voiceAPI.md).

## Available Languages

This function returns the currently supported languages for text based `autosuggest(text:)` calls.  It will return the two letter code ([ISO 639](https://en.wikipedia.org/wiki/ISO_639)), and the name of the language both in that language and in English.

The values returned from the `convertTo3wa` method are described in the [what3words REST API documentation](https://docs.what3words.com/api/v3/#available-languages)

#### Code Example
```swift
api.availableLanguages() { (languages, error) in
  for language in languages ?? [] {
    print(language.code, language.name, language.nativeName)
  }
}
```

For the available Voice API languages call `api.availableVoiceLanguages(completion:)` which works exactly the same way.

## Grid Section

Returns a section of the 3m x 3m what3words grid for a given area. The requested box must not exceed 4km from corner to corner, or a BadBoundingBoxTooBig error will be returned. Latitudes must be >= -90 and <= 90, but longitudes are allowed to wrap around 180. To specify a bounding-box that crosses the anti-meridian, use longitude greater than 180. Example value: 50.0, 179.995, 50.01, 180.0005. 

The grid is returned as `[W3WLine]?` and each `W3WLine` contains a `start` and `end` variable, both of type `CLLocationCoordinate2D`.

The values returned from the `gridSection` function are described in the [what3words REST API documentation](https://docs.what3words.com/api/v3/#grid-section)

#### Code Example
```swift
let southWest = CLLocationCoordinate2D(latitude: 52.208867, longitude: 0.117540)
let northEast = CLLocationCoordinate2D(latitude: 52.207988, longitude: 0.116126)

api.gridSection(southWest: southWest, northEast: northEast) { (lines, error) in
  for line in lines ?? [] {
    print(line.start, " -> ", line.end)
  }
}
```

## Validation Functions

These are some functions that will search or validate three word addresses.

#### isPossible3wa(text: String) -> Bool

 Checks to see if the text follows the form of a three word address via regex, that is, a word followed by a separator followed by a word followed by a separator followed by a word.  A word is defined as series of letters that belong to any writing system.
This does not validate the address as being a real location on the earth, just that it follows the textual form of one.  For example, xx.xx.xx would pass this test even though it is not a valid address.

```Swift
if api.isPossible3wa(text: "abc.def.ghi") {
  print("does match the text pattern for a three word address")
}
```

This would print the result because even though "abc.def.ghi" is **not** a valid three word address, still it **does** fit the form of one, [word][separator][word][separator][word].

#### isValid3wa(words: String, completion: @escaping (Bool) -> ())

Verifies that the text is a valid three word address that successfully represents a square on earth.  This makes a call to the API to verify.  The other validation functions only run a regex locally.

```Swift
api.isValid3wa(words: "filled.count.soap") { valid in
  if valid {
    print("the address provided is a real address somewhere on earth")
  }
}
```

#### findPossible3wa(text: String) -> [String]

Finds any number of possible three word addresses in a block of text. The term "possible three word addresses" refers to text that matches the regex used in isPossible3wa(), that is, these are pieces of text that appear to be three word address, but have not been veified against the engine as representing an actual place on earth.

```Swift
let twas = api.findPossible3wa(text: "This is a filled.count.soap sentence with index.home.raft fun in it nowhere near grilled.cheese.sandwhich")
print(twas)
```

This will print out: `["filled.count.soap", "index.home.raft", "grilled.cheese.sandwhich"]`


<a name="errors"></a>
## Handling Errors

All functions call the completion block with `error` as the second parameter.  All Swift what3words `error` types are of `enum` type and conform to [`CustomStringConvertible`](https://developer.apple.com/documentation/swift/customstringconvertible), so they can be used with `String(describing: error)`:

#### Code Example
```swift
api.convertTo3wa(coordinates: CLLocationCoordinate2D(latitude: 51.4243877, longitude: -0.34745)) { square, error in
  if let e = error {
    print(String(describing: e))
  } else {
    print(square?.words ?? "")
  }
}
```

Api call errors are of type `W3WError` enum and the voice `autosuggest` call returns a `W3WVoiceError` enum.

<a name="sdk"></a>
## SDK Compatibility

There is also an SDK that works offline. More information is available [here](https://developer.what3words.com/enterprise-suite/mobile-offline-sdk).

The SDK can be used interchangeably with this API wrapper.  That is, you can start your project using this API wrapper, and you can later upgrade to the SDK with minimal changes to your code.

Below is a table of which SDK version is compatible with which API wrapper version:

| w3w-swift-wrapper | SDK Version       |
| ----------------- | ----------------- |
| v3.8.2 and lower  | v3.8.0 and lower  |
| v3.9.0 and higher | v4.0.0 and higher |
