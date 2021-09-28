//
//  Model.swift
//  AutosuggestExampleSwiftUI
//
//  Created by Dave Duprey on 14/09/2021.
//

import Foundation
import MapKit
import W3WSwiftApi
import Combine



class Model: ObservableObject {
  
  @Published var autosuggest = W3WAutosuggestHelper(What3WordsV3(apiKey: "YourApiKey"))
  @Published var searchText = "///"
  @Published var error: W3WError?
  
  var cancellable: AnyCancellable?
  let somewhereInLondon = CLLocationCoordinate2D(latitude: 51.520847, longitude: -0.195521) // A place in London to use as focus for autosuggest.  Typically this is set to your user's GPS location
  
  init() {
    // subscribe to searchText changes
    cancellable = $searchText.sink { text in
      self.autosuggest.update(text: text, options: W3WOption.focus(self.somewhereInLondon)) { error in
        self.error = error
        self.objectWillChange.send()
      }
    }
  }
}
