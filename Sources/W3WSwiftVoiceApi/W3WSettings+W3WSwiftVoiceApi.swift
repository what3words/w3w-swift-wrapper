//
//  W3WSettings.swift
//
//
//  Created by Dave Duprey on 07/11/2022.
//

//#if W3WSwiftVoiceApi

import W3WSwiftCore

extension W3WSettings {
  
  static let apiVersion  = "2.0.0"

  static let max_recording_length       = 4.0
  static let min_voice_sample_length    = 2.5
  static let end_of_speech_quiet_time   = 0.75
  static let defaultSampleRate          = Int32(44100)
  static let defaulMaxAmplitude         = 0.25
  
  /// the VoiceAPI endpoint
  static let voiceApiUrl        = "wss://voiceapi.what3words.com/v1"
  //static let voiceApiUrlHttps   = "https://voiceapi.what3words.com/v1"
  static let voiceApiUploadUrl  = "https://voiceapi.what3words.com/v1/autosuggest-upload"
  static let voiceSocketPath    = "/autosuggest"
  static let voiceApiVersion    = "1.0.1"
  static let voiceHeaderKey     = "what3words-Swift"

  
}
//#endif
