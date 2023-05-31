//
//  W3WVoiceSocketError.swift
//  
//
//  Created by Dave Duprey on 23/05/2023.
//

import Foundation


/// Error enum for voice socket issues
public enum W3WVoiceSocketError : Error, CustomStringConvertible {
  case socketAlreadyOpen
  case socketCreationError
  case attemptToSendOnCLosedSocket
  case serverReturnedUnexpectedData
  case serverReturnedUnexpectedType
  case notFound404
  case other(error: Error)
  case message(message: String)
  case unknown
  case socketError(error: W3WWebSocketError)
  
  public var description : String {
    switch self {
    case .socketAlreadyOpen:             return "Socket was already open when open() was called"
    case .socketCreationError:           return "Error opening the socket to the server"
    case .attemptToSendOnCLosedSocket:   return "send() was called, but the socket has already been closed"
    case .serverReturnedUnexpectedData:  return "The server returned an unrecognized result"
    case .serverReturnedUnexpectedType:  return "The server returned unrecognized data types"
    case .notFound404:                   return "404 error.  The URL to the voice API is incorrect"
    case .other(let error):              return error.localizedDescription
    case .message(let message):          return message
    case .unknown:                       return "Unknown error"
    case .socketError(let error):        return String(describing: error)
    }
  }
  
  
}
