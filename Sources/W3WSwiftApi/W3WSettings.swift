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
  
}

