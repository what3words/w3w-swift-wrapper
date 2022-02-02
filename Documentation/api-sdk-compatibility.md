# <img valign='top' src="https://what3words.com/assets/images/w3w_square_red.png" width="64" height="64" alt="what3words">&nbsp;SDK - API compatibility


Overview
--------

The SDK and API are designed to be interoperable. This is done by making them conform to a common protocol called `W3WProtocolV3`.  To upgrade your code from using the API to the SDK, you should only have to chage the line that instantiates the API to instantiate the SDK instead.  All other subsequent calls can remain exactly the same.

#### convertToCoordinates Example

To call `convertToCoordinates` using the API you would use something like this:

```
import W3WSwiftApi

var api = What3WordsV3(apiKey: "YourApiKey")

api.convertToCoordinates(words: "filled.count.soap") { square, error in
  print(square?.coordinates?.latitude, square?.coordinates?.longitude)
}
```

Notice that it is exactly the same function call with the SDK:


```
import w3w
import W3WSwiftApi

let sdk = What3Words(dataPath: "/path/to/w3w-data")

sdk.convertToCoordinates(words: "filled.count.soap") { square, error in
  print(square?.coordinates?.latitude, square?.coordinates?.longitude)
}
```

Note that `W3WSwiftApi` is still imported in the SDK example. This is becuase the API has the `W3WProtocolV3` definition.


### W3WProtocolV3

The `W3WProtocolV3` protocol ensures the following functions are peresent in the api's `What3WordsV3` and the sdk's `What3Words` objects:

`convertToCoordinates`, `convertTo3wa`, `autosuggest`, `autosuggestWithCoordinates`, `gridSection`, `availableLanguages`, `distance`, `isPossible3wa`, `findPossible3wa`, `didYouMean`

### Additional SDK functionality

As mentioned earlier, if you are switching from the API to the SDK, all you need to do is change the api's `What3WordsV3` to the sdk's `What3Words`, and everything will work the same.  However, the SDK contains additional functions that the API does not have.  This is because the API call takes time to execute and the SDK can return a result immediately.

For each function common to the SDK and API there is one additional function in the SDK that does not take a completion block, but instead returns the values directly.  If you are not concerned about also using the API interoperably, you might decide to change to them to make the code cleaner.

For example, the `converToCoordinates` call above could be done without the callback (SDK only):

```
let coordinates = try? sdk.convertToCoordinates(words: "filled.count.soap")
print(coordinates?.latitude, coordinates?.longitude)
```

However, note that it returns only the coordinates and not the whole square.  To get a square from this, there is also an additional convenience function for that: `convertToSquare`:

```
let square = try? sdk.convertToSquare(coordinates: coords, language: "en")
```

### The what3words Swift Component library

What3words maintains a component library which contains text fields with autosuggest and map UI components.  The entire library is built against `W3WProtocolV3` and not specifically the API or SDK.  Therefore if you use any of those components, you can pass in either an api or sdk object wherever one is needed.

The component library can be found here: [https://github.com/what3words/w3w-swift-components](https://github.com/what3words/w3w-swift-components)

##### Consider using W3WProtocolV3 in your code

If you pass the API or SDK object around your code, consider using ``W3WProtocolV3` as a type in your functions so that they can also take either the API's`What3WordsV3` or the sdk's `What3Words` object. This is what we did with the `W3WSwiftComponents` library.

For example:

```
  func printCoordinates(w3w: W3WProtocolV3, words: String) {
    w3w.convertToCoordinates(words: words) { square, error in
      print(square?.coordinates?.latitude, square?.coordinates?.longitude)
    }
  }
  
  // print coordinates using the API
  printCoordinates(w3w: api, words: "filled.count.soap")

  // print coordinates using the SDK
  printCoordinates(w3w: sdk, words: "filled.count.soap")
```



### The W3WProtocolV3 functions

Here are definitions of the `W3WProtocolV3` available functions:

```
convertToCoordinates(words: String, completion: @escaping W3WSquareResponse)

convertTo3wa(coordinates: CLLocationCoordinate2D, language: String, completion: @escaping W3WSquareResponse)

autosuggest(text: String, options: [W3WOptionProtocol], completion: @escaping W3WSuggestionsResponse)

autosuggest(text: String, options: W3WOptionProtocol..., completion: @escaping W3WSuggestionsResponse)

autosuggest(text: String, completion: @escaping W3WSuggestionsResponse)

autosuggestWithCoordinates(text: String, options: [W3WOptionProtocol], completion: @escaping W3WSuggestionsWithCoordinatesResponse)

autosuggestWithCoordinates(text: String, options: W3WOptionProtocol..., completion: @escaping W3WSuggestionsWithCoordinatesResponse)

autosuggestWithCoordinates(text: String, completion: @escaping W3WSuggestionsWithCoordinatesResponse)

gridSection(south_lat:Double, west_lng:Double, north_lat:Double, east_lng:Double,   

gridSection(southWest:CLLocationCoordinate2D, northEast:CLLocationCoordinate2D, completion: @escaping W3WGridResponse)

availableLanguages(completion: @escaping W3WLanguagesResponse)
```

### Additional SDK functions

These functions are available with the SDK, but not part of the `W3WProtocolV3`

```
convertToCoordinates(words: String) throws -> CLLocationCoordinate2D?

convertTo3wa(coordinates: CLLocationCoordinate2D, language: String) throws -> String?

autosuggest(text: String, options: [W3WSdkOption]) throws -> [W3WSdkSuggestion]

autosuggest(text: String, options: W3WSdkOptions) throws -> [W3WSdkSuggestion]

autosuggest(text: String, options: W3WSdkOption) throws -> [W3WSdkSuggestion]

version() -> String

dataVersion() -> String

gridSection(south: Double, west: Double, north: Double, east: Double) -> [W3WSdkLine]?

gridSection(southWest: CLLocationCoordinate2D, northEast: CLLocationCoordinate2D) -> [W3WSdkLine]?

availableLanguages() -> [W3WSdkLanguage]

convertToSquare(words: String) throws -> W3WSdkSquare?

convertToSquare(coordinates: CLLocationCoordinate2D, language: String) throws -> W3WSdkSquare?

```