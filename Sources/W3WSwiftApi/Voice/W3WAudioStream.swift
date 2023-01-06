//
//  VoiceApi.swift
//  VoiceApiDemo
//
//  Created by Dave Duprey on 23/04/2020.
//  Copyright © 2020 What3Words. All rights reserved.
//


import AVKit



public struct W3WSampleData {
  public let buffer: W3WSampleDataBuffer
  public let sampleRate: Int
  
  let avBuffer: AVAudioPCMBuffer?
  
  public func numberOfSamples() -> UInt {
    return buffer.numberOfSamples()
  }

  
  public func asAVAudioPCMBuffer() -> AVAudioPCMBuffer? {
    return avBuffer
  }

}


public enum W3WSampleDataBuffer {
  case pcm_f32le(UnsafeBufferPointer<Float>)
  case pcm_s16le(UnsafeBufferPointer<Int16>)
  
  public func numberOfSamples() -> UInt {
    switch self {
    case .pcm_s16le(let sample):
      return UInt(sample.count)
    case .pcm_f32le(let sample):
      return UInt(sample.count)
    }
  }
  
}


open class W3WAudioStream {

  /// the sample rate
  public var sampleRate: Int = 44100
  
  /// the audio encoding format
  public var encoding: W3WEncoding = .pcm_f32le
  
  /// callback for when the mic has new audio data
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
  

  public func add(samples: UnsafeBufferPointer<Float>) {
    sampleArrived(samples)
  }
  
  
  public func endSamples() {
  }
  
  
//  /// the sample rate
//  var sampleRate: Int { get set }
//
//  /// the sample rate
//  /// the audio encoding format
//  var encoding: W3WEncoding { get set }
//
//  /// callback for when the mic has new audio date
//  var sampleArrived: (Data) -> () { get set }
//
//  /// callback for the UI to update/animate any graphics showing microphone volume/amplitude
//  var volumeUpdate: (Double) -> () { get set }
//
//  /// callback for when the voice recognition stopped
//  var listeningUpdate: ((W3WVoiceListeningState) -> ()) { get set }
//
//  /// error callback
//  var onError: (W3WVoiceError) -> () { get set }
}


//public class W3WAudioStream {
//  var sampleRate: Int = 44100
//  var encoding: W3WEncoding = .pcm_f32le
//
//  //var voiceApi: W3WVoiceSocket?
//  //var callback: W3WVoiceSuggestionsResponse?
//
//
//  public init(sampleRate: Int, encoding:W3WEncoding) {
//    self.sampleRate = sampleRate
//    self.encoding   = encoding
//  }
//
//
//  public func add(samples: Data) {
//    //voiceApi?.send(samples: samples)
//  }
//
//
////  public func endSamples() {
////    voiceApi?.endSamples()
////  }
//
//
////  public func close() {
////    voiceApi?.close()
////  }
//
//
//  /// configure the audiostream
////  func configure(apiKey: String, callback: @escaping W3WVoiceSuggestionsResponse) {
////    self.voiceApi   = W3WVoiceSocket(apiKey: apiKey)
////    self.callback   = callback
////
////    voiceApi?.suggestions = { suggestions in self.update(suggestions: suggestions) }
////    voiceApi?.error       = { error in self.update(error: error) }
////  }
//
//
//  /// Opens the connection to the voice API
////  public func open(sampleRate:Int, encoding:W3WEncoding = .pcm_f32le, options: [W3WOption]) {
////    voiceApi?.open(sampleRate: sampleRate, encoding: .pcm_f32le, options: options)
////  }
//
//
////  func update(suggestions: [W3WVoiceSuggestion]) {
////    callback?(suggestions, nil)
////  }
//
////  func update(error: W3WVoiceError) {
////    callback?(nil, error)
////  }
//
//
////  deinit {
////    close()
////  }
//
//
//}

