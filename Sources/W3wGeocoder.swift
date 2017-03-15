//
//  W3wGeocoder.swift
//  what3words
//
//  Created by Mihai Dumitrache on 12/03/2017.
//  Copyright © 2017 What3Words. All rights reserved.
//

import Foundation
import CoreLocation

public typealias W3wGeocodeResponseHandler = ((_ result: [String: Any]?, _ error: Error?) -> Void)

public struct W3wGeocoder {
  
  private static var kApiUrl = "https://api.what3words.com/v2"
  
  private static var instance: W3wGeocoder?
  private var apiKey: String!
  
  private init(apiKey: String) {
    self.apiKey = apiKey
  }
  
  private init() {
  }
  
  public static var shared: W3wGeocoder {
    get {
      guard let instance = W3wGeocoder.instance else {
        fatalError("You need to call `W3wGeocoder.setup(with: \"<your api key>\")`")
      }
      return instance
    }
  }
  
  /**
   * You'll need to register for a what3words API key to access the API.
   * Setup W3wGeocoder with your own apiKey.
   * @param key What3Words api key
   */
  public static func setup(with apiKey: String) {
    self.instance = W3wGeocoder(apiKey: apiKey)
  }
  
  /**
   * Forward geocodes a 3 word address to a position, expressed as coordinates of latitude and longitude.
   * @param addr A 3 word address as a string
   * @param lang A supported 3 word address language as an ISO 639-1 2 letter code. Defaults to en
   * @param display Return display type; can be one of full (the default), terse (less output) or minimal (the bare minimum)
   * @param completion A W3wGeocodeResponseHandler completion handler
   */
  public func forwardGeocode(addr: String, lang: String = "en", display: String = "full", completion: @escaping W3wGeocodeResponseHandler) {
    let params: [String: String] = ["addr": addr, "key": apiKey, "lang": lang, "display": display ]
    self.performRequest(path: "/forward", params: params, completion: completion)
  }
  
  /**
   * Reverse geocodes coordinates, expressed as latitude and longitude to a 3 word address.
   * @param coords A CLLocationCoordinate2D object
   * @param lang A supported 3 word address language as an ISO 639-1 2 letter code. Defaults to en
   * @param display Return display type; can be one of full (the default), terse (less output) or minimal (the bare minimum)
   * @param completion A W3wGeocodeResponseHandler completion handler
   */
  public func reverseGeocode(coords: CLLocationCoordinate2D, lang: String = "en", display: String = "full", completion: @escaping W3wGeocodeResponseHandler) {
    let params: [String: String] = ["coords": "\(coords.latitude),\(coords.longitude)", "key": apiKey, "lang": lang, "display": display ]
    self.performRequest(path: "/reverse", params: params, completion: completion)
  }
  
  /**
   * Returns a list of 3 word addresses based on user input and other parameters.
   * @param addr The full or partial 3 word address to obtain suggestions for. At minimum this must be the first two complete words plus at least one character from the third word
   * @param lang For autosuggest the lang parameter is required; for autosuggest-ml, the lang parameter is optional. If specified, this parameter must be a supported 3 word address language as an ISO 639-1 2 letter code
   * @param focus A location, specified as a latitude,longitude used to refine the results. If specified, the results will be weighted to give preference to those near the specified location in addition to considering similarity to the addr string. If omitted the default behaviour is to weight results for similarity to the addr string only
   * @param clip Restricts results to those within a geographical area. If omitted defaults to clip=none. More details here: https://docs.what3words.com/api/v2/#autosuggest-clip
   * @param count The number of AutoSuggest results to return. A maximum of 100 results can be specified, if a number greater than this is requested, this will be truncated to the maximum. The default is 3
   * @param display Return display type; can be one of full (the default) or terse
   * @param completion A W3wGeocodeResponseHandler completion handler
   */
  public func autosuggest(addr: String, lang: String = "en", focus: CLLocationCoordinate2D? = nil, clip: String? = nil, count: Int = 3, display: String = "full", completion: @escaping W3wGeocodeResponseHandler) {
    var params: [String: String] = ["addr": addr, "key": apiKey, "lang": lang, "count": "\(count)", "display": display]
    if let focus = focus {
      params["focus"] = "\(focus.latitude),\(focus.longitude)"
    }
    if let clip = clip {
      params["clip"] = clip
    }
    
    self.performRequest(path: "/autosuggest", params: params, completion: completion)
  }
  
  /**
   * Returns a blend of the three most relevant 3 word address candidates for a given location, based on a full or partial 3 word address.
   * @param addr The full or partial 3 word address to obtain suggestions for. At minimum this must be the first two complete words plus at least one character from the third word
   * @param lang For autosuggest the lang parameter is required; for autosuggest-ml, the lang parameter is optional. If specified, this parameter must be a supported 3 word address language as an ISO 639-1 2 letter code
   * @param focus A location, specified as a latitude,longitude used to refine the results. If specified, the results will be weighted to give preference to those near the specified location in addition to considering similarity to the addr string. If omitted the default behaviour is to weight results for similarity to the addr string only
   * @param completion A W3wGeocodeResponseHandler completion handler
   */
  public func standardBlend(addr: String, lang: String = "en", focus: CLLocationCoordinate2D? = nil, completion: @escaping W3wGeocodeResponseHandler) {
    var params: [String: String] = ["addr": addr, "key": apiKey, "lang": lang]
    if let focus = focus {
      params["focus"] = "\(focus.latitude),\(focus.longitude)"
    }
    
    self.performRequest(path: "/standardblend", params: params, completion: completion)
  }
  
  /**
   * Returns a section of the 3m x 3m what3words grid for a given area.
   * @param bbox Bounding box, specified by the northeast and southwest corner coordinates, for which the grid should be returned. Example value: 52.208867,0.117540,52.207988,0.116126
   * @param completion A W3wGeocodeResponseHandler completion handler
   */
  public func grid(bbox: String, completion: @escaping W3wGeocodeResponseHandler) {
    let params: [String: String] = ["bbox": bbox, "key": apiKey]
    
    self.performRequest(path: "/grid", params: params, completion: completion)
  }
  
  /**
   * Retrieves a list of the currently loaded and available 3 word address languages.
   * @param completion A W3wGeocodeResponseHandler completion handler
   */
  public func languages(completion: @escaping W3wGeocodeResponseHandler) {
    let params: [String: String] = ["key": apiKey]
    
    self.performRequest(path: "/languages", params: params, completion: completion)
  }
  
  // MARK: API Request
  
  public struct W3wError: Error {
    public let code: Int
    public let message: String
  }
  
  private func performRequest(path: String, params: [String: String], completion: @escaping W3wGeocodeResponseHandler) {
    
    var urlComponents = URLComponents(string: W3wGeocoder.kApiUrl + path)!

    var queryItems: [URLQueryItem] = []
    for (name, value) in params {
      let item = URLQueryItem(name: name, value: value)
      queryItems.append(item)
    }
    urlComponents.queryItems = queryItems
    
    guard let url = urlComponents.url else {
      assertionFailure("Invalid url: \(urlComponents)")
      return
    }
    
    let task = URLSession.shared.dataTask(with: url) { (data, _, error) in
      guard let data = data else {
        completion(nil, error)
        return
      }
      
      guard let jsonData = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] else {
        completion(nil, error)
        return
      }
      
      guard let json = jsonData else {
        completion(nil, W3wError(code: 0, message: "Invalid response"))
        return
      }
      
      if let code = json["code"] as? Int, let message = json["message"] as? String {
        completion(nil, W3wError(code: code, message: message))
        return
      }
      
      if let status = json["status"] as? [String: Any], let code = status["code"] as? Int, let message = status["message"] as? String {
        completion(nil, W3wError(code: code, message: message))
        return
      }
      
      completion(json, nil)
    }
    task.resume()
  }
}
