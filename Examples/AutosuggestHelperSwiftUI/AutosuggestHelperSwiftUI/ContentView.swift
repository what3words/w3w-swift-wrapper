//
//  ContentView.swift
//  AutosuggestExampleSwiftUI
//
//  Created by Dave Duprey on 13/09/2021.
//

import SwiftUI
import W3WSwiftApi


// MARK: View

// shows a text field and a list below it with what3words suggestions
struct ContentView: View {
  
  // model contains the W3WAutosuggestHelper
  @ObservedObject var model = Model()
  
  // used to display the selected suggestion
  @State var showingSuggestion = false
  @State var selectedSquare: W3WSquare?

  var body: some View {

    // show the textfield and suggestions or error if any
    VStack {
      TextField("eg: filled.count.soap", text: $model.searchText)
        .padding(4.0)
        .border(Color.gray, width: 0.5)
      
      // absent any error, list the suggestions
      if model.error == nil {
        List(model.autosuggest.suggestions, id: \.self.words) { suggestion in
          SuggestionView(suggestion: suggestion)
            .onTapGesture { self.tapped(suggestion: suggestion) } // if a row is tapped, show it in an alert
        }
        
        // if there is an error, then present it
      } else {
        VStack {
          Text(model.error?.description ?? "")
            .font(.title)
          Spacer()
        }
      }
      
      
    }
    // pop up a little alert showing the selected value
    .alert(isPresented: $showingSuggestion, content: {
      Alert(title: Text(selectedSquare?.words ?? "No result"), message: Text(String(format: "%@, (%f,%f)", selectedSquare?.nearestPlace ?? "", selectedSquare?.coordinates?.latitude ?? 0.0, selectedSquare?.coordinates?.latitude ?? 0.0)), dismissButton: .destructive(Text("Dismiss"), action: { showingSuggestion = false })) })
    .padding(16.0)

  }
  
  
  /// called when a row is tapped this calls selected and shows the resulting W3WSquare.  A W3WSquare is basically a suggestion but has coordinate values as well
  func tapped(suggestion: W3WSuggestion) {
    model.autosuggest.selected(suggestion: suggestion) { square, error in
      selectedSquare = square
      showingSuggestion = true
    }
  }
  
}


struct ContentView_Previews: PreviewProvider {
  static var previews: some View {
    ContentView()
  }
}
