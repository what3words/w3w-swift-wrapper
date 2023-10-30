//
//  File.swift
//  
//
//  Created by Dave Duprey on 16/12/2022.
//

import CoreLocation
import W3WSwiftCore


extension W3WApiLine {
  
  init(jsonLine: JsonLine?) throws {
    if let startLatitude  = jsonLine?.start?.lat,
       let startLongitude = jsonLine?.start?.lng,
       let endLatitude    = jsonLine?.end?.lat,
       let endLongitude   = jsonLine?.end?.lng
    {
      self.init(start: CLLocationCoordinate2D(latitude: startLatitude, longitude: startLongitude), end: CLLocationCoordinate2D(latitude: endLatitude, longitude: endLongitude))
      
    } else {
      throw W3WError.message("Bad parameters passed to W3WLine constructor")
    }
  }
  
}
