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


/// Stores info about a language used with getLangauges() API call
public struct W3WApiLanguage: W3WLanguage {
  /// name of the language
  public var name:String
  /// name of the language in that langauge
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
  
  // W3ApiSuggestion
  public var rank: Int?
}


/// Helper object representing a W3W place in  API calls
public struct W3WApiSquare: W3WSquare {
  // W3WSuggestion
  public var words: String?
  public var country: String?
  public var nearestPlace: String?
  public var distanceToFocus: Double?
  public var language: String?
  
  // W3Square
  public var coordinates: CLLocationCoordinate2D?
  //public var bounds: W3WBoundingBox?
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

}
