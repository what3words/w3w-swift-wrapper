//
//  VoiceApi.swift
//  VoiceApiDemo
//
//  Created by Dave Duprey on 23/04/2020.
//  Copyright © 2020 What3Words. All rights reserved.
//


import Foundation
import CoreLocation


public class W3WAudioStream {

  /// the sample rate
  public var sampleRate: Int = 44100
  
  /// the audio encoding format
  public var encoding: W3WEncoding = .pcm_f32le
  
  /// callback for when the mic has new audio data
  public var sampleArrived: (UnsafeBufferPointer<Float>) -> () = { _ in }
  
  /// callback for the UI to update/animate any graphics showing microphone volume/amplitude
  public var volumeUpdate: (Double) -> () = { _ in }
  
  /// callback for when the voice recognition stopped
  public var listeningUpdate: ((W3WVoiceListeningState) -> ()) = { _ in }
  
  /// error callback
  public var onError: (W3WVoiceError) -> () = { _ in }

  /// base class for audio streaming
  public init(sampleRate: Int, encoding:W3WEncoding) {
    self.sampleRate = sampleRate
    self.encoding   = encoding
  }

  
  /// base class for audio streaming
  public init() {
  }
  

  public func add(samples: UnsafeBufferPointer<Float>) {
    sampleArrived(samples)
  }
  
  
  public func endSamples() {
  }

}
