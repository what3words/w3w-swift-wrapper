//
//  VoiceApi.swift
//  VoiceApiDemo
//
//  Created by Dave Duprey on 23/04/2020.
//  Copyright © 2020 What3Words. All rights reserved.
//


import Foundation
import CoreLocation
#if canImport(UIKit)
import UIKit
#endif
import W3WSwiftCore


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


#if !os(watchOS)

public class W3WVoiceSocket {
  
  // MARK: Variables
  
  /// the VoiceAPI endpoint
  let endpoint = W3WSettings.voiceApiUrl + W3WSettings.voiceSocketPath
  
  /// the VoiceAPI API key
  var key = "<Your API Key>"
  
  /// default language
  var language = W3WSettings.defaultLanguage
  
  /// Socket session
  var socket: W3WebSocket?
  
  /// we need to count the number of data packages sent for the endSamples() function
  var sequenceNumber = 0
  
  var id: String?
  var quality: String?
  
  private var version_header = W3WSettings.voiceHeaderKey + "/x.x.x (Swift x.x.x; iOS x.x.x)"
  private var bundle_header  = ""

  // MARK: Callbacks
  
  /// a callback block for when recognition is complete
  public var suggestions: ([W3WVoiceSuggestion]) -> () = { _ in }
  //public var received: (String) -> () = { _ in }
  
  /// a callback block for when an error happens
  //public var closed: (String?, String?) -> () = { _,_ in }
  
  /// a callback block for when an error happens
  public var error: (W3WError) -> () = { _ in }
  
  
  // MARK: Initialization
  
  
  /// init with the API key for the voice service
  public init(apiKey: String) {
    key = apiKey
    figureOutVersions()
  }
  
  
  // MARK: Open and Close Socket

  
  public func open(sampleRate:Int, encoding:W3WEncoding = .pcm_f32le, options: W3WOption...) {
    open(sampleRate:sampleRate, encoding:encoding, options: options)
  }
  
  
  public func open(sampleRate:Int, encoding:W3WEncoding = .pcm_f32le, options: [W3WOption]?) {
    // don't allow socket to be opened if it is already in use
    if socket != nil {
      error(W3WError.voiceSocketError(error: W3WVoiceSocketError.socketAlreadyOpen))
      
      // we are good to go
    } else {
      
      // Build the URL for the call begining with the api key and including all the AutoSuggest paramters, and use that to initialze the socket
      var urlString = endpoint + "?key=\(key)"
      
      for option in options ?? [] {
        urlString += "&" + option.key() + "=" + option.asString()
      }
      
      let headers = [
        "X-Ios-Bundle-Identifier": bundle_header,
        "X-W3W-Wrapper": version_header,
      ]
      
      socket = W3WebSocket(urlString, headers: headers)
      
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
        self.error(W3WError.voiceSocketError(error: W3WVoiceSocketError.socketCreationError))
      }
    }
  }

  
  func ended(_ code : Int, _ reason : String, _ wasClean : Bool, _ error : Error?) {

    if code != 1000 {
      if let data = reason.data(using: .utf8) {
        if let jsonData = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
          if let reasonCode = jsonData["code"] as? String, let message = jsonData["message"] as? String {
            update(close: reasonCode, message: message)
          }
        } else {
          self.error(W3WError.voiceSocketError(code: code, error: W3WVoiceSocketError.message(message: reason)))
        }
      }
    }
  }
  
  
  
  func update(close code: String?, message: String?) {
    if let c = code {
      switch c {
      case "InvalidKey":
        self.error(W3WError.invalidApiKey)
      case "MissingKey":
        self.error(W3WError.missingKey)
      case "SuspendedKey":
        self.error(W3WError.suspendedKey)
      case "BadInput":
        self.error(W3WError.badInput)
      case "NotFound":
        self.error(W3WError.notFound)
      default:
        self.error(W3WError.invalidApiKey)
      }
    }
  }
  
  
  func errored(_ error: W3WWebSocketError) {
    self.error(W3WError.voiceSocketError(error: W3WVoiceSocketError.socketError(error: error)))
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
      self.error(W3WError.voiceSocketError(error: W3WVoiceSocketError.attemptToSendOnCLosedSocket))
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
      error(W3WError.voiceSocketError(error: W3WVoiceSocketError.serverReturnedUnexpectedData))
      
    default:
      error(W3WError.voiceSocketError(error: W3WVoiceSocketError.serverReturnedUnexpectedType))
    }
  }
  
  
  /// tell the server that we are not going to send anymore audio
  public func endSamples() {
    socket?.send(text: "{\"message\":\"EndOfStream\",\"last_seq_no\":\(sequenceNumber)}")
  }
  
  
  /// parse with incoming json, and send suggestions to whomever is interested
  private func recieved(text: String) {
    let jsonDecoder = JSONDecoder()
    
    // try and get suggestions out of this
    if let responseJson = try? jsonDecoder.decode(JsonVoiceResponse.self, from: text.data(using: .utf8)!) {
      
      switch responseJson.message {
      
      case "Suggestions":
        if let suggestions = responseJson.suggestions {
          self.suggestions(toVoiceSuggestions(from: suggestions))
        }
        
      case "RecognitionStarted":
        if let id = responseJson.id {
          self.id = id
        }
        
      case "AudioAdded":
        if let sequenceNumber = responseJson.seq_no {
          self.sequenceNumber = sequenceNumber
        }
        
      case "Info":
        if let type = responseJson.type, let quality = responseJson.quality {  // , let _ = responseJson.reason
          if type == "recognition_quality" {
            self.quality = quality
          }
        }
        
      case "Error":
        if let type = responseJson.type {  // , let _ = responseJson.code, let _ = responseJson.reason
          switch type {
            case "invalid_message":
              error(W3WError.invalidMessage)
            case "invalid_audio_type":
              error(W3WError.invalidAudioType)
            case "job_error":
              error(W3WError.jobError)
            case "data_error":
              error(W3WError.dataError)
            case "buffer_error":
              error(W3WError.bufferError)
            case "protocol_error":
              error(W3WError.protocolError)
            default:
              error(W3WError.unknown)
          }
        }
        
      case "W3WError":
        if let code = Int(responseJson.error?.code ?? "-1") {
          error(W3WError.code(code, responseJson.error?.message ?? "unknown"))
        }
          
          
          //error(W3WError.apiError(error: W3WError.unknownErrorCodeFromServer))
        
      default:
        print("Unknonw message from server, update API code")
      }
    }
  }
  
  
  func toVoiceSuggestions(from: [JsonVoiceSuggestion]?) -> [W3WVoiceSuggestion] {
    var suggestions = [W3WVoiceSuggestion]()
    
    for suggestion in from ?? [] {
      suggestions.append(W3WVoiceSuggestion(jsonVoiceSuggestion: suggestion))
    }
    
    return suggestions
  }

  
  // Establish the various version numbers in order to set an HTTP header for the URL session
  // ugly, but haven't found a better, way, if anyone knows a better way to get the swift version at runtime, let us know...
  private func figureOutVersions() {
    #if os(macOS)
    let os_name        = "Mac"
    #elseif os(watchOS)
    let os_name        = WKInterfaceDevice.current().systemName
    #else
    let os_name        = UIDevice.current.systemName
    #endif
    let os_version     = ProcessInfo().operatingSystemVersion
    var swift_version  = "x.x"
    //var api_version    = "x.x.x"
    
    #if swift(>=7)
    swift_version = "7.x"
    #elseif swift(>=6)
    swift_version = "6.x"
    #elseif swift(>=5)
    swift_version = "5.x"
    #elseif swift(>=4)
    swift_version = "4.x"
    #elseif swift(>=3)
    swift_version = "3.x"
    #elseif swift(>=2)
    swift_version = "2.x"
    #else
    swift_version = "1.x"
    #endif
    
    version_header  = W3WSettings.voiceHeaderKey + "/" + W3WSettings.voiceApiVersion + " (Swift " + swift_version + "; " + os_name + " "  + String(os_version.majorVersion) + "."  + String(os_version.minorVersion) + "."  + String(os_version.patchVersion) + ")"
    bundle_header   = Bundle.main.bundleIdentifier ?? ""
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
  public var error: (W3WError) -> () = { _ in }

  /// init with the API key for the voice service
  public init(apiKey: String) {
    key = apiKey
  }
  
  public func open(sampleRate:Int, encoding:W3WEncoding = .pcm_f32le, options: [W3WOption]) {
    error(W3WError.platformNotSupported)
  }
  
  /// send a block of 32 bit floating point audio sample data
  public func send(samples: Data) {
    error(W3WError.platformNotSupported)
  }
  
  public func endSamples() {
    error(W3WError.platformNotSupported)
  }

  public func close() {
  }
  
}

#endif // if os(watchOS) // from top of file
