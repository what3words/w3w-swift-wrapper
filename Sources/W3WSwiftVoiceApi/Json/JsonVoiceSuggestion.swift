//
//  JsonVoiceSuggestion.swift
//  
//
//  Created by Dave Duprey on 04/04/2023.
//

import Foundation
import W3WSwiftCore


public struct JsonVoiceSuggestion: Codable {
  
  // W3WSuggestion
  public var words : String?             // the three word address
  public var country : String?           // ISO 3166-1 alpha-2 country code
  public var nearestPlace : String?      // text description of a nearby place
  public var distanceToFocus : Double?   // number of kilometers to the nearest place
  public var language : String?          // two letter language code
  
  // W3WRanked
  public var rank : Int?                 // indicates this suggestion's place in list from most probable to least probable match
  
}



//public struct JsonVoiceSuggestion: Codable {
//
//  var words : String?                    // the three word address
//  var country : W3WBaseCountry?          // ISO 3166-1 alpha-2 country code
//  var nearestPlace : String?             // text description of a nearby place
//  var distanceToFocus : W3WBaseDistance? // number of kilometers to the nearest place
//  var language : W3WBaseLanguage?        // two letter language code
//
//  // W3WRanked
//  var rank : Int?                 // indicates this suggestion's place in list from most probable to least probable match
//
////  enum CodingKeys: String, CodingKey {
////    case country = "country"
////    case nearestPlace = "nearestPlace"
////    case words = "words"
////    case distanceToFocus = "distanceToFocusKm"
////    case rank = "rank"
////    case language = "language"
////  }
////
////  public init(from decoder: Decoder) throws {
////    let values    = try decoder.container(keyedBy: CodingKeys.self)
////    nearestPlace  = try values.decodeIfPresent(String.self, forKey: .nearestPlace)
////    words         = try values.decodeIfPresent(String.self, forKey: .words)
////    rank          = try values.decodeIfPresent(Int.self,    forKey: .rank)
////
////    if let countryCode      = try values.decodeIfPresent(String.self, forKey: .country) {
////      country = W3WApiCountry(code: countryCode)
////    }
////
////    if let distanceToFocusInt = try values.decodeIfPresent(Double.self, forKey: .distanceToFocus) {
////      distanceToFocus = W3WApiDistance(kilometers: distanceToFocusInt)
////    }
////
////    if let languageCode = try values.decodeIfPresent(String.self, forKey: .language) {
////      language = W3WApiLanguage(code: languageCode)
////    }
////  }
//
//
////  public init(words: String? = nil, country : String? = nil, nearestPlace : String? = nil, distanceToFocus : Double? = nil, language : String? = nil) {
////    self.words = words
////    self.country = country
////    self.nearestPlace = nearestPlace
////    self.distanceToFocus = distanceToFocus
////    self.language = language
////  }
//
//}
