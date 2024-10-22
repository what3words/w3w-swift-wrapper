//
//  W3WSettings.swift
//
//
//  Created by Dave Duprey on 07/11/2022.
//

import W3WSwiftCore

extension W3WSettings {
  
  static let apiVersion  = "2.0.0"

  static let maxRecordingLength         = 4.0
  static let minVoiceSampleLength       = 2.5
  static let endOfSpeechQuietTime       = 0.75
  static let defaultSampleRate          = Int32(44100)
  static let defaulMaxAmplitude         = 0.25
  
  /// the VoiceAPI endpoint
  static let voiceApiUrl        = "wss://voiceapi.what3words.com/v1"
  static let voiceApiUploadUrl  = "https://voiceapi.what3words.com/v1/autosuggest-upload"
  static let voiceSocketPath    = "/autosuggest"
  static let voiceApiVersion    = "1.0.1"
  static let voiceHeaderKey     = "what3words-Swift"
  
}
