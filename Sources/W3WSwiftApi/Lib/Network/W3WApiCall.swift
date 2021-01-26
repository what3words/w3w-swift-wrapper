//
//  File.swift
//  
//
//  Created by Dave Duprey on 02/11/2020.
//  Copyright © 2020 What3Words. All rights reserved.
//

import Foundation
import CoreLocation
#if !os(macOS)
import UIKit
#endif
#if os(watchOS)
import WatchKit
#endif


/// closure definition for internal HTTP requests
public typealias W3WDataResponse             = ((_ result: [String: Any]?, _ error: W3WError?) -> Void)


/// A base class for making API calls to a service
public class W3WApiCall {
  
  var apiUrl: String
  var apiKey: String
  
  let         api_version    = W3WSettings.apiVersion
  private var version_header = "what3words-Swift/x.x.x (Swift x.x.x; iOS x.x.x)"
  private var bundle_header  = ""
  private var customHeaders  = [String:String]()

  
  // MARK: Constructors
  
  /// Initialize the API wrapper
  /// - Parameters:
  ///     - apiKey: Your api key.  Register for one at: https://accounts.what3words.com/create-api-key
  public init(apiUrl: String, apiKey: String) {
    self.apiUrl = apiUrl
    self.apiKey = apiKey
    self.figureOutVersions()
  }
  
  
  /// Initialize the API wrapper
  /// - Parameters:
  ///     - apiKey: Your api key.  Register for one at: https://accounts.what3words.com/create-api-key
  ///     - apiUrl: Url for custom server - for enterprise customers
  ///     - customHeaders: additional HTTP headers to send on requests - for enterprise customers
  public init(apiUrl: String, apiKey: String, customHeaders: [String: String]) {
    self.apiUrl = apiUrl
    self.apiKey = apiKey
    self.apiUrl = apiUrl
    self.set(customHeaders: customHeaders)
    self.figureOutVersions()
  }
  
  
  // MARK: Accessors
  
  /**
   This function is intended for use by our enterprise customers who
   run a private version of our API server.  Most people will noy use this
   Set a custom header to be sent on the next and all subsequent API calls
   - parameter customHeaders: additional HTTP headers to send on requests - for enterprise customers
   */
  public func set(customHeaders: [String: String]) {
    self.customHeaders = customHeaders
  }
  
  
  /**
   Clears all previously set custom headers - for enterprise customers
   */
  public func clearCustomHeaders() {
    customHeaders = [:]
  }

  
  /**
   indicates if W3W servers are being employed or this is set to a custom server
   */
  public func customServersSet() -> Bool {
    return apiUrl != W3WSettings.apiUrl
  }
  
  
  // MARK: HTTP Request
  
  
  /**
   Calls w3w URL
   - parameter path: The URL to call
   - parameter params: disctionary of parameters to send on querystring
   - parameter completion: The completion handler
   */
  public func performRequest(path: String, params: [String: String], completion: @escaping W3WDataResponse) {
    
    // prepare url components
    var urlComponents = URLComponents(string: apiUrl + path)!
    
    var queryItems: [URLQueryItem] = [URLQueryItem(name: "key", value: apiKey)]
    for (name, value) in params {
      let item = URLQueryItem(name: name, value: value)
      queryItems.append(item)
    }
    urlComponents.queryItems = queryItems
    
    guard let url = urlComponents.url else {
      assertionFailure("Invalid url: \(urlComponents)")
      return
    }
    
    // prepare request
    var request = URLRequest(url: url)
    
    request.setValue(version_header, forHTTPHeaderField: "X-W3W-Wrapper")
    request.setValue(bundle_header, forHTTPHeaderField: "X-Ios-Bundle-Identifier")
    
    // add custom headers if any
    for (name, value) in customHeaders {
      request.setValue(value, forHTTPHeaderField: name)
    }
    
    // make the call
    let task = URLSession.shared.dataTask(with: request) { (data, _, error) in
      guard let data = data else {
        completion(nil, W3WError.badConnection) //W3WError(code: "BadConnection", message: error?.localizedDescription ?? "Unknown Cause"))
        return
      }
      
      if data.count == 0 {
        completion(nil, nil)
        return
      }
      
      var jsonData:[String: Any]?
      
      do {
        jsonData = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
      }
      catch {
        completion(nil, W3WError.badJson) //(code: "BadData", message: "Malformed JSON data returned"))
        return
      }
      
      guard let json = jsonData else {
        completion(nil, W3WError.invalidResponse) //(code: "Invalid", message: "Invalid response"))
        return
      }
      
      if let error = json["error"] as? [String: Any], let code = error["code"] as? String {
        completion(nil, W3WError.from(code: code))
        return
      }
      
      if let code = json["code"] as? String {
        completion(nil, W3WError.from(code: code))
        return
      }
      
      if let error = json["error"] as? String {
        completion(nil, W3WError.from(code: error))
        return
      }
      
      completion(json, nil)
    }
    task.resume()
  }

  

  
  // MARK: Json parsing
  
  /**
   Make an array ot W3Language from a data dictionary
   - parameter from: Dictionary of values, usually from a JSON decode
   */
  func languages(from: [String: Any]?) -> [W3WApiLanguage]? {
    var languages: [W3WApiLanguage]? = nil
    
    if let l = from {
      if let list = l["languages"] as? Array<Any?>? {
        for ll in list ?? [] {
          if let lang = ll as? Dictionary<String, Any?> {
            let language = W3WApiLanguage(
              name: lang["name"] as? String ?? "",
              nativeName: lang["nativeName"] as? String ?? "",
              code: lang["code"] as? String ?? ""
            )
            if languages == nil {
              languages = [W3WApiLanguage]()
            }
            languages?.append(language)
          }
        }
      }
    }
    return languages
  }
  
  

  /**
   Make an array ot W3APISuggestion from a data dictionary
   - parameter from: Dictionary of values, usually from a JSON decode
   */
  func suggestions(from: [String: Any]?) -> [W3WApiSuggestion]? {
    var suggestions = [W3WApiSuggestion]()
    if let s = from {
      if let list = s["suggestions"] as? Array<Any?>? {
        for ss in list! {
          if let sugg = ss as? Dictionary<String, Any?> {
            let suggestion = W3WApiSuggestion(
              words: sugg["words"] as? String,
              country: sugg["country"] as? String,
              nearestPlace: sugg["nearestPlace"] as? String,
              distanceToFocus: sugg["distanceToFocusKm"] as? Double,
              language: sugg["language"] as? String,
              rank: sugg["rank"] as? Int
            )
            suggestions.append(suggestion)
          }
        }
      }
    }
    return suggestions
  }
  
  
  /**
   Make an array ot W3Line from a data dictionary
   - parameter from: Dictionary of values, usually from a JSON decode
   */
  func lines(from: [String: Any]?) -> [W3WLine]? {
    var lines = [W3WApiLine]()
    if let r = from {
      if let lineArray = r["lines"] as? Array<Any?>? {
        for startEnd in lineArray! {
          if let sa = startEnd as? Dictionary<String, Any?> {
            if let start = sa["start"] as? Dictionary<String, Any?>, let end = sa["end"] as? Dictionary<String, Any?> {
              let line = W3WApiLine(
                start: CLLocationCoordinate2D(
                  latitude: start["lat"] as! CLLocationDegrees,
                  longitude: start["lng"] as! CLLocationDegrees),
                end: CLLocationCoordinate2D(
                  latitude: end["lat"] as! CLLocationDegrees,
                  longitude: end["lng"] as! CLLocationDegrees))
              lines.append(line)
            }
          }
        }
      }
    }
    return lines
  }
  
  
  // MARK: Version Headers
  
  
  // Establish the various version numbers in order to set an HTTP header for the URL session
  // ugly, but haven't found a better, way, if anyone knows a better way to get the swift version at runtime, let us know...
  private func figureOutVersions() {
    #if os(macOS)
    let os_name        = "Mac"
    #elseif os(watchOS)
    let os_name        = WKInterfaceDevice.current().systemName
    #else
    let os_name        = UIDevice.current.systemName
    #endif
    let os_version     = ProcessInfo().operatingSystemVersion
    var swift_version  = "x.x"
    //var api_version    = "x.x.x"
    
    #if swift(>=7)
    swift_version = "7.x"
    #elseif swift(>=6)
    swift_version = "6.x"
    #elseif swift(>=5)
    swift_version = "5.x"
    #elseif swift(>=4)
    swift_version = "4.x"
    #elseif swift(>=3)
    swift_version = "3.x"
    #elseif swift(>=2)
    swift_version = "2.x"
    #else
    swift_version = "1.x"
    #endif
    
    version_header  = "what3words-Swift/" + api_version + " (Swift " + swift_version + "; " + os_name + " "  + String(os_version.majorVersion) + "."  + String(os_version.minorVersion) + "."  + String(os_version.patchVersion) + ")"
    bundle_header   = Bundle.main.bundleIdentifier ?? ""
  }
  
  
  
  
}
