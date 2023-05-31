//
//  Sound.swift
//  w3w-watchos WatchKit Extension
//
//  Created by Dave Duprey on 13/01/2020.
//  Copyright © 2020 Dave Duprey. All rights reserved.
//

import Foundation



/// Stores sound data, returns it as .WAV, possibly others
public class W3WAudioRecording {
  
 
  /// store for the samples
  public var samples = Data()
  
  /// sample rate of the recording
  var sampleRate:Int32 = W3WSettings.defaultSampleRate
  
  /// bps of the samples
  var sampleType = SampleType.bit16

  /// return the bps given the tpye enum
  var bitsPerSample:Int16 {
    get {
      switch sampleType {
        case .bit8:
          return 8
        case .bit16:
          return 16
        case .bit32:
          return 32
      }
    }
  }


  // MARK: Initialization
  
  /// default init assumed 16 bit samples
  public init(sampleRate: Int32 = 44100, sampleType: SampleType = .bit16) {
    self.sampleRate = sampleRate
    self.sampleType = sampleType
  }
  

  /// init with a particular sample
  /// - Parameters:
  ///     - sampleType: the bits per sample specified by enum
  public init(sampleType:SampleType) {
    self.sampleType = sampleType
  }

  
  /// init with another Sound to make a copy
  public init(samples:Data, sampleRate:Int32, sampleType: SampleType) {
    self.samples    = Data(samples)
    self.sampleRate = sampleRate
    self.sampleType = sampleType
  }
  
  
  /// init with another Sound to make a copy
  public init(copying:W3WAudioRecording) {
    self.samples    = Data(copying.samples)
    self.sampleRate = copying.sampleRate
    self.sampleType = copying.sampleType
  }


  
  // MARK: Accessors

  
  /// sets the sample rate
  public func setSampleRate(_ sampleRate:Int32) {
    self.sampleRate = sampleRate
  }
  
  
  /// sets the sample rate
  public func setSampleRate(_ sampleRate:Int) {
    self.sampleRate = Int32(sampleRate)
  }
  

  /// duration retured in seconds
  public func getDuration() -> Double {
    var bytesPerSample = 1
    
    switch sampleType {
      case .bit8:
        bytesPerSample = 1
      case .bit16:
        bytesPerSample = 2
      case .bit32:
        bytesPerSample = 4
    }
    
    return Double(samples.count / bytesPerSample) / Double(sampleRate)
  }
  

  
  // MARK: Sample Functions

  var sampleCountDebug = 0
  
  
  /// adds a 16 bit integer sample to whatever format is current
  /// - Parameters:
  ///     - sample: sound sample
  public func add(sample:Int16) {
    sampleCountDebug += 1
    switch sampleType {
      case .bit8:
        samples.append(int16To1Byte(sample), count: 1)
      case .bit16:
        samples.append(int16To2Bytes(sample), count: 2)
      case .bit32:
        samples.append(int16To4Bytes(sample), count: 4)
    }
  }

  
  /// adds a 32 bit integer sample to whatever format is current
  /// - Parameters:
  ///     - sample: sound sample
  public func add(sample:Int32) {
    sampleCountDebug += 1
    switch sampleType {
      case .bit8:
        samples.append(int32To1Byte(sample), count: 1)
      case .bit16:
        samples.append(int16To2Bytes(Int16(sample)), count: 2)
      case .bit32:
        samples.append(int32To4Bytes(sample), count: 4)
    }

  }
  
  
  /// adds a 32 bit float sample to whatever format is current
  /// - Parameters:
  ///     - sample: sound sample
  public func add(sample:Float32) {
    sampleCountDebug += 1
    let convertedToInt16 = Int16(sample * 32768 / (2.0 * .pi))
    add(sample: convertedToInt16)
  }
  
  
  func add(samples: Data) {
    self.samples.append(samples)
  }

  
  /// clears the sound buffer
  public func removeAllSamples() {
    samples.removeAll()
  }
  
  
  // MARK: Converting Formats
  
  /// returns the stored sound as a .WAV
  public func asWav() -> Data {
    //Prepare Wav file header
    let waveHeaderFormat = createWaveHeader(data: samples) as Data
    
    //Prepare Final Wav File Data
    let waveFileData = waveHeaderFormat + samples
    
    //Store Wav file in document directory.
    //return try storeMusicFile(data: waveFileData)
    return waveFileData
  }


  
  /// breats a .WAV header data block
  /// - Parameters:
  ///     - data: sound buffer
  private func createWaveHeader(data: Data) -> NSData {
    let sampleRate:Int32    = self.sampleRate
    let chunkSize:Int32     = 36 + Int32(data.count)
    let subChunkSize:Int32  = 16
    let format:Int16        = 1
    let channels:Int16      = 1
    let bitsPerSample:Int16 = self.bitsPerSample
    let byteRate:Int32      = sampleRate * Int32(channels * bitsPerSample / 8)
    let blockAlign: Int16   = channels * bitsPerSample / 8
    let dataSize:Int32      = Int32(data.count)
    
    let header = NSMutableData()
    
    header.append([UInt8]("RIFF".utf8), length: 4)
    header.append(int32To4Bytes(chunkSize), length: 4)
    
    //WAVE
    header.append([UInt8]("WAVE".utf8), length: 4)
    
    //FMT
    header.append([UInt8]("fmt ".utf8), length: 4)
    
    header.append(int32To4Bytes(subChunkSize), length: 4)
    header.append(int16To2Bytes(format), length: 2)
    header.append(int16To2Bytes(channels), length: 2)
    header.append(int32To4Bytes(sampleRate), length: 4)
    header.append(int32To4Bytes(byteRate), length: 4)
    header.append(int16To2Bytes(blockAlign), length: 2)
    header.append(int16To2Bytes(bitsPerSample), length: 2)
    
    header.append([UInt8]("data".utf8), length: 4)
    header.append(int32To4Bytes(dataSize), length: 4)
    
    return header
  }
  
  
  
  /// converts
  private func int32To4Bytes(_ i: Int32) -> [UInt8] {
    return [
      //little endian
      UInt8(truncatingIfNeeded: (i      ) & 0xff),
      UInt8(truncatingIfNeeded: (i >>  8) & 0xff),
      UInt8(truncatingIfNeeded: (i >> 16) & 0xff),
      UInt8(truncatingIfNeeded: (i >> 24) & 0xff)
    ]
  }
  
  
  /// converts
  private func int16To2Bytes(_ i: Int16) -> [UInt8] {
    return [
      //little endian
      UInt8(truncatingIfNeeded: (i      ) & 0xff),
      UInt8(truncatingIfNeeded: (i >>  8) & 0xff)
    ]
  }

  
  /// converts
  private func int8To1Byte(_ i: Int8) -> [UInt8] {
    return [
      UInt8(truncatingIfNeeded: i),
    ]
  }

  
  /// converts
  private func int16To4Bytes(_ i: Int16) -> [UInt8] {
    int32To4Bytes(Int32(i << 16))
  }
  
  
  /// converts
  private func int16To1Byte(_ i: Int16) -> [UInt8] {
    int8To1Byte(Int8(i >> 8))
  }
  
  
  /// converts
  private func int32To1Byte(_ i: Int32) -> [UInt8] {
    int8To1Byte(Int8(i >> 24))
  }

  // MARK: output

  
  /// save a soundfile to the Documents directory for the app
  func saveToDisk(url: URL) {
    try? asWav().write(to: url)
  }

  
  /// save a soundfile to the Documents directory for the app
  func saveToDisk(filename: String) -> String? {
    var fullPath: String? = nil
    
    if let url = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?.appendingPathComponent(filename) {
      saveToDisk(url: url)
      fullPath = url.relativePath
    }
    
    return fullPath
  }

  
}


  // MARK: Enums


/// Encoding format
public enum Encoding {
  case pcm_f32le
  case pcm_f16le
  case pcm_f8le
  
  var value: String {
    get { return String(describing: self) }
  }
}


/// bits per sample
public enum SampleType {
  case bit32
  case bit16
  case bit8
}
