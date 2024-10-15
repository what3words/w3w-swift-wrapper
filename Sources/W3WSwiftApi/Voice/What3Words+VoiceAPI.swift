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

#if canImport(W3WSwiftVoiceApi)
import W3WSwiftVoiceApi

#if !os(watchOS)

/// Extension to the What3Words API allowing an autosuggest accepting voice
/// this employs the W3WVoiceApi class which does the actual work and can
/// be used instead independantly
extension What3WordsV4: W3WVoiceProtocol {

  /**
   Autosuggest with option array
   Returns a list of 3 word addresses based on user input and other parameters.
   - parameter audio: An W3WAudioStream object or derivitive, typically W3WMicrophone providing audio data
   - parameter options: An array of W3WOption providing various options, see API documentation for details
   - parameter callback: A completion block providing the suggestions and any error - ([W3WVoiceSuggestion]?, W3WVoiceError?) -> Void
   */
  public func autosuggest(audio: W3WAudioStream, options: [W3WOption], callback: @escaping W3WVoiceSuggestionsResponse) {
    let voiceApi = W3WVoiceApi(apiKey: apiKey)
    voiceApi.autosuggest(audio: audio, options: options, callback: callback)
  }
  
  
  /**
   Autosuggest with varidic parameters for option
   Returns a list of 3 word addresses based on user input and other parameters.
   - parameter audio: An W3WAudioStream object or derivitive, typically W3WMicrophone providing audio data
   - parameter options: An varidic paraameter of W3WOption providing various options, see API documentation for details
   - parameter callback: A completion block providing the suggestions and any error - ([W3WVoiceSuggestion]?, W3WVoiceError?) -> Void
   */
  public func cltosuggest(audio: W3WAudioStream, options: W3WOption..., callback: @escaping W3WVoiceSuggestionsResponse) {
    let voiceApi = W3WVoiceApi(apiKey: apiKey)
    voiceApi.autosuggest(audio: audio, options: options, callback: callback)
  }
  
  
  /**
   Autosuggest accepting W3WOptions for the options
   Returns a list of 3 word addresses based on user input and other parameters.
   - parameter audio: An W3WAudioStream object or derivitive, typically W3WMicrophone providing audio data
   - parameter options: An W3WOptions() containing various options, these are constructed using the chaining pattern, see example code
   - parameter callback: A completion block providing the suggestions and any error - ([W3WVoiceSuggestion]?, W3WVoiceError?) -> Void
   */
  public func autosuggest(audio: W3WAudioStream, options: W3WOptions, callback: @escaping W3WVoiceSuggestionsResponse) {
    let voiceApi = W3WVoiceApi(apiKey: apiKey)
    voiceApi.autosuggest(audio: audio, options: options.options, callback: callback) //, completion: { _ in })
  }
  

  
  
  /**
   Autosuggest with option array
   Returns a list of 3 word addresses based on user input and other parameters.
   - parameter audio: An W3WAudioStream object or derivitive, typically W3WMicrophone providing audio data
   - parameter options: An array of W3WOption providing various options, see API documentation for details
   - parameter callback: A completion block providing the suggestions and any error - ([W3WVoiceSuggestion]?, W3WVoiceError?) -> Void
   */
  @available(*, deprecated, message: "Use W3WOption.voiceLanguage(String) option and omit language: parameter")
  public func autosuggest(audio: W3WAudioStream, language: W3WLanguage, options: [W3WOption]?, callback: @escaping W3WVoiceSuggestionsResponse) {
    let voiceApi = W3WVoiceApi(apiKey: apiKey)
    voiceApi.autosuggest(audio: audio, language: language, options: options, callback: callback)
  }


  /**
   Autosuggest with varidic parameters for option
   Returns a list of 3 word addresses based on user input and other parameters.
   - parameter audio: An W3WAudioStream object or derivitive, typically W3WMicrophone providing audio data
   - parameter options: An varidic paraameter of W3WOption providing various options, see API documentation for details
   - parameter callback: A completion block providing the suggestions and any error - ([W3WVoiceSuggestion]?, W3WVoiceError?) -> Void
   */
  @available(*, deprecated, message: "Use W3WOption.voiceLanguage(String) option and omit language: parameter")
  public func autosuggest(audio: W3WAudioStream, language: W3WLanguage, options: W3WOption..., callback: @escaping W3WVoiceSuggestionsResponse) {
    let voiceApi = W3WVoiceApi(apiKey: apiKey)
    voiceApi.autosuggest(audio: audio, language: language, options: options, callback: callback)
  }

  
  /**
   Autosuggest accepting W3WOptions for the options
   Returns a list of 3 word addresses based on user input and other parameters.
   - parameter audio: An W3WAudioStream object or derivitive, typically W3WMicrophone providing audio data
   - parameter options: An W3WOptions() containing various options, these are constructed using the chaining pattern, see example code
   - parameter callback: A completion block providing the suggestions and any error - ([W3WVoiceSuggestion]?, W3WVoiceError?) -> Void
   */
  @available(*, deprecated, message: "Use W3WOption.voiceLanguage(String) option and omit language: parameter")
  public func autosuggest(audio: W3WAudioStream, language: W3WLanguage, options: W3WOptions, callback: @escaping W3WVoiceSuggestionsResponse) {
    let voiceApi = W3WVoiceApi(apiKey: apiKey)
    voiceApi.autosuggest(audio: audio, language: language, options: options.options, callback: callback) //, completion: { _ in })
  }


  
  /**
   Retrieve a list of languages supported by VoiceAPI
   */
  public func availableVoiceLanguages(completion: @escaping W3WLanguagesResponse) {
    let voiceApi = W3WVoiceApi(apiKey: apiKey)
    voiceApi.availableVoiceLanguages(completion: completion)
  }
  
}

#endif // if os(watchOS) // from top of file
#endif //if import W3WSwiftVoiceApi
