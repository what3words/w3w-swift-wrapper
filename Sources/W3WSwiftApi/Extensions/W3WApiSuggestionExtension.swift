//
//  File.swift
//  
//
//  Created by Dave Duprey on 08/11/2022.
//


import CoreLocation
import W3WSwiftCore


extension W3WApiSuggestion {

  init(jsonSuggestion: JsonSuggestion?) {
    
    // parse the language code which could be of the form 'XX', or, 'XX_XX'
    var lang: W3WApiLanguage? = nil
    if let code = jsonSuggestion?.language {
      var l = W3WApiLanguage(code: code)
      if let locale = jsonSuggestion?.locale {
        l = W3WApiLanguage(locale: locale)
      }
      lang = l
    }
        
    self.init(
      words: jsonSuggestion?.words,
      country: jsonSuggestion?.country == nil ? nil : W3WApiCountry(code: jsonSuggestion!.country!),
      nearestPlace: jsonSuggestion?.nearestPlace,
      distanceToFocus: jsonSuggestion?.distanceToFocusKm == nil ? nil : W3WApiDistance(kilometers: Double(jsonSuggestion!.distanceToFocusKm!)),
      language: lang,
      rank: jsonSuggestion?.rank
    )
  }

}
