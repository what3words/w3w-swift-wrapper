//
//  W3WSampleData.swift
//
//  Created by Dave Duprey on 23/05/2023.
//

import AVKit


/// a struct that manages AVAudioPCMBuffer and whose interface is mostly agnostic to it
public struct W3WSampleData {
  
  // MARK: Vars
  
  /// the ios audio buffer
  let buffer: AVAudioPCMBuffer?
  
  
  /// returns the sample rate of the buffer
  public var sampleRate: UInt? {
    get {
      if let sr = buffer?.format.sampleRate {
        return UInt(sr)
      } else {
        return nil
      }
    }
  }
  
  /// returns the data if it is in float format, otherwise nil
  public var float32Buffer: UnsafeBufferPointer<Float>? {
    get {
      if let b = buffer {
        if let floatBuffer = b.floatChannelData?[0] {
          return UnsafeBufferPointer<Float>(start: floatBuffer, count: Int(b.frameLength))
        } else {
          return nil
        }
      } else {
        return nil
      }
    }
  }
  
  
  /// returns the data if it's in int16 format, otehrwise nil
  public var int16Buffer: UnsafeBufferPointer<Int16>? {
    get {
      if let b = buffer {
        if let intBuffer = b.int16ChannelData?[0] {
          return UnsafeBufferPointer<Int16>(start: intBuffer, count: Int(b.frameLength))
        } else {
          return nil
        }
      } else {
        return nil
      }
    }
  }
  
  
  /// returns the data if it's in int32 format, otehrwise nil
  public var int32Buffer: UnsafeBufferPointer<Int32>? {
    get {
      if let b = buffer {
        if let intBuffer = b.int32ChannelData?[0] {
          return UnsafeBufferPointer<Int32>(start: intBuffer, count: Int(b.frameLength))
        } else {
          return nil
        }
      } else {
        return nil
      }
    }
  }
  
  
  /// returns the number of samples in the data
  public func numberOfSamples() -> UInt {
    return UInt(buffer?.frameLength ?? 0)
  }
  
  
  // MARK: Inits
  
  
  /// Holds sound sample data
  /// - parameter buffer: An iOS audio buffer
  public init(buffer: AVAudioPCMBuffer?) {
    self.buffer = buffer
  }
  
  
  /// Holds sound sample data
  /// - parameter buffer: An array of Int16 sound sample data
  public init(array: [Int16], sampleRate: UInt) {
    var b:AVAudioPCMBuffer? = nil
    
    array.withUnsafeBytes { (bufferPointer) in
      if let pointer = bufferPointer.baseAddress {
        let data = Data(bytes: pointer, count: array.count * Int16.bitWidth / 8)
        b = Self.makePCMBuffer(data: data, format: .pcm_s16le, sampleRate: sampleRate)
      }
    }
    
    self.buffer = b
  }
  
  
  /// Holds sound sample data
  /// - parameter buffer: An pointer to Float sample sata
  /// - parameter sampleRate: The sample rate of the recorded data
  public init(pointer: UnsafeBufferPointer<Float>, sampleRate: UInt) {
    self.buffer = Self.createAudioPCMBufferFloat(from: pointer, sampleRate: sampleRate)
  }
  
  
  /// Holds sound sample data
  /// - parameter data: A foundation Data object holding sound sample data
  /// - parameter format: The format of the sound sample data
  /// - parameter sampleRate: The sample rate of the recorded data
  public init(data: Data, format: W3WEncoding, sampleRate: UInt) {
    self.buffer = Self.makePCMBuffer(data: data, format: format, sampleRate: sampleRate)
  }
    
  
  
  /// Makes a PCM buffer from a foundation Data object
  static func makePCMBuffer(data: Data, format: W3WEncoding, sampleRate: UInt) -> AVAudioPCMBuffer? {
    if let format = AVAudioFormat(commonFormat: format == .pcm_f32le ? .pcmFormatFloat32 : .pcmFormatInt16, sampleRate: Double(sampleRate), channels: 1, interleaved: false) {
      let streamDesc = format.streamDescription.pointee
      let frameCapacity = UInt32(data.count) / streamDesc.mBytesPerFrame
      guard let buffer = AVAudioPCMBuffer(pcmFormat: format, frameCapacity: frameCapacity) else { return nil }
      
      buffer.frameLength = buffer.frameCapacity
      let audioBuffer = buffer.audioBufferList.pointee.mBuffers
      
      data.withUnsafeBytes { (bufferPointer) in
        guard let addr = bufferPointer.baseAddress else { return }
        audioBuffer.mData?.copyMemory(from: addr, byteCount: Int(audioBuffer.mDataByteSize))
      }
      return buffer
    }
    
    return nil
  }
  
  
  /// convert a pointer to Floats to an iOS audio buffer
  static func createAudioPCMBufferFloat(from bufferPointer: UnsafeBufferPointer<Float>, sampleRate: UInt) -> AVAudioPCMBuffer? {
    if let format = AVAudioFormat(standardFormatWithSampleRate: Double(sampleRate), channels: 1) {
      guard let buffer = AVAudioPCMBuffer(pcmFormat: format, frameCapacity: UInt32(bufferPointer.count)) else {
        return nil
      }
      
      buffer.frameLength = buffer.frameCapacity
      
      let audioBuffer = buffer.audioBufferList.pointee.mBuffers
      
      for frame in 0..<Int(buffer.frameLength) {
        let floatBuffer = UnsafeMutableBufferPointer(start: audioBuffer.mData?.assumingMemoryBound(to: Float.self), count: Int(audioBuffer.mDataByteSize) / MemoryLayout<Float>.stride)
        let sample = bufferPointer[frame]
        floatBuffer[frame] = sample
      }
      
      return buffer
    }
    
    return nil
  }
  
}



