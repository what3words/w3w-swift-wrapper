//
//  W3WVoiceResponse.swift
//  
//
//  Created by Dave Duprey on 04/04/2023.
//

import Foundation
import W3WSwiftCore


// TODO: rename this to JsonVoiceResponse

/// helper object for decoding JSON using Codable
public struct JsonVoiceResponse : Codable {
  public let message : String?
  public let suggestions : [JsonVoiceSuggestion]?
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
    suggestions = try values.decodeIfPresent([JsonVoiceSuggestion].self, forKey: .suggestions)
    id          = try values.decodeIfPresent(String.self, forKey: .id)
    seq_no      = try values.decodeIfPresent(Int.self, forKey: .seq_no)
    code        = try values.decodeIfPresent(Int.self, forKey: .code)
    type        = try values.decodeIfPresent(String.self, forKey: .type)
    quality     = try values.decodeIfPresent(String.self, forKey: .quality)
    reason      = try values.decodeIfPresent(String.self, forKey: .reason)
    error       = try values.decodeIfPresent(W3WJsonVoiceError.self, forKey: .error)
    
  }
  
}
