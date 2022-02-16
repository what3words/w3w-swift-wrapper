//
//  TableViewController.swift
//  AutosuggestHelper
//
//  Created by Dave Duprey on 09/09/2021.
//

import UIKit
import MapKit
import W3WSwiftApi


// USING AUTOSUGGEST HELPER TO AUGMENT YOUR CURRENT AUTOCOMPLETE FIELD
//
// This is a basic app that queries Apple's address database using MKLocalSearchCompleter
// much like your app might be doing now with some geographical database.
//
// However, we added what3words suggestions to it using our convenience object
// W3WAutosuggestHelper.
//
// We used UITableViewController's ability to have multiple sections, and used section zero for
// the what3words suggestions and section one for the old fashioned addresses.
//
// W3WAutosuggestHelper has a function called update(text:options:completion) that will throttle
// the calls to no more than 3 per second, so it can be called as rapidly as your user can
// type.  It has a completion block to allow you to call something like tableView.reloadData()
//
// For providing row counts it has a getSuggestionCount(), and for retrieving individual
// suggestion, as you might do in a tableView(cellForRowAt:indexPath) call, there is a
// getSuggestion(row:Int) call
//
// Then once your user has selected a row, there is a selected(row:completion) which does
// some updating and returns a W3WSquare object upon completion. A W3WSquare is basically a
// W3WSuggestion except it also contains latitude,longitude information for the square outlines,
// and centerpoint of the square.
//
// The notable autosuggest helper code in this example is unabashedly commented in
// capital letters to make it esasier to identify the important parts


class TableViewController: UITableViewController, UISearchResultsUpdating, UISearchControllerDelegate, UISearchBarDelegate, MKLocalSearchCompleterDelegate {

  // MARK: - Variables
  
  // Search text field
  let searchController = UISearchController(searchResultsController: nil)
  
  // Apple's place search engine, and address list
  var regularAddressSearcher = MKLocalSearchCompleter()
  var regularAddressResults = [MKLocalSearchCompletion]()

  // WHAT3WORDS AUTOSUGGEST HELPER
  var autosuggest = W3WAutosuggestHelper(What3WordsV3(apiKey: "YourApiKey"))
  
  let locationInLondon = CLLocationCoordinate2D(latitude: 51.520847, longitude: -0.195521)
  
  
  // MARK: - Init
  
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    // configure search text field, and set delegates for callback
    searchController.searchResultsUpdater = self
    navigationItem.searchController = searchController
    navigationItem.searchController?.delegate = self
    
    // delegate for Apple's location database
    regularAddressSearcher.delegate = self
  }
  
  
  // MARK: - Search text updated
  
  
  /// called when the text in the search field has changed
  func updateSearchResults(for searchController: UISearchController) {
    if let text = searchController.searchBar.text {
      if text.count > 0 { // only search when there is something in the text field
      
        // update Apple's address search
        regularAddressSearcher.queryFragment = text
        
        // UPDATE WHAT3WORDS SEARCH, AND ON COMPLETION, RELOAD THE TABLE
        autosuggest.update(text: text, options: [W3WOption.focus(locationInLondon)]) { error in
          self.tableView.reloadData()
          
          // IF AN ERROR HAPPENED, SHOW IT ON SCREEN
          if let e = error {
            self.notify(title: "Error", message: e.description)
          }
        }
      }
    }
  }
  
  
  // reload the table when there are new Apple address results
  func completerDidUpdateResults(_ completer: MKLocalSearchCompleter) {
    regularAddressResults = completer.results
    tableView.reloadData()
  }

    
  // MARK: - Table view delegate

  
  /// one way to incorporate what3words suggestions into your autocomplete table, is to
  /// move your results to section one, and use section zero for what3words.
  /// here we return two sections, one for what3words, and one for Apple's address database
  override func numberOfSections(in tableView: UITableView) -> Int {
    return 2
  }

  
  /// return the row count for each section, section zero is what3words, and section one is Apple's addresses
  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    if section == 0 {
      return autosuggest.getSuggestionCount() // GET THE NUMBER OF SUGGESTIONS
    } else {
      return regularAddressResults.count
    }
  }


  /// make a cell for the table.  we fill the cell with the what3words suggestion data for section zero, and
  /// with Apple's address data for section one
  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = UITableViewCell(style: .subtitle, reuseIdentifier: nil)

    // GET THE SUGGESTION FOR THE CELL
    if indexPath.section == 0 {
      if let suggestion = autosuggest.getSuggestion(row: indexPath.row) {
        cell.textLabel?.text = "///" + (suggestion.words ?? "")
        cell.detailTextLabel?.text = suggestion.nearestPlace
      }
      
    // cell for regular address results
    } else {
      let searchResult = regularAddressResults[indexPath.row]
      cell.textLabel?.text = searchResult.title
      cell.detailTextLabel?.text = searchResult.subtitle
    }
    
    return cell
    }
  
  
  override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    tableView.deselectRow(at: indexPath, animated: true)

    // if this is section zero, then it is for a what3words suggestion
    if indexPath.section == 0 {
            
      // TELL THE AUTOSUGGEST HELPER THAT A ROW WAS SELECTED AND HAVE IT RETURN THE LAT,LONG COORDS IN A W3WSquare
      autosuggest.selected(row: indexPath.row) { square, error in
        if let e = error {
          self.notify(title: "Error", message: e.description)
        } else {
          self.notify(title: "\(square?.words ?? "")", message: "Latitude: " + "\(square?.coordinates?.latitude ?? 0.0)\nLongitude: " + "\(square?.coordinates?.longitude ?? 0.0)")
        }
      }
    }
  }

  
  // MARK: - Popup Message
  
  
  func notify(title: String, message: String) {
    let note = UIAlertController(title: title, message: message, preferredStyle: .actionSheet)
    note.addAction(UIAlertAction(title: "Dismiss", style: .default, handler: { _ in }))
    self.present(note, animated: true) { }
  }
  
}
