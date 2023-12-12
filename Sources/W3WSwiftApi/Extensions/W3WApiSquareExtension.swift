//
//  File.swift
//  
//
//  Created by Dave Duprey on 08/11/2022.
//


import CoreLocation
import W3WSwiftCore


extension W3WApiSquare {

  init(jsonSquare: JsonSquare?) {
    
    // parse the language code which could be of the form 'XX', or, 'XX_XX'
    var lang: W3WApiLanguage? = nil
    
    if let code = jsonSquare?.language {
      if let locale = jsonSquare?.locale {
        lang = W3WApiLanguage(locale: locale)
      } else {
        lang = W3WApiLanguage(code: code)
      }
    }
    
    var coords: CLLocationCoordinate2D? = nil
    if let lat = jsonSquare?.coordinates?.lat, let lng = jsonSquare?.coordinates?.lng {
      coords = CLLocationCoordinate2D(latitude: lat, longitude: lng)
    }
    
    var box: W3WApiBox? = nil
    if let swlat = jsonSquare?.square?.southwest?.lat, let swlng = jsonSquare?.square?.southwest?.lng, let nelat = jsonSquare?.square?.northeast?.lat, let nelng = jsonSquare?.square?.northeast?.lng {
      box = W3WApiBox(southWest: CLLocationCoordinate2D(latitude: swlat, longitude: swlng), northEast: CLLocationCoordinate2D(latitude: nelat, longitude: nelng))
    }
    
    self.words = jsonSquare?.words
    self.country = jsonSquare?.country == nil ? nil : W3WApiCountry(code: jsonSquare!.country!)
    self.nearestPlace = jsonSquare?.nearestPlace
    self.distanceToFocus = jsonSquare?.distanceToFocus == nil ? nil : W3WApiDistance(kilometers: jsonSquare!.distanceToFocus!)
    self.language = lang
    self.coordinates = coords
    self.bounds = box
    self.map = jsonSquare?.map
  }

}
