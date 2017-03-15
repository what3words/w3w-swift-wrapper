# <img src="https://what3words.com/assets/images/w3w_square_red.png" width="64" height="64" alt="what3words">&nbsp;w3w-swift-wrapper

A swift library to use the [what3words REST API](https://docs.what3words.com/api/v2/).

# Overview

The what3words Swift library gives you programmatic access to convert a 3 word address to coordinates (_forward geocoding_), to convert coordinates to a 3 word address (_reverse geocoding_), and to determine the currently support 3 word address languages.

## Authentication

To use this library you’ll need a what3words API key, which can be signed up for [here](https://map.what3words.com/register?dev=true).

# Installation

#### CocoaPods (iOS 8+, OS X 10.9+)

You can use [CocoaPods](http://cocoapods.org/) to install `w3w-swift-wrapper`by adding it to your `Podfile`:

```ruby
platform :ios, '8.0'
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
import PackageDescription

let package = Package(
    name: "YOUR_PROJECT_NAME",
    targets: [],
    dependencies: [
        .Package(url: "https://github.com/what3words/w3w-swift-wrapper.git", versions: Version(1,0,0)..<Version(1, .max, .max)),
    ]
)
```

Note that the [Swift Package Manager](https://swift.org/package-manager) is still in early design and development, for more information checkout its [GitHub Page](https://github.com/apple/swift-package-manager)

#### Manually (iOS 7+, OS X 10.10+)

To use this library in your project manually just drag W3wGeocoder.swift to the project tree

## Forward geocoding
Forward geocodes a 3 word address to a position, expressed as coordinates of latitude and longitude.

This function takes the words parameter as a string of 3 words `'table.book.chair'`

The returned payload from the `forwardGeocode` method is described in the [what3words REST API documentation](https://docs.what3words.com/api/v2/#forward-result).

## Reverse geocoding

Reverse geocodes coordinates, expressed as latitude and longitude to a 3 word address.

This function takes the latitude and longitude as a CLLocationCoordinate2D object

The returned payload from the `reverseGeocode` method is described in the [what3words REST API documentation](https://docs.what3words.com/api/v2/#reverse-result).


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

We provide various `clip` policies to allow you to specify a geographic area that is used to exclude results that are not likely to be relevant to your users. We recommend that you use the `clip` parameter to give a more targeted, shorter set of results to your user. If you know your user’s current location, we also strongly recommend that you use the `focus` to return results which are likely to be more relevant.

In summary, the `clip` policy is used to optionally restrict the list of candidate AutoSuggest results, after which, if focus has been supplied, this will be used to rank the results in order of relevancy to the focus.

http://docs.what3words.local/api/v2/#autosuggest-clip

The returned payload from the `autosuggest` method is described in the [what3words REST API documentation](https://docs.what3words.com/api/v2/#autosuggest-result).

## Get Languages

Retrieves a list of the currently loaded and available 3 word address languages.

The returned payload from the `languages` method is described in the [what3words REST API documentation](https://docs.what3words.com/api/v2/#lang-result).

## Code examples

```swift
import what3words
W3wGeocoder.setup(with: "<Secret API Key>")
```

### Forward Geocode
```swift
W3wGeocoder.shared.forwardGeocode(addr: "index.home.raft") { (result, error) in
    print(result)
}
```

### Reverse Geocode
```swift
let coords = CLLocationCoordinate2D(latitude: 51.4243877, longitude: -0.34745)
W3wGeocoder.shared.reverseGeocode(coords: coords) { (result, error) in
    print(result)
}
```
