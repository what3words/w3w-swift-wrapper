//
//  File.swift
//  
//
//  Created by Dave Duprey on 06/04/2023.
//

import Foundation
import W3WSwiftCore



/// Communicates with the Speechmatics API
public class W3WVoiceUploadApi {
  
  let endpoint: String!
  
  
  // MARK: Initialization
  
  
  /// - Parameters:
  ///     - engine: W3w Core SDK
  public init(apiKey: String) {
    endpoint = W3WSettings.voiceApiUploadUrl + "?key=" + apiKey
  }
  
  
  //  public init(api: What3WordsV4) {
  //    endpoint = W3WSettings.voiceApiUploadUrl + "?key=" + api.apiKey
  //  }
  
  
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
          
          var country: W3WCountry? = nil
          if let countryCode = suggestionObject["country"] as? String {
            country = W3WBaseCountry(code: countryCode)
          }
          
          var distance: W3WDistance? = nil
          if let kilometers = suggestionObject["distanceToFocusKm"] as? Double {
            distance = W3WBaseDistance(kilometers: kilometers)
          }
          
          var language: W3WVoiceLanguage? = nil
          if let languageCode = suggestionObject["langauge"] as? String {
            language = W3WVoiceLanguage(code: languageCode)
          }
          
          places.append(W3WVoiceSuggestion(words: words, country: country, nearestPlace: suggestionObject["nearestPlace"] as? String, distanceToFocus: distance, language: language))
        }
      }
      callback(places, nil)
      
    } else {
      print("ERROR")
      callback(nil, W3WError.invalidMessage)
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
        callback(nil, W3WError.voiceSocketError(error: W3WVoiceSocketError.other(error: error ?? W3WError.unknown)))
        return
        
      } else if let d = data {
        self.recieved(data: d, callback: callback)
        return
        
      }
      
      callback(nil, W3WError.unknown)
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
  
  /// utility to check that language was passed in as it is non-optional for voice
  func checkForLanguageOption(options: [W3WOption]?) -> Bool {
    var languagePresent = false
    
    for option in options ?? [] {
      if option.key() == "voice-language" {
        languagePresent = true
        break
      }
    }
    
    return languagePresent
  }
  
  
}


