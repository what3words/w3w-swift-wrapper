//
//  VoiceApi.swift
//  VoiceApiDemo
//
//  Created by Dave Duprey on 23/04/2020.
//  Copyright © 2020 What3Words. All rights reserved.
//


import Foundation
import CoreLocation


/// Defines the closure used for completion blocks for Voice recognition interfaaces
public typealias W3WVoiceSuggestionsResponse     = ((_ result: [W3WVoiceSuggestion]?, _ error: W3WVoiceError?) -> Void)


#if !os(watchOS)


/// A wrapper for what3words Voice recognition API
public class W3WVoiceApi: W3WApiCall, W3WVoice {
  
  /// holds the web socket object
  var voiceSocket: W3WVoiceSocket?
  
  /// A wrapper for what3words Voice recognition API
  /// - parameter apiKey: A what3words voice enabled api key
  public init(apiKey: String) {
    super.init(apiUrl: W3WSettings.voiceApiUrl, apiKey: apiKey)
    self.voiceSocket = W3WVoiceSocket(apiKey: apiKey)
  }
  
  
  /// A wrapper for what3words Voice recognition API
  /// - parameter api: A what3words API object
  public init(api: What3WordsV3) {
    super.init(apiUrl: W3WSettings.voiceApiUrl, apiKey: api.apiKey)
    self.voiceSocket = W3WVoiceSocket(apiKey: api.apiKey)
  }

  
   /// Retrieves a list of the currently loaded and available 3 word address languages.
   /// - parameter completion: A W3wGeocodeResponseHandler completion handler
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
  private func common(audio: W3WAudioStream, language: String, options: [W3WOption], callback: @escaping W3WVoiceSuggestionsResponse) {
 
    let filteredOptions = replaceOrAddVoiceLanguageIn(options: options, language: language)

    // send any suggestions
    voiceSocket?.suggestions = { suggestions in
      self.stop(audio: audio)
      callback(suggestions, nil)
    }

    // deal with any voice error
    voiceSocket?.error = { error in
      self.stop(audio: audio)
      callback(nil, error)
    }
    
    // deal with any audio error
    audio.onError = { error in
      self.stop(audio: audio)
      callback(nil, error)
    }
    
    // handles sampes when they come in
    audio.sampleArrived = { data in
      self.voiceSocket?.send(samples: Data(buffer: data))
    }
    
    // if we were given a microphone, then turn it on
    if #available(tvOS 11.0, watchOS 4.0, *) {
      if let microphone = audio as? W3WMicrophone {
        microphone.start()
      }
    }

    // open the ocnnection to the server
    voiceSocket?.open(sampleRate: audio.sampleRate, encoding: audio.encoding, options: filteredOptions)
  }
  
  
  /// stop the audio and the web socket
  func stop(audio: W3WAudioStream) {
    voiceSocket?.endSamples()
    voiceSocket?.close()
    voiceSocket = nil
    
    audio.endSamples()
    
    // if we were given a microphone, then turn it on
    if #available(tvOS 11.0, watchOS 4.0, *) {
      if let microphone = audio as? W3WMicrophone {
        microphone.stop()
      }
    }
  }

  
  /// Returns a list of 3 word address suggestions based on user input and other parameters.
  /// - parameter audio: An audio source such as a W3WMicrophone
  /// - parameter options: are provided as an array of W3Option objects.
  /// - parameter callback: A completion block providing the suggestions and any error
  public func autosuggest(audio: W3WAudioStream, language: String, options: [W3WOption], callback: @escaping W3WVoiceSuggestionsResponse) {
    common(audio: audio, language: language, options: options, callback: callback) //, completion: { _ in })
  }


  /// Returns a list of 3 word address suggestions based on user input and other parameters.
  /// - parameter audio: An audio source such as a W3WMicrophone
  /// - parameter options: are provided as a varidic list of W3Option objects.
  /// - parameter callback: A completion block providing the suggestions and any error
  public func autosuggest(audio: W3WAudioStream, language: String, options: W3WOption..., callback: @escaping W3WVoiceSuggestionsResponse) {
    common(audio: audio, language: language, options: options, callback: callback) //, completion: { _ in })
  }

  
  /// Returns a list of 3 word address suggestions based on user input and other parameters.
  /// - parameter audio: An audio source such as a W3WMicrophone
  /// - parameter options: are provided as a W3Options object.
  /// - parameter callback: A completion block providing the suggestions and any error
  public func autosuggest(audio: W3WAudioStream, language: String, options: W3WOptions, callback: @escaping W3WVoiceSuggestionsResponse) {
    common(audio: audio, language: language, options: options.options, callback: callback) //, completion: { _ in })
  }

  

  /// removes voiceLanguage option if present, and adds the language specified in the language parameter
  /// this is a remedy for teh case a redundancy is caused by the parameter and optioins both specifying a language
  /// perference is given to the parameter
  func replaceOrAddVoiceLanguageIn(options: [W3WOption], language: String) -> [W3WOption] {
    var newOptions = [W3WOption]()
    
    for option in options {
      if option.key() != W3WOptionKey.voiceLanguage {
        newOptions.append(option)
      }
    }
    
    newOptions.append(W3WOption.voiceLanguage(language))
    
    return newOptions
  }
  
      
}

#endif
