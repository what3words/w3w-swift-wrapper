//
//  File.swift
//  
//
//  Created by Dave Duprey on 30/10/2020.
//  Copyright © 2020 What3Words. All rights reserved.
//

import Foundation
import CoreLocation



public typealias W3WVoiceSuggestionsResponse     = ((_ result: [W3WVoiceSuggestion]?, _ error: W3WVoiceError?) -> Void)


public enum W3WVoiceError : Error, CustomStringConvertible {
  case noLanguageSpecified
  case voiceSocketError(error: W3WVoiceSocketError)
  case microphoneError(error: W3WMicrophoneError)
  
  public var description : String {
    switch self {
      case .noLanguageSpecified:        return "No language was specified"
      case .voiceSocketError(let error):   return String(describing: error)
      case .microphoneError(let error): return String(describing: error)
    }
  }
  
}



public protocol W3WVoice {
  func autosuggest(audio: W3WAudioStream, language: String, options: [W3WOption], callback: @escaping W3WVoiceSuggestionsResponse)
  func autosuggest(audio: W3WAudioStream, language: String, options: W3WOption..., callback: @escaping W3WVoiceSuggestionsResponse)
  func autosuggest(audio: W3WAudioStream, language: String, options: W3WOptions, callback: @escaping W3WVoiceSuggestionsResponse)
}



/// helper object for decoding JSON using Codable
public struct W3WVoiceSuggestions : Codable {
  public let message : String?
  public let suggestions : [W3WVoiceSuggestion]?
  
  enum CodingKeys: String, CodingKey {
    
    case message = "message"
    case suggestions = "suggestions"
  }
  
  public init(from decoder: Decoder) throws {
    let values = try decoder.container(keyedBy: CodingKeys.self)
    message = try values.decodeIfPresent(String.self, forKey: .message)
    suggestions = try values.decodeIfPresent([W3WVoiceSuggestion].self, forKey: .suggestions)
  }
  
}


///// helper object for decoding JSON using Codable
//struct W3WVoiceSuggestions : Codable {
//  let message : String?
//  let suggestions : [W3WVoiceSuggestion]?
//
//  enum CodingKeys: String, CodingKey {
//
//    case message = "message"
//    case suggestions = "suggestions"
//  }
//
//  init(from decoder: Decoder) throws {
//    let values = try decoder.container(keyedBy: CodingKeys.self)
//    message = try values.decodeIfPresent(String.self, forKey: .message)
//    suggestions = try values.decodeIfPresent([W3WVoiceSuggestion].self, forKey: .suggestions)
//  }
//
//}
