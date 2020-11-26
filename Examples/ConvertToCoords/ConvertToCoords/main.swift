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

api.convertToCoordinates(words: "filled.count.soap")  { (square, error) in
      
  // if there was an error, print it
  if let e = error {
    print(String(describing: e))
    
    // on success print the result
  } else if let s = square {
    print("The coordinates for ", (s.words ?? ""), " are ", (s.coordinates?.latitude ?? "?"), ", ", (s.coordinates?.longitude ?? "?"))
  }
  
}


// Wait to allow the above call to finish
// The wait is only nessesary because this is a command line app. Command line apps don't wait for asychronous calls to finish
// A better way to handle this is with DispatchSemaphore(), but as example code, we felt this would neeslessly muddy up the example
Thread.sleep(forTimeInterval: 10)
