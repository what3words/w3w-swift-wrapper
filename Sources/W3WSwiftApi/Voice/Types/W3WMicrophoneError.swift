//
//  W3WMicrophoneError.swift
//  
//
//  Created by Dave Duprey on 23/05/2023.
//

import AVFoundation


/// Error enum for microphone issues
public enum W3WMicrophoneError : Error, CustomStringConvertible {
  case noInputAvailable
  case audioSystemFailedToStart
  
  public var description : String {
    switch self {
    case .noInputAvailable:         return "No audio inputs available"
    case .audioSystemFailedToStart: return "The audio system failed to start"
    }
  }
  
}


