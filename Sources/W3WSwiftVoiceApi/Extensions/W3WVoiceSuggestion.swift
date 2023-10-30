//
//  File.swift
//
//
//  Created by Dave Duprey on 08/11/2022.
//


import CoreLocation
import W3WSwiftCore


extension W3WVoiceSuggestion {
  
  init(jsonVoiceSuggestion: JsonVoiceSuggestion?) {
    
    // parse the language code which could be of the form 'XX', or, 'XX_XX'
    var lang: W3WVoiceLanguage? = nil

    if let code = jsonVoiceSuggestion?.language {
      let l = W3WVoiceLanguage(code: code)
      //if let locale = jsonVoiceSuggestion?.locale {
      //  l = W3WVoiceLanguage(locale: locale)
      //}
      lang = l
    }
    
    self.init(
      words: jsonVoiceSuggestion?.words,
      country: jsonVoiceSuggestion?.country == nil ? nil : W3WBaseCountry(code: jsonVoiceSuggestion!.country!),
      nearestPlace: jsonVoiceSuggestion?.nearestPlace,
      distanceToFocus: jsonVoiceSuggestion?.distanceToFocus == nil ? nil : W3WBaseDistance(kilometers: Double(jsonVoiceSuggestion!.distanceToFocus!)),
      language: lang,
      rank: jsonVoiceSuggestion?.rank
    )
  }
  
}
