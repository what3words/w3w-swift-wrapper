//
//  main.swift
//  Example
//
//  Created by Dave Duprey on 06/03/2019.
//  Copyright © 2019 What3Words. All rights reserved.
//

import Foundation
import CoreLocation


W3wGeocoder.setup(with: "<Secret API Key>")

let france  = ClipToCountry(country: "FR")
let place   = Focus(focus: CLLocationCoordinate2D(latitude: 48.856618, longitude: 2.3522411))
let count   = NumberResults(numberOfResults: 4)

// Find some suggestions for a partial address
W3wGeocoder.shared.autosuggest(input: "freshen.overlook.clo", options: france, place, count)  { (suggestions, error) in
  
  // if there was an error, print it
  if let e = error {
    print(e.code, e.message)

  // on success print the results
  } else {
    for suggestion in suggestions ?? [] {
      print("\(suggestion.words) is near \(suggestion.nearestPlace) - Country Code:\(suggestion.country)")
    }
  }
  
  // Find coordinates for the first suggestion
  if let suggestion = suggestions?.first {
    print("\nFinding the coordinates for: \(suggestion.words)")

    W3wGeocoder.shared.convertToCoordinates(words: suggestion.words)  { (place, error) in

      // if there was an error, print it
      if let e = error {
        print(e.code, e.message)

      // on success print the result
      } else if let p = place {
        print("The coordinates for \(p.words) are (\(p.coordinates.latitude),\(p.coordinates.longitude))")
      }
    }

  }
  
}


// Wait to allow the above call to finish
// The wait is only nessesary because this is a command line app. Command line apps don't wait for asychronous calls to finish
// A better way to handle this is with DispatchSemaphore(), but as example code, we felt this would neeslessly muddy up the example
Thread.sleep(forTimeInterval: 10)
