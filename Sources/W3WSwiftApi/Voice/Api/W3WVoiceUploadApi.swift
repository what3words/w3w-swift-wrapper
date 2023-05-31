//
//  W3WVoiceUploadApi.swift
//  
//
//  Created by Dave Duprey on 23/05/2023.
//

import Foundation



/// Communicates with the Speechmatics API
public class W3WVoiceUploadApi {
  
  let endpoint: String!
  
  
  // MARK: Initialization
  

  /// Initialise a W3WVoiceUploadApi
  /// - Parameters:
  ///     - apiKey: voice anabled api key for what3words
  public init(apiKey: String) {
    endpoint = W3WSettings.voiceApiUploadUrl + "?key=" + apiKey
  }
  
  
  /// Initialise a W3WVoiceUploadApi
  /// - Parameters:
  ///     - api: W3w Api
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
  
  
  /**
   Send the audio gathered so far to speechmatics as an audio file
   Returns a list of 3 word addresses based on user input and other parameters.
   - parameter audio: An audio recording containing a spoken 3 wrods address
   - parameter options: are provided as an array of W3Option objects.
   - parameter callback: A completion block providing the suggestions and any error - ([W3WVoiceSuggestion]?, W3WVoiceError?) -> Void
   */
  public func common(audio: W3WAudioRecording, options: [W3WOption], callback: @escaping W3WVoiceSuggestionsResponse) {
    
    // start making the URL string
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
   Returns a list of 3 word addresses based on user input and other parameters.
   - parameter audio: An audio recording containing a spoken 3 wrods address
   - parameter options: are provided as an array of W3Option objects.
   - parameter callback: A completion block providing the suggestions and any error - ([W3WVoiceSuggestion]?, W3WVoiceError?) -> Void
   */
  public func autosuggest(audio: W3WAudioRecording, options: [W3WOption], callback: @escaping W3WVoiceSuggestionsResponse) {
    common(audio: audio, options: options, callback: callback)
  }
  
  
  /**
   Returns a list of 3 word addresses based on user input and other parameters.
   - parameter audio: An audio recording containing a spoken 3 wrods address
   - parameter options: are provided as a varidic list of W3Option objects.
   - parameter callback: A completion block providing the suggestions and any error - ([W3WVoiceSuggestion]?, W3WVoiceError?) -> Void
   */
  public func autosuggest(audio: W3WAudioRecording, options: W3WOption..., callback: @escaping W3WVoiceSuggestionsResponse) {
    common(audio: audio, options: options, callback: callback) //, completion: { _ in })
  }
  
  
  /**
   Returns a list of 3 word addresses based on user input and other parameters.
   - parameter audio: An audio recording containing a spoken 3 wrods address
   - parameter options: Options are provided as a W3WOptopns() object
   - parameter callback: A completion block providing the suggestions and any error - ([W3WVoiceSuggestion]?, W3WVoiceError?) -> Void
   */
  public func autosuggest(audio: W3WAudioRecording, options: W3WOptions, callback: @escaping W3WVoiceSuggestionsResponse) {
    common(audio: audio, options: options.options, callback: callback) //, completion: { _ in })
  }
  
  
  
  /// make a querystring for a URL using the provided parameters
  ///   - parameter options: an array of autosuggest options
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


