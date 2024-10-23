# <img valign='top' src="https://what3words.com/assets/images/w3w_square_red.png" width="64" height="64" alt="what3words">&nbsp;SDK - API compatibility


Overview
--------

The SDK and API are designed to be interoperable. This is done by making them conform to a common protocol called `W3WProtocolV4`.  To upgrade your code from using the API to the SDK, you should only have to change the line that instantiates the API to instantiate the SDK instead.  All other subsequent calls can remain exactly the same.

#### convertToCoordinates Example

To call `convertToCoordinates` using the API you would use something like this:

```
import W3WSwiftApi

var api = What3WordsV4(apiKey: "YourApiKey")

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

Note that `W3WSwiftApi` is still imported in the SDK example. This is because the API has the `W3WProtocolV4` definition.

For more info on parameters required when constructing the SDK's `What3Words` object, please refer to the SDK documentation.  Generally it needs the path to the what3words language data (`w3w-data`).  There is also an optional second parameter called `engineType` which for all Apple devices you'll almost certainly want to leave as the default `.device` type.

### W3WProtocolV4

The `W3WProtocolV4` protocol ensures the following functions are present in the api's `What3WordsV4` and the sdk's `What3Words` objects:

`convertToCoordinates`, `convertTo3wa`, `autosuggest`, `autosuggestWithCoordinates`, `gridSection`, `availableLanguages`, `distance`, `isPossible3wa`, `findPossible3wa`, `didYouMean`

### Additional SDK functionality

As mentioned earlier, if you are switching from the API to the SDK, all you need to do is change the api's `What3WordsV4` to the sdk's `What3Words`, and everything will work the same.  However, the SDK contains additional functions that the API does not have.  This is because the API call takes time to execute and the SDK can return a result immediately.

For each function common to the SDK and API there is one additional function in the SDK that does not take a completion block, but instead returns the values directly.  If you are not concerned about also using the API interoperably, you might decide to change to them to make the code cleaner.

For example, the `converToCoordinates` call above could be done without the callback (SDK only):

```
let coordinates = try? sdk.convertToCoordinates(words: "filled.count.soap")
print(coordinates?.latitude, coordinates?.longitude)
```

However, note that it returns only the coordinates and not the whole square.  To get a square from this, there is also an additional convenience function for that: `convertToSquare`:

```
let square = try? sdk.convertToSquare(coordinates: coords, language: W3WBaseLanguage(locale: "en"))
```

### The what3words Swift Component library

What3words maintains a component library which contains text fields with autosuggest and map UI components.  The entire library is built against `W3WProtocolV4` and not specifically the API or SDK.  Therefore if you use any of those components, you can pass in either an api or sdk object wherever one is needed.

The component library can be found here: [https://github.com/what3words/w3w-swift-components](https://github.com/what3words/w3w-swift-components)

##### Consider using W3WProtocolV4 in your code

If you pass the API or SDK object around your code, consider using ``W3WProtocolV4` as a type in your functions so that they can also take either the API's`What3WordsV4` or the sdk's `What3Words` object. This is what we did with the `W3WSwiftComponents` library.

For example:

```
  func printCoordinates(w3w: W3WProtocolV4, words: String) {
    w3w.convertToCoordinates(words: words) { square, error in
      print(square?.coordinates?.latitude, square?.coordinates?.longitude)
    }
  }
  
  // print coordinates using the API
  printCoordinates(w3w: api, words: "filled.count.soap")

  // print coordinates using the SDK
  printCoordinates(w3w: sdk, words: "filled.count.soap")
```



### The W3WProtocolV4 functions

Here are definitions of the `W3WProtocolV4` available functions:

```
 /**
   Converts a 3 word address to a position, expressed as coordinates of latitude and longitude.
   - parameter words: A 3 word address as a string
   - parameter format: Return data format type; can be one of json (the default) or geojson
   - parameter completion: A W3ResponsePlace completion handler
   */
  func convertToCoordinates(words: String, completion: @escaping W3WSquareResponse)
  
  
  /**
   Returns a three word address from a latitude and longitude
   - parameter coordinates: A CLLocationCoordinate2D object
   - parameter language: A supported 3 word address language as an ISO 639-1 2 letter code. Defaults to en
   - parameter format: Return data format type; can be one of json (the default) or geojson
   - parameter completion: A W3ResponsePlace completion handler
   */
  func convertTo3wa(coordinates: CLLocationCoordinate2D, language: W3WLanguage, completion: @escaping W3WSquareResponse)
  
  
  /**
   Returns a list of 3 word addresses based on user input and other parameters.
   - parameter input: The full or partial 3 word address to obtain suggestions for. At minimum this must be the first two complete words plus at least one character from the third word.
   - options are provided by instantiating W3Option objects in the varidic length parameter list.  Eg:
   */
  func autosuggest(text: String, options: [W3WOption]?, completion: @escaping W3WSuggestionsResponse)
  func autosuggest(text: String, options: W3WOptions?, completion: @escaping W3WSuggestionsResponse)
  func autosuggest(text: String, options: W3WOption..., completion: @escaping W3WSuggestionsResponse)
  func autosuggest(text: String, completion: @escaping W3WSuggestionsResponse)
  
  
  /**
   Returns a list of 3 word addresses based on user input and other parameters, including coordinates of each suggestion
   - parameter input: The full or partial 3 word address to obtain suggestions for. At minimum this must be the first two complete words plus at least one character from the third word.
   - options are provided by instantiating W3Option objects in the varidic length parameter list.  Eg:
   */
  func autosuggestWithCoordinates(text: String, options: [W3WOption]?, completion: @escaping W3WSquaresResponse)
  func autosuggestWithCoordinates(text: String, options: W3WOptions?, completion: @escaping W3WSquaresResponse)
  func autosuggestWithCoordinates(text: String, options: W3WOption..., completion: @escaping W3WSquaresResponse)
  func autosuggestWithCoordinates(text: String, completion: @escaping W3WSquaresResponse)
  
  
  /**
   Returns a section of the 3m x 3m what3words grid for a given area.
   - parameter southWest: The southwest corner of the box
   - parameter northEast: The northeast corner of the box
   - parameter format: Return data format type; can be one of json (the default) or geojson Example value:format=Format.json
   - parameter completion: A W3wGeocodeResponseHandler completion handler
   */
  func gridSection(southWest:CLLocationCoordinate2D, northEast:CLLocationCoordinate2D, completion: @escaping W3WGridResponse)
  
  /**
   Returns a section of the 3m x 3m what3words grid for a given area.
   - parameter bounds: The bounds of the box
   - parameter format: Return data format type; can be one of json (the default) or geojson Example value:format=Format.json
   - parameter completion: A W3wGeocodeResponseHandler completion handler
   */
  func gridSection(bounds: W3WBox, completion: @escaping W3WGridResponse)

  /**
   Retrieves a list of the currently loaded and available 3 word address languages.
   - parameter completion: A W3wGeocodeResponseHandler completion handler
   */
  func availableLanguages(completion: @escaping W3WLanguagesResponse)
  
```
