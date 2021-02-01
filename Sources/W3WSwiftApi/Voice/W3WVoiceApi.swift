//
//  VoiceApi.swift
//  VoiceApiDemo
//
//  Created by Dave Duprey on 23/04/2020.
//  Copyright © 2020 What3Words. All rights reserved.
//


import Foundation
import CoreLocation




#if !os(watchOS)


public class W3WVoiceApi: W3WApiCall, W3WVoice {
  
  
  public init(apiKey: String) {
    super.init(apiUrl: W3WSettings.voiceApiUrl, apiKey: apiKey)
  }
  
  
  public init(api: What3WordsV3) {
    super.init(apiUrl: W3WSettings.voiceApiUrl, apiKey: api.apiKey)
  }

  
  /**
   Retrieves a list of the currently loaded and available 3 word address languages.
   - parameter completion: A W3wGeocodeResponseHandler completion handler
   */
  public func availableVoiceLanguages(completion: @escaping W3WLanguagesResponse) {
    self.performRequest(path: "/available-languages", params: [:]) { (result, error) in
      if let lines = result {
        completion(self.languages(from: lines), error)
      } else {
        completion(nil, error)
      }
    }
  }

  
  /// the important function here, this actually starts the voice session, all other functions are for convenience and call this one and accept different combinations of paramters
  //private func common(audio: W3WAudioStream, options: [W3WOption], callback: @escaping W3WVoiceSuggestionsResponse, completion: @escaping W3WClosedResponse) {
  private func common(audio: W3WAudioStream, language: String, options: [W3WOption], callback: @escaping W3WVoiceSuggestionsResponse) {
 
    let filteredOptions = replaceOrAddVoiceLanguageIn(options: options, langauge: language)

    // connects the callback and intializes the VoiceApi
    audio.configure(apiKey: self.apiKey, callback: callback) //, completion: completion)

    // if we were given a microphone, then turn it on
    if let microphone = audio as? W3WMicrophone {
      microphone.start()
    }

    // open the ocnnection to the server
    audio.open(sampleRate: audio.sampleRate, encoding: audio.encoding, options: filteredOptions)
  }
  

  /**
   Convenience function without a completion
   */
  public func autosuggest(audio: W3WAudioStream, language: String, options: [W3WOption], callback: @escaping W3WVoiceSuggestionsResponse) {
    common(audio: audio, language: language, options: options, callback: callback) //, completion: { _ in })
  }


  /**
   Convenience function to allow use of option list without array and  without a completion
   */
  public func autosuggest(audio: W3WAudioStream, language: String, options: W3WOption..., callback: @escaping W3WVoiceSuggestionsResponse) {
    common(audio: audio, language: language, options: options, callback: callback) //, completion: { _ in })
  }

  
  /**
   Convenience function without a completion
   */
  public func autosuggest(audio: W3WAudioStream, language: String, options: W3WOptions, callback: @escaping W3WVoiceSuggestionsResponse) {
    common(audio: audio, language: language, options: options.options, callback: callback) //, completion: { _ in })
  }

  

  /// removes voiceLanguage option if present, and adds the language specified in the language parameter
  /// this is a remedy for teh case a redundancy is caused by the parameter and optioins both specifying a langauge
  /// perference is given to the parameter
  func replaceOrAddVoiceLanguageIn(options: [W3WOption], langauge: String) -> [W3WOption] {
    var newOptions = [W3WOption]()
    
    for option in options {
      if option.key() != W3WOptionKey.voiceLanguage {
        newOptions.append(option)
      }
    }
    
    newOptions.append(W3WOption.voiceLanguage(langauge))
    
    return newOptions
  }
  
  

  /// utility to check that langauge was passed in as it is non-optional for voice
  func checkForLanguageOption(options: [W3WOption]) -> Bool {
    var languagePresent = false
    
    for option in options {
      if option.key() == W3WOptionKey.voiceLanguage {
        languagePresent = true
        break
      }
    }
    
    return languagePresent
  }
    
}

#endif // if !os(watchOS) - from top of file
