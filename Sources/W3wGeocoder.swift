//
//  W3wGeocoder.swift
//  what3words
//
//  Created by Mihai Dumitrache on 12/03/2017.
//  Updated to V3 API by Dave Duprey on 15/02/2019.
//  Copyright © 2017 What3Words. All rights reserved.
//

import Foundation
import CoreLocation


public typealias W3wGeocodeResponseHandler = ((_ result: [String: Any]?, _ error: Error?) -> Void)

public struct W3wGeocoder {
  
  private static var kApiUrl = "https://api.what3words.com/v3"
  
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
   You'll need to register for a what3words API key to access the API.
   Setup W3wGeocoder with your own apiKey.
   - parameter apiKey: What3Words api key
   */
  public static func setup(with apiKey: String) {
    self.instance = W3wGeocoder(apiKey: apiKey)
  }
  
  /**
   Converts a 3 word address to a position, expressed as coordinates of latitude and longitude.
   - parameter words: A 3 word address as a string
   - parameter format: Return data format type; can be one of json (the default) or geojson
   - parameter completion: A W3wGeocodeResponseHandler completion handler
   */
  public func convertToCoordinates(words: String, format: Format = .json, completion: @escaping W3wGeocodeResponseHandler) {
    let params: [String: String] = ["words": words, "format": format.rawValue ]
    self.performRequest(path: "/convert-to-coordinates", params: params, completion: completion)
  }
  
  /**
   Returns a three word address from a latitude and longitude
   - parameter coordinates: A CLLocationCoordinate2D object
   - parameter language: A supported 3 word address language as an ISO 639-1 2 letter code. Defaults to en
   - parameter format: Return data format type; can be one of json (the default) or geojson
   - parameter completion: A W3wGeocodeResponseHandler completion handler
   */
  public func convertTo3wa(coordinates: CLLocationCoordinate2D, language: String = "en", format: Format = .json, completion: @escaping W3wGeocodeResponseHandler) {
    let params: [String: String] = ["coordinates": "\(coordinates.latitude),\(coordinates.longitude)", "language": language, "format": format.rawValue ]
    self.performRequest(path: "/convert-to-3wa", params: params, completion: completion)
  }
  
  /**
   Returns a list of 3 word addresses based on user input and other parameters.
   - parameter input: The full or partial 3 word address to obtain suggestions for. At minimum this must be the first two complete words plus at least one character from the third word.
   - options are provided by instantiating AutoSuggestOption objects in the varidic length parameter list.  Eg:
        -  autosuggest(input: "filled.count.soap", options: FallbackLanguage("en"), BoundingCircle(51.4243877, -0.3474524, 4.0), NumberResults(5), completion_handler)
   
   - option NumberResults(numberOfResults:String): The number of AutoSuggest results to return. A maximum of 100 results can be specified, if a number greater than this is requested, this will be truncated to the maximum. The default is 3
   - option Focus(focus:CLLocationCoordinate2D): This is a location, specified as a latitude (often where the user making the query is). If specified, the results will be weighted to give preference to those near the focus. For convenience, longitude is allowed to wrap around the 180 line, so 361 is equivalent to 1.
   - option NumberFocusResults(numberFocusResults:Int): Specifies the number of results (must be <= n-results) within the results set which will have a focus. Defaults to n-results. This allows you to run autosuggest with a mix of focussed and unfocussed results, to give you a "blend" of the two. This is exactly what the old V2 standarblend did, and standardblend behaviour can easily be replicated by passing n-focus-results=1, which will return just one focussed result and the rest unfocussed.
   - option BoundingCountry(country:String): Restricts autosuggest to only return results inside the countries specified by comma-separated list of uppercase ISO 3166-1 alpha-2 country codes (for example, to restrict to Belgium and the UK, use clip-to-country=GB,BE). Clip-to-country will also accept lowercase country codes. Entries must be two a-z letters. WARNING: If the two-letter code does not correspond to a country, there is no error: API simply returns no results. eg: "NZ,AU"
   - option BoundingBox(south_lat:Double, west_lng:Double, north_lat: Double, east_lng:Double): Restrict autosuggest results to a bounding box, specified by coordinates. Such as south_lat,west_lng,north_lat,east_lng, where: south_lat <= north_lat west_lng <= east_lng In other words, latitudes and longitudes should be specified order of increasing size. Lng is allowed to wrap, so that you can specify bounding boxes which cross the ante-meridian: -4,178.2,22,195.4 Example value: "51.521,-0.343,52.6,2.3324"
   - option BoundingCircle(lat:Double, lng:Double, kilometers:Double): Restrict autosuggest results to a circle, specified by lat,lng,kilometres. For convenience, longitude is allowed to wrap around 180 degrees. For example 181 is equivalent to -179. Example value: "51.521,-0.343,142"
   - option BoundingPolygon(polygon:[CLLocationCoordinate2D]): Restrict autosuggest results to a polygon, specified by a comma-separated list of lat,lng pairs. The polygon should be closed, i.e. the first element should be repeated as the last element; also the list should contain at least 4 entries. The API is currently limited to accepting up to 25 pairs. Example value: "51.521,-0.343,52.6,2.3324,54.234,8.343,51.521,-0.343"
   - option InputType(inputType:InputTypeEnum): For power users, used to specify voice input mode. Can be text (default), vocon-hybrid or nmdp-asr. See voice recognition section for more details.
   - option FallbackLanguage(language:String): For normal text input, specifies a fallback language, which will help guide AutoSuggest if the input is particularly messy. If specified, this parameter must be a supported 3 word address language as an ISO 639-1 2 letter code. For voice input (see voice section), language must always be specified.
   */
  public func autosuggest(input: String, options: AutoSuggestOption..., completion: @escaping W3wGeocodeResponseHandler) {
    var params: [String: String] = ["input": input]
    
    for option in options {
      params[option.key()] = option.value()
    }

    self.performRequest(path: "/autosuggest", params: params, completion: completion)
    }
  
 
  /**
   Returns a section of the 3m x 3m what3words grid for a given area.
   - parameter bounding-box: Bounding box, as a lat,lng,lat,lng, for which the grid should be returned. The requested box must not exceed 4km from corner to corner, or a BadBoundingBoxTooBig error will be returned. Latitudes must be >= -90 and <= 90, but longitudes are allowed to wrap around 180. To specify a bounding-box that crosses the anti-meridian, use longitude greater than 180. Example value: "50.0,179.995,50.01,180.0005" .
   - parameter format: Return data format type; can be one of json (the default) or geojson Example value:format=Format.json
   - parameter completion: A W3wGeocodeResponseHandler completion handler
   */
  public func gridSection(south_lat:Double, west_lng:Double, north_lat:Double, east_lng:Double, format: Format = .json, completion: @escaping W3wGeocodeResponseHandler) {
    let params: [String: String] = ["bounding-box": "\(south_lat),\(west_lng),\(north_lat),\(east_lng)", "format": format.rawValue]

    self.performRequest(path: "/grid-section", params: params, completion: completion)
  }

  /**
   Retrieves a list of the currently loaded and available 3 word address languages.
   - parameter completion: A W3wGeocodeResponseHandler completion handler
   */
  public func availableLanguages(completion: @escaping W3wGeocodeResponseHandler) {
    self.performRequest(path: "/available-languages", params: [:], completion: completion)
  }

  // MARK: API Request
  
  public struct W3wError: Error {
    public let code: String
    public let message: String
  }
  
  private func performRequest(path: String, params: [String: String], completion: @escaping W3wGeocodeResponseHandler) {
    
    var urlComponents = URLComponents(string: W3wGeocoder.kApiUrl + path)!

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
    
    let task = URLSession.shared.dataTask(with: url) { (data, _, error) in
      guard let data = data else {
        completion(nil, W3wError(code: "BadConnection", message: error?.localizedDescription ?? "Unknown Cause"))
        return
      }
      
      guard let jsonData = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] else {
        completion(nil, W3wError(code: "BadData", message: "Malformed JSON data returned"))
        return
      }
      
      guard let json = jsonData else {
        completion(nil, W3wError(code: "Invalid", message: "Invalid response"))
        return
      }

      if let error = json["error"] as? [String: Any], let code = error["code"] as? String, let message = error["message"] as? String {
        completion(nil, W3wError(code: code, message: message))
        return
      }
      
    //  if let status = json["status"] as? [String: Any], let code = status["code"] as? Int, let message = status["message"] as? String {
    //    completion(nil, W3wError(code: code, message: message))
    //    return
    //  }
      
      completion(json, nil)
    }
    task.resume()
  }
}

  // MARK: AutoSuggest Options


public class AutoSuggestOption {
    var k = ""
    var v = ""
    func key() -> String { return k }
    func value() -> String { return v }
}


public class FallbackLanguage : AutoSuggestOption {
  init(language:String) {
    super.init();
    k = "language";
    v = language
  }
}

public class NumberResults : AutoSuggestOption {
  init(numberOfResults:Int) {
    super.init();
    k = "number-results";
    v = "\(numberOfResults)"
  }
}

public class Focus : AutoSuggestOption {
  init(focus:CLLocationCoordinate2D) {
    super.init();
    k = "focus";
    v = "\(focus.latitude),\(focus.longitude)"
  }
}


public class NumberFocusResults : AutoSuggestOption {
  init(numberFocusResults:Int) {
    super.init();
    k = "number-focus-results";
    v = "\(numberFocusResults)"
  }
}


public class InputType : AutoSuggestOption {
  init(inputType:InputTypeEnum) {
    super.init();
    k = "input-type";
    v = inputType.rawValue
  }
}


public class BoundingCountry : AutoSuggestOption {
  init(country:String) {
    super.init();
    k = "clip-to-country";
    v = "\(country)"
  }
}


public class BoundingCircle : AutoSuggestOption {
  init(lat:Double, lng:Double, kilometers:Double) {
    super.init();
    k = "clip-to-circle";
    v = "\(lat),\(lng),\(kilometers)"
  }
}

public class BoundingBox : AutoSuggestOption {
  init(south_lat:Double, west_lng:Double, north_lat:Double, east_lng:Double) {
    super.init()
    k = "clip-to-bounding-box"
    v = "\(south_lat),\(west_lng),\(north_lat),\(east_lng)"
    }
  }

public class BoundingPolygon : AutoSuggestOption {
  init(polygon:[CLLocationCoordinate2D])
      {
      super.init()

      k = "clip-to-polygon"
      for point in polygon {
          v += "\(point.latitude),\(point.longitude),"
      }
      v.removeLast() // drop the last ','
      }
}

public enum InputTypeEnum : String {
  case voconHybrid = "vocon-hybrid"
  case nmdpAsr     = "nmdp-asr"
}

public enum Format : String {
  case json = "json"
  case geojson = "geojson"
}
