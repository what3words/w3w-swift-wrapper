//
//  VoiceApi.swift
//  VoiceApiDemo
//
//  Created by Dave Duprey on 23/04/2020.
//  Copyright © 2020 What3Words. All rights reserved.
//


import Foundation
import CoreLocation



public enum W3WVoiceSocketError : Error, CustomStringConvertible {
  case socketAlreadyOpen
  case socketCreationError
  case invalidApiKey
  case attemptToSendOnCLosedSocket
  case serverReturnedUnexpectedData
  case serverReturnedUnexpectedType
  case notFound404
  case other(error: Error)
  case unknown
  case socketError(error: W3WWebSocketError)
  
  public var description : String {
    switch self {
      case .socketAlreadyOpen:             return "Socket was already open when open() was called"
      case .socketCreationError:           return "Error opening the socket to the server"
      case .invalidApiKey:                 return "Invalid API key provided"
      case .attemptToSendOnCLosedSocket:   return "send() was called, but the socket has already been closed"
      case .serverReturnedUnexpectedData:  return "The server returned an unrecognized result"
      case .serverReturnedUnexpectedType:  return "The server returned unrecognized data types"
      case .notFound404:                   return "404 error.  The URL to the voice API is incorrect"
      case .other(let error):              return error.localizedDescription
      case .unknown:                       return "Unknown error"
      case .socketError(let error):        return String(describing: error)
    }
  }

  
}


#if !os(watchOS)

public class W3WVoiceSocket {
  
  // MARK: Variables
  
  /// the VoiceAPI endpoint
  let endpoint = W3WSettings.voiceApiUrl + W3WSettings.voiceSocketPath
  
  /// the VoiceAPI API key
  var key = "<Your API Key>"
  
  /// default language
  var language           = "en"
  
  /// Socket session
  var socket: W3WebSocket?
  
  /// we need to count the number of data packages sent for the endSamples() function
  var sequenceNumber = 0
  
  // MARK: Callbacks
  
  /// a callback block for when recognition is complete
  public var suggestions: ([W3WVoiceSuggestion]) -> () = { _ in }
  
  /// a callback block for when an error happens
  //public var closed: (W3WCloseCondition) -> () = { _ in }
  
  /// a callback block for when an error happens
  public var error: (W3WVoiceSocketError) -> () = { _ in }
  
  
  // MARK: Initialization
  
  
  /// init with the API key for the voice service
  public init(apiKey: String) {
    key = apiKey
  }
  
  
  // MARK: Open and Close Socket

  
  public func open(sampleRate:Int, encoding:W3WEncoding = .pcm_f32le, options: W3WOption...) {
    open(sampleRate:sampleRate, encoding:encoding, options: options)
  }
  
  
  public func open(sampleRate:Int, encoding:W3WEncoding = .pcm_f32le, options: [W3WOption]) {
    // don't allow socket to be opened if it is already in use
    if socket != nil {
      error(W3WVoiceSocketError.socketAlreadyOpen)
      
      // we are good to go
    } else {
      
      // Build the URL for the call begining with the api key and including all the AutoSuggest paramters, and use that to initialze the socket
      var urlString = endpoint + "?key=\(key)"
      
      for option in options {
        urlString += "&" + option.key() + "=" + option.asString()
      }
      
      socket = W3WebSocket(urlString)
      
      // configure callback events and send the handshake
      if let s = socket {
        // Assign some websocket events to member functions
        //s.event.close   = { code, reason, clean in self.closed(W3WCloseCondition(code: code)) }
        s.event.error   = { error in self.errored(error) }
        s.event.message = { message in self.recieved(message: message) }
        s.event.open    = { }
        s.event.pong    = { data in print("PONG", data) }
        s.event.end     = { code, reason, clean, error in self.ended(code, reason, clean, error) }
        
        // send server the audio parameters with the initial message
        let handshakeMessage = "{\"message\": \"StartRecognition\", \"audio_format\": { \"type\": \"raw\", \"encoding\": \"\(encoding)\", \"sample_rate\": \(sampleRate) } }"
        socket?.send(text: handshakeMessage)
        
        // socket failed
      } else {
        self.error(W3WVoiceSocketError.socketCreationError)
      }
    }
  }

  
  func ended(_ code : Int, _ reason : String, _ wasClean : Bool, _ error : Error?) {

    if code != 1000 {
      if let data = reason.data(using: .utf8) {
        if let jsonData = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
          if let reasonCode = jsonData["code"] as? String {
            switch reasonCode {
            case "InvalidKey":
              self.error(W3WVoiceSocketError.invalidApiKey)
            default:
              print("unknown error code")
            }
          }
        } else {
          switch code {
            case 1001: self.error(W3WVoiceSocketError.socketError(error: .protocolError("Going Away")))
            case 1002: self.error(W3WVoiceSocketError.socketError(error: .protocolError("Protocol Error")))
            case 1003: self.error(W3WVoiceSocketError.socketError(error: .protocolError("Protocol Error: Unhandled Type")))
            case 1005: self.error(W3WVoiceSocketError.socketError(error: .protocolError("No Status received")))
            case 1006: self.error(W3WVoiceSocketError.socketError(error: .network(error?.localizedDescription ?? "Abnormal Socket Closure")))
            case 1007: self.error(W3WVoiceSocketError.socketError(error: .payloadError(error?.localizedDescription ?? "Encoding Error")))
            case 1008: self.error(W3WVoiceSocketError.socketError(error: .protocolError("Policy violation")))
            case 1009: self.error(W3WVoiceSocketError.socketError(error: .payloadError("Message Too Big")))
            default:
              if let e = error {
                self.error(W3WVoiceSocketError.socketError(error: .protocolError(e.localizedDescription)))
              } else {
                self.error(W3WVoiceSocketError.unknown)
              }
          }
        }
      }
    }
  }
  
  func errored(_ error: W3WWebSocketError) {
    self.error(W3WVoiceSocketError.socketError(error: error))
  }
    
  
  /// close the socket
  public func close() {
    socket?.close()
    socket = nil
  }
  
  
  
  // MARK: Send and Recieve
  
  
  /// send a block of 32 bit floating point audio sample data
  public func send(samples: Data) {
    
    if let s = socket {
      s.send(samples)
    }
      
    // if the socket isn't there
    else {
      self.error(W3WVoiceSocketError.attemptToSendOnCLosedSocket)
    }
  }
  
  
  
  /// All incoming websocket messages come through here
  ///   - parameter message: the message from the socket
  private func recieved(message: Any) {
    
    //print(message)

    switch message {
    case is String:
      self.recieved(text: message as! String)  // inform the caller that a message came in.
      
    case is Data:
      error(W3WVoiceSocketError.serverReturnedUnexpectedData)
      
    default:
      error(W3WVoiceSocketError.serverReturnedUnexpectedType)
    }
  }
  
  
  /// tell the server that we are not going to send anymore audio
  public func endSamples() {
    socket?.send(text: "{\"message\":\"EndOfStream\",\"last_seq_no\":\(sequenceNumber)}")
  }
  
  
  /// parse with incoming json, and send suggestions to whomever is interested
  private func recieved(text:String) {
    let jsonDecoder = JSONDecoder()
    if let suggestionsJSON = try? jsonDecoder.decode(W3WVoiceSuggestions.self, from: text.data(using: .utf8)!) {
      if let suggestions = suggestionsJSON.suggestions {
        self.suggestions(suggestions)
      }
    }
  }
  
}


#else // if we are compiling for watchOS, then we make a dummy class.  We could include watchOS compatibility in future if Apple ever allows full WebSockets on watchOS


public class W3WVoiceSocket {
  
  /// the VoiceAPI API key
  var key = ""

  // MARK: Callbacks
  
  /// a callback block for when recognition is complete
  public var suggestions: ([W3WVoiceSuggestion]) -> () = { _ in }
  
  /// a callback block for when an error happens
  public var closed: (String) -> () = { _ in }
  
  /// a callback block for when an error happens
  public var error: (W3WVoiceSocketError) -> () = { _ in }

  /// init with the API key for the voice service
  public init(apiKey: String) {
    key = apiKey
  }
  
  public func open(sampleRate:Int, encoding:W3WEncoding = .pcm_f32le, options: [W3WOption]) {
    error(W3WVoiceSocketError.socketCreationError)
  }
  
  /// send a block of 32 bit floating point audio sample data
  public func send(samples: Data) {
    assertionFailure("watchOS not yet supported")
  }
  
  public func endSamples() {
    assertionFailure("watchOS not yet supported")
  }

  public func close() {
  }
  
}

#endif // if os(watchOS) // from top of file
