//
//  VoiceApi.swift
//  VoiceApiDemo
//
//  Created by Dave Duprey on 23/04/2020.
//  Copyright © 2020 What3Words. All rights reserved.
//


import Foundation
import CoreLocation




#if !os(watchOS)


public class W3WVoiceApi: W3WApiCall, W3WVoice {
  
  var voiceSocket: W3WVoiceSocket?

  
  public init(apiKey: String) {
    super.init(apiUrl: W3WSettings.voiceApiUrl, apiKey: apiKey)
    self.voiceSocket = W3WVoiceSocket(apiKey: apiKey)
  }
  
  
  public init(api: What3WordsV3) {
    super.init(apiUrl: W3WSettings.voiceApiUrl, apiKey: api.apiKey)
    self.voiceSocket = W3WVoiceSocket(apiKey: api.apiKey)
  }

  
  /**
   Retrieves a list of the currently loaded and available 3 word address languages.
   - parameter completion: A W3wGeocodeResponseHandler completion handler
   */
  public func availableVoiceLanguages(completion: @escaping W3WLanguagesResponse) {
    self.performRequest(path: "/available-languages", params: [:]) { (result, error) in
      if let lines = result {
        completion(self.languages(from: lines), error)
      } else {
        completion(nil, error)
      }
    }
  }

  
  /// the important function here, this actually starts the voice session, all other functions are for convenience and call this one and accept different combinations of paramters
  private func common(audio: W3WAudioStream, language: String, options: [W3WOption], callback: @escaping W3WVoiceSuggestionsResponse) {
 
    let filteredOptions = replaceOrAddVoiceLanguageIn(options: options, language: language)

    // send any suggestions
    voiceSocket?.suggestions = { suggestions in
      self.stop(audio: audio)
      callback(suggestions, nil)
    }

    // deal with any error
    voiceSocket?.error = { error in
      self.stop(audio: audio)
      callback(nil, error)
    }

    audio.listeningUpdate = { state in
    }
    
    audio.onError = { error in
      self.stop(audio: audio)
      callback(nil, error)
    }
    
    audio.volumeUpdate = { volume in
    }
    
    audio.sampleArrived = { data in
      self.voiceSocket?.send(samples: Data(buffer: data))
    }
    
    // if we were given a microphone, then turn it on
    if #available(tvOS 11.0, *) {
      if let microphone = audio as? W3WMicrophone {
        microphone.start()
      }
    }

    // open the ocnnection to the server
    voiceSocket?.open(sampleRate: audio.sampleRate, encoding: audio.encoding, options: filteredOptions)
  }
  
  
  func stop(audio: W3WAudioStream) {
    voiceSocket?.close()
    voiceSocket = nil
    
    audio.endSamples()
    
    // if we were given a microphone, then turn it on
    if #available(tvOS 11.0, *) {
      if let microphone = audio as? W3WMicrophone {
        microphone.stop()
      }
    }
  }

  
  /**
   Convenience function without a completion
   */
  public func autosuggest(audio: W3WAudioStream, language: String, options: [W3WOption], callback: @escaping W3WVoiceSuggestionsResponse) {
    common(audio: audio, language: language, options: options, callback: callback) //, completion: { _ in })
  }


  /**
   Convenience function to allow use of option list without array and  without a completion
   */
  public func autosuggest(audio: W3WAudioStream, language: String, options: W3WOption..., callback: @escaping W3WVoiceSuggestionsResponse) {
    common(audio: audio, language: language, options: options, callback: callback) //, completion: { _ in })
  }

  
  /**
   Convenience function without a completion
   */
  public func autosuggest(audio: W3WAudioStream, language: String, options: W3WOptions, callback: @escaping W3WVoiceSuggestionsResponse) {
    common(audio: audio, language: language, options: options.options, callback: callback) //, completion: { _ in })
  }

  

  /// removes voiceLanguage option if present, and adds the language specified in the language parameter
  /// this is a remedy for teh case a redundancy is caused by the parameter and optioins both specifying a language
  /// perference is given to the parameter
  func replaceOrAddVoiceLanguageIn(options: [W3WOption], language: String) -> [W3WOption] {
    var newOptions = [W3WOption]()
    
    for option in options {
      if option.key() != W3WOptionKey.voiceLanguage {
        newOptions.append(option)
      }
    }
    
    newOptions.append(W3WOption.voiceLanguage(language))
    
    return newOptions
  }
  
      
}


#else

  // MARK: watchOS version


/// Communicates with the Speechmatics API
public class W3WVoiceApi {
  
  let endpoint: String!
  
  
  // MARK: Initialization
  
  
  /// - Parameters:
  ///     - engine: W3w Core SDK
  public init(apiKey: String) {
    endpoint = W3WSettings.voiceApiUploadUrl + "?key=" + apiKey
  }
  
  
  public init(api: What3WordsV3) {
    endpoint = W3WSettings.voiceApiUploadUrl + "?key=" + api.apiKey
  }
  
  
  /// called when new text is recieved
  func recieved(text:String) {
  }
  
  
  /// called when new data is received
  func recieved(data:Data, callback: W3WVoiceSuggestionsResponse) {
    let json = try? JSONSerialization.jsonObject(with: data) as? [String:Any]
    var places:[W3WVoiceSuggestion] = []
    
    if let suggestionArray = json?["w3w_results"] as! [[String:Any]]? {
      for suggestionObject in suggestionArray {
        if let words = suggestionObject["words"] as? String {
          places.append(W3WVoiceSuggestion(words: words, country: suggestionObject["country"] as? String, nearestPlace: suggestionObject["nearestPlace"] as? String, distanceToFocus: suggestionObject["distanceToFocusKm"] as? Double, language: suggestionObject["langauge"] as? String))
        }
      }
      callback(places, nil)
      
    } else {
      print("ERROR")
      callback(nil, W3WVoiceError.invalidMessage)
    }
  }
  
  
  
  
  // MARK: Send the audio & await reply
  
  /// Send the audio gathered so far to speechmatics as an audio file
  public func common(audio: W3WAudioRecording, options: [W3WOption], callback: @escaping W3WVoiceSuggestionsResponse) {
    
    // start making the URL string
    //var urlString = endpoint + "&voice-language=\(language)"
    let urlString = endpoint +  makeQueryStringFromAutoSuggestParameters(options: options)
    
    // build the URL object
    var request = URLRequest(url: URL(string: urlString)!)
    request.httpMethod = "POST"
    request.timeoutInterval = 20.0
    
    let CRLF      = "\r\n"
    let filename  = "voice.wav"
    let formName  = "file"
    let type      = "audio/wav"     // file type
    let boundary  = String(format: "----iOSURLSessionBoundary.%08x%08x", arc4random(), arc4random())
    
    var body = Data()
    
    // file data //
    body.append(("--\(boundary)" + CRLF).data(using: .utf8)!)
    body.append(("Content-Disposition: form-data; name=\"\(formName)\"; filename=\"\(filename)\"" + CRLF).data(using: .utf8)!)
    body.append(("Content-Type: \(type)" + CRLF + CRLF).data(using: .utf8)!)
    body.append(audio.asWav()) // convert the sound file to WAV
    body.append(CRLF.data(using: .utf8)!)
    body.append(("--\(boundary)--" + CRLF).data(using: .utf8)!) // footer
    
    // URL request params
    request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
    request.setValue("\(body.count)", forHTTPHeaderField: "Content-Length")
    request.httpBody = body
    
    // make the call
    let session = URLSession(configuration: .default)
    print("About To Send Sound")
    session.dataTask(with: request) { (data, response, error) in
      
      // deal with reply from Speechmatics
      print("Got Reply From Server")
      if error != nil {
        callback(nil, W3WVoiceError.voiceSocketError(error: W3WVoiceSocketError.other(error: error ?? W3WVoiceError.unknown)))
        return
      
      } else if let d = data {
        self.recieved(data: d, callback: callback)
        return

      }
        
      callback(nil, W3WVoiceError.unknown)
    }
    .resume()
  }
  
  
  /**
   Convenience function without a completion
   */
  public func autosuggest(audio: W3WAudioRecording, options: [W3WOption], callback: @escaping W3WVoiceSuggestionsResponse) {
    common(audio: audio, options: options, callback: callback) //, completion: { _ in })
  }
  
  
  /**
   Convenience function to allow use of option list without array and  without a completion
   */
  public func autosuggest(audio: W3WAudioRecording, options: W3WOption..., callback: @escaping W3WVoiceSuggestionsResponse) {
    common(audio: audio, options: options, callback: callback) //, completion: { _ in })
  }
  
  
  /**
   Convenience function without a completion
   */
  public func autosuggest(audio: W3WAudioRecording, options: W3WOptions, callback: @escaping W3WVoiceSuggestionsResponse) {
    common(audio: audio, options: options.options, callback: callback) //, completion: { _ in })
  }

  
  
  /// make a querystring for a URL using the provided parameters
  ///   - parameter language: the two leeter langauge code fo rthe language being spoken
  ///   - parameter resultCount: The number of AutoSuggest results to return. A maximum of 100 results can be specified, if a number greater than this is requested, this will be truncated to the maximum. The default is 3
  ///   - parameter focus: This is a location, specified as a latitude (often where the user making the query is). If specified, the results will be weighted to give preference to those near the focus. For convenience, longitude is allowed to wrap around the 180 line, so 361 is equivalent to 1.
  ///   - parameter focusCount: Specifies the number of results (must be less than or equal to n-results) within the results set which will have a focus. Defaults to n-results. This allows you to run autosuggest with a mix of focussed and unfocussed results, to give you a "blend" of the two. This is exactly what the old V2 standarblend did, and standardblend behaviour can easily be replicated by passing n-focus-results=1, which will return just one focussed result and the rest unfocussed.
  ///   - parameter country: only show results for thi country
  ///   - parameter cicleCenter: Restrict autosuggest results to a circle, specified by focus
  ///   - parameter cicleRadius: Restrict autosuggest results to a circle, specified by focus
  private func makeQueryStringFromAutoSuggestParameters(options: [W3WOption]?) -> String {
    var queryString = ""
    var filteredOptions = options ?? [W3WOption]()

    // if no language is specified then add a default one
    if !checkForLanguageOption(options: options) {
      filteredOptions.append(W3WOption.voiceLanguage(W3WSettings.defaultLanguage))
    }
    
    for option in filteredOptions {
      queryString += "&" + option.key() + "=" + option.asString()
    }

    return queryString
  }
  
  
  func addLanguageOption() -> String {
    let language = W3WOption.voiceLanguage(W3WSettings.defaultLanguage)
    return language.key() + "=" + language.asString()
  }
  
  
}

#endif // if !os(watchOS) - from top of file


extension W3WVoiceApi {
  
  /// utility to check that language was passed in as it is non-optional for voice
  func checkForLanguageOption(options: [W3WOption]?) -> Bool {
    var languagePresent = false
    
    for option in options ?? [] {
      if option.key() == W3WOptionKey.voiceLanguage {
        languagePresent = true
        break
      }
    }
    
    return languagePresent
  }

  
}
