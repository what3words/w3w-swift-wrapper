//
//  main.swift
//  ConvertToCoords
//
//  Created by Dave Duprey on 04/11/2020.
//

import Foundation
import CoreLocation
import W3WSwiftApi


var api = What3WordsV3(apiKey: "<Your API Key>")

let france  = W3WOption.clipToCountry("FR")
let place   = W3WOption.focus(CLLocationCoordinate2D(latitude: 48.856618, longitude: 2.3522411))
let count   = W3WOption.numberOfResults(4)

// Find some suggestions for a partial address
api.autosuggest(text: "freshen.overlook.clo", options: france, place, count)  { (suggestions, error) in
  
  // if there was an error, print it
  if let e = error {
    print(String(describing: e))
    
    // on success print the results
  } else {
    for suggestion in suggestions ?? [] {
      print((suggestion.words ?? ""), " is near ", (suggestion.nearestPlace ?? ""), "Country Code: ", (suggestion.country ?? ""))
    }
  }
  
  // Find coordinates for the first suggestion
  if let words = suggestions?.first?.words {
    print("\nFinding the coordinates for: \(words)")
    
    api.convertToCoordinates(words: words)  { (square, error) in
      
    // if there was an error, print it
    if let e = error {
      print(String(describing: e))
      
      // on success print the result
    } else if let s = square {
      print("The coordinates for ", (s.words ?? ""), " are ", (s.coordinates?.latitude ?? "?"), ", ", (s.coordinates?.longitude ?? "?"))
    }
  }
    
  }
  
}


// Wait to allow the above call to finish
// The wait is only nessesary because this is a command line app. Command line apps don't wait for asychronous calls to finish
// A better way to handle this is with DispatchSemaphore(), but as example code, we felt this would neeslessly muddy up the example
Thread.sleep(forTimeInterval: 10)
