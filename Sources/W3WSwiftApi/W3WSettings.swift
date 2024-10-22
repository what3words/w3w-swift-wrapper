//
//  W3WSettings.swift
//  
//
//  Created by Dave Duprey on 07/11/2022.
//

import W3WSwiftCore

extension W3WSettings {
  
  static let apiUrl      = "https://api.what3words.com/v3"

  static let apiVersion  = "4.0.0"
  
  static var domains     = ["what3words.com", "w3w.io"]
    
  
  // MARK: Defaults
  
  static var defaultDebounceDelay = 0.3
  
  // MARK: Constants
  
  public static var maxMetersDiagonalForGrid = 4000.0
  
  // MARK: Audio
  
  static let maxRecordingLength         = 4.0
  static let minVoiceSampleLength       = 2.5
  static let endOfSpeechQuietTime       = 0.75
  static let defaultSampleRate          = Int32(44100)
  static let defaulMaxAmplitude         = 0.25
  
}

