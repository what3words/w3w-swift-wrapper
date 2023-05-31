//
//  File.swift
//  
//
//  Created by Dave Duprey on 02/11/2020.
//  Copyright © 2020 What3Words. All rights reserved.
//

import Foundation


extension W3WSettings {
  
  /// the VoiceAPI endpoint
  static let voiceApiUrl        = "wss://voiceapi.what3words.com/v1"
  
  /// the voice API endpoint for uploading a sound file
  static let voiceApiUploadUrl  = "https://voiceapi.what3words.com/v1/autosuggest-upload"
  
  /// URL path for web socket
  static let voiceSocketPath    = "/autosuggest"
  
  /// Voice API wrapper version
  static let voiceApiVersion    = "1.1.0"
  
  /// URL header to identify this wrapper code
  static let voiceHeaderKey     = "what3words-Swift"
  
}
