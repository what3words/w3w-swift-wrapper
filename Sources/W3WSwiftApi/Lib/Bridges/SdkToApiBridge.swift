//
//  SdkToApiBridge.swift
//  CoreSdkPlusApi
//
//  Created by Dave Duprey on 18/09/2020.
//  Copyright © 2020 Dave Duprey. All rights reserved.
//
//  NOTE:
//  This is included by the compiler if the iOS SDK is available
//  It creates compatibility between the API and the SDK, specifically
//  interoperability.  This is achived by extending the classes and
//  and structs to conform to the protocols that are used throughout
//  the component library.  Contact what3words if you wish to use
//  the SDK and remove the dependancy on an Internet conneciton
//

import Foundation


#if canImport(w3w)
import w3w

// make the following conform to the main protocols
//extension W3WSdkSuggestion: W3WSuggestion { }
//extension W3WSdkBoundingBox: W3WBoundingBox { }
//extension W3WSdkSquare: W3WSquare, W3WWithCoordinates, W3WSuggestion { }
//extension W3WSdkLanguage: W3WLanguage { }
//extension W3WSdkLine: W3WLine { }


extension W3WSdkSquare {
  func asW3WSquare() -> W3WSquare {
    return W3WApiSquare(words: words, coordinates: coordinates, country : country?.code, nearestPlace : nearestPlace, distanceToFocus : distanceToFocus?.meters, language : language?.code, southWestBounds: southWestBounds, northEastBounds: northEastBounds, map: nil)
  }
}


extension W3WSdkSuggestion {
  func asW3WSuggestion() -> W3WSuggestion {
    return W3WApiSuggestion(words: words, country : country?.code, nearestPlace : nearestPlace, distanceToFocus : distanceToFocus?.meters, language : language?.code)
  }
}


extension W3WSdkLine {
  func asW3WLine() -> W3WLine {
    return W3WApiLine(start: start, end: end)
  }
}


extension W3WSdkLanguage {
  func asW3WLanguage() -> W3WLanguage {
    return W3WApiLanguage(name: "", nativeName: "", code: code)
  }
}


extension W3WSdkBox {
  func asW3WBox() -> W3WBoundingBox {
    return W3WApiBoundingBox(southWest: southWest, northEast: northEast)
  }
}



public struct W3WSdkSuggestionWithCoordinates: W3WSuggestionWithCoordinates, W3WSuggestion, W3WWithCoordinates {
  
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
  
//  public init(words: String? = nil, coordinates: CLLocationCoordinate2D? = nil, country : String? = nil, nearestPlace : String? = nil, distanceToFocus : Double? = nil, language : String? = nil, southWestBounds: CLLocationCoordinate2D? = nil, northEastBounds: CLLocationCoordinate2D? = nil) {
//    self.words = words
//    self.coordinates = coordinates
//    self.country = country
//    self.nearestPlace = nearestPlace
//    self.distanceToFocus = distanceToFocus
//    self.language = language
//    self.southWestBounds = southWestBounds
//    self.northEastBounds = northEastBounds
//  }
  
  func asW3WSuggestion() -> W3WSuggestion {
    return W3WApiSuggestionWithCoordinates(words: words, country : country, nearestPlace : nearestPlace, distanceToFocus : distanceToFocus, language : language, southWestBounds: southWestBounds, northEastBounds: northEastBounds)
  }
}


/// Make the Core SDK conform to the main what3words Swift protocol
extension What3Words: W3WProtocolV3 {
  
  /// Converts a 3 word address to a position, expressed as coordinates of latitude and longitude.
  /// - parameter words: A 3 word address as a string
  /// - parameter completion: code block whose parameters contain a W3WSquare and if any, an error
  public func convertToCoordinates(words: String, completion: @escaping W3WSquareResponse) {
    do {
      if let square = try convertToSquare(words: words), square.coordinates != nil {
        completion(square.asW3WSquare(), nil)
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
      if let square = try convertToSquare(coordinates: coordinates, language: W3WSdkLanguage(code: language)), square.words != nil {
        completion(square.asW3WSquare(), nil)
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
    
    do {
      for option in options {
        if let o = try? W3WSdkOption.convert(from: option) {
          coreOptions.append(o)
        }
      }
    
      let suggestions = try autosuggest(text: text, options: coreOptions)
      let apiSuggestionArray = suggestions.map { suggestion in return suggestion.asW3WSuggestion() }
      completion(apiSuggestionArray, nil)
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

    do {
      for option in options {
        if let o = try? W3WSdkOption.convert(from: option) {
          coreOptions.append(o)
        }
      }
    
      let suggestions = try autosuggest(text: text, options: coreOptions)
      
      var suggestionsWithCoordinates = [W3WApiSuggestionWithCoordinates]()
      for suggestion in suggestions {
        if let words = suggestion.words, let square = try? convertToSquare(words: words) {
          let suggestionWithCoordinate = W3WApiSuggestionWithCoordinates(words: square.words, coordinates: square.coordinates, country: square.country?.code, nearestPlace: square.nearestPlace, distanceToFocus: square.distanceToFocus?.kilometers, language: square.language?.code, southWestBounds: square.southWestBounds, northEastBounds: square.northEastBounds)
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
      let apiLineArray = grid?.map { line in return line.asW3WLine() }
      completion(apiLineArray, nil)
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
    let list = availableLanguages().map { language in return language.asW3WLanguage() }
    completion(list, nil)
  }
  
  
  private func convert(error: Any) -> W3WError {
    if let e = error as? W3WSdkError {
      return W3WError.sdkError(error: e)
    } else {
      return W3WError.unknown
    }
  }
  
}



/// Ensures the SDK's options conform to the main Option protocol
extension W3WSdkOption: W3WOptionProtocol {
  public func key() -> String {
    key.description
  }
  
  public func asString() -> String {
    value.asString()
  }
  
  public func asBoolean() -> Bool {
    value.asBoolean() ?? false
  }
  
  public func asCoordinates() -> CLLocationCoordinate2D {
    value.asCoordinates() ?? CLLocationCoordinate2D()
  }
  
  public func asBoundingBox() -> (CLLocationCoordinate2D, CLLocationCoordinate2D) {
    let box = value.asBox()
    return (box?.southWest ?? CLLocationCoordinate2D(), box?.northEast ?? CLLocationCoordinate2D())
  }
  
  public func asBoundingCircle() -> (CLLocationCoordinate2D, Double) {
    let circle = value.asCircle()
    return (circle?.center ?? CLLocationCoordinate2D(), circle?.radius.kilometers ?? 0.0)
  }
  
  public func asBoundingPolygon() -> [CLLocationCoordinate2D] {
    value.asPolygon()?.points ?? []
  }
  
  
  
  public func asStringArray() -> [String] {
    return value.asStringArray()
  }
  
  
  static func convert(from: W3WOptionProtocol) throws -> W3WSdkOption? {
    
    switch from.key() {
    
    case W3WOptionKey.language:
      if let l = try? W3WSdkLanguage(code: from.asString()) {
        return W3WSdkOption.language(l)
      }
      
    case W3WOptionKey.voiceLanguage:
      if let l = try? W3WSdkLanguage(code: from.asString()) {
        return W3WSdkOption.voiceLanguage(l)
      }
    case W3WOptionKey.numberOfResults:
      return W3WSdkOption.numberOfResults(Int(from.asString()) ?? 3)
    case W3WOptionKey.focus:
      return W3WSdkOption.focus(from.asCoordinates())
    case W3WOptionKey.numberFocusResults:
      return W3WSdkOption.numberFocusResults(Int(from.asString()) ?? 3)
    case W3WOptionKey.inputType:
      return coreInputType(from:from)
    case W3WOptionKey.clipToCountry:
      if from.asString().contains(",") {
        let countries = try from.asStringArray().map { code in return try W3WSdkCountry(code: code) }
        return W3WSdkOption.clip(to: countries)
      } else {
        return W3WSdkOption.clip(to: try W3WSdkCountry(code: from.asString()))
      }
    case W3WOptionKey.clipToCountries:
      return W3WSdkOption.clip(to: try from.asStringArray().map { code in return try W3WSdkCountry(code: code) } )
    case W3WOptionKey.preferLand:
      return W3WSdkOption.preferLand(from.asBoolean())
    case W3WOptionKey.clipToCircle:
      return W3WSdkOption.clip(to: try W3WSdkCircle(center: from.asBoundingCircle().0, radius: W3WSdkDistance(kilometers: from.asBoundingCircle().1)))
    case W3WOptionKey.clipToBox:
      return W3WSdkOption.clip(to: try W3WSdkBox(southWest: from.asBoundingBox().0, northEast: from.asBoundingBox().1))
    case W3WOptionKey.clipToPolygon:
      return W3WSdkOption.clip(to: try W3WSdkPolygon(points: from.asBoundingPolygon()))
    default:
      return W3WSdkOption.language(W3WSdkLanguage.english)
    }
    
    return W3WSdkOption.language(W3WSdkLanguage.english)
  }
  
}


private func coreInputType(from: W3WOptionProtocol) -> W3WSdkOption {

  return W3WSdkOption.inputType(W3WSdkInputType.custom(from.asString()))
  
//  switch from.key() {
    
//  case W3WOptionKey.language:

  
  //  case W3WSdkInputType.text:
//    return W3WSdkOption.inputType(W3WSdkInputType.text)
//
//  case W3WSdkInputType.voconHybrid:
//    return W3WSdkOption.inputType(W3WSdkInputType.voconHybrid)
//
//  case W3WSdkInputType.genericVoice.rawValue:
//    return W3WSdkOption.inputType(W3WSdkInputType.genericVoice)
//
//  case W3WSdkInputType.nmdpAsr.rawValue:
//    return W3WSdkOption.inputType(W3WSdkInputType.nmdpAsr)
//
//  case W3WSdkInputType.speechmatics.rawValue:
//    return W3WSdkOption.inputType(W3WSdkInputType.speechmatics)
//
//  case W3WSdkInputType.mihup.rawValue:
//    return W3WSdkOption.inputType(W3WSdkInputType.mihup)
//
//  case W3WSdkInputType.mawdoo3.rawValue:
//    return W3WSdkOption.inputType(W3WSdkInputType.mawdoo3)
//
//  case W3WSdkInputType.ocrSdk.rawValue:
//    return W3WSdkOption.inputType(W3WSdkInputType.ocrSdk)
//
//  default:
//    return W3WSdkOption.inputType(W3WSdkInputType.text)
//  }
}

#endif
