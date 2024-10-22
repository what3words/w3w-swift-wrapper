//
//  VoiceApi.swift
//  VoiceApiDemo
//
//  Created by Dave Duprey on 23/04/2020.
//  Copyright © 2020 What3Words. All rights reserved.
//


import Foundation
import CoreLocation
import W3WSwiftCore

#if !os(watchOS)


public class W3WVoiceApi: W3WRequest, W3WVoiceProtocol {
    
  var voiceSocket: W3WVoiceSocket?

  
  public init(apiKey: String) {
    super.init(baseUrl: W3WSettings.voiceApiUrl, parameters: ["key":apiKey], headers: [:])
    self.voiceSocket = W3WVoiceSocket(apiKey: apiKey)
  }
  
    
  /**
   Retrieves a list of the currently loaded and available 3 word address languages.
   - parameter completion: A W3wGeocodeResponseHandler completion handler
   */
  public func availableVoiceLanguages(completion: @escaping W3WLanguagesResponse) {
    self.performRequest(path: "/available-languages", params: [:]) { (code, result, error) in
      if let languages = W3WJson<JsonVoiceLanguages>.decode(json: result) {
        if let e = Self.makeErrorIfAny(code: code, data: languages.error, error: error) {
          completion(nil, e)

        } else {
          completion(Self.toLanguages(from: languages), nil)
        }
      }      
    }
  }
  
  
  static func toLanguages(from: JsonVoiceLanguages?) -> [W3WVoiceLanguage] {
    var languages = [W3WVoiceLanguage]()
    
    for language in from?.languages ?? [] {
      languages.append(W3WVoiceLanguage(code: language.code ?? "", name: language.name ?? "", nativeName: language.nativeName ?? ""))
    }
    
    return languages
  }
  
  
  /// the important function here, this actually starts the voice session, all other functions are for convenience and call this one and accept different combinations of paramters
  private func common(audio: W3WAudioStream, options: [W3WOption]?, callback: @escaping W3WVoiceSuggestionsResponse) {
 
    //let filteredOptions = replaceOrAddVoiceLanguageIn(options: options, language: language)

    // send any suggestions
    voiceSocket?.suggestions = { suggestions in
      self.stop(audio: audio)
      callback(suggestions, nil)
    }

    // deal with any error
    voiceSocket?.error = { error in
      self.stop(audio: audio)
      callback(nil, error)
    }
    
    audio.onError = { error in
      self.stop(audio: audio)
      callback(nil, error)
    }
    
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
    //voiceSocket?.open(sampleRate: audio.sampleRate, encoding: audio.encoding, options: filteredOptions)
    voiceSocket?.open(sampleRate: audio.sampleRate, encoding: audio.encoding, options: options)
  }
  
  
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

  
  /**
   Autosuggest with option array
   Returns a list of 3 word addresses based on user input and other parameters.
   - parameter audio: An W3WAudioStream object or derivitive, typically W3WMicrophone providing audio data
   - parameter options: An array of W3WOption providing various options, see API documentation for details
   - parameter callback: A completion block providing the suggestions and any error - ([W3WVoiceSuggestion]?, W3WVoiceError?) -> Void
   */
  public func autosuggest(audio: W3WAudioStream, options: [W3WOption]?, callback: @escaping W3WVoiceSuggestionsResponse) {
    common(audio: audio, options: options, callback: callback)
  }
  
  
  /**
   Autosuggest with varidic parameters for option
   Returns a list of 3 word addresses based on user input and other parameters.
   - parameter audio: An W3WAudioStream object or derivitive, typically W3WMicrophone providing audio data
   - parameter options: An varidic paraameter of W3WOption providing various options, see API documentation for details
   - parameter callback: A completion block providing the suggestions and any error - ([W3WVoiceSuggestion]?, W3WVoiceError?) -> Void
   */
  public func autosuggest(audio: W3WAudioStream, options: W3WOption..., callback: @escaping W3WVoiceSuggestionsResponse) {
    common(audio: audio, options: options, callback: callback)
  }
  
  
  /**
   Autosuggest accepting W3WOptions for the options
   Returns a list of 3 word addresses based on user input and other parameters.
   - parameter audio: An W3WAudioStream object or derivitive, typically W3WMicrophone providing audio data
   - parameter options: An W3WOptions() containing various options, these are constructed using the chaining pattern, see example code
   - parameter callback: A completion block providing the suggestions and any error - ([W3WVoiceSuggestion]?, W3WVoiceError?) -> Void
   */
  public func autosuggest(audio: W3WAudioStream, options: W3WOptions, callback: @escaping W3WVoiceSuggestionsResponse) {
    common(audio: audio, options: options.options, callback: callback)
  }
  
  
  /// deprecated: use autosuggest(audio:options:completion) instead
  @available(*, deprecated, message: "Use W3WOption.voiceLanguage(String) option and omit language: parameter")
  public func autosuggest(audio: W3WAudioStream, language: W3WLanguage, options: [W3WOption]?, callback: @escaping W3WVoiceSuggestionsResponse) {
    common(audio: audio, options: replaceOrAddVoiceLanguageIn(options: options, language: language), callback: callback)
  }
  
  /// deprecated: use autosuggest(audio:options:completion) instead
  @available(*, deprecated, message: "Use W3WOption.voiceLanguage(String) option and omit language: parameter")
  public func autosuggest(audio: W3WAudioStream, language: W3WLanguage, options: W3WOption..., callback: @escaping W3WVoiceSuggestionsResponse) {
    common(audio: audio, options: replaceOrAddVoiceLanguageIn(options: options, language: language), callback: callback)
  }
  
  
  /// deprecated: use autosuggest(audio:options:completion) instead
  @available(*, deprecated, message: "Use W3WOption.voiceLanguage(String) option and omit language: parameter")
  public func autosuggest(audio: W3WAudioStream, language: W3WLanguage, options: W3WOptions, callback: @escaping W3WVoiceSuggestionsResponse) {
    common(audio: audio, options: replaceOrAddVoiceLanguageIn(options: options.options, language: language), callback: callback)
  }
  


  /// removes voiceLanguage option if present, and adds the language specified in the language parameter
  /// this is a remedy for teh case a redundancy is caused by the parameter and optioins both specifying a language
  /// perference is given to the parameter
  func replaceOrAddVoiceLanguageIn(options: [W3WOption]?, language: W3WLanguage) -> [W3WOption] {
    var newOptions = [W3WOption]()

    for option in options ?? [] {
      if option.key() != "voice-language" {
        newOptions.append(option)
      }
    }

    newOptions.append(W3WOption.voiceLanguage(language))

    return newOptions
  }
  
  
  /// Checks the Json data for error data, and makes W3WError based on that. Absent
  /// that it passes through any error passed in.  This function is `static` to avoid
  /// even the appearance of retain cycle caused by `self` capture.
  /// - Parameters:
  ///   - code: HTTP code that was returned
  ///   - data: json data to look in for error info
  ///   - error: any error that ewas passed back by the W3WRequest class functions
  static func makeErrorIfAny(code: Int?, data: JsonVoiceError?, error: W3WError?) -> W3WError? {
    
    if let e = data {
      return W3WError.code(code ?? -1, e.message ?? "unknown")
    }
    
    return error
  }
      
}

#endif
