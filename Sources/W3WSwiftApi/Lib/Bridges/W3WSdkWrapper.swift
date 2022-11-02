//
//  File.swift
//  
//
//  Created by Dave Duprey on 02/11/2022.
//

import Foundation

#if canImport(w3w)
import w3w


public class W3WSdkWrapper {
  
  
  /// reference to the swift SDK
  var sdk: What3Words!

  
  /// Initialize the Core SDK
  /// - parameter dataPath: path to the w3w-data folder
  /// - parameter engineType: choose whether the engine should be optimized for speed or size
  public init(dataPath: String? = nil, engineType: W3WEngineType = .device) {
    sdk = What3Words(dataPath: dataPath, engineType: engineType)
  }
  
  
  // MARK:- Convert Functions
  
  
  /// Converts a 3 word address to a position, expressed as coordinates of latitude and longitude.
  /// - parameter words: A 3 word address as a string
  /// - returns coordinate of the three word address
  /// - throws W3WSdkError
  public func convertToCoordinates(words: String) throws -> CLLocationCoordinate2D? {
    return try sdk.convertToCoordinates(words: words)
  }
  
  
  /// Converts a 3 word address to a position, expressed as coordinates of latitude and longitude.
  /// - parameter words: A 3 word address as a string
  /// - parameter completion: code block whose parameters contain a W3WSquare and if any, an error
  public func convertToCoordinates(words: String, completion: @escaping W3WSquareResponse) {
    do {
      if let square = try convertToSquare(words: words), square.coordinates != nil {
        completion(square, nil)
      } else {
        completion(nil, W3WError.badWords)
      }
    } catch {
      completion(nil, convert(error: error))
    }
  }
  
  
  /// Converts a 3 word address to a position, expressed as coordinates of latitude and longitude.
  /// - parameter coordinates: A CLLocationCoordinate2D object
  /// - parameter language: A supported 3 word address language as an [ISO 639-1](https://en.wikipedia.org/wiki/List_of_ISO_639-1_codes) 2 letter code. Defaults to "en"
  /// - parameter completion: code block whose parameters contain a W3WSquare and if any, an error
  public func convertTo3wa(coordinates: CLLocationCoordinate2D, language: String, completion: @escaping W3WSquareResponse) {
    do {
      if let square = try convertToSquare(coordinates: coordinates, language: language), square.words != nil {
        completion(square, nil)
      } else {
        completion(nil, W3WError.badCoordinates)
      }
    } catch {
      completion(nil, convert(error: error))
    }
  }
  
  
  /// Returns a list of 3 word addresses suggestions based on user input and other parameters.
  /// - parameter text: The full or partial 3 word address to obtain suggestions for. At minimum this must be the first two complete words plus at least one character from the third word.
  /// - parameter language: A supported 3 word address language as an [ISO 639-1](https://en.wikipedia.org/wiki/List_of_ISO_639-1_codes) 2 letter code. Defaults to "en"
  /// - parameter options: are provided as an array of W3SdkOption objects.
  /// - parameter completion: code block whose parameters contain an array of W3WSuggestions, and, if any, an error
  public func autosuggest(text: String, options: [W3WOptionProtocol], completion: @escaping W3WSuggestionsResponse) {
    var coreOptions = [W3WSdkOption]()
    for option in options {
      coreOptions.append(W3WSdkOption.convert(from: option))
    }
    
    do {
      let suggestions = try autosuggest(text: text, options: coreOptions)
      completion(suggestions, nil)
    } catch {
      completion(nil, convert(error: error))
    }
  }
  
  
  /// Returns a list of 3 word addresses suggestions with lat,long coords based on user input and other parameters.
  /// - parameter text: The full or partial 3 word address to obtain suggestions for. At minimum this must be the first two complete words plus at least one character from the third word.
  /// - parameter language: A supported 3 word address language as an [ISO 639-1](https://en.wikipedia.org/wiki/List_of_ISO_639-1_codes) 2 letter code. Defaults to "en"
  /// - parameter options: are provided as an array of W3SdkOption objects.
  /// - parameter completion: code block whose parameters contain an array of W3WSuggestions, and, if any, an error
  public func autosuggestWithCoordinates(text: String, options: [W3WOptionProtocol], completion: @escaping W3WSuggestionsWithCoordinatesResponse) {
    var coreOptions = [W3WSdkOption]()
    for option in options {
      coreOptions.append(W3WSdkOption.convert(from: option))
    }
    
    do {
      let suggestions = try autosuggest(text: text, options: coreOptions)
      
      var suggestionsWithCoordinates = [W3WSdkSuggestionWithCoordinates]()
      for suggestion in suggestions {
        if let words = suggestion.words, let square = try? convertToSquare(words: words) {
          let suggestionWithCoordinate = W3WSdkSuggestionWithCoordinates(words: square.words, country: square.country, nearestPlace: square.nearestPlace, distanceToFocus: square.distanceToFocus, language: square.language, coordinates: square.coordinates, southWestBounds: square.southWestBounds, northEastBounds: square.northEastBounds)
          suggestionsWithCoordinates.append(suggestionWithCoordinate)
        }
      }
      completion(suggestionsWithCoordinates, nil)
      
    } catch {
      completion(nil, convert(error: error))
    }
  }
  
  
  /// Returns a section of the 3m x 3m what3words grid for a given area.
  /// - parameter southWest: The southwest corner of the box
  /// - parameter northEast: The northeast corner of the box
  /// - parameter completion: code block whose parameters contain an array of W3WLines (in lat/long) for drawing the what3words grid over a map, and , if any, an error
  public func gridSection(southWest: CLLocationCoordinate2D, northEast: CLLocationCoordinate2D, completion: @escaping W3WGridResponse) {
    do {
      let grid = try gridSection(southWest: southWest, northEast: northEast)
      completion(grid, nil)
    } catch {
      completion([], convert(error: error))
    }
  }
  
  
  
  public func gridSection(south_lat: Double, west_lng: Double, north_lat: Double, east_lng: Double, completion: @escaping W3WGridResponse) {
    gridSection(southWest: CLLocationCoordinate2D(latitude: south_lat, longitude: west_lng), northEast: CLLocationCoordinate2D(latitude: north_lat, longitude: east_lng), completion: completion)
  }
  
  
  
  /// Retrieves a list of the currently loaded and available 3 word address languages.
  /// - parameter completion: code block whose parameters contain a list of the currently loaded and available 3 word address languages, and , if any, an error
  public func availableLanguages(completion: @escaping W3WLanguagesResponse) {
    completion(availableLanguages(), nil)
  }
  
  
  private func convert(error: Any) -> W3WError {
    if let e = error as? W3WSdkError {
      return W3WError.sdkError(error: e)
    } else {
      return W3WError.unknown
    }
  }

  
  /// Returns a three word address from a latitude and longitude
  /// - parameter coordinates: A CLLocationCoordinate2D object
  /// - parameter language: A supported 3 word address language as an [ISO 639-1](https://en.wikipedia.org/wiki/List_of_ISO_639-1_codes) 2 letter code. Defaults to "en"
  /// - returns the three word address
  /// - throws W3WSdkError
  public func convertTo3wa(coordinates: CLLocationCoordinate2D, language: String) throws -> String? {
    return try? convertTo3wa(coordinates: coordinates, language: language)
  }
  
  
  
  // MARK:- Autosuggest
  
  
  /// Returns a list of 3 word addresses based on user input and other parameters.
  /// - parameter text: The full or partial 3 word address to obtain suggestions for. At minimum this must be the first two complete words plus at least one character from the third word.
  /// - parameter options: are provided as an array of W3SdkOption objects.
  /// - returns An array of W3WSuggestions
  /// - throws W3WSdkError
  public func autosuggest(text: String, options: [W3WSdkOption]) throws -> [W3WSdkSuggestion] {
    return try sdk.autosuggest(text: text, options: options)
  }
  
  
  /// Returns a list of 3 word addresses based on user input and other parameters.
  /// - parameter text: The full or partial 3 word address to obtain suggestions for. At minimum this must be the first two complete words plus at least one character from the third word.
  /// - parameter options: are provided in a W3SdkOptions object.
  /// - returns An array of W3WSuggestions
  /// - throws W3WSdkError
  public func autosuggest(text: String, options: W3WSdkOptions) throws -> [W3WSdkSuggestion] {
    return try autosuggest(text: text, options: options.options)
  }
  
  
  /// Returns a list of 3 word addresses based on user input and other parameters.
  /// - parameter text: The full or partial 3 word address to obtain suggestions for. At minimum this must be the first two complete words plus at least one character from the third word.
  /// - parameter options: a single W3WOption
  /// - returns An array of W3WSuggestions
  /// - throws W3WSdkError
  public func autosuggest(text: String, options: W3WSdkOption) throws -> [W3WSdkSuggestion] {
    return try autosuggest(text: text, options: [options])
  }
  
  
  /// Returns a list of 3 word addresses based on user input
  /// - parameter text: The full or partial 3 word address to obtain suggestions for. At minimum this must be the first two complete words plus at least one character from the third word.
  /// - returns An array of W3WSuggestions
  /// - throws W3WSdkError
  public func autosuggest(text: String) throws -> [W3WSdkSuggestion] {
    return try autosuggest(text: text, options: [])
  }
  
  
  // MARK:- Info functions
  
  
  /// Get version information for the various parts "modules" of this SDK
  /// - parameter module: choose .swiftInterface, .engine, or .data
  public func version(module: W3WSdkModule = .swiftInterface) -> String {
    return sdk.version(module: module)
  }
  
  
  /// Get the current version of the what3words SDK data files that are in use
  @available(*, deprecated, message: "Use version(module: .data) instead")
  public func dataVersion() -> String {
    return sdk.dataVersion()
  }
  
  
  /// Returns a section of the 3m x 3m what3words grid for a given area.
  /// - parameter south: The south latitude of the box
  /// - parameter west: The west longitude of the box
  /// - parameter north: The north latitude of the box
  /// - parameter east: The east longitude of the box
  public func gridSection(south: Double, west: Double, north: Double, east: Double) throws -> [W3WSdkLine]? {
    return try sdk.gridSection(south: south, west: west, north: north, east: east)
  }
  
  
  
  /// Returns a section of the 3m x 3m what3words grid for a given area.
  /// - parameter southWest: The southwest corner of the box
  /// - parameter northEast: The northeast corner of the box
  /// - returns an array of W3WLines (in lat/long) for drawing the what3words grid over a map
  public func gridSection(southWest: CLLocationCoordinate2D, northEast: CLLocationCoordinate2D) throws -> [W3WSdkLine]? {
    return try gridSection(south: southWest.latitude, west: southWest.longitude, north: northEast.latitude, east: northEast.longitude)
  }
  
  
  
  /// Retrieves a list of the currently loaded and available 3 word address languages.
  public func availableLanguages() -> [W3WSdkLanguage] {
    return sdk.availableLanguages()
  }
  
  
  /// From a three word address, get all info associated with a three word square, such as neaest place, country, bounding box etc...
  /// - parameter words: A 3 word address as a string
  /// - returns A W3WSquare containing info such as neaest place, country, bounding box etc...
  /// - throws W3WSdkError
  public func convertToSquare(words: String) throws -> W3WSdkSquare? {
    return try sdk.convertToSquare(words: words)
  }

  
  /// From a coordinate, and prefered language, get all info associated with a three word square, such as neaest place, country, bounding box etc...
  /// - parameter coordinates: A CLLocationCoordinate2D object
  /// - parameter language: A supported 3 word address language as an [ISO 639-1](https://en.wikipedia.org/wiki/List_of_ISO_639-1_codes) 2 letter code. Defaults to "en"
  /// - returns A W3WSquare containing info such as neaest place, country, bounding box etc...
  /// - throws W3WSdkError
  public func convertToSquare(coordinates: CLLocationCoordinate2D, language: String) throws -> W3WSdkSquare? {
    return try sdk.convertToSquare(coordinates: coordinates, language: language)
  }

  
}


#endif
