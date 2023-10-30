//
//  File.swift
//  
//
//  Created by Dave Duprey on 04/04/2023.
//

import Foundation

// TODO: rename this to JsonVoiceError

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

