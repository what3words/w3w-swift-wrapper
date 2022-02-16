//
//  W3DataTypes.swift
//  what3words
//
//  Created by Dave Duprey on 27/07/2020.
//  Copyright © 2020 What3Words. All rights reserved.
//
//  This code provides datatypes specific to the what3words
//  API calls.  They all conform to the what3words protocols
//  for their respective types
//

import Foundation
import CoreLocation


// MARK: callback block definitions

public typealias W3WApiSuggestionsResponse  = ((_ result: [W3WApiSuggestion]?, _ error: W3WError?) -> Void)


// MARK: API data types


/// Helper object representing a W3W bounding box
public struct W3WApiBoundingBox: W3WBoundingBox {
  public var southWest: CLLocationCoordinate2D
  public var northEast: CLLocationCoordinate2D
}


/// defines a geograpfical region
public struct W3WApiBoundingCircle: W3WBoundingCircle {
  public var center: CLLocationCoordinate2D
  public var radius: Double
}


/// Helper object representing a W3W grid line
public struct W3WApiLine: W3WLine {
  public var start:CLLocationCoordinate2D
  public var end:CLLocationCoordinate2D
}


/// Stores info about a language used with getLanguages() API call
public struct W3WApiLanguage: W3WLanguage {
  /// name of the language
  public var name:String
  /// name of the language in that language
  public var nativeName:String
  /// ISO 639-1 2 letter code
  public var code:String
  /// code for the voice language in use - depreciated, but maybe one day appreciated
  //  public var voiceCode:String
  
  public init(name: String, nativeName: String, code: String) {
    self.name = name
    self.nativeName = nativeName
    self.code = code
  }
  
}


/// Struct continaing language code and names
extension W3WLanguage {
  public static var english: W3WApiLanguage {
    return W3WApiLanguage(name: "English", nativeName: "English", code: "en")
  }
}


/// Suggestions returned from autosuggest API calls
public struct W3WApiSuggestion: W3WSuggestion, W3WRanked {
  // W3WSuggestion
  public var words: String?
  public var country: String?
  public var nearestPlace: String?
  public var distanceToFocus: Double?
  public var language: String?
  
  // W3WRanked
  public var rank: Int?
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
  
  // W3WRanked
  public var rank : Int?                 // indicates this suggestion's place in list from most probable to least probable match
}


/// Helper object representing a W3W place in  API calls
public struct W3WApiSquare: W3WSquare, W3WWithCoordinates {
  // W3WSuggestion
  public var words: String?
  public var country: String?
  public var nearestPlace: String?
  public var distanceToFocus: Double?
  public var language: String?
  
  // W3Square
  public var coordinates: CLLocationCoordinate2D?
  public var southWestBounds: CLLocationCoordinate2D?
  public var northEastBounds: CLLocationCoordinate2D?
  public var map: String?

  /**
   Make a W3Square from a data dictionary
   - parameter from: Dictionary of values, usually from a JSON decode
   */
  public init(with result:[String: Any]?) {
    country      = result?["country"] as? String ?? ""
    nearestPlace = result?["nearestPlace"] as? String ?? ""
    words        = result?["words"] as? String ?? ""
    language     = result?["language"] as? String ?? ""
    map          = result?["map"] as? String ?? ""
    
    // if bounds are provided, assign them
    if let bounds = result?["square"] as? Dictionary<String, Any?>? {
      if let ne = bounds?["northeast"] as? Dictionary<String, Any?>? {
        northEastBounds = CLLocationCoordinate2D(latitude: ne!["lat"] as! CLLocationDegrees, longitude: ne!["lng"] as! CLLocationDegrees)
      }
      
      if let sw = bounds?["southwest"] as? Dictionary<String, Any?>? {
        southWestBounds = CLLocationCoordinate2D(latitude: sw!["lat"] as! CLLocationDegrees, longitude: sw!["lng"] as! CLLocationDegrees)
      }
    }
    
    // if there are coordinates, assign them
    if let coord = result?["coordinates"] as? Dictionary<String, Any?>? {
      if let c = coord {
        coordinates = CLLocationCoordinate2D(latitude: c["lat"] as! CLLocationDegrees, longitude: c["lng"] as! CLLocationDegrees)
      }
    }
  }

  
  /**
   Make a W3WApiSquare
   */
  public init(words: String? = nil, coordinates: CLLocationCoordinate2D? = nil, country : String? = nil, nearestPlace : String? = nil, distanceToFocus : Double? = nil, language : String? = nil, southWestBounds: CLLocationCoordinate2D? = nil, northEastBounds: CLLocationCoordinate2D? = nil, map: String? = nil) {
    self.words = words
    self.coordinates = coordinates
    self.country = country
    self.nearestPlace = nearestPlace
    self.distanceToFocus = distanceToFocus
    self.language = language
    self.southWestBounds = southWestBounds
    self.northEastBounds = northEastBounds
    self.map = map
  }

  
}


public struct W3WApiSuggestionWithCoordinates: W3WSuggestionWithCoordinates, W3WSquare, W3WWithCoordinates, W3WSuggestion, W3WRanked {
  
  // W3WSuggestion
  public var words: String?
  public var country: String?
  public var nearestPlace: String?
  public var distanceToFocus: Double?
  public var language: String?
  
  // W3Square
  public var coordinates: CLLocationCoordinate2D?
  public var southWestBounds: CLLocationCoordinate2D?
  public var northEastBounds: CLLocationCoordinate2D?
  public var map: String?

  // W3WRanked
  public var rank: Int?

  /**
   Make a W3Square from a data dictionary
   - parameter from: Dictionary of values, usually from a JSON decode
   */
  public init(with result:[String: Any?]?) {
    country      = result?["country"] as? String ?? ""
    nearestPlace = result?["nearestPlace"] as? String ?? ""
    words        = result?["words"] as? String ?? ""
    language     = result?["language"] as? String ?? ""
    map          = result?["map"] as? String ?? ""
    rank         = result?["rank"] as? Int
    
    // if bounds are provided, assign them
    if let bounds = result?["square"] as? Dictionary<String, Any?>? {
      if let ne = bounds?["northeast"] as? Dictionary<String, Any?>? {
        northEastBounds = CLLocationCoordinate2D(latitude: ne!["lat"] as! CLLocationDegrees, longitude: ne!["lng"] as! CLLocationDegrees)
      }
      
      if let sw = bounds?["southwest"] as? Dictionary<String, Any?>? {
        southWestBounds = CLLocationCoordinate2D(latitude: sw!["lat"] as! CLLocationDegrees, longitude: sw!["lng"] as! CLLocationDegrees)
      }
    }
    
    // if there are coordinates, assign them
    if let coord = result?["coordinates"] as? Dictionary<String, Any?>? {
      if let c = coord {
        coordinates = CLLocationCoordinate2D(latitude: c["lat"] as! CLLocationDegrees, longitude: c["lng"] as! CLLocationDegrees)
      }
    }
  }

}


// MARK: Enums

public enum W3WSelectionType: String {
  case text  = "text"
  case voice = "voice"
}


// MARK: Initializers


extension W3WApiSuggestion {
  
  public init(words: String? = nil, country : String? = nil, nearestPlace : String? = nil, distanceToFocus : Double? = nil, language : String? = nil) {
    self.words = words
    self.country = country
    self.nearestPlace = nearestPlace
    self.distanceToFocus = distanceToFocus
    self.language = language
  }
  
}



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
