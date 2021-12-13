//
//  Recorder.swift
//  ThreeWordGo WatchKit Extension
//
//  Created by Dave Duprey on 08/04/2020.
//  Copyright © 2020 Dave Duprey. All rights reserved.
//

import Foundation


@available(watchOS 4.0, tvOS 11.0, *)
public class W3WAudioRecorder {
  
  /// Microphone to record the sound
  var microphone = W3WMicrophone()
  
  /// Stores the sound as it's recorded
  var recording = W3WAudioRecording()
  
  /// current sample rate - this may differ from microphone sample rate as rate conversion can happen while recording
  var currentSampleRate: Int

  /// indicate whether the microphone is engaged or not
  var engaged = false

  /// indicate if recording should automatically stop on 'end of speech detection'
  var endOfSpeechEnabled = true
  
  /// indicate if recording should automatically after acertain amount of time
  var maxRecordingLength = W3WSettings.max_recording_length
  
  /// the number of sound samples that have been recieved from the mic
  var sampleCount = 0
  
  /// for end of speech.  we keep track of the last relitavely loud sample.  End of speech happens after 3/4 or a second of no loud samples
  var lastLoudSampleTime = W3WSettings.max_recording_length
  
  /// max and min amplitude help calculate end of speech
  public var maxAmplitude = 0.0
  
  /// max and min amplitude help calculate end of speech
  public var minAmplitude = 0.0

  /// the current recording level
  var recordingLevel:Double = 0.0

  /// callback for the UI to update/animate any graphics showing microphone volume/amplitude
  public var volumeUpdate: (Double) -> () = { _ in }
  
  /// callback for when the voice recognition stopped
  public var listeningUpdate: ((W3WVoiceListeningState) -> ()) = { _ in }

  /// callback for errors
  public var recordingError: (String) -> Void = { _ in }

  /// called with the data when the recording is finished
  public var recordingFinished: (W3WAudioRecording) -> () = { _ in }
  
  
  public init() {
    currentSampleRate = microphone.getSampleRate()
    recording.setSampleRate(currentSampleRate)
        
    microphone.sampleArrived = { data in
      self.sampleArrivedFromMic(data: data)
    }

    microphone.volumeUpdate = { volume in
      self.volumeUpdate(volume)
    }
    
    microphone.listeningUpdate = { state in
      self.listeningUpdate(state)
    }
    
    //microphone.updateError   = { error in self.recordingError(String(describing: error)) }
  }
  
  
  public init(sampleRate: Int) {
    _ = microphone.set(sampleRate: sampleRate)  // we ignore if this call succeeds, because if it fails, the next line uses whatever the mic wants
    currentSampleRate = microphone.getSampleRate()
    recording.setSampleRate(currentSampleRate)
    microphone.sampleArrived = { data in self.sampleArrivedFromMic(data: data) }
    //microphone.updateError   = { error in self.recordingError(String(describing: error)) }
  }
  

  func configureSampleRate() {
    currentSampleRate = microphone.getSampleRate()
    recording.setSampleRate(currentSampleRate)
  }

  
  public func isRecording() -> Bool {
    return engaged
  }
  
  
  public func endOfSpeech(enabled: Bool) {
    endOfSpeechEnabled = enabled
  }
  
  
  public func set(maximumRecordingLength: Double) {
    maxRecordingLength = maximumRecordingLength
  }
  
  
  /// Start recording audio from the mic
  public func start() {

    // if the mic is unavailable, try stopping it
    if !microphone.isMicrophoneAvailable() {
      microphone.stop()
      engaged = false
    }

    // if the mic is in use by this object, then stop before start
    if engaged {
      microphone.stop()
      engaged = false
    }
    
    // start the mic and mark it as engaged
    configureSampleRate()
    microphone.start()
    engaged = true

    
//    if microphone.isMicrophoneAvailable() {
//      engaged = true
//      microphone.start()
//    } else {
//      microphone.stop()
//      microphone.start()
//    }
  }
  
  
  /// Start recording audio from the mic
  /// - Parameters:
  ///     - convertingToSampleRate: converts the mic data to  new samplerate before storing it
  public func start(convertingToSampleRate: Int) {
    engaged = true
    currentSampleRate = convertingToSampleRate
    recording.setSampleRate(convertingToSampleRate)
    microphone.start(convertingToSampleRate: convertingToSampleRate)
  }
  
  
  public func stop() {
    stop(andSend: true)
  }
  
  
  public func cancel() {
    stop(andSend: false)
  }
  
  
  private func stop(andSend: Bool) {
    if engaged {
      engaged = false

      microphone.stop()

      // send a copy of the sound to whomever is interested in it
      if andSend {
        recordingFinished(W3WAudioRecording(copying: recording))
      }

      // reset key values for next recording
      reset()
    }
  }
  
  
  private func reset() {
    // clear the local copy of the sound
    recording.removeAllSamples() // reset the sound
    
    // reset level tracking variables
    lastLoudSampleTime  = W3WSettings.max_recording_length
    sampleCount         = 0
    maxAmplitude        = 0.0
    minAmplitude        = 0.0
  }
  
  
  // MARK: Microphone callback
  
  
  /// microphone callback with new audio data
  private func sampleArrivedFromMic(data: UnsafeBufferPointer<Float>) {
    sampleCount += data.count

    // keep track of how loud stuff is, notably tracking lastLoudSampleTime
    recordingLevels()

    // add samples individually to sound (they need to be converted one at a time at this point, todo: modify Microphone to recieve the data as Int using AVAudioMixerNode)
    if (data.baseAddress != nil) {
      for f in data {
        addSample(sample: f)
      }
    }

    // convert sample counts to time in seconds, report error if the sample rate is set to zero
    var recordingTime = 0.0
    if currentSampleRate == 0 {
      recordingError(NSLocalizedString("Error: Sample Rate is zero", comment: ""))
      recordingTime = Double(sampleCount) / Double(0.00000001)
    } else {
      recordingTime = Double(sampleCount) / Double(currentSampleRate)
    }

    // detect end of speech, if warrented
    if endOfSpeechEnabled {
      if (endOfSpeechFunction(recordingTime: recordingTime, lastLoudSampleTime: lastLoudSampleTime)) {
        if engaged {
          stop() // stop recording
        }
      }
    }
    
  }

  
  
  // MARK: End of Speech Functions
  
  /// scans the audio data for maximum and minimum sound levels
  private func recordingLevels() {
    
    self.maxAmplitude   = microphone.maxAmplitude
    self.minAmplitude   = microphone.minAmplitude
    self.recordingLevel = microphone.amplitude
    
    if self.recordingLevel > self.maxAmplitude / 4.0 {
      self.lastLoudSampleTime = Double(self.sampleCount) / Double(self.currentSampleRate)
    }

    DispatchQueue.main.async {
      self.volumeUpdate(self.recordingLevel)
    }
  }
  
  
  /// determine if speech has substantively stopped
  private func endOfSpeechFunction(recordingTime:Double, lastLoudSampleTime:Double) -> Bool {
    
    // if the lastLoudSample happened more than 'end_of_speech_quiet_time' seconds ago, then there is a long enough pause in the substantive sound
    let muchQuietTime:Bool = (lastLoudSampleTime < recordingTime - W3WSettings.end_of_speech_quiet_time && recordingTime > W3WSettings.min_voice_sample_length)
    let recordingTooLong   = recordingTime > maxRecordingLength   //= (sound.samples.count == LibSettings.max_recording_sample_count)
    
    if muchQuietTime {
      print("EOS worked")
    }
    
    if recordingTooLong && engaged {
      print("Recording timeout")
    }
    
    //print("Au: ", muchQuietTime, recordingTooLong, engaged, sampleCount, recordingTime, lastLoudSampleTime, maxRecordingLength, microphone.minAmplitude, microphone.maxAmplitude, microphone.amplitude)
    
    // or if we've gone past the maximum number of samples we want
    //return (lastLoudSampleTime < recordingTime - LibSettings.end_of_speech_quiet_time && recordingTime > LibSettings.min_voice_sample_length) || (sound.samples.count == LibSettings.max_recording_sample_count)
    return (muchQuietTime || recordingTooLong) && engaged
  }
  
  
  // MARK: Sound file
  
  
  /// add a 16 bit int sample to the sound file
  public func addSample(sample:Int16) {
    recording.add(sample: sample)
  }
  
  
  /// add a 32 bit int sample to the sound file
  public func addSample(sample:Int32) {
    recording.add(sample: sample)
  }
  
  
  /// add a 32 bit float sample to the sound file
  public func addSample(sample:Float32) {
    let convertedToInt16 = Int16(sample * 32768 / (2.0 * .pi))
    recording.add(sample: convertedToInt16)
  }

  
  
}
