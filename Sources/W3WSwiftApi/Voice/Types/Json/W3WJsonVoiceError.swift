//
//  W3WJsonVoiceError.swift
//  
//
//  Created by Dave Duprey on 31/05/2023.
//

import Foundation


/// helper object for decoding JSON from the Voice API using Codable
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
