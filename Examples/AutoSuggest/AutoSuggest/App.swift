//
//  App.swift
//  AutoSuggest
//
//  Created by Dave Duprey on 03/11/2020.
//

import SwiftUI
import W3WSwiftApi


//========================================
// MARK: Model

class Model: ObservableObject {
  
  var api = What3WordsV3(apiKey: "<Your API Key>")
  
  @Published var suggestions = [W3WSuggestion]()
  @Published var error: String?

  init() {
    // get 24 results from the partial three word address (generally we reccomend leaving the result count to the default 3, but we set this to 24 for example sake
    api.autosuggest(text: "filled.count.soa", options: W3WOptions().clipToCountry("GB")) { suggestions, error in
      DispatchQueue.main.async { // ensure this runs on the main thread as it updates the UI
        if let e = error {
          self.error = String(describing: e)
        } else {
          self.suggestions = suggestions ?? []
        }
      }
    }
  }
}


//========================================
// MARK: View

struct ContentView: View {
  
  @ObservedObject var model: Model
  
  var body: some View {
    
    // if no error show the list of suggestions
    if model.error == nil {
      List(model.suggestions, id: \.self.words) { suggestion in
        VStack(alignment: .leading) {
          Text("///").foregroundColor(.accentColor) + Text((suggestion.words ?? ""))
          Text((suggestion.nearestPlace ?? "") + ", " + (suggestion.country ?? ""))
            .font(.footnote)
        }
      }

    // if there is an error, show that instead
    } else {
      Text(model.error ?? "")
        .font(.title)
    }
  }
}


//========================================
// MARK: App

@main
struct AutoSuggestApp: App {
  
  @ObservedObject var model = Model()
  
  var body: some Scene {
    WindowGroup {
      ContentView(model: model)
    }
  }
  
}


