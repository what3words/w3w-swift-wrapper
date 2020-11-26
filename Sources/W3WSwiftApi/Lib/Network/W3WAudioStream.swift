//
//  VoiceApi.swift
//  VoiceApiDemo
//
//  Created by Dave Duprey on 23/04/2020.
//  Copyright © 2020 What3Words. All rights reserved.
//


//#if !os(watchOS)

import Foundation
import CoreLocation



public class W3WAudioStream {
  var sampleRate: Int = 44100
  var encoding: W3WEncoding = .pcm_f32le
  
  var voiceApi: W3WVoiceSocket?
  var callback: W3WVoiceSuggestionsResponse?
  //var completion: W3WClosedResponse?
  
  
  public init(sampleRate: Int, encoding:W3WEncoding) {
    self.sampleRate = sampleRate
    self.encoding   = encoding
  }

  
  public func add(samples: Data) {
    voiceApi?.send(samples: samples)
  }
  
  
  public func endSamples() {
    voiceApi?.endSamples()
  }
  
  
  public func close() {
    voiceApi?.close()
  }
  
  
  /// configure the audiostream
  func configure(apiKey: String, callback: @escaping W3WVoiceSuggestionsResponse) {
    self.voiceApi   = W3WVoiceSocket(apiKey: apiKey)
    self.callback   = callback
    //self.completion = completion
    
    voiceApi?.suggestions = { suggestions in self.update(suggestions: suggestions) }
    //voiceApi?.closed      = { reason in self.update(closed: reason) }
    voiceApi?.error       = { error in self.update(error: error) }
  }
  
  
  /// Opens the connection to the voice API
  public func open(sampleRate:Int, encoding:W3WEncoding = .pcm_f32le, options: [W3WOption]) {
    voiceApi?.open(sampleRate: sampleRate, encoding: .pcm_f32le, options: options)
  }
  
  
  func update(suggestions: [W3WVoiceSuggestion]) {
    callback?(suggestions, nil)
  }

  
  func update(error: W3WVoiceSocketError) {
    callback?(nil, W3WVoiceError.voiceSocketError(error: error))
  }

  
  func update(error: W3WVoiceError) {
    callback?(nil, error)
  }


  deinit {
    close()
  }

  
}


//#endif // if os(watchOS) // from top of file