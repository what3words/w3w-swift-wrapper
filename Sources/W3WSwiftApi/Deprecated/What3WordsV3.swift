//
//  What3WordsV3.swift
//  
//
//  Created by Dave Duprey on 07/11/2022.
//

import Foundation
import W3WSwiftCore
import CoreLocation


@available(*, deprecated, message: "Use What3WordsV4 instead")
public class What3WordsV3: W3WProtocolV3 {
  
  var apiV4: What3WordsV4
  
  
  // MARK: Constructors
  
  /// Initialize the API wrapper
  /// - Parameters:
  ///     - apiKey: Your api key.  Register for one at: https://accounts.what3words.com/create-api-key
  public init(apiKey: String) {
    apiV4 = What3WordsV4(apiKey: apiKey, apiUrl: W3WSettings.apiUrl)
  }
  
  
  /// Initialize the API wrapper
  /// - Parameters:
  ///     - apiKey: Your api key.  Register for one at: https://accounts.what3words.com/create-api-key
  ///     - apiUrl: Url for custom server - for enterprise customers
  public init(apiKey: String, apiUrl: String) {
    apiV4 = What3WordsV4(apiKey: apiKey, apiUrl: apiUrl)
  }
  
  
  /// Initialize the API wrapper
  /// - Parameters:
  ///     - apiKey: Your api key.  Register for one at: https://accounts.what3words.com/create-api-key
  ///     - apiUrl: Url for custom server - for enterprise customers
  ///     - customHeaders: additional HTTP headers to send on requests - for enterprise customers
  public init(apiKey: String, apiUrl: String, customHeaders: [String: String]) {
    apiV4 = What3WordsV4(apiKey: apiKey, apiUrl: apiUrl, headers: customHeaders)
  }
  
  
  
  // MARK: API Convert Functions
  
  /**
   Converts a 3 word address to a position, expressed as coordinates of latitude and longitude.
   - parameter words: A 3 word address as a string
   - parameter completion: A W3ResponsePlace completion handler
   */
  public func convertToCoordinates(words: String, completion: @escaping W3WSquareResponse) {
    apiV4.convertToCoordinates(words: words, completion: completion)
  }
  
  
  /**
   Returns a three word address from a latitude and longitude
   - parameter coordinates: A CLLocationCoordinate2D object
   - parameter language: A supported 3 word address language as an ISO 639-1 2 letter code. Defaults to en
   - parameter completion: A W3ResponsePlace completion handler
   */
  public func convertTo3wa(coordinates: CLLocationCoordinate2D, language: String = W3WApiLanguage.english.code, completion: @escaping W3WSquareResponse) {
    apiV4.convertTo3wa(coordinates: coordinates, language: W3WBaseLanguage(locale: language), completion: completion)
  }
  
  
  // MARK: Autosuggest
  
  
  /**
   Returns a list of 3 word addresses based on user input and other parameters.
   - parameter text: The full or partial 3 word address to obtain suggestions for. At minimum this must be the first two complete words plus at least one character from the third word.
   - parameter options: are provided as an array of W3Option objects. They can also be passed as a  varidic length parameter list, or in a W3WOptopns() object thanks to the W3WProtocolV3 protocol conformity
   - parameter callback: A completion block providing the suggestions and any error - ([W3WVoiceSuggestion]?, W3WVoiceError?) -> Void
   -  autosuggest(input: "filled.count.soap", options: FallbackLanguage("en"), BoundingCircle(51.4243877, -0.3474524, 4.0), NumberResults(5), completion_handler)
   */
  public func autosuggest(text: String, options: [W3WOptionProtocol], completion: @escaping W3WSuggestionsResponse) {
    apiV4.autosuggest(text: text, options: options, completion: completion)
  }
  
  
  /**
   Returns a list of 3 word addresses based on user input and other parameters.
   - parameter text: The full or partial 3 word address to obtain suggestions for. At minimum this must be the first two complete words plus at least one character from the third word.
   - parameter options: are provided as an array of W3Option objects. They can also be passed as a  varidic length parameter list, or in a W3WOptopns() object thanks to the W3WProtocolV3 protocol conformity
   - parameter callback: A completion block providing the suggestions and any error - ([W3WVoiceSuggestion]?, W3WVoiceError?) -> Void
   -  autosuggest(input: "filled.count.soap", options: FallbackLanguage("en"), BoundingCircle(51.4243877, -0.3474524, 4.0), NumberResults(5), completion_handler)
   */
  public func autosuggestWithCoordinates(text: String, options: [W3WOptionProtocol], completion: @escaping W3WSuggestionsWithCoordinatesResponse) {
    apiV4.autosuggestWithCoordinates(text: text, options: options, completion: completion)
  }
  
  // MARK: Other API calls
  
  /**
   Returns a section of the 3m x 3m what3words grid for a given area.
   - parameter bounding-box: Bounding box, as a lat,lng,lat,lng, for which the grid should be returned. The requested box must not exceed 4km from corner to corner, or a BadBoundingBoxTooBig error will be returned. Latitudes must be >= -90 and <= 90, but longitudes are allowed to wrap around 180. To specify a bounding-box that crosses the anti-meridian, use longitude greater than 180. Example value: "50.0,179.995,50.01,180.0005" .
   - parameter completion: A W3wGeocodeResponseHandler completion handler
   */
  public func gridSection(south_lat:Double, west_lng:Double, north_lat:Double, east_lng:Double, completion: @escaping W3WGridResponse) {
    apiV4.gridSection(south_lat: south_lat, west_lng: west_lng, north_lat: north_lat, east_lng: east_lng, completion: completion)
  }
  
  
  /**
   Returns a section of the 3m x 3m what3words grid for a given area.
   - parameter southWest: The southwest corner of the box
   - parameter northEast: The northeast corner of the box
   - parameter completion: A W3wGeocodeResponseHandler completion handler
   */
  public func gridSection(southWest:CLLocationCoordinate2D, northEast:CLLocationCoordinate2D, completion: @escaping W3WGridResponse) {
    apiV4.gridSection(south_lat: southWest.latitude, west_lng: southWest.longitude, north_lat: northEast.latitude, east_lng: northEast.longitude, completion: completion)
  }
  
  
  /**
   Retrieves a list of the currently loaded and available 3 word address languages.
   - parameter completion: A W3wGeocodeResponseHandler completion handler
   */
  public func availableLanguages(completion: @escaping W3WLanguagesResponse) {
    apiV4.availableLanguages(completion: completion)
  }
  
  
  /**
   Inform the server that the user has made a selection in the autosuggest results
   - parameter selection: The three word address that the user selected
   - parameter input: The text input used to call autosuggest in the first place
   - parameter source: Indicated if the autosuggest was called using text, or voice input
   */
  public func autosuggestSelection(selection: String, rank: Int, rawInput: String, sourceApi: W3WSelectionType = .text) {
    apiV4.autosuggestSelection(selection: selection, rank: rank, rawInput: rawInput)
  }
  
  
  // MARK: Other API calls
  
  
  /**
   Determines if the currently set URL points to a what3words server or not
   This is useful because some functions like autosuggestSelection only work
   with w3w servers, and not the enterprise server product
   */
  public func isCurrentServerW3W() -> Bool {
    return apiV4.isCurrentServerW3W()
  }
  
  

//public class What3WordsV3: W3WRequest, W3WProtocolV3 {
//
//  var apiKey: String
//
//  let api_version    = W3WSettings.apiVersion
//
//  private lazy var version_header = getHeaderValue(version: api_version) // is of the form: "what3words-Swift/x.x.x (Swift x.x.x; iOS x.x.x)"
//
//  private var bundle_header = Bundle.main.bundleIdentifier ?? ""
//
//
//  // MARK: Constructors
//
//
//  /// Initialize the API wrapper
//  /// - Parameters:
//  ///     - apiKey: Your api key.  Register for one at: https://accounts.what3words.com/create-api-key
//  ///     - apiUrl: Url for custom server - for enterprise customers
//  ///     - headers: any additional HTTP headers to send on requests - for enterprise customers
//  public init(apiKey: String, apiUrl: String? = nil, headers: [String: String]? = nil) {
//    self.apiKey = apiKey
//    super.init(baseUrl: apiUrl ?? W3WSettings.apiUrl, parameters: ["key":apiKey], headers: headers ?? [:])
//  }
//
//
//  /// Make a copy of this instance
//  /// - Parameters:
//  ///     - api: the `What3WordsV3` object to be copied
//  public func copy() -> What3WordsV3 {
//    return What3WordsV3(apiKey: apiKey, apiUrl: baseUrl, headers: headers)
//  }
//
//
//  // MARK: API Convert Functions
//
//  /**
//   Converts a 3 word address to a position, expressed as coordinates of latitude and longitude.
//   - parameter words: A 3 word address as a string
//   - parameter completion: A W3ResponsePlace completion handler
//   */
//  public func convertToCoordinates(words: String, completion: @escaping W3WSquareResponse) {
//    // set up the parameters
//    let params: [String: String] = [
//      "words":  words,
//      "format": W3WFormat.json.rawValue
//    ]
//
//    // make the call
//    performRequest(path:  "/convert-to-coordinates", params: params) { code, result, error in
//      if let square = W3WJson<JsonSquare>.decode(json: result) {
//
//        if let e = Self.makeErrorIfAny(code: code, data: square.error, error: error) {
//          completion(nil, e)
//
//        } else {
//          completion(W3WApiSquare(jsonSquare: square), nil)
//        }
//      }
//    }
//  }
//
//
//  /**
//   Returns a three word address from a latitude and longitude
//   - parameter coordinates: A CLLocationCoordinate2D object
//   - parameter language: A supported 3 word address language as an ISO 639-1 2 letter code. Defaults to en
//   - parameter completion: A W3ResponsePlace completion handler
//   */
//  public func convertTo3wa(coordinates: CLLocationCoordinate2D, language: W3WLanguage = W3WApiLanguage.english, completion: @escaping W3WSquareResponse) {
//    let params: [String: String] = [
//      "coordinates": "\(coordinates.latitude),\(coordinates.longitude)",
//      "language": language.code,
//      "locale": language.locale,
//      "format": W3WFormat.json.rawValue
//    ]
//
//    self.performRequest(path: "/convert-to-3wa", params: params) { code, result, error in
//      if let square = W3WJson<JsonSquare>.decode(json: result) {
//
//        if let e = Self.makeErrorIfAny(code: code, data: square.error, error: error) {
//          completion(nil, e)
//
//        } else {
//          completion(W3WApiSquare(jsonSquare: square), nil)
//        }
//      }
//    }
//  }
//
//
//  /**
//   Returns a three word address from a latitude and longitude
//   - parameter coordinates: A CLLocationCoordinate2D object
//   - parameter language: A supported 3 word address language as an ISO 639-1 2 letter code. Defaults to en
//   - parameter completion: A W3ResponsePlace completion handler
//   */
//  @available(*, deprecated, message: "Use convertTo3wa(coordinates: CLLocationCoordinate2D, language: W3WLanguage) instead")
//  public func convertTo3wa(coordinates: CLLocationCoordinate2D, language: String = W3WApiLanguage.english.locale, completion: @escaping W3WSquareResponse) {
//    convertTo3wa(coordinates: coordinates, language: W3WApiLanguage(locale: language), completion: completion)
//  }
//
//
//
//  // MARK: Autosuggest
//
//
//  /**
//   Returns a list of 3 word addresses based on user input and other parameters.
//   - parameter text: The full or partial 3 word address to obtain suggestions for. At minimum this must be the first two complete words plus at least one character from the third word.
//   - parameter options: are provided as an array of W3Option objects. They can also be passed as a  varidic length parameter list, or in a W3WOptopns() object thanks to the W3WProtocolV3 protocol conformity
//   - parameter callback: A completion block providing the suggestions and any error - ([W3WVoiceSuggestion]?, W3WVoiceError?) -> Void
//   -  autosuggest(input: "filled.count.soap", options: FallbackLanguage("en"), BoundingCircle(51.4243877, -0.3474524, 4.0), NumberResults(5), completion_handler)
//   */
//  public func autosuggest(text: String, options: [W3WOption], completion: @escaping W3WSuggestionsResponse) {
//    let params = toParameters(from: options, with: ["input": text])
//
//    self.performRequest(path: "/autosuggest", params: params) { code, result, error in
//      if let suggestions = W3WJson<JsonSuggestions>.decode(json: result) {
//        if let e = Self.makeErrorIfAny(code: code, data: suggestions.error, error: error) {
//          completion(nil, e)
//
//        } else {
//          completion(Self.toSuggestions(from: suggestions), nil)
//        }
//      }
//    }
//  }
//
//
//  /**
//   Returns a list of 3 word addresses based on user input and other parameters.
//   - parameter text: The full or partial 3 word address to obtain suggestions for. At minimum this must be the first two complete words plus at least one character from the third word.
//   - parameter options: are provided as an array of W3Option objects. They can also be passed as a  varidic length parameter list, or in a W3WOptopns() object thanks to the W3WProtocolV3 protocol conformity
//   - parameter callback: A completion block providing the suggestions and any error - ([W3WVoiceSuggestion]?, W3WVoiceError?) -> Void
//   -  autosuggest(input: "filled.count.soap", options: FallbackLanguage("en"), BoundingCircle(51.4243877, -0.3474524, 4.0), NumberResults(5), completion_handler)
//   */
//  public func autosuggestWithCoordinates(text: String, options: [W3WOption], completion: @escaping W3WSquaresResponse) {
//    let params = toParameters(from: options, with: ["input": text])
//
//    self.performRequest(path: "/autosuggest-with-coordinates", params: params) { code, result, error in
//      if let suggestions = W3WJson<JsonSquareSuggestions>.decode(json: result) {
//        if let e = Self.makeErrorIfAny(code: code, data: suggestions.error, error: error) {
//          completion(nil, e)
//
//        } else {
//          completion(Self.toSquares(from: suggestions), nil)
//        }
//      }
//    }
//  }
//
//
//  // MARK: Other API calls
//
//  /**
//   Returns a section of the 3m x 3m what3words grid for a given area.
//   - parameter bounding-box: Bounding box, as a lat,lng,lat,lng, for which the grid should be returned. The requested box must not exceed 4km from corner to corner, or a BadBoundingBoxTooBig error will be returned. Latitudes must be >= -90 and <= 90, but longitudes are allowed to wrap around 180. To specify a bounding-box that crosses the anti-meridian, use longitude greater than 180. Example value: "50.0,179.995,50.01,180.0005" .
//   - parameter completion: A W3wGeocodeResponseHandler completion handler
//   */
//  public func gridSection(south_lat:Double, west_lng:Double, north_lat:Double, east_lng:Double, completion: @escaping W3WGridResponse) {
//    let params: [String: String] = ["bounding-box": "\(south_lat),\(west_lng),\(north_lat),\(east_lng)", "format": W3WFormat.json.rawValue]
//
//    self.performRequest(path: "/grid-section", params: params) { code, result, error in
//      if let lines = W3WJson<JsonLines>.decode(json: result) {
//
//        if let e = Self.makeErrorIfAny(code: code, data: lines.error, error: error) {
//          completion(nil, e)
//
//        } else {
//          completion(Self.toLines(from: lines), nil)
//        }
//      }
//    }
//  }
//
//
//  /**
//   Returns a section of the 3m x 3m what3words grid for a given area.
//   - parameter southWest: The southwest corner of the box
//   - parameter northEast: The northeast corner of the box
//   - parameter completion: A W3wGeocodeResponseHandler completion handler
//   */
//  public func gridSection(southWest:CLLocationCoordinate2D, northEast:CLLocationCoordinate2D, completion: @escaping W3WGridResponse) {
//    self.gridSection(south_lat: southWest.latitude, west_lng: southWest.longitude, north_lat: northEast.latitude, east_lng: northEast.longitude, completion: completion)
//  }
//
//
//  /**
//   Retrieves a list of the currently loaded and available 3 word address languages.
//   - parameter completion: A W3wGeocodeResponseHandler completion handler
//   */
//  public func availableLanguages(completion: @escaping W3WLanguagesResponse) {
//    self.performRequest(path: "/available-languages", params: [:]) { code, result, error in
//      if let languages = W3WJson<JsonLanguages>.decode(json: result) {
//
//        if let e = Self.makeErrorIfAny(code: code, data: languages.error, error: error) {
//          completion(nil, e)
//
//        } else {
//          completion(Self.toLanguages(from: languages), nil)
//        }
//      }
//    }
//  }
//
//
//  /**
//   Inform the server that the user has made a selection in the autosuggest results
//   - parameter selection: The three word address that the user selected
//   - parameter input: The text input used to call autosuggest in the first place
//   - parameter source: Indicated if the autosuggest was called using text, or voice input
//   */
//  public func autosuggestSelection(selection: String, rank: Int, rawInput: String, sourceApi: W3WSelectionType = .text) {
//    if isCurrentServerW3W() {
//      let params: [String: String] = [
//        "raw-input":  rawInput,
//        "selection":  selection,
//        "source-api": sourceApi.rawValue,
//        "rank":       String(rank)
//      ]
//
//      self.performRequest(path: "/autosuggest-selection", params: params) { code, results, error in
//        // nothing is returned, and we ignore any error too
//      }
//    }
//  }
//
//
//
//  // MARK: Util
//
//
//  static func toSuggestions(from: JsonSuggestions?) -> [W3WApiSuggestion] {
//    var suggestions = [W3WApiSuggestion]()
//
//    for suggestion in from?.suggestions ?? [] {
//      suggestions.append(W3WApiSuggestion(jsonSuggestion: suggestion))
//    }
//
//    return suggestions
//  }
//
//
//  static func toSquares(from: JsonSquareSuggestions?) -> [W3WApiSquare] {
//    var suggestions = [W3WApiSquare]()
//
//    for square in from?.suggestions ?? [] {
//      suggestions.append(W3WApiSquare(jsonSquare: square))
//    }
//
//    return suggestions
//  }
//
//
//  static func toLines(from: JsonLines?) -> [W3WApiLine] {
//    var lines = [W3WApiLine]()
//
//    for line in from?.lines ?? [] {
//      if let l = try? W3WApiLine(jsonLine: line) {
//        lines.append(l)
//      }
//    }
//
//    return lines
//  }
//
//
//  static func toLanguages(from: JsonLanguages?) -> [W3WApiLanguage] {
//    var languages = [W3WApiLanguage]()
//
//    for language in from?.languages ?? [] {
//      languages.append(W3WApiLanguage(code: language.code ?? "", name: language.name ?? "", nativeName: language.nativeName ?? ""))
//    }
//
//    return languages
//  }
//
//
//  func toParameters(from: [W3WOption]?, with: [String: String] = [:]) -> [String: String] {
//    var params: [String: String] = with
//
//    for option in from ?? [] {
//      params[option.key().description] = option.asString()
//    }
//
//    return params
//  }
//
//
//  /// Checks the Json data for error data, and makes W3WError based on that. Absent
//  /// that it passes through any error passed in.  This function is `static` to avoid
//  /// even the appearance of retain cycle caused by `self` capture.
//  /// - Parameters:
//  ///   - code: HTTP code that was returned
//  ///   - data: json data to look in for error info
//  ///   - error: any error that ewas passed back by the W3WRequest class functions
//  static func makeErrorIfAny(code: Int?, data: JsonError?, error: W3WError?) -> W3WError? {
//
//    if let e = data {
//      return W3WError.url(code: code, message: e.message)
//    }
//
//    return error
//  }
//
//
//
//  /**
//   Determines if the currently set URL points to a what3words server or not
//   This is useful because some functions like autosuggestSelection only work
//   with w3w servers, and not the enterprise server product
//   */
//  public func isCurrentServerW3W() -> Bool {
//    var w3w = false
//
//    for domain in W3WSettings.domains {
//      if W3WSettings.apiUrl.lowercased().contains(domain) {
//        w3w = true
//      }
//    }
//
//    return w3w
//  }
//
//
//}
