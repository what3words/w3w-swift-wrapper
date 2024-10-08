//
//  File.swift
//
//
//  Created by Dave Duprey on 07/11/2022.
//

import W3WSwiftCore


public extension W3WError {

  // MARK: Voice API error convenience
  
  static func voiceSocketError(code: Int? = nil, error: W3WVoiceSocketError) -> W3WError {
    return W3WError.code(code ?? -1, error.description)
  }
  
  
  static let noLanguageSpecified = W3WError.message("No language was specified")
  static let invalidApiKey       = W3WError.message("Invalid API key provided")
  static let missingKey          = W3WError.message("Api key was missing")
  static let suspendedKey        = W3WError.message("Api key is suspended")
  static let badInput            = W3WError.message("Api input was bad")
  static let notFound            = W3WError.message("Not found")
  
  static let invalidMessage       = W3WError.message("The message received was not understood")
  static let invalidAudioType      = W3WError.message("Audio type is not supported, is deprecated, or the audio_type is malformed.")
  static let jobError               = W3WError.message("Unable to do any work on this request, the Server might have timed out etc")
  static let dataError               = W3WError.message("Unable to accept the data specified - usually because there is too much data being sent at once.")
  static let bufferError              = W3WError.message("Unable to fit the data in a corresponding buffer. This can happen for clients sending the input data faster then realtime.")
  static let protocolError              = W3WError.message("Message received was syntactically correct, but could not be accepted due to protocol limitations. This is usually caused by messages sent in the wrong order.")
  
  static let platformNotSupported         = W3WError.message("This API wrapper is not supported for this type of device yet")
  static let apiDoesNotSupportVoice        = W3WError.message("The SDK or API passed in does not support voice functionality (W3WVoice protocol)")
  static let badConnectionToVoiceServer     = W3WError.message("Couldn't connect to server")
  static let invalidResponseFromVoiceServer = W3WError.message("Invalid response from voice server")

  // Microphone
  
  static let noInputAvailable              = W3WError.message("No audio inputs available")
  static let audioSystemFailedToStart      = W3WError.message("The audio system failed to start")

  
}
