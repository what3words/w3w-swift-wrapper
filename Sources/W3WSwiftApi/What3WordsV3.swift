//
//  W3wGeocoder.swift
//  what3words
//
//  Created by Dave Duprey on 27/07/2020.
//  Copyright © 2020 What3Words. All rights reserved.
//

import Foundation
import CoreLocation



public class What3WordsV3: W3WApiCall, W3WProtocolV3 {
      
  
  // MARK: Constructors
  
  /// Initialize the API wrapper
  /// - Parameters:
  ///     - apiKey: Your api key.  Register for one at: https://accounts.what3words.com/create-api-key
  public init(apiKey: String) {
    super.init(apiUrl: W3WSettings.apiUrl, apiKey: apiKey)
  }
  
  
  /// Initialize the API wrapper
  /// - Parameters:
  ///     - apiKey: Your api key.  Register for one at: https://accounts.what3words.com/create-api-key
  ///     - apiUrl: Url for custom server - for enterprise customers
  public init(apiKey: String, apiUrl: String) {
    super.init(apiUrl: apiUrl, apiKey: apiKey)
  }
  
  
  /// Initialize the API wrapper
  /// - Parameters:
  ///     - apiKey: Your api key.  Register for one at: https://accounts.what3words.com/create-api-key
  ///     - apiUrl: Url for custom server - for enterprise customers
  ///     - customHeaders: additional HTTP headers to send on requests - for enterprise customers
  public init(apiKey: String, apiUrl: String, customHeaders: [String: String]) {
    super.init(apiUrl: apiUrl, apiKey: apiKey, customHeaders: customHeaders)
  }


  
  // MARK: API Convert Functions
  
  /**
   Converts a 3 word address to a position, expressed as coordinates of latitude and longitude.
   - parameter words: A 3 word address as a string
   - parameter completion: A W3ResponsePlace completion handler
   */
  public func convertToCoordinates(words: String, completion: @escaping W3WSquareResponse) {
    let params: [String: String] = ["words": words, "format": W3WFormat.json.rawValue ]
    self.performRequest(path: "/convert-to-coordinates", params: params) { (result, error) in
      if let square = result {
        completion(W3WApiSquare(with: square), error)
      } else {
        completion(nil, error)
      }
    }
  }
  
  
  /**
   Returns a three word address from a latitude and longitude
   - parameter coordinates: A CLLocationCoordinate2D object
   - parameter language: A supported 3 word address language as an ISO 639-1 2 letter code. Defaults to en
   - parameter completion: A W3ResponsePlace completion handler
   */
  public func convertTo3wa(coordinates: CLLocationCoordinate2D, language: String = W3WApiLanguage.english.code, completion: @escaping W3WSquareResponse) {
    let params: [String: String] = ["coordinates": "\(coordinates.latitude),\(coordinates.longitude)", "language": language, "format": W3WFormat.json.rawValue ]
    self.performRequest(path: "/convert-to-3wa", params: params) { (result, error) in
      if let square = result {
        completion(W3WApiSquare(with: square), error)
      } else {
        completion(nil, error)
      }
    }
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
    var params: [String: String] = ["input": text]
    
    for option in options {
      params[option.key()] = option.asString()
    }
    
    self.performRequest(path: "/autosuggest", params: params) { (result, error) in
      if let suggestions = result {
        completion(self.suggestions(from: suggestions), error)
      } else {
        completion(nil, error)
      }
    }
  }
  
  
  // MARK: Other API calls
  
  /**
   Returns a section of the 3m x 3m what3words grid for a given area.
   - parameter bounding-box: Bounding box, as a lat,lng,lat,lng, for which the grid should be returned. The requested box must not exceed 4km from corner to corner, or a BadBoundingBoxTooBig error will be returned. Latitudes must be >= -90 and <= 90, but longitudes are allowed to wrap around 180. To specify a bounding-box that crosses the anti-meridian, use longitude greater than 180. Example value: "50.0,179.995,50.01,180.0005" .
   - parameter completion: A W3wGeocodeResponseHandler completion handler
   */
  public func gridSection(south_lat:Double, west_lng:Double, north_lat:Double, east_lng:Double, completion: @escaping W3WGridResponse) {
    let params: [String: String] = ["bounding-box": "\(south_lat),\(west_lng),\(north_lat),\(east_lng)", "format": W3WFormat.json.rawValue]
    
    self.performRequest(path: "/grid-section", params: params) { (result, error) in
      if let lines = result {
        completion(self.lines(from: lines), error)
      } else {
        completion(nil, error)
      }
    }
  }
  
  
  /**
   Returns a section of the 3m x 3m what3words grid for a given area.
   - parameter southWest: The southwest corner of the box
   - parameter northEast: The northeast corner of the box
   - parameter completion: A W3wGeocodeResponseHandler completion handler
   */
  public func gridSection(southWest:CLLocationCoordinate2D, northEast:CLLocationCoordinate2D, completion: @escaping W3WGridResponse) {
    self.gridSection(south_lat: southWest.latitude, west_lng: southWest.longitude, north_lat: northEast.latitude, east_lng: northEast.longitude, completion: completion)
  }
  
  
  /**
   Retrieves a list of the currently loaded and available 3 word address languages.
   - parameter completion: A W3wGeocodeResponseHandler completion handler
   */
  public func availableLanguages(completion: @escaping W3WLanguagesResponse) {
    self.performRequest(path: "/available-languages", params: [:]) { (result, error) in
      if let lines = result {
        completion(self.languages(from: lines), error)
      } else {
        completion(nil, error)
      }
    }
  }
  
  
  
}


