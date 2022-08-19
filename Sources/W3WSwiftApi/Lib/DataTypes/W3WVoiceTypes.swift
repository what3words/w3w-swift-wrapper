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
  case invalidApiKey
  case missingKey
  case suspendedKey
  case badInput
  case notFound
  case noLanguageSpecified
  
  case invalidMessage
  case invalidAudioType
  case jobError
  case dataError
  case bufferError
  case protocolError
  case unknown
  
  case platformNotSupported
  case apiDoesNotSupportVoice
  case apiError(error: W3WError)
  case voiceSocketError(error: W3WVoiceSocketError)
  case microphoneError(error: W3WMicrophoneError)

  public var description : String {
    switch self {
      case .noLanguageSpecified:  return "No language was specified"
      case .invalidApiKey:        return "Invalid API key provided"
      case .unknown:              return "Unknown voice API error"
      case .missingKey:           return "Api key was missing"
      case .suspendedKey:         return "Api key is suspended"
      case .badInput:             return "Api input was bad"
      case .notFound:             return "Not found"
        
      case .invalidMessage:       return "The message received was not understood"
      case .invalidAudioType:     return "Audio type is not supported, is deprecated, or the audio_type is malformed."
      case .jobError:             return "Unable to do any work on this request, the Server might have timed out etc"
      case .dataError:            return "Unable to accept the data specified - usually because there is too much data being sent at once."
      case .bufferError:          return "Unable to fit the data in a corresponding buffer. This can happen for clients sending the input data faster then realtime."
      case .protocolError:        return "Message received was syntactically correct, but could not be accepted due to protocol limitations. This is usually caused by messages sent in the wrong order."
        
      case .platformNotSupported: return "This API wrapper is not supported for this type of device yet"
      case .apiDoesNotSupportVoice: return "The SDK or API passed in does not support voice functionality (W3WVoice protocol)"
    
      case .apiError(error: let error):  return String(describing: error)
      case .voiceSocketError(let error): return String(describing: error)
      case .microphoneError(let error):  return String(describing: error)
    }
  }
  
}



public protocol W3WVoice {
  func autosuggest(audio: W3WAudioStream, language: String, options: [W3WOption], callback: @escaping W3WVoiceSuggestionsResponse)
  func autosuggest(audio: W3WAudioStream, language: String, options: W3WOption..., callback: @escaping W3WVoiceSuggestionsResponse)
  func autosuggest(audio: W3WAudioStream, language: String, options: W3WOptions, callback: @escaping W3WVoiceSuggestionsResponse)
}



/// helper object for decoding JSON using Codable
public struct W3WVoiceResponse : Codable {
  public let message : String?
  public let suggestions : [W3WVoiceSuggestion]?
  public let id : String?
  public let seq_no : Int?
  public let code : Int?
  public let type : String?
  public let quality : String?
  public let reason : String?
  public let error : W3WJsonVoiceError?

  enum CodingKeys: String, CodingKey {
    case message      = "message"
    case suggestions  = "suggestions"
    case id           = "id"
    case seq_no       = "seq_no"
    case code         = "code"
    case type         = "type"
    case quality      = "quality"
    case reason       = "reason"
    case error        = "error"
  }
  
  public init(from decoder: Decoder) throws {
    let values  = try decoder.container(keyedBy: CodingKeys.self)
    
    message     = try values.decodeIfPresent(String.self, forKey: .message)
    suggestions = try values.decodeIfPresent([W3WVoiceSuggestion].self, forKey: .suggestions)
    id          = try values.decodeIfPresent(String.self, forKey: .id)
    seq_no      = try values.decodeIfPresent(Int.self, forKey: .seq_no)
    code        = try values.decodeIfPresent(Int.self, forKey: .code)
    type        = try values.decodeIfPresent(String.self, forKey: .type)
    quality     = try values.decodeIfPresent(String.self, forKey: .quality)
    reason      = try values.decodeIfPresent(String.self, forKey: .reason)
    error       = try values.decodeIfPresent(W3WJsonVoiceError.self, forKey: .error)

  }
  
}


public struct W3WJsonVoiceError : Codable {
  let code : String?
  let message : String?
  
  enum CodingKeys: String, CodingKey {
    
    case code = "code"
    case message = "message"
  }
  
  public init(from decoder: Decoder) throws {
    let values = try decoder.container(keyedBy: CodingKeys.self)
    code = try values.decodeIfPresent(String.self, forKey: .code)
    message = try values.decodeIfPresent(String.self, forKey: .message)
  }
  
}

