//
//  File.swift
//  
//
//  Created by Dave Duprey on 20/09/2021.
//

import Foundation
import MapKit


/// An  API wrapper object for use in ObjectiveC projects
@objc public class What3WordsObjC: NSObject {
  
  /// the actual API wrapper that we are wrapping
  var api: What3WordsV3!
  
  
  // MARK: Constructors
  
  
  /// Initialize the API wrapper
  /// - Parameters:
  ///     - apiKey: Your api key.  Register for one at: https://accounts.what3words.com/create-api-key
  @objc public init(apiKey: String) {
    api = What3WordsV3(apiKey: apiKey)
  }
  
  
  /// Initialize the API wrapper
  /// - Parameters:
  ///     - apiKey: Your api key.  Register for one at: https://accounts.what3words.com/create-api-key
  ///     - apiUrl: Url for custom server - for enterprise customers
  @objc public init(apiKey: String, apiUrl: String) {
    api = What3WordsV3(apiKey: apiKey, apiUrl: apiUrl)
  }
  
  
  /// Initialize the API wrapper
  /// - Parameters:
  ///     - apiKey: Your api key.  Register for one at: https://accounts.what3words.com/create-api-key
  ///     - apiUrl: Url for custom server - for enterprise customers
  ///     - customHeaders: additional HTTP headers to send on requests - for enterprise customers
  @objc public init(apiKey: String, apiUrl: String, customHeaders: [String: String]) {
    api = What3WordsV3(apiKey: apiKey, apiUrl: apiUrl, customHeaders: customHeaders)
  }
  
  
  
  // MARK: API Convert Functions
  
  
  @objc(convertToCoordinates:completion:)
  public func convertToCoordinates(words: String, completion: @escaping (W3WObjcSquare?, NSError?) -> ()) {
    api.convertToCoordinates(words: words) { square, error in
      let nserror = (error == nil) ? nil : NSError(domain: "w3w", code: 0, userInfo: [NSLocalizedDescriptionKey: error?.description ?? "Unknown"])
      completion(W3WObjcSquare(square: square), nserror);
    }
  }
  
  
  @objc(convertTo3wa:language:completion:)
  public func convertTo3wa(coordinates: CLLocationCoordinate2D, language: String, completion: @escaping (W3WObjcSquare?, NSError?) -> ()) {
    api.convertTo3wa(coordinates: coordinates, language: language) { square, error in
      let nserror = (error == nil) ? nil : NSError(domain: "w3w", code: 0, userInfo: [NSLocalizedDescriptionKey: error?.description ?? "Unknown"])
      completion(W3WObjcSquare(square: square), nserror);
    }
  }
  

  // MARK: Autosuggest
  

  @objc(autosuggest:options:completion:)
  public func autosuggest(text: String, options: W3WObjcOptions, completion: @escaping ([W3WObjcSuggestion]?, NSError?) -> ()) {
    api.autosuggest(text: text, options: options.options) { suggestions, error in
      var suggestionArray = [W3WObjcSuggestion]()
      for suggestion in suggestions ?? [] {
        suggestionArray.append(W3WObjcSuggestion(suggestion: suggestion))
      }
      let nserror = (error == nil) ? nil : NSError(domain: "w3w", code: 0, userInfo: [NSLocalizedDescriptionKey: error?.description ?? "Unknown"])
      completion(suggestionArray, nserror);
    }
  }
  

  @objc(autosuggest:completion:)
  public func autosuggest(text: String, completion: @escaping ([W3WObjcSuggestion]?, NSError?) -> ()) {
    self.autosuggest(text: text, options: W3WObjcOptions(), completion: completion)
  }
  

  @objc(autosuggestWithCoordinates:options:completion:)
  public func autosuggestWithCoordinates(text: String, options: W3WObjcOptions, completion: @escaping ([W3WObjcSquare]?, NSError?) -> ()) {
    api.autosuggestWithCoordinates(text: text, options: options.options) { suggestionsWithCoordinates, error in
      var squareArray = [W3WObjcSquare]()
      for suggestionWithCoordinates in suggestionsWithCoordinates ?? [] {
        squareArray.append(W3WObjcSquare(suggestionWithCoordinates: suggestionWithCoordinates))
      }
      let nserror = (error == nil) ? nil : NSError(domain: "w3w", code: 0, userInfo: [NSLocalizedDescriptionKey: error?.description ?? "Unknown"])
      completion(squareArray, nserror);
    }
  }

  
  @objc(autosuggestWithCoordinates:completion:)
  public func autosuggestWithCoordinates(text: String, completion: @escaping ([W3WObjcSquare]?, NSError?) -> ()) {
    self.autosuggestWithCoordinates(text: text, options: W3WObjcOptions(), completion: completion)
  }
  
  
  // MARK: Other API calls
  

  @objc(gridSection:west_lng:north_lat:east_lng:completion:)
  public func gridSection(south_lat: Double, west_lng: Double, north_lat: Double, east_lng: Double, completion: @escaping ([W3WObjcLine]?, NSError?) -> ()) {
    api.gridSection(south_lat: south_lat, west_lng: west_lng, north_lat: north_lat, east_lng: east_lng) { lines, error in
      var lineArray = [W3WObjcLine]()
      for line in lines ?? [] {
        lineArray.append(W3WObjcLine(start: line.start, end: line.end))
      }
      let nserror = (error == nil) ? nil : NSError(domain: "w3w", code: 0, userInfo: [NSLocalizedDescriptionKey: error?.description ?? "Unknown"])
      completion(lineArray, nserror)
    }
  }
  
  
  @objc(gridSection:northEast:completion:)
  public func gridSection(southWest: CLLocationCoordinate2D, northEast: CLLocationCoordinate2D, completion: @escaping ([W3WObjcLine]?, NSError?) -> ()) {
    api.gridSection(southWest: southWest, northEast: northEast) { lines, error in
      var lineArray = [W3WObjcLine]()
      for line in lines ?? [] {
        lineArray.append(W3WObjcLine(start: line.start, end: line.end))
      }
      let nserror = (error == nil) ? nil : NSError(domain: "w3w", code: 0, userInfo: [NSLocalizedDescriptionKey: error?.description ?? "Unknown"])
      completion(lineArray, nserror)
    }
  }

  
  @objc(availableLanguages:)
  public func availableLanguages(completion: @escaping ([W3WObjcLanguage]?, NSError?) -> ()) {
    api.availableLanguages() { languages, error in
      var languageArray = [W3WObjcLanguage]()
      for language in languages ?? [] {
        languageArray.append(W3WObjcLanguage(name: language.name, nativeName: language.nativeName, code: language.code))
      }
      let nserror = (error == nil) ? nil : NSError(domain: "w3w", code: 0, userInfo: [NSLocalizedDescriptionKey: error?.description ?? "Unknown"])
      completion(languageArray, nserror)
    }
  }
    
}
