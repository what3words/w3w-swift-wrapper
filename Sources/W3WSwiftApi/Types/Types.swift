//
//  File.swift
//  
//
//  Created by Dave Duprey on 05/01/2023.
//

import CoreLocation
import W3WSwiftCore

///  The Api types are the same as the Base types, except for Square
///  which has a `map` value, and Suggestion which has  `rank`

public typealias W3WApiBox        = W3WBaseBox
public typealias W3WApiCircle     = W3WBaseCircle
public typealias W3WApiDistance   = W3WBaseDistance
public typealias W3WApiLine       = W3WBaseLine
public typealias W3WApiPolygon    = W3WBasePolygon
public typealias W3WApiCountry    = W3WBaseCountry
public typealias W3WApiLanguage   = W3WBaseLanguage


public struct W3WApiSuggestion: W3WSuggestion, W3WRanked, CustomStringConvertible {
  
  /// three word address
  public let words: String?
  
  /// contains ISO 3166-1 alpha-2 country codes, such as US,CA
  public let country: W3WCountry?
  
  /// nearest place
  public let nearestPlace: String?
  
  /// distance from focus
  public let distanceToFocus: W3WDistance?
  
  /// the language to use
  public let language: W3WLanguage?
  
  /// an integer indicating `n` for the nth suggestion
  public var rank: Int?
  
  /// convenience function for human readable suggestion output
  public var description: String {
    var retval = ""
    
    if let w = words {  retval += "\(w) " }
    if let c = country?.code {  retval += "\(c) " }
    if let n = nearestPlace {  retval += "\(n) " }
    if let d = distanceToFocus {  retval += "\(d.meters)m " }
    if let l = language?.locale ?? language?.code {  retval += "\(l) " }
    if let r = rank { retval += "\(r == 1 ? "1st" : (r == 2 ? "2nd" : (r == 3 ? "3rd" : "\(r)th")))"}
    
    return retval.trimmingCharacters(in: .whitespaces)
  }
  
  public init(words: String? = nil, country: W3WBaseCountry? = nil, nearestPlace: String? = nil, distanceToFocus: W3WBaseDistance? = nil, language: W3WBaseLanguage? = nil, rank: Int? = nil) {
    self.words = words
    self.country = country
    self.nearestPlace = nearestPlace
    self.distanceToFocus = distanceToFocus
    self.language = language
    self.rank = rank
  }
  
}



public struct W3WApiSquare: W3WSquare {

  /// three word address
  public let words: String?
  
  /// ISO 3166-1 alpha-2 country codes, such as US,CA
  public let country: W3WCountry?
  
  /// nearest place
  public let nearestPlace: String?
  
  /// distance from focus in kilometers
  public let distanceToFocus: W3WDistance?
  
  /// the language to use
  public let language: W3WLanguage?
  
  /// coordinates of the square
  public let coordinates: CLLocationCoordinate2D?
  
  /// the square's bounds
  public let bounds: W3WApiBox?

  /// a URL for the map (generally used as a convenience value for web applications)
  public let map: String?

  public init(words: String? = nil, country: W3WApiCountry? = nil, nearestPlace: String? = nil, distanceToFocus: W3WApiDistance? = nil, language: W3WApiLanguage? = nil, coordinates: CLLocationCoordinate2D? = nil, bounds: W3WApiBox? = nil, map: String? = nil) {
    self.words = words
    self.country = country
    self.nearestPlace = nearestPlace
    self.distanceToFocus = distanceToFocus
    self.language = language
    self.coordinates = coordinates
    self.bounds = bounds
    self.map = map
  }
  
}
