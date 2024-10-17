//
//  W3WAutosuggestHelper.swift
//
//  Created by Dave Duprey on 23/08/2021.
//  Copyright © 2021 what3words. All rights reserved.
//

import Foundation
import CoreLocation
import W3WSwiftCore

@available(*, deprecated, renamed: "W3WAutoSuggestHelper")
public typealias W3WAutosuggestHelper = W3WAutoSuggestHelper


/// Wrapper for autosuggest calls including a debouncer to throttle calls and an onSelected to
/// find the coordinates only for the selected result.
public class W3WAutoSuggestHelper {
  
  /// The API or SDK
  var w3w: W3WProtocolV4?
  
  /// Suggestions found using the last text provided to update(text:completion)
  public var suggestions = [W3WSuggestion]()
  
  /// The debouncer
  var debouncer: W3WDebouncer<String>?
  
  /// Debounce delay
    public var debounceDelay =  1.0 //W3WSettings.defaultDebounceDelay

  /// To remember the last autosugggest text so that the autosuggest-selected can be called
  var lastAutosuggestTextUsed = ""

  
  /// initilise with the API or SDK
  /// - parameter w3w: The API or SDK
  public init(_ w3w: W3WProtocolV4) {
    self.w3w = w3w
  }
  
  
  /// called to update the text to use for the autosuggest calls.  Typically called for every
  /// character a user types in a text field
  /// - parameter text: the text to search from
  /// - parameter options: options for the autosuggest call
  /// - parameter completion: indicates when new results are ready (typically used to trigger a results table reload)
  public func update(text: String, options: [W3WOption]? = [], completion: @escaping ([W3WSuggestion], W3WError?) -> () = { _,_ in }) {
    if debouncer == nil {
      debouncer = W3WDebouncer<String>(delay: debounceDelay) { text in
        self.lastAutosuggestTextUsed = text
        self.w3w?.autosuggest(text: text, options: options) { suggestions, error in
          if let s = suggestions {
            self.suggestions = s
          } else {
            self.suggestions = []
          }
          DispatchQueue.main.async {
            completion(self.suggestions, error)
          }
        }
      }
    }
        
    if w3w?.isPossible3wa(text: text) ?? false {
      debouncer?.execute(text)
    } else {
      suggestions = []
      DispatchQueue.main.async {
        // TODO: check this works
        completion([], nil)
      }
    }
  }
  

  /// called to update the text to use for the autosuggest calls.  Typically called for every
  /// character a user types in a text field
  /// - parameter text: the text to search from
  /// - parameter options: options for the autosuggest call
  /// - parameter completion: indicates when new results are ready (typically used to trigger a results table reload)
  public func update(text: String, options: W3WOptions, completion: @escaping ([W3WSuggestion], W3WError?) -> () = { _,_ in }) {
    update(text: text, options: options.options, completion: completion)
  }
  

  /// called to update the text to use for the autosuggest calls.  Typically called for every
  /// character a user types in a text field
  /// - parameter text: the text to search from
  /// - parameter options: options for the autosuggest call
  /// - parameter completion: indicates when new results are ready (typically used to trigger a results table reload)
  public func update(text: String, options: W3WOption..., completion: @escaping ([W3WSuggestion], W3WError?) -> () = { _,_ in }) {
    update(text: text, options: options, completion: completion)
  }
  

  /// returns the number of suggestions stored, typically used in a tableView(_ tableView:numberOfRowsInSection:) call
  public func getSuggestionCount() -> Int {
    return suggestions.count
  }
  
  
  /// returns a suggestion by it's array index, typically used in a tableView(_tableView:cellForRowAt:) for display values
  /// - parameter row: the cell row for the suggestion
  public func getSuggestion(row: Int) -> W3WSuggestion? {
    if row < suggestions.count {
      return suggestions[row]
    } else {
      return nil
    }
  }
  
  
  func getIndex(suggestion: W3WSuggestion) -> Int {
    return Int(suggestions.firstIndex(where: { s in s.words == suggestion.words }) ?? 0)
  }

  
  /// calls back with a W3WSquare including lat,lng coords, typically used in tableView(_ tableView: UITableView, didSelectRowAt)
  /// to get coords for the user selected tableview cell.
  /// - parameter suggestion: a suggestion contained in the suggestions list
  /// - parameter completion: returns a W3WSquare containing lat,lng,  or W3WError when completed
  public func selected(suggestion: W3WSuggestion, completion: @escaping W3WSquareResponse) {
    if let api = w3w as? What3WordsV4 {
      
      // find the rank of the suggestion
      var rank = getIndex(suggestion: suggestion)
      if let apiSuggestion = suggestion as? W3WApiSuggestion {
        rank = apiSuggestion.rank ?? getIndex(suggestion: suggestion)
      }
      
      // notify about selection
      if let words = suggestion.words {
        api.autosuggestSelection(selection: words, rank: rank, rawInput: lastAutosuggestTextUsed)
      }
    }
    
    // get the coordinates
    if let words = suggestion.words {
      w3w?.convertToCoordinates(words: words) { square, error in
        DispatchQueue.main.async {
          completion(square, error)
        }
      }
    }
  }
  
  
  /// calls back with a W3WSquare including lat,lng coords, typically used in tableView(_ tableView: UITableView, didSelectRowAt)
  /// to get coords for the user selected tableview cell.
  /// - parameter row: the cell row for the suggestion
  public func selected(row: Int, completion: @escaping W3WSquareResponse) {
    if let suggestion = getSuggestion(row: row) {
      selected(suggestion: suggestion, completion: completion)
    }
  }
  
  
}



