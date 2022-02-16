//
//  File.swift
//
//
//  Created by Dave Duprey on 16/09/2021.
//

import Foundation
import MapKit



/// Objective-C compatible Suggestion object
@objcMembers public class W3WObjcSuggestion: NSObject {
  public var words: NSString?
  public var country: NSString?
  public var nearestPlace: NSString?
  public var distanceToFocus: NSNumber?
  public var language: NSString?
  
  public init(words: String?, country: String?, nearestPlace: String?, distanceToFocus: NSNumber?, language: String?) {
    self.words            = words as NSString?
    self.country          = country as NSString?
    self.nearestPlace     = nearestPlace as NSString?
    self.distanceToFocus  = distanceToFocus as NSNumber?
    self.language         = language as NSString?
  }
  
  public init(suggestion: W3WSuggestion?) {
    self.words            = suggestion?.words as NSString?
    self.country          = suggestion?.country as NSString?
    self.nearestPlace     = suggestion?.nearestPlace as NSString?
    if let distance = suggestion?.distanceToFocus {
      self.distanceToFocus = NSNumber(floatLiteral: distance)
    } else {
      self.distanceToFocus = nil
    }
    self.language         = suggestion?.language as NSString?
  }
}


/// Objective-C compatible square object
@objcMembers public class W3WObjcSquare: NSObject {
  public var words: NSString?
  public var country: NSString?
  public var nearestPlace: NSString?
  public var distanceToFocus: NSNumber?
  public var language: NSString?
  public var coordinates: W3WObjcCoordinates?
  public var southWestBounds: W3WObjcCoordinates?
  public var northEastBounds: W3WObjcCoordinates?
  public var map: NSString?
  
  @objc public init(words: String?, country: String? = nil, nearestPlace: String? = nil, distanceToFocus: NSNumber? = nil, language: String? = nil, coordinates: W3WObjcCoordinates? = nil, southWestBounds: W3WObjcCoordinates? = nil, northEastBounds: W3WObjcCoordinates? = nil, map: String? = nil) {
    self.words            = words as NSString?
    self.country          = country as NSString?
    self.nearestPlace     = nearestPlace as NSString?
    self.distanceToFocus  = NSNumber(nonretainedObject: distanceToFocus)
    self.language         = language as NSString?
    self.coordinates      = coordinates
    self.southWestBounds  = southWestBounds
    self.northEastBounds  = northEastBounds
    self.map              = map as NSString?
  }
  
  public init(square: W3WSquare?) {
    self.words            = square?.words as NSString?
    self.country          = square?.country as NSString?
    self.nearestPlace     = square?.nearestPlace as NSString?
    if let distance = square?.distanceToFocus {
      self.distanceToFocus = NSNumber(nonretainedObject: distance)
    }
    self.language         = square?.language as NSString?
    if let coordinate = square?.coordinates {
      self.coordinates      = W3WObjcCoordinates(coordinates: coordinate)
    }
    if let southWestBounds = square?.southWestBounds {
      self.southWestBounds  = W3WObjcCoordinates(coordinates: southWestBounds)
    }
    if let northEastBounds = square?.northEastBounds {
      self.northEastBounds  = W3WObjcCoordinates(coordinates: northEastBounds)
    }
    self.map              = square?.map as NSString?
  }
  
  public init(suggestionWithCoordinates: W3WSuggestionWithCoordinates?) {
    self.words            = suggestionWithCoordinates?.words as NSString?
    self.country          = suggestionWithCoordinates?.country as NSString?
    self.nearestPlace     = suggestionWithCoordinates?.nearestPlace as NSString?
    if let distance = suggestionWithCoordinates?.distanceToFocus {
      self.distanceToFocus = NSNumber(nonretainedObject: distance)
    }
    self.language         = suggestionWithCoordinates?.language as NSString?
    if let coordinate = suggestionWithCoordinates?.coordinates {
      self.coordinates      = W3WObjcCoordinates(coordinates: coordinate)
    }
    if let southWestBounds = suggestionWithCoordinates?.southWestBounds {
      self.southWestBounds  = W3WObjcCoordinates(coordinates: southWestBounds)
    }
    if let northEastBounds = suggestionWithCoordinates?.northEastBounds {
      self.northEastBounds  = W3WObjcCoordinates(coordinates: northEastBounds)
    }
    self.map              = nil
  }
}


/// Coordinate for objc compatibility
@objcMembers public class W3WObjcCoordinates: NSObject {
  var coordinates: CLLocationCoordinate2D
  
  @objc public init(latitude: Double, longitude: Double) {
    coordinates = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
  }
  
  @objc public init(coordinates: CLLocationCoordinate2D) {
    self.coordinates = CLLocationCoordinate2D(latitude: coordinates.latitude, longitude: coordinates.longitude)
  }
  
  @objc public var latitude: Double {
    get {
      return coordinates.latitude
    }
    set {
      coordinates.latitude = newValue
    }
  }
  
  @objc public var longitude: Double {
    get {
      return coordinates.longitude
    }
    set {
      coordinates.longitude = newValue
    }
  }
}


/// Objective-C compatible square object
@objcMembers public class W3WObjcLine: NSObject, W3WLine {
  public var start: CLLocationCoordinate2D
  public var end: CLLocationCoordinate2D
  
  public init(start: CLLocationCoordinate2D, end: CLLocationCoordinate2D) {
    self.start = start
    self.end   = end
  }
}


@objcMembers public class W3WObjcLanguage: NSObject, W3WLanguage {
  public var name: String
  public var nativeName: String
  public var code: String
  
  public init(name: String, nativeName: String, code: String) {
    self.name = name
    self.nativeName = nativeName
    self.code = code
  }
}


/// ObjC enum for autosuggest input type option
@objc public enum W3WObjcInputType: Int {
  case text
  case voconHybrid
  case nmdpAsr
  case genericVoice
  case speechmatics
  case mihup
  case mawdoo3
  case ocrSdk
}


/// ObjC compatible option object for autosuggest calls
@objcMembers public class W3WObjcOptions: NSObject {
  public var options = [W3WOption]()
  
  /// location of the user to help autosuggest provide more relevant suggestions
  public func addFocus(_ focus: CLLocationCoordinate2D) {
    options.append(W3WOption.focus(focus))
  }
  
  /// language to use for the voice API
  public func addVoiceLanguage(_ voiceLanguage: String) {
    options.append(W3WOption.voiceLanguage(voiceLanguage))
  }
  
  /// language to use for the voice API
  public func addLanguage(_ language: String) {
    options.append(W3WOption.language(language))
  }

  /// number of results that will use the focus option
  public func addNumberFocusResults(_ numberFocusResults: Int) {
    options.append(W3WOption.numberFocusResults(numberFocusResults))
  }
  
  /// the number of results to return in total
  public func addNumberOfResults(_ numberOfResults: Int) {
    options.append(W3WOption.numberOfResults(numberOfResults))
  }
  
  /// tells autosuggest to only return results from one country
  public func addClipToCountry(_ clipToCountry: String) {
    options.append(W3WOption.clipToCountry(clipToCountry))
  }
  
  /// tells autosuggest to limit results to particular countries
  public func addClipToCountries(_ clipToCountries: [String]) {
    options.append(W3WOption.clipToCountries(clipToCountries))
  }
  
  /// limit results to a particular geographic circle
  public func addClipToCircle(_ center:CLLocationCoordinate2D, radius: Double) {
    options.append(W3WOption.clipToCircle(center: center, radius: radius))
  }
  
  /// limit results to a geographic rectangle
  public func addClipToBoxSouthWest(_ southWest:CLLocationCoordinate2D, northEast:CLLocationCoordinate2D) {
    options.append(W3WOption.clipToBox(southWest: southWest, northEast: northEast))
  }
  
  /// limit results to a geographic polygon
  public func addClipToPolygon(_ clipToPolygon: [CLLocationCoordinate2D]) {
    options.append(W3WOption.clipToPolygon(clipToPolygon))
  }
  
  /// gives preference to land based addresses
  public func addPreferLand(_ preferLand: Bool) {
    options.append(W3WOption.preferLand(preferLand))
  }
  
  
  /// tells autosuggest which type of data is being passed to it (not relevant for autosuggest component)
  public func addInputType(_ inputType: W3WObjcInputType) {
    var it: W3WOption?
    
    switch inputType {
    case .genericVoice:
      it = W3WOption.inputType(.genericVoice)
    case .mihup:
      it = W3WOption.inputType(.mihup)
    case .nmdpAsr:
      it = W3WOption.inputType(.nmdpAsr)
    case .speechmatics:
      it = W3WOption.inputType(.speechmatics)
    case .text:
      it = W3WOption.inputType(.text)
    case .voconHybrid:
      it = W3WOption.inputType(.voconHybrid)
    case .mawdoo3:
      it = W3WOption.inputType(.mawdoo3)
    case .ocrSdk:
      it = W3WOption.inputType(.ocrSdk)
    }
    
    if let i = it {
      options.append(i)
    }
  }
}
