//
//  W3DataTypes.swift
//  what3words
//
//  Created by Dave Duprey on 27/07/2020.
//  Copyright © 2020 What3Words. All rights reserved.
//

import Foundation
import CoreLocation


// MARK: callback block definitions

public typealias W3WSquareResponse               = ((_ result: W3WSquare?, _ error: W3WError?) -> Void)
public typealias W3WSuggestionsResponse          = ((_ result: [W3WSuggestion]?, _ error: W3WError?) -> Void)
public typealias W3WGridResponse                 = ((_ result: [W3WLine]?, _ error: W3WError?) -> Void)
public typealias W3WLanguagesResponse            = ((_ result: [W3WLanguage]?, _ error: W3WError?) -> Void)



// MARK: Error

/// Main error enum for the w3w API
public enum W3WError : Error, CustomStringConvertible, Equatable {
  public static func == (lhs: W3WError, rhs: W3WError) -> Bool {
    return lhs.description == rhs.description
  }
  

  // API Errors
  case badWords
  case badCoordinates
  case badLanguage
  case badFormat
  case badClipToPolygon
  case badBoundingBoxTooBig
  case missingWords
  case missingInput
  case missingBoundingBox
  case duplicateParameter
  case missingKey
  case invalidKey

  // Communication Errors
  case unknownErrorCodeFromServer
  case notFound404
  case badConnection
  case badJson
  case invalidResponse
  case socketError(error: W3WWebSocketError)
  
  public var description : String {
    switch self {
      case .badWords:            return "Words not found in what3words"
      case .badCoordinates:      return "Coordinates don't exist"
      case .badLanguage:         return "Language not available"
      case .badFormat:           return "Query was in the wrong format"
      case .badClipToPolygon:    return "Polygon for clipping is not correct"
      case .badBoundingBoxTooBig:return "The requested box exceeded 4km from corner to corner"
      case .badConnection:       return "Couldn't connect to server"
      case .badJson:             return "Malformed JSON returned"
      case .missingWords:        return "Words are missing from the address"
      case .missingInput:        return "More input required"
      case .missingBoundingBox:  return "Bounding Box required"
      case .missingKey:          return "The API key was missing"
      case .invalidKey:          return "The API key is invalid"
      case .notFound404:          return "URL not found, 404 error"
      case .duplicateParameter:    return "A parameter was provided twice"
      case .invalidResponse:          return "Invalid Response"
      case .unknownErrorCodeFromServer: return "Error code fromo API server is not recognized, upgrade this API?"
      case .socketError(let error):       return String(describing: error)
    }
  }

}


// MARK: Enums


public enum W3WInputType : String {
  case text         = "text"
  case voconHybrid  = "vocon-hybrid"
  case nmdpAsr      = "nmdp-asr"
  case genericVoice = "generic-voice"
  case speechmatics = "speechmatics"
  case mihup        = "mihup"
}


public enum W3WFormat : String {
  case json    = "json"
  case geojson = "geojson"
}


public enum W3WEncoding : String {
  case pcm_f32le = "pcm_f32le"
  //case pcm_s16le = "pcm_s16le"
}


// MARK: Geometry


/// defines a geograpfical region
public protocol W3WBoundingBox {
  var southWest: CLLocationCoordinate2D { get set }
  var northEast: CLLocationCoordinate2D { get set }
}


/// defines a geograpfical region
public protocol W3WBoundingCircle {
  var center: CLLocationCoordinate2D { get set }
  var radius: Double { get set }
}



/// represents a W3W grid line
public protocol W3WLine {
  var start:CLLocationCoordinate2D { get set }
  var end:CLLocationCoordinate2D { get set }
}



// MARK: Data protocols


/// Stores info about a language used with getLangauges() API call
public protocol W3WLanguage { //}: Hashable {
  /// name of the language
  var name:String { get set }
  /// name of the language in that langauge
  var nativeName:String { get set }
  /// ISO 639-1 2 letter code
  var code:String { get set }
}



public protocol W3WRanked {
  var rank: Int? { get set }
}


// MARK: Suggestions
 

// common denominated suggestion structure
public protocol W3WSuggestion {
  var words: String? { get set }
  var country: String? { get set }
  var nearestPlace: String? { get set }
  var distanceToFocus: Double? { get set }
  var language: String? { get set }
}


/// Helper object representing a W3W suggestion from a voice system
/// Note: perhaps it's best to move the init's to voice-api as an extension
public struct W3WVoiceSuggestion: W3WSuggestion, W3WRanked {
  // W3WSuggestion
  public var words : String?             // the three word address
  public var country : String?           // ISO 3166-1 alpha-2 country code
  public var nearestPlace : String?      // text description of a nearby place
  public var distanceToFocus : Double?   // number of kilometers to the nearest place
  public var language : String?          // two letter language code
  
  // W3VoiceSuggestion
  public var rank : Int?                 // indicates this suggestion's place in list from most probable to least probable match
}


/// Helper object representing a W3W square
public protocol W3WSquare: W3WSuggestion {
  // W3WSuggestion
  var words: String? { get set }
  var country: String? { get set }
  var nearestPlace: String? { get set }
  var distanceToFocus: Double? { get set }
  var language: String? { get set }
  
  // W3Square
  var coordinates: CLLocationCoordinate2D? { get set }
  var southWestBounds: CLLocationCoordinate2D? { get set }
  var northEastBounds: CLLocationCoordinate2D? { get set }
  var map: String? { get set }
}



// MARK: Autosuggest Options


// Autosuggest options for Swift are designed to be specified using the
// factory pattern or individually.  Typically W3WOption.language("en") or
// W3WOptions().langauge("en").clipToCountry("GB").  Autosuggest accepts
// Individual W3WOption, an array of [W3WOption] or W3WOptions for
// its options parameter(s)


/// conformity provides a way to return the values as the different possible types
public protocol W3WOptionProtocol {
  func key()     -> String
  func asString()   -> String
  func asBoolean()    -> Bool
  func asCoordinates()  -> CLLocationCoordinate2D
  func asBoundingBox()   -> (CLLocationCoordinate2D, CLLocationCoordinate2D)
  func asBoundingCircle() -> (CLLocationCoordinate2D, Double)
  func asBoundingPolygon() -> [CLLocationCoordinate2D]
}


/// parameter names for API calls
public struct W3WOptionKey {
  public static let language = "language"
  public static let voiceLanguage = "voice-language"
  public static let numberOfResults = "n-results"
  public static let focus = "focus"
  public static let numberFocusResults = "n-focus-results"
  public static let inputType = "input-type"
  public static let clipToCountry = "clip-to-country"
  public static let preferLand = "prefer-land"
  public static let clipToCircle = "clip-to-circle"
  public static let clipToBox = "clip-to-bounding-box"
  public static let clipToPolygon = "clip-to-polygon"
}


public enum W3WOption: W3WOptionProtocol {
  case language(String)
  case voiceLanguage(String)
  case numberOfResults(Int)
  case focus(CLLocationCoordinate2D)
  case numberFocusResults(Int)
  case inputType(W3WInputType)
  case clipToCountry(String)
  case clipToCountries([String])
  case preferLand(Bool)
  case clipToCircle(center:CLLocationCoordinate2D, radius: Double)
  case clipToBox(southWest: CLLocationCoordinate2D, northEast: CLLocationCoordinate2D)
  case clipToPolygon([CLLocationCoordinate2D])
  
  public func key() -> String {
    switch self {
    case .language:
      return W3WOptionKey.language
    case .voiceLanguage:
      return W3WOptionKey.voiceLanguage
    case .numberOfResults:
      return W3WOptionKey.numberOfResults
    case .focus:
      return W3WOptionKey.focus
    case .numberFocusResults:
      return W3WOptionKey.numberFocusResults
    case .inputType:
      return W3WOptionKey.inputType
    case .clipToCountry:
      return W3WOptionKey.clipToCountry
    case .clipToCountries:
      return W3WOptionKey.clipToCountry
    case .preferLand:
      return W3WOptionKey.preferLand
    case .clipToCircle:
      return W3WOptionKey.clipToCircle
    case .clipToBox:
      return W3WOptionKey.clipToBox
    case .clipToPolygon:
      return W3WOptionKey.clipToPolygon
    }
  }
  
  public func asString() -> String {
    switch self {
    case .language(let language):
      return language
    case .voiceLanguage(let voiceLanguage):
      return voiceLanguage
    case .numberOfResults(let numberOfResults):
      return "\(numberOfResults)"
    case .focus(let focus):
      return String(format: "%.10f,%.10f", focus.latitude, focus.longitude)
    case .numberFocusResults(let numberFocusResults):
      return "\(numberFocusResults)"
    case .inputType(let inputType):
      return inputType.rawValue
    case .clipToCountry(let clipToCountry):
      return clipToCountry
    case .clipToCountries(let countries):
      return countries.joined(separator: ",")
    case .preferLand(let preferLand):
      return preferLand ? "true" : "false"
    case .clipToCircle(let center, let radius):
      return String(format: "%.10f,%.10f,%.5f", center.latitude, center.longitude, radius)
    case .clipToBox(let southWest, let northEast):
      return String(format: "%.10f,%.10f,%.10f,%.10f", southWest.latitude, southWest.longitude, northEast.latitude, northEast.longitude)
    case .clipToPolygon(let polygon):
      var polyCoords = [String]()
      for coord in polygon {
        polyCoords.append("\(coord.latitude),\(coord.longitude)")
      }
      return polyCoords.joined(separator: ",")
    }
  }
  
  
  public func asCoordinates() -> CLLocationCoordinate2D {
    switch self {
    case .focus(let focus):
      return focus
    case .clipToCircle(let center, _):
      return center
    default:
      return CLLocationCoordinate2D()
    }
  }
  
  
  public func asBoolean() -> Bool {
    switch self {
    case .preferLand(let preference):
      return preference
    default:
      return false
    }
  }
  
  
  public func asBoundingBox() -> (CLLocationCoordinate2D, CLLocationCoordinate2D) {
    switch self {
    case .clipToBox(let northEast, let southWest):
      return (northEast, southWest)
    default:
      return (CLLocationCoordinate2D(), CLLocationCoordinate2D())
    }
  }
  
  
  public func asBoundingCircle() -> (CLLocationCoordinate2D, Double) {
    switch self {
    case .clipToCircle(let center, let radius):
      return (center, radius)
    default:
      return (CLLocationCoordinate2D(), 0.0)
    }
  }
  
  
  public func asBoundingPolygon() -> [CLLocationCoordinate2D] {
    switch self {
    case .clipToPolygon(let polygon):
      return polygon
    default:
      return [CLLocationCoordinate2D]()
    }
  }
}


public class W3WOptions {

  public var options = [W3WOption]()

  public init() {}
  
  public func language(_ language:String)            -> W3WOptions { options.append(W3WOption.language(language)); return self }
  public func voiceLanguage(_ voiceLangauge:String)  -> W3WOptions { options.append(W3WOption.voiceLanguage(voiceLangauge)); return self }
  public func numberOfResults(_ numberOfResults:Int) -> W3WOptions { options.append(W3WOption.numberOfResults(numberOfResults)); return self }
  public func inputType(_ inputType:W3WInputType)     -> W3WOptions { options.append(W3WOption.inputType(inputType)); return self }
  public func clipToCountry(_ clipToCountry:String)     -> W3WOptions { options.append(W3WOption.clipToCountry(clipToCountry)); return self }
  public func preferLand(_ preferLand:Bool)                   -> W3WOptions { options.append(W3WOption.preferLand(preferLand)); return self }
  public func focus(_ focus:CLLocationCoordinate2D)                       -> W3WOptions { options.append(W3WOption.focus(focus)); return self }
  public func numberFocusResults(_ numberFocusResults:Int)                        -> W3WOptions { options.append(W3WOption.numberFocusResults(numberFocusResults)); return self }
  public func clipToPolygon(_ clipToPolygon:[CLLocationCoordinate2D])                  -> W3WOptions { options.append(W3WOption.clipToPolygon(clipToPolygon)); return self }
  public func clipToCircle(center: CLLocationCoordinate2D, radius: Double)                -> W3WOptions { options.append(W3WOption.clipToCircle(center: center, radius: radius)); return self }
  public func clipToBox(southWest:CLLocationCoordinate2D, northEast:CLLocationCoordinate2D) -> W3WOptions { options.append(W3WOption.clipToBox(southWest: southWest, northEast: northEast)); return self }
}



// MARK: what3words interface


public protocol W3WProtocolV3 {
  
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
  func convertTo3wa(coordinates: CLLocationCoordinate2D, language: String, completion: @escaping W3WSquareResponse)

  
  /**
   Returns a list of 3 word addresses based on user input and other parameters.
   - parameter input: The full or partial 3 word address to obtain suggestions for. At minimum this must be the first two complete words plus at least one character from the third word.
   - options are provided by instantiating W3Option objects in the varidic length parameter list.  Eg:
   */
  func autosuggest(text: String, options: [W3WOptionProtocol], completion: @escaping W3WSuggestionsResponse)
  
  
  /**
   Convenience functions to allow different uses of options
   */
  func autosuggest(text: String, options: W3WOptionProtocol..., completion: @escaping W3WSuggestionsResponse)
  func autosuggest(text: String, completion: @escaping W3WSuggestionsResponse)
  
  
  /**
   Returns a section of the 3m x 3m what3words grid for a given area.
   - parameter bounding-box: Bounding box, as a lat,lng,lat,lng, for which the grid should be returned. The requested box must not exceed 4km from corner to corner, or a BadBoundingBoxTooBig error will be returned. Latitudes must be >= -90 and <= 90, but longitudes are allowed to wrap around 180. To specify a bounding-box that crosses the anti-meridian, use longitude greater than 180. Example value: "50.0,179.995,50.01,180.0005" .
   - parameter format: Return data format type; can be one of json (the default) or geojson Example value:format=Format.json
   - parameter completion: A W3wGeocodeResponseHandler completion handler
   */
  func gridSection(south_lat:Double, west_lng:Double, north_lat:Double, east_lng:Double, completion: @escaping W3WGridResponse)
  
  /**
   Returns a section of the 3m x 3m what3words grid for a given area.
   - parameter southWest: The southwest corner of the box
   - parameter northEast: The northeast corner of the box
   - parameter format: Return data format type; can be one of json (the default) or geojson Example value:format=Format.json
   - parameter completion: A W3wGeocodeResponseHandler completion handler
   */
  func gridSection(southWest:CLLocationCoordinate2D, northEast:CLLocationCoordinate2D, completion: @escaping W3WGridResponse)
  
  /**
   Retrieves a list of the currently loaded and available 3 word address languages.
   - parameter completion: A W3wGeocodeResponseHandler completion handler
   */
  func availableLanguages(completion: @escaping W3WLanguagesResponse)
  
}


/// automatically make any class that confirms accept the different types of Option parameters
extension W3WProtocolV3 {
  public func autosuggest(text: String, options: W3WOptionProtocol..., completion: @escaping W3WSuggestionsResponse) {
    autosuggest(text: text, options: options, completion: completion)
  }
  
  public func autosuggest(text: String, completion: @escaping W3WSuggestionsResponse) {
    autosuggest(text: text, options: [], completion: completion)
  }
  
  public func autosuggest(text: String, options: W3WOptions, completion: @escaping W3WSuggestionsResponse) {
    autosuggest(text: text, options: options.options, completion: completion)
  }

}



// MARK: Initializers


extension W3WVoiceSuggestion: Codable {
  
  enum CodingKeys: String, CodingKey {
    case country = "country"
    case nearestPlace = "nearestPlace"
    case words = "words"
    case distanceToFocus = "distanceToFocusKm"
    case rank = "rank"
    case language = "language"
  }
  
  public init(from decoder: Decoder) throws {
    let values      = try decoder.container(keyedBy: CodingKeys.self)
    country         = try values.decodeIfPresent(String.self, forKey: .country)
    nearestPlace    = try values.decodeIfPresent(String.self, forKey: .nearestPlace)
    words           = try values.decodeIfPresent(String.self, forKey: .words)
    distanceToFocus = try values.decodeIfPresent(Double.self, forKey: .distanceToFocus)
    rank            = try values.decodeIfPresent(Int.self,    forKey: .rank)
    language        = try values.decodeIfPresent(String.self, forKey: .language)
  }

  
  public init(words: String? = nil, country : String? = nil, nearestPlace : String? = nil, distanceToFocus : Double? = nil, language : String? = nil) {
    self.words = words
    self.country = country
    self.nearestPlace = nearestPlace
    self.distanceToFocus = distanceToFocus
    self.language = language
  }

}


