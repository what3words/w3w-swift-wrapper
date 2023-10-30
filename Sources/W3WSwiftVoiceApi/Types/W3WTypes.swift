//
//  W3WTypes.swift
//  
//
//  Created by Dave Duprey on 06/04/2023.
//

import CoreLocation
import W3WSwiftCore

///  The Api types are the same as the Base types, except for Square
///  which has a `map` value, and Suggestion which has  `rank`

//public typealias W3WVoiceBox        = W3WBaseBox
//public typealias W3WVoiceCircle     = W3WBaseCircle
//public typealias W3WVoiceDistance   = W3WBaseDistance
//public typealias W3WVoiceLine       = W3WBaseLine
//public typealias W3WVoicePolygon    = W3WBasePolygon
//public typealias W3WVoiceCountry    = W3WBaseCountry
//public typealias W3WVoiceLanguage   = W3WBaseLanguage
//public typealias W3WVoiceSquare     = W3WBaseSquare
//public typealias W3WVoiceSuggestion = W3WBaseSuggestion

// Represents a W3W suggestion from a voice system
//public struct W3WVoiceSuggestion: W3WSuggestion, W3WRanked {
//
//  // W3WSuggestion
//  public var words : String?                    // the three word address
//  public var country : W3WCountry?          // ISO 3166-1 alpha-2 country code
//  public var nearestPlace : String?             // text description of a nearby place
//  public var distanceToFocus : W3WDistance? // number of kilometers to the nearest place
//  public var language : W3WLanguage?        // two letter language code
//
//  // W3WRanked
//  public var rank : Int?                 // indicates this suggestion's place in list from most probable to least probable match
//
//  public init(words: String? = nil, country : W3WCountry? = nil, nearestPlace : String? = nil, distanceToFocus : W3WDistance? = nil, language : W3WVoiceLanguage? = nil, rank: Int? = nil) {
//    self.words = words
//    self.country = country
//    self.nearestPlace = nearestPlace
//    self.distanceToFocus = distanceToFocus
//    self.language = language
//    self.rank = rank
//  }
//
//}
