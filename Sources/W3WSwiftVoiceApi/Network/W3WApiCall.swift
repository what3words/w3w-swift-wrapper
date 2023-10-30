////
////  File.swift
////
////
////  Created by Dave Duprey on 02/11/2020.
////  Copyright © 2020 What3Words. All rights reserved.
////
//
//import Foundation
//import CoreLocation
//#if canImport(UIKit)
//import UIKit
//#endif
//#if os(watchOS)
//import WatchKit
//#endif
//
//import W3WSwiftCore
//
//
///// closure definition for internal HTTP requests
//public typealias W3WDataResponse             = ((_ result: [String: Any]?, _ error: W3WError?) -> Void)
//
//
///// A base class for making API calls to a service
//public class W3WApiCall {
//  
//  var apiUrl: String
//  var apiKey: String
//  
//  let         api_version    = W3WSettings.apiVersion
//  private var version_header = "what3words-Swift/x.x.x (Swift x.x.x; iOS x.x.x)"
//  private var bundle_header  = ""
//  private var customHeaders  = [String:String]()
//
//  
//  // MARK: Constructors
//  
//  /// Initialize the API wrapper
//  /// - Parameters:
//  ///     - apiKey: Your api key.  Register for one at: https://accounts.what3words.com/create-api-key
//  public init(apiUrl: String, apiKey: String) {
//    self.apiUrl = apiUrl
//    self.apiKey = apiKey
//    self.figureOutVersions()
//  }
//  
//  
//  /// Initialize the API wrapper
//  /// - Parameters:
//  ///     - apiKey: Your api key.  Register for one at: https://accounts.what3words.com/create-api-key
//  ///     - apiUrl: Url for custom server - for enterprise customers
//  ///     - customHeaders: additional HTTP headers to send on requests - for enterprise customers
//  public init(apiUrl: String, apiKey: String, customHeaders: [String: String]) {
//    self.apiUrl = apiUrl
//    self.apiKey = apiKey
//    self.apiUrl = apiUrl
//    self.set(customHeaders: customHeaders)
//    self.figureOutVersions()
//  }
//  
//
//    
//  /// Make a copy of this instance
//  /// - Parameters:
//  ///     - api: the `What3WordsV3` object to be copied
////  public func copy(api: What3WordsV3) -> What3WordsV3 {
////    return What3WordsV3(apiKey: apiKey, apiUrl: apiUrl, customHeaders: customHeaders)
////  }
//  
//  
//  // MARK: Accessors
//  
//  /**
//   This function is intended for use by our enterprise customers who
//   run a private version of our API server.  Most people will noy use this
//   Set a custom header to be sent on the next and all subsequent API calls
//   - parameter customHeaders: additional HTTP headers to send on requests - for enterprise customers
//   */
//  public func set(customHeaders: [String: String]) {
//    self.customHeaders = customHeaders
//  }
//  
//  
//  /**
//   If a header with `key` already exists, it updates the header with `value`
//   if a header with key does not exist is adds this header to the custom headers
//   - parameter key: key of the header to be updated / added
//   - parameter value: value for the header
//   */
//  public func updateHeader(key: String, value: String) {
//    self.customHeaders[key] = value
//  }
//  
//  
//  /**
//   Remove a header with `key`
//   - parameter key: key of the header to be removed
//   */
//  public func removeHeader(key: String) {
//    self.customHeaders.removeValue(forKey: key)
//  }
//  
//  
//  /**
//   Clears all previously set custom headers - for enterprise customers
//   */
//  public func clearCustomHeaders() {
//    customHeaders = [:]
//  }
//
//  
//  /**
//   indicates if W3W servers are being employed or this is set to a custom server
//   */
////  @available(*, deprecated, message: "Use What3WordsV3.isCurrentServerW3W() instead. Note: it returns the opposite boolean value to this function")
////  public func customServersSet() -> Bool {
////    return apiUrl != W3WSettings.apiUrl
////  }
//  
//  
//  // MARK: HTTP Request
//  
//  
//  /**
//   Calls w3w URL
//   - parameter path: The URL to call
//   - parameter params: disctionary of parameters to send on querystring
//   - parameter completion: The completion handler
//   */
//  public func performRequest(path: String, params: [String: String], completion: @escaping W3WDataResponse) {
//    
//    // generate the request
//    if let request = makeRequest(path: path, params: params) {
//      
//      // make the call
//      let task = URLSession.shared.dataTask(with: request) { (data, _, error) in
//        
//        // deal with the results, and complete with the info
//        self.parseResults(data: data, error: error, completion: completion)
//      }
//      
//      // start the call
//      task.resume()
//    }
//  }
//
//  
//  /**
//   given a path and parameters, make a URLRequest object
//   - parameter path: The URL to call
//   - parameter params: disctionary of parameters to send on querystring
//   */
//  func makeRequest(path: String, params: [String: String]) -> URLRequest? {
//    // prepare url components
//    var urlComponents = URLComponents(string: apiUrl + path)!
//    
//    // add the querystring variables from the param dictionary
//    var queryItems: [URLQueryItem] = [URLQueryItem(name: "key", value: apiKey)]
//    for (name, value) in params {
//      let item = URLQueryItem(name: name, value: value)
//      queryItems.append(item)
//    }
//    urlComponents.queryItems = queryItems
//    
//    // create the URL
//    guard let url = urlComponents.url else {
//      assertionFailure("Invalid url: \(urlComponents)")
//      return nil
//    }
//    
//    // prepare request
//    var request = URLRequest(url: url)
//    
//    // set headers
//    request.setValue(version_header, forHTTPHeaderField: "X-W3W-Wrapper")
//    request.setValue(bundle_header, forHTTPHeaderField: "X-Ios-Bundle-Identifier")
//    
//    // add custom headers if any
//    for (name, value) in customHeaders {
//      request.setValue(value, forHTTPHeaderField: name)
//    }
//    
//    return request
//  }
//  
//  
//  /**
//   Calls w3w URL
//   - parameter data: the returned data from the API
//   - parameter error: an error if any
//   - parameter completion: The completion handler
//   */
//  func parseResults(data: Data?, error: Error?, completion: @escaping W3WDataResponse) {
//    guard let data = data else {
//      completion(nil, W3WError.other(error))
//      return
//    }
//    
//    if data.count == 0 {
//      completion(nil, nil)
//      return
//    }
//    
//    var jsonData:[String: Any]?
//    
//    do {
//      jsonData = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
//    }
//    catch {
//      completion(nil, W3WError.message(error.localizedDescription))
//      return
//    }
//    
//    guard let json = jsonData else {
//      completion(nil, W3WError.invalidResponseFromVoiceServer)
//      return
//    }
//    
//    if let error = json["error"] as? [String: Any], let code = error["code"] as? String, let message = error["message"] as? String {
//      completion(nil, W3WError.code(Int(code) ?? -1, message))
//      return
//    }
//    
//    if let code = json["code"] as? String, let message = json["message"] as? String {
//      completion(nil, W3WError.code(Int(code) ?? -1, message))
//      return
//    }
//    
//    if let error = json["error"] as? [String: Any], let code = error["code"] as? String {
//      completion(nil, W3WError.code(Int(code) ?? -1, "error"))
//      return
//    }
//    
//    if let code = json["code"] as? String {
//      completion(nil, W3WError.code(Int(code) ?? -1, "error"))
//      return
//    }
//    
//    if let error = json["error"] as? String {
//      completion(nil, W3WError.message(error))
//      return
//    }
//    
//    if error != nil {
//      completion(nil, W3WError.badConnectionToVoiceServer)
//    }
//
//    completion(json, nil)
//  }
//  
//  
//  // MARK: Json parsing
//  
//  /**
//   Make an array ot W3Language from a data dictionary
//   - parameter from: Dictionary of values, usually from a JSON decode
//   */
//  func languages(from: [String: Any]?) -> [W3WVoiceLanguage]? {
//    var languages: [W3WVoiceLanguage]? = nil
//    
//    if let l = from {
//      if let list = l["languages"] as? Array<Any?>? {
//        for ll in list ?? [] {
//          if let lang = ll as? Dictionary<String, Any?> {
//            let language = W3WVoiceLanguage(
//              code: lang["code"] as? String ?? "",
//              name: lang["name"] as? String ?? "",
//              nativeName: lang["nativeName"] as? String ?? ""
//            )
//            if languages == nil {
//              languages = [W3WVoiceLanguage]()
//            }
//            languages?.append(language)
//          }
//        }
//      }
//    }
//    return languages
//  }
//  
//  
//
//  /**
//   Make an array ot W3APISuggestion from a data dictionary
//   - parameter from: Dictionary of values, usually from a JSON decode
//   */
//  func suggestions(from: [String: Any]?) -> [W3WVoiceSuggestion]? {
//    var suggestions = [W3WVoiceSuggestion]()
//    if let s = from {
//      if let list = s["suggestions"] as? Array<Any?>? {
//        for ss in list! {
//          if let sugg = ss as? Dictionary<String, Any?> {
//            
//            var country: W3WVoiceCountry? = nil
//            if let countryCode = sugg["country"] as? String {
//              country = W3WVoiceCountry(code: countryCode)
//            }
//            
//            var distance: W3WVoiceDistance? = nil
//            if let kilometers = sugg["distanceToFocusKm"] as? Double {
//              distance = W3WVoiceDistance(kilometers: kilometers)
//            }
//            
//            var language: W3WVoiceLanguage? = nil
//            if let languageCode = sugg["language"] as? String {
//              language = W3WVoiceLanguage(code: languageCode)
//            }
//            
//            let suggestion = W3WVoiceSuggestion(
//              words: sugg["words"] as? String,
//              country: country,
//              nearestPlace: sugg["nearestPlace"] as? String,
//              distanceToFocus: distance,
//              language: language,
//              rank: sugg["rank"] as? Int
//            )
//            suggestions.append(suggestion)
//          }
//        }
//      }
//    }
//    return suggestions
//  }
//  
//  
//  /**
//   Make an array ot W3APISuggestionWithCoordinates from a data dictionary
//   - parameter from: Dictionary of values, usually from a JSON decode
//   */
////  func suggestionsWithCoordinates(from: [String: Any]?) -> [W3WApiSuggestionWithCoordinates]? {
////    var suggestions = [W3WApiSuggestionWithCoordinates]()
////    if let s = from {
////      if let list = s["suggestions"] as? Array<Any?>? {
////        for ss in list! {
////          if let sugg = ss as? Dictionary<String, Any?> {
////            let suggestion = W3WApiSuggestionWithCoordinates(with: sugg)
////            suggestions.append(suggestion)
////          }
////        }
////      }
////    }
////    return suggestions
////  }
//  
//  
//  /**
//   Make an array ot W3Line from a data dictionary
//   - parameter from: Dictionary of values, usually from a JSON decode
//   */
//  func lines(from: [String: Any]?) -> [W3WLine]? {
//    var lines = [W3WVoiceLine]()
//    if let r = from {
//      if let lineArray = r["lines"] as? Array<Any?>? {
//        for startEnd in lineArray! {
//          if let sa = startEnd as? Dictionary<String, Any?> {
//            if let start = sa["start"] as? Dictionary<String, Any?>, let end = sa["end"] as? Dictionary<String, Any?> {
//              let line = W3WVoiceLine(
//                start: CLLocationCoordinate2D(
//                  latitude: start["lat"] as! CLLocationDegrees,
//                  longitude: start["lng"] as! CLLocationDegrees),
//                end: CLLocationCoordinate2D(
//                  latitude: end["lat"] as! CLLocationDegrees,
//                  longitude: end["lng"] as! CLLocationDegrees))
//              lines.append(line)
//            }
//          }
//        }
//      }
//    }
//    return lines
//  }
//  
//  
//  // MARK: Version Headers
//  
//  
//  func getOsName() -> String {
//    #if os(macOS)
//      let os_name        = "Mac"
//    #elseif os(watchOS)
//      let os_name        = WKInterfaceDevice.current().systemName
//    #else
//      let os_name        = UIDevice.current.systemName
//    #endif
//    
//    return os_name
//  }
//  
//  
//  func getOsVersion() -> String {
//    let osv = ProcessInfo().operatingSystemVersion
//    return String(osv.majorVersion) + "."  + String(osv.minorVersion) + "."  + String(osv.patchVersion)
//  }
//  
//  
//  func getSwiftVersion() -> String {
//    var swift_version  = "x.x"
//    
//    #if swift(>=7)
//        swift_version = "7.x"
//    #elseif swift(>=6)
//        swift_version = "6.x"
//    #elseif swift(>=5)
//        swift_version = "5.x"
//    #elseif swift(>=4)
//        swift_version = "4.x"
//    #elseif swift(>=3)
//        swift_version = "3.x"
//    #elseif swift(>=2)
//        swift_version = "2.x"
//    #else
//        swift_version = "1.x"
//    #endif
//    
//    return swift_version
//  }
//  
//  
//  /// make the value for a header in W3W format to indicate version number and other basic info
//  public func getHeaderValue(version: String) -> String {
//    return "what3words-Swift/" + version + " (Swift " + getSwiftVersion() + "; " + getOsName() + " "  + getOsVersion() + ")"
//  }
//  
//  
//  // Establish the various version numbers in order to set an HTTP header for the URL session
//  // ugly, but haven't found a better, way, if anyone knows a better way to get the swift version at runtime, let us know...
//  private func figureOutVersions() {
//    version_header  = getHeaderValue(version: api_version)
//    bundle_header   = Bundle.main.bundleIdentifier ?? ""
//  }
//  
//}
