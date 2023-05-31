//
//  Microphone.swift
//  SpeechmaticsDemo
//
//  Created by Dave Duprey on 22/10/2019.
//  Copyright © 2019 What3Words. All rights reserved.
//

import Foundation
import AVFoundation



/// Manages the device microphone
@available(watchOS 4.0, tvOS 11.0, *)
open class W3WMicrophone: W3WAudioStream {
  
  /// CoreAudio interface
  private var audioEngine: AVAudioEngine!
  
  /// handle to a microphone
  private var mic: AVAudioInputNode!
  
  /// keep track as to whether 'mic' has been connected to the audio system
  private var audioIsTapped = false
  
  /// a current amplitude
  public var amplitude = 0.0
  
  /// the maximum amplitude so far
  public var maxAmplitude = W3WSettings.defaulMaxAmplitude
  
  /// the minimum amplitude so far
  public var minAmplitude = 0.0
  
  /// the smallest "max" volume for the amplitude normalization function
  private static let smallestMaxVolume = 0.25

  
  // MARK: Initialization

  override public init() {
    super.init()
    configure()
  }
  
  
  /// Represents the device mirophone
  /// - paramter sampleRate: The sample rate (Hz) to request the microphone use
  /// - paramter encoding: The sample type - Int16 or Float32
  override public init(sampleRate: Int, encoding: W3WEncoding) {
    super.init(sampleRate: sampleRate, encoding: encoding)
    configure()
  }

    
  func configure() {
    audioEngine = AVAudioEngine()
    mic = audioEngine.inputNode
    
    do {
      #if canImport(UIKit)
      try AVAudioSession.sharedInstance().setCategory(.record)
      try AVAudioSession.sharedInstance().setActive(true)
      #endif
    } catch {
      print("Error using microphone")
    }
  }
  
  
  
  
  // MARK: Accessors
  
  /// get the current sample rate from the mic
  public func getSampleRate() -> Int {
    return Int(mic.inputFormat(forBus: 0).sampleRate)
  }

  /// set the sample rate to record at
  /// - Parameters:
  ///     - sampleRate: the requested sample rate
  /// - Returns: boolean indicates if it successully changed the sample rate
  public func set(sampleRate: Int) -> Bool {
    #if !os(watchOS) && !os(macOS)
    try? AVAudioSession.sharedInstance().setPreferredSampleRate(Double(sampleRate))
    #endif

    // figure out if the sample rate was changed and signal that back
    let newRate = self.getSampleRate()
    if newRate == sampleRate {
      self.sampleRate = newRate
      return true
    } else {
      return false
    }
  }
  
  /// returns whether the mic is live or idle
  public func isRecording() -> Bool {
    return audioIsTapped
  }
  
  
  /// indicates if there is an available microphone
  public func isMicrophoneAvailable() -> Bool {
    return (mic.inputFormat(forBus: 0).channelCount > 0)
  }

  
  /// indicates if the microphone is available
  public func isInputAvailable() -> Bool {
    if mic.inputFormat(forBus: 0).sampleRate != 0 {
      return true
    } else {
      return false
    }
  }
  
  
  // MARK: start() stop()
  
  /// start the mic recording
  public func start() {
    start(convertingToSampleRate: sampleRate)
  }
  
  
  /// start the mic recording, and return the data converted to a custom sampleRate
  @available(macOS 10.11, *)
  public func start(convertingToSampleRate: Int) {
    
    var outputFormat: AVAudioFormat!
    
    if encoding == .pcm_s16le {
      outputFormat = AVAudioFormat(commonFormat: .pcmFormatInt16, sampleRate: Double(convertingToSampleRate), channels: 1, interleaved: false)!
    } else {
      outputFormat = AVAudioFormat(commonFormat: .pcmFormatFloat32, sampleRate: Double(convertingToSampleRate), channels: 1, interleaved: false)!
    }

    let micFormat    = mic.inputFormat(forBus: 0)
    if let converter    = AVAudioConverter(from: micFormat, to: outputFormat) {
      
      if (audioIsTapped == false) {
        audioIsTapped = true
        
        listeningUpdate(.started)
        
        mic.installTap(onBus: 0, bufferSize: 2048, format: micFormat) { (buffer, time) in
          
          let convertedBuffer = AVAudioPCMBuffer(pcmFormat: outputFormat, frameCapacity: AVAudioFrameCount(outputFormat.sampleRate) * buffer.frameLength / AVAudioFrameCount(buffer.format.sampleRate))!
          
          var error: NSError? = nil
          let status = converter.convert(to: convertedBuffer, error: &error) { inNumPackets, outStatus in
            outStatus.pointee = AVAudioConverterInputStatus.haveData
            return buffer
          }
          
          assert(status != .error)
          
          self.micReturnedSamples(buffer: convertedBuffer, time: time)
        }
        
      } else {
        //print("Warning: microphone was started twice")
      }
      
    } else {
      onError(W3WVoiceError.microphoneError(error: W3WMicrophoneError.audioSystemFailedToStart))
    }
      
    do {
      try audioEngine.start()
    } catch {
    }
  }

    
  /// stop the mic recording
  public func stop() {
    audioEngine.stop()
    audioEngine.reset()
    
    if (audioIsTapped == true) {
      audioIsTapped = false
      mic.removeTap(onBus: 0)
    }

    listeningUpdate(.stopped)
  }
  
  
  // MARK: Events
  
  /// called when there are new data from the microphone
  private func micReturnedSamples(buffer: AVAudioPCMBuffer, time: AVAudioTime!) {
    calulateAmplitude(buffer: buffer)
    
    let sampleData = W3WSampleData(buffer: buffer)
    onSamples(sampleData)
  }
  
  
  func calulateAmplitude(buffer: AVAudioPCMBuffer) {
    // fade the amplitude indicator quickly, but not imediately
    self.amplitude = self.amplitude * 0.3

    // if it's float data
    if encoding == .pcm_f32le {
      calculateAmplitudeFloat(buffer: buffer)
      sampleArrived(UnsafeBufferPointer(start: buffer.floatChannelData![0], count: Int(buffer.frameLength)))

    // if it's int data
    } else {
      calculateAmplitudeInt16(buffer: buffer)
    }
    
    // a code block to update amplitude for the UI;
    self.volumeUpdate(getNomralizedVolumeLevelForUI())
  }
  
  
  
  private func calculateAmplitudeInt16(buffer: AVAudioPCMBuffer) {
    let sampleDataInt16 = UnsafeBufferPointer(start: buffer.int16ChannelData![0], count: Int(buffer.frameLength))

    // remember the max amplitude
    if let i = sampleDataInt16.max() {
      let m = Float(i) / Float(Int16.max)
      self.amplitude = Double(m)
      if m > abs(Float(self.maxAmplitude)) {
        self.maxAmplitude = abs(Double(m))
        print(self.maxAmplitude)
      }
    }

    // remember the min amplitude
    if let i = sampleDataInt16.max() {
      let m = Float(i) / Float(Int16.max)
      if m < abs(Float(self.minAmplitude)) {
        self.minAmplitude = abs(Double(m))
      }
    }
    
  }
  
  
  private func calculateAmplitudeFloat(buffer: AVAudioPCMBuffer) {
    let sampleDataFloat = UnsafeBufferPointer(start: buffer.floatChannelData![0], count: Int(buffer.frameLength))
    
    // remember the max amplitude
    if let m = sampleDataFloat.max() {
      self.amplitude = Double(m)
      if m > abs(Float(self.maxAmplitude)) {
        self.maxAmplitude = abs(Double(m))
      }
    }
    
    // remember the min amplitude
    if let m = sampleDataFloat.min() {
      if m < abs(Float(self.minAmplitude)) {
        self.minAmplitude = abs(Double(m))
      }
    }
    
  }
  
  
  // MARK: Util
  
  /// get a number somewhere approximately 0.0 to 1.0 (sometimes a little more or less) to represent the current volume
  public func getNomralizedVolumeLevelForUI() -> Double {
    // protect against divide by zero
    if (maxAmplitude == 0) {
      return 0.0
      
      // make the normalized volume a percent of the actual volume devided by the maximum recorded value, unless the max value is small
    } else {
      var normalizedLevel = amplitude / maxAmplitude
      
      if (maxAmplitude < W3WMicrophone.smallestMaxVolume) {
        normalizedLevel = amplitude
      }
      
      return normalizedLevel
    }
    
  }

}
