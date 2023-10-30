//
//  File.swift
//  
//
//  Created by Dave Duprey on 07/11/2022.
//

import W3WSwiftCore


public extension W3WError {
  
  static func url(code: Int? = nil, message: String? = nil) -> W3WError {
    if let c = code {
      return .code(c, message ?? "")
    } else if let m = message {
      return .message(m)
    } else {
      return .unknown
    }
  }
  
  
  // MARK: Voice API error convenience
  
  static func voiceSocketError(code: Int? = nil, error: W3WError) -> W3WError {
    return W3WError.code(code ?? -1, error.description)
  }
  
  static let noLanguageSpecified = W3WError.message("No language was specified")
  static let invalidApiKey       = W3WError.message("Invalid API key provided")
  static let missingKey          = W3WError.message("Api key was missing")
  static let suspendedKey        = W3WError.message("Api key is suspended")
  static let badInput            = W3WError.message("Api input was bad")
  static let notFound            = W3WError.message("Not found")
  static let invalidMessage      = W3WError.message("The message received was not understood")
  static let invalidAudioType     = W3WError.message("Audio type is not supported, is deprecated, or the audio_type is malformed.")
  static let jobError               = W3WError.message("Unable to do any work on this request, the Server might have timed out etc")
  static let dataError                = W3WError.message("Unable to accept the data specified - usually because there is too much data being sent at once.")
  static let bufferError                = W3WError.message("Unable to fit the data in a corresponding buffer. This can happen for clients sending the input data faster then realtime.")
  static let protocolError               = W3WError.message("Message received was syntactically correct, but could not be accepted due to protocol limitations. This is usually caused by messages sent in the wrong order.")
  static let platformNotSupported          = W3WError.message("This API wrapper is not supported for this type of device yet")
  static let apiDoesNotSupportVoice         = W3WError.message("The SDK or API passed in does not support voice functionality (W3WVoice protocol)")
  static let invalidResponseFromVoiceServer = W3WError.message("Invalid response from voice server")
  static let badConnectionToVoiceServer    = W3WError.message("Couldn't connect to server")
  
}



//public enum W3WApiError : Error {
//  
//  // API Errors
//  case badWords(String)
//  case badCoordinates(String)
//  case badLanguage(String)
//  case badFormat(String)
//  case badClipToPolygon(String)
//  case badBoundingBoxTooBig(String)
//  case badClipToCountry(String)
//  case badInput(String)
//  case badNResults(String)
//  case badNFocusResults(String)
//  case badFocus(String)
//  case badClipToCircle(String)
//  case badClipToBoundingBox(String)
//  case badInputType(String)
//  case badBoundingBox(String)
//  case missingLanguage(String)
//  case missingWords(String)
//  case missingInput(String)
//  case missingBoundingBox(String)
//  case duplicateParameter(String)
//  case missingKey(String)
//  case invalidKey(String)
//  case suspendedKey(String)
//  case invalidApiVersion(String)
//  case invalidReferrer(String)
//  case invalidIpAddress(String)
//  case invalidAppCredentials(String)
//  
//  // Communication Errors
//  case unknownErrorCodeFromServer(String)
//  case notFound404(String)
//  case badConnection(String)
//  case badJson(String)
//  case invalidResponse(String)
//  case socketError(error: W3WWebSocketError)
//  
//  // Other Errors
//  case other(W3WError)
//  case sdkError(error: Error & CustomStringConvertible)
//  case message(String)
//  case unknown
//  
//  public var description : String {
//    switch self {
//    case .badWords(let message):            return message
//    case .badCoordinates(let message):      return message
//    case .badLanguage(let message):         return message
//    case .missingLanguage(let message):     return message
//    case .badFormat(let message):           return message
//    case .badClipToPolygon(let message):    return message
//    case .badBoundingBoxTooBig(let message):return message
//    case .badConnection(let message):       return message
//    case .badJson(let message):             return message
//    case .suspendedKey(let message):        return message
//    case .invalidApiVersion(let message):    return message
//    case .invalidReferrer(let message):       return message
//    case .invalidIpAddress(let message):       return message
//    case .invalidAppCredentials(let message):  return message
//    case .badClipToCountry(let message):       return message
//    case .badInput(let message):              return message
//    case .badNResults(let message):          return message
//    case .badNFocusResults(let message):    return message
//    case .badFocus(let message):            return message
//    case .badClipToCircle(let message):     return message
//    case .badClipToBoundingBox(let message):return message
//    case .badInputType(let message):        return message
//    case .badBoundingBox(let message):      return message
//    case .missingWords(let message):        return message
//    case .missingInput(let message):        return message
//    case .missingBoundingBox(let message):  return message
//    case .missingKey(let message):          return message
//    case .invalidKey(let message):          return message
//    case .notFound404(let message):          return message
//    case .duplicateParameter(let message):      return message
//    case .invalidResponse(let message):           return message
//    case .unknownErrorCodeFromServer(let message): return message
//    case .socketError(let error):                  return String(describing: error)
//    case .sdkError(let error):                    return String(describing: error)
//    case .other(let error):                      return String(describing: error)
//    case .unknown:                              return "Unknown Error"
//    case .message(let message):                return message
//    }
//  }
//  
//}
