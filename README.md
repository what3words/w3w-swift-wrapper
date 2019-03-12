# <img valign='top' src="https://what3words.com/assets/images/w3w_square_red.png" width="64" height="64" alt="what3words">&nbsp;w3w-swift-wrapper

A swift library to use the [what3words REST API](https://docs.what3words.com/api/v3/).

# Overview

The what3words Swift wrapper gives you programmatic access to 

* convert a 3 word address to coordinates 
* convert coordinates to a 3 word address
* autosuggest functionality which takes a slightly incorrect 3 word address, and suggests a list of valid 3 word addresses
* obtain a section of the 3m x 3m what3words grid for a bounding box.
* determine the currently support 3 word address languages.

This repository contains an Xcode project that builds a framework, and tests for the wrapper.  You may instead choose to skip the framework and simply drag and drop the `W3wGeocoder.swift` file into your project.

# Authentication

To use this library you’ll need a what3words API key, which can be signed up for [here](https://accounts.what3words.com/register?dev=true).

# Installation

#### CocoaPods (iOS 8+, OS X 10.10+)

You can use [CocoaPods](http://cocoapods.org/) to install `w3w-swift-wrapper`by adding it to your `Podfile`:

```ruby
platform :ios, '9.0'
use_frameworks!

target 'MyApp' do
    pod 'what3words', :git => 'https://github.com/what3words/w3w-swift-wrapper.git'
end
```

#### Carthage (iOS 8+, OS X 10.10+)

You can use [Carthage](https://github.com/Carthage/Carthage) to install `w3w-swift-wrapper` by adding it to your `Cartfile`:

```
github "what3words/w3w-swift-wrapper"
```

#### Swift Package Manager

You can use [The Swift Package Manager](https://swift.org/package-manager) to install `w3w-swift-wrapper` by adding the proper description to your `Package.swift` file:

```swift
.package(url: "https://github.com/what3words/w3w-swift-wrapper.git", .branch("master"))
```
and add "what3words" to the dependancies:

```swift
dependencies: ["what3words"]),
```


Note that the [Swift Package Manager](https://swift.org/package-manager) is still in early design and development, for more information checkout its [GitHub Page](https://github.com/apple/swift-package-manager)

#### Manually

You can manually drag W3wGeocoder.swift into the project tree.  You can then skip the import statement in your code.

### Import

If you used the framework via a package manager then use the following:

```swift
import what3words
import CoreLocation
```

Note: If you skipped the framework and manually dragged and dropped the W3wGeocoder.swift then you don't need use the import statement.

### Initialise

```swift
W3wGeocoder.setup(with: "<Secret API Key>")
```
### Usage

Calls to the API are done through a shared singleton. Also, each call takes a completion block as the last parameter. This allows Swift's trailing closure syntax to be used.  The return values are helper objects containing the relevant values.  If there was a problem with any call, it will be indicated by the error object.  See example below.

## Convert To 3 Word Address

Convert coordinates, expressed as latitude and longitude to a 3 word address.

This function takes the latitude and longitude as a CLLocationCoordinate2D object

The returned payload from the `convertTo3wa` method is described in the [what3words REST API documentation](https://docs.what3words.com/api/v3/#convert-to-3wa).

#### Code Example
```swift
let coords = CLLocationCoordinate2D(latitude: 51.4243877, longitude: -0.34745)
W3wGeocoder.shared.convertTo3wa(coordinates: coords) { (place, error) in
    print(place?.words)
}
```


## Convert To Coordinates
Convert a 3 word address to a position, expressed as coordinates of latitude and longitude.

This function takes the words parameter as a string of 3 words `'table.book.chair'`

The returned payload from the `convertToCoordinates` method is described in the [what3words REST API documentation](https://docs.what3words.com/api/v3/#convert-to-coordinates).

#### Code Example
```swift
W3wGeocoder.shared.convertToCoordinates(words: "index.home.raft") { (place, error) in
    print(place?.coordinates.latitude, place?.coordinates.longitude)
}
```

## AutoSuggest

Returns a list of 3 word addresses based on user input and other parameters.

This method provides corrections for the following types of input error:
* typing errors
* spelling errors
* misremembered words (e.g. singular vs. plural)
* words in the wrong order

The `autoSuggest` method determines possible corrections to the supplied 3 word address string based on the probability of the input errors listed above and returns a ranked list of suggestions. This method can also take into consideration the geographic proximity of possible corrections to a given location to further improve the suggestions returned.

### Input 3 word address

You will only receive results back if the partial 3 word address string you submit contains the first two words and at least the first character of the third word; otherwise an error message will be returned.

### Clipping and Focus

We provide various `clip` policies to allow you to specify a geographic area that is used to exclude results that are not likely to be relevant to your users. We recommend that you use the clipping to give a more targeted, shorter set of results to your user. If you know your user’s current location, we also strongly recommend that you use the `focus` to return results which are likely to be more relevant.

In summary, the clip policy is used to optionally restrict the list of candidate AutoSuggest results, after which, if focus has been supplied, this will be used to rank the results in order of relevancy to the focus.

The returned payload from the `autosuggest` method is described in the [what3words REST API documentation](https://docs.what3words.com/api/v2/#autosuggest-result).

### Usage

The first parameter `input` is the partial three words, or voice data.  It is followed by a varidic list of AutoSuggestOption objects.  The last parameter is the completion block.

#### Code Example One
```swift
W3wGeocoder.shared.autosuggest(input: "geschaft.planter.carciofi", options: ClipToCountry(country:"DE")) { (suggestions, error) in
    for suggestion in suggestions ?? [] {
      print("\(suggestion.words) is near \(suggestion.nearestPlace) - Country Code:\(suggestion.country)")
    }
}
```

#### Code Example Two
```swift
let coords = CLLocationCoordinate2D(latitude: 51.4243877, longitude: -0.34745)
W3wGeocoder.shared.autosuggest(input: flottons.annulons.garço", options: Focus(focus: coords), FallbackLanguage(language: "fr")) { (suggestions, error) in
    print(suggestions)
}
```


#### Code Example Three
```swift
let coords = CLLocationCoordinate2D(latitude: 51.4243877, longitude: -0.34745)
W3wGeocoder.shared.autosuggest(input: "geschaft.planter.carciofi", options: Focus(focus: coords), FallbackLanguage(language: "de")) { (suggestions, error) in
    print(suggestions)
}
```
## Available Languages

This function returns the currently supported languages.  It will return the two letter code ([ISO 639](https://en.wikipedia.org/wiki/ISO_639)), and the name of the language both in that language and in English.

The returned payload from the `convertTo3wa` method is described in the [what3words REST API documentation](https://docs.what3words.com/api/v3/#available-languages)

#### Code Example
```swift
W3wGeocoder.shared.availableLanguages() { (languages, error) in
    print(languages)
}
```

## Grid Section

Returns a section of the 3m x 3m what3words grid for a given area. The requested box must not exceed 4km from corner to corner, or a BadBoundingBoxTooBig error will be returned. Latitudes must be >= -90 and <= 90, but longitudes are allowed to wrap around 180. To specify a bounding-box that crosses the anti-meridian, use longitude greater than 180. Example value: 50.0, 179.995, 50.01, 180.0005. 

The returned payload from the `gridSection` function  is described in the [what3words REST API documentation](https://docs.what3words.com/api/v3/#grid-section)

#### Code Example
```swift
W3wGeocoder.shared.gridSection(south_lat: 52.208867, west_lng: 0.117540, north_lat: 52.207988, east_lng: 0.116126) { (lines, error) in
    print(lines)
}
```


## Handling Errors

All functions call the completion block with `error` as the second parameter.  Be sure to check it for possible problems.

```php
W3wGeocoder.shared.convertToCoordinates(words: "index.home.raft") { (result, error) in
      if let e = error {
        print(e.code, e.message)
    }
}
```

Error values are listed in the [what3words REST API documentation](https://docs.what3words.com/api/v3/#error-handling). 
