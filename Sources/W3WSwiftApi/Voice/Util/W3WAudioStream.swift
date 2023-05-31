//
//  VoiceApi.swift
//  VoiceApiDemo
//
//  Created by Dave Duprey on 23/04/2020.
//  Copyright © 2020 What3Words. All rights reserved.
//


import AVKit


open class W3WAudioStream {
  
  /// the sample rate
  public var sampleRate: Int = 44100
  
  /// the audio encoding format
  public var encoding: W3WEncoding = .pcm_f32le
  
  /// callback for when the mic has new audio data
  // will be depricated: @available(*, deprecated, message: "Use onSamples instead which returns a W3WSampleData type")
  public var sampleArrived: (UnsafeBufferPointer<Float>) -> () = { _ in }
  
  /// expermental new callback for multi-format buffers
  public var onSamples: (W3WSampleData) -> () = { _ in }
  
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
  
  
  /// add float samples to the stream
  /// - parameter samples: pointer to Float samples
  public func add(samples: UnsafeBufferPointer<Float>) {
    sampleArrived(samples)
    add(samples: W3WSampleData(pointer: samples, sampleRate: UInt(sampleRate)))
  }
  
  
  /// add ios avAudio samples to the stream
  /// - parameter samples: ios audio buffer samples
  public func add(samples: AVAudioPCMBuffer) {
    add(samples: W3WSampleData(buffer: samples))
  }
  
  
  /// add w3w sampledata to the stream
  /// - parameter samples: w3w sample data struct
  public func add(samples: W3WSampleData) {
    onSamples(samples)
    
    // for backwards compatibility
    if encoding == .pcm_f32le {
      if let buffer = samples.float32Buffer {
        sampleArrived(buffer)
      }
    }
  }
  
  
  /// tells system samples will be ending
  public func endSamples() {
  }
  

  
}
