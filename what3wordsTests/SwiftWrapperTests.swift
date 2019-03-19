//
//  what3wordsTests.swift
//  what3wordsTests
//
//  Created by Mihai Dumitrache on 12/03/2017.
//  Copyright © 2017 What3Words. All rights reserved.
//

import XCTest
import CoreLocation

@testable import what3words

class SwiftWrapperTests: XCTestCase {
  
  
  override class func setUp() {
    super.setUp()

  W3wGeocoder.setup(with: "<Secret API Key>")
  }
  
  
  func testConvertToCoordinates() {
    let expectation = self.expectation(description: "Convert To Coordinates")
    W3wGeocoder.shared.convertToCoordinates(words: "index.home.raft") { (place, error) in

      XCTAssertEqual(place?.words, "index.home.raft")
      XCTAssertNil(error)

      expectation.fulfill()
    }
    waitForExpectations(timeout: 3.0, handler: nil)
  }


  func testConvertTo3waDifferentLanguage() {
    let expectation = self.expectation(description: "Convert to Words")
    W3wGeocoder.shared.convertTo3wa(coordinates: CLLocationCoordinate2D(latitude: 51.521238, longitude: -0.203607), language: "fr") { (place, error) in

      XCTAssertEqual(place?.words, "mitiger.tarir.prolonger")
      XCTAssertNil(error)

      expectation.fulfill()
    }
    waitForExpectations(timeout: 3.0, handler: nil)
  }


  func testConvertTo3wa() {
    let expectation = self.expectation(description: "Convert To 3wa")
    W3wGeocoder.shared.convertTo3wa(coordinates: CLLocationCoordinate2D(latitude: 51.521238, longitude: -0.203607)) { (place, error) in

      XCTAssertEqual(place?.words, "index.home.raft")
      XCTAssertNil(error)

      expectation.fulfill()
    }
    waitForExpectations(timeout: 3.0, handler: nil)
  }



  func testGridSection() {
    let expectation = self.expectation(description: "Grid")
    W3wGeocoder.shared.gridSection(south_lat: 52.208867, west_lng: 0.117540, north_lat: 52.207988, east_lng: 0.116126) { (grid, error) in

      XCTAssertGreaterThan(grid!.count, 0, "Grid lines missing")
      XCTAssertNotNil(grid)
      XCTAssertNil(error)
      expectation.fulfill()
    }
    waitForExpectations(timeout: 3.0, handler: nil)
  }


  func testGridSection2() {
    let expectation = self.expectation(description: "Grid")

    W3wGeocoder.shared.gridSection(southWest: CLLocationCoordinate2D(latitude: 52.208867, longitude:0.117540), northEast: CLLocationCoordinate2D(latitude: 52.207988, longitude:0.116126)) { (grid, error) in

      XCTAssertGreaterThan(grid!.count, 0, "Grid lines missing")
      XCTAssertNotNil(grid)
      XCTAssertNil(error)
      expectation.fulfill()
    }
    waitForExpectations(timeout: 3.0, handler: nil)
  }



  func testLanguages() {
    let expectation = self.expectation(description: "Languages")
    W3wGeocoder.shared.availableLanguages() { (languages, error) in

      XCTAssertNotNil(languages)
      XCTAssertGreaterThan(languages!.count, 0, "No languages returned")
      XCTAssertNotNil(languages?.first?.code)
      XCTAssertNotNil(languages?.first?.name)
      XCTAssertNotNil(languages?.first?.nativeName)
      XCTAssertNil(error)
      expectation.fulfill()
    }
    waitForExpectations(timeout: 3.0, handler: nil)
  }
  
  
  func testAutosuggest() {
    let expectation = self.expectation(description: "Autosuggest")
    W3wGeocoder.shared.autosuggest(input: "geschaft.planter.carciofi") { (suggestions, error) in
    
      XCTAssertEqual(suggestions?.count, 3)
      XCTAssertEqual(suggestions?.first?.words, "esche.piante.carciofi")
      XCTAssertNil(error)
  
      expectation.fulfill()
    }
    waitForExpectations(timeout: 3.0, handler: nil)
  }

//options: BoundingBox(southWest: , northEast:


  func testAutosuggestWtihBoundingBox1() {
    let expectation = self.expectation(description: "Autosuggest")
    
    W3wGeocoder.shared.autosuggest(input: "geschaft.planter.carciofi", options:BoundingBox(south_lat: 51.521, west_lng: -0.343, north_lat: 52.6, east_lng: 2.3324)) { (suggestions, error) in

      XCTAssertEqual(suggestions?.count, 2)
      XCTAssertEqual(suggestions?.first?.words, "restate.piante.carciofo")
      XCTAssertNil(error)

      expectation.fulfill()
    }
    waitForExpectations(timeout: 3.0, handler: nil)
  }



  func testAutosuggestWtihBoundingBox2() {
    let expectation = self.expectation(description: "Autosuggest")
    
    let southWest = CLLocationCoordinate2D(latitude: 51.521, longitude:-0.343)
    let northEast = CLLocationCoordinate2D(latitude: 52.6, longitude:2.3324)
    
    W3wGeocoder.shared.autosuggest(input: "geschaft.planter.carciofi", options:BoundingBox(southWest: southWest, northEast: northEast)) { (suggestions, error) in

      XCTAssertEqual(suggestions?.count, 2)
      XCTAssertEqual(suggestions?.first?.words, "restate.piante.carciofo")
      XCTAssertNil(error)

      expectation.fulfill()
    }
    waitForExpectations(timeout: 3.0, handler: nil)
  }



  func testAutosuggestWithFocus() {
    let expectation = self.expectation(description: "Autosuggest")

    W3wGeocoder.shared.autosuggest(input: "geschaft.planter.carciofi", options: Focus(focus: CLLocationCoordinate2D(latitude: 51.4243877, longitude: -0.34745)),NumberFocusResults(numberFocusResults: 2)) { (suggestions, error) in
    
      XCTAssertEqual(suggestions?.count, 3)
      XCTAssertEqual(suggestions?.first?.words, "restate.piante.carciofo")
      XCTAssertNil(error)

      expectation.fulfill()
    }
    waitForExpectations(timeout: 3.0, handler: nil)
  }


  
  func testAutosuggestWithCountry() {
    let expectation = self.expectation(description: "Autosuggest")

    W3wGeocoder.shared.autosuggest(input: "oui.oui.oui", options: ClipToCountry(country: "fr")) { (suggestions, error) in

      XCTAssertEqual(suggestions?.count, 3)
      XCTAssertEqual(suggestions?.first?.words, "oust.souk.souk")
      XCTAssertNil(error)

      expectation.fulfill()
    }
    waitForExpectations(timeout: 3.0, handler: nil)
  }

  
  func testAutosuggestWithCircle1() {
    let expectation = self.expectation(description: "Autosuggest")

    W3wGeocoder.shared.autosuggest(input: "mitiger.tarir.prolong", options: BoundingCircle(lat: 51.521238, lng: -0.203607, kilometers: 1.0)) { (suggestions, error) in

      XCTAssertEqual(suggestions?.count, 1)
      XCTAssertEqual(suggestions?.first?.words, "mitiger.tarir.prolonger")
      XCTAssertNil(error)

      expectation.fulfill()
    }
    waitForExpectations(timeout: 3.0, handler: nil)
  }


  
  func testAutosuggestWithCircle2() {
    let expectation = self.expectation(description: "Autosuggest")

    let centre = CLLocationCoordinate2D(latitude: 51.521238, longitude: -0.203607)

    W3wGeocoder.shared.autosuggest(input: "mitiger.tarir.prolong", options:BoundingCircle(centre: centre, kilometers: 1.0)) { (suggestions, error) in

      XCTAssertEqual(suggestions?.count, 1)
      XCTAssertEqual(suggestions?.first?.words, "mitiger.tarir.prolonger")
      XCTAssertNil(error)

      expectation.fulfill()
    }
    waitForExpectations(timeout: 3.0, handler: nil)
  }

  
  func testAutosuggestWithPolygon() {
    let expectation = self.expectation(description: "Autosuggest")

    let polygon = [
          CLLocationCoordinate2D(latitude:51.0, longitude:0.0),
          CLLocationCoordinate2D(latitude:51.0, longitude:0.1),
          CLLocationCoordinate2D(latitude:51.1, longitude:0.1),
          CLLocationCoordinate2D(latitude:51.1, longitude:0.0),
          CLLocationCoordinate2D(latitude:51.0, longitude:0.0),
          ];
    //,,,51.521,-0.343

    W3wGeocoder.shared.autosuggest(input: "scenes.irritated.sparkle", options:BoundingPolygon(polygon: polygon)) { (suggestions, error) in

      XCTAssertEqual(suggestions?.count, 1)
      XCTAssertEqual(suggestions?.first?.words, "scenes.irritated.sparkles")
      XCTAssertNil(error)

      expectation.fulfill()
    }
    
    waitForExpectations(timeout: 3.0, handler: nil)
  }


  
  func testMultilingualAutosuggest() {
    let expectation = self.expectation(description: "Autosuggest")
    W3wGeocoder.shared.autosuggest(input: "aaa.aaa.aaa", options: FallbackLanguage(language: "de")) { (suggestions, error) in

      XCTAssertEqual(suggestions?.count, 3)
      XCTAssertEqual(suggestions?.first?.words, "saal.saal.saal")
      XCTAssertNil(error)

      expectation.fulfill()
    }
    waitForExpectations(timeout: 3.0, handler: nil)
  }



  func testAutosuggestNumberResults() {
    let expectation = self.expectation(description: "Autosuggest")
    W3wGeocoder.shared.autosuggest(input: "geschaft.planter.carciofi", options: NumberResults(numberOfResults: 5)) { (suggestions, error) in

      XCTAssertEqual(suggestions?.count, 5)
      XCTAssertEqual(suggestions?.first?.words, "esche.piante.carciofi")
      XCTAssertNil(error)

      expectation.fulfill()
    }
    waitForExpectations(timeout: 3.0, handler: nil)
  }



  func testVoiceAutosuggest() {
    let expectation = self.expectation(description: "Autosuggest")
    
    let json = "%7B%22_isInGrammar%22%3A%22yes%22%2C%22_isSpeech%22%3A%22yes%22%2C%22_hypotheses%22%3A%5B%7B%22_score%22%3A342516%2C%22_startRule%22%3A%22whatthreewordsgrammar%23_main_%22%2C%22_conf%22%3A6546%2C%22_endTimeMs%22%3A6360%2C%22_beginTimeMs%22%3A1570%2C%22_lmScore%22%3A300%2C%22_items%22%3A%5B%7B%22_type%22%3A%22terminal%22%2C%22_score%22%3A34225%2C%22_orthography%22%3A%22tend%22%2C%22_conf%22%3A6964%2C%22_endTimeMs%22%3A2250%2C%22_beginTimeMs%22%3A1580%7D%2C%7B%22_type%22%3A%22terminal%22%2C%22_score%22%3A47670%2C%22_orthography%22%3A%22artichokes%22%2C%22_conf%22%3A7176%2C%22_endTimeMs%22%3A3180%2C%22_beginTimeMs%22%3A2260%7D%2C%7B%22_type%22%3A%22terminal%22%2C%22_score%22%3A43800%2C%22_orthography%22%3A%22poached%22%2C%22_conf%22%3A6181%2C%22_endTimeMs%22%3A4060%2C%22_beginTimeMs%22%3A3220%7D%5D%7D%2C%7B%22_score%22%3A342631%2C%22_startRule%22%3A%22whatthreewordsgrammar%23_main_%22%2C%22_conf%22%3A6498%2C%22_endTimeMs%22%3A6360%2C%22_beginTimeMs%22%3A1570%2C%22_lmScore%22%3A300%2C%22_items%22%3A%5B%7B%22_type%22%3A%22terminal%22%2C%22_score%22%3A34340%2C%22_orthography%22%3A%22tent%22%2C%22_conf%22%3A6772%2C%22_endTimeMs%22%3A2250%2C%22_beginTimeMs%22%3A1580%7D%2C%7B%22_type%22%3A%22terminal%22%2C%22_score%22%3A47670%2C%22_orthography%22%3A%22artichokes%22%2C%22_conf%22%3A7176%2C%22_endTimeMs%22%3A3180%2C%22_beginTimeMs%22%3A2260%7D%2C%7B%22_type%22%3A%22terminal%22%2C%22_score%22%3A43800%2C%22_orthography%22%3A%22poached%22%2C%22_conf%22%3A6181%2C%22_endTimeMs%22%3A4060%2C%22_beginTimeMs%22%3A3220%7D%5D%7D%2C%7B%22_score%22%3A342668%2C%22_startRule%22%3A%22whatthreewordsgrammar%23_main_%22%2C%22_conf%22%3A6474%2C%22_endTimeMs%22%3A6360%2C%22_beginTimeMs%22%3A1570%2C%22_lmScore%22%3A300%2C%22_items%22%3A%5B%7B%22_type%22%3A%22terminal%22%2C%22_score%22%3A34225%2C%22_orthography%22%3A%22tend%22%2C%22_conf%22%3A6964%2C%22_endTimeMs%22%3A2250%2C%22_beginTimeMs%22%3A1580%7D%2C%7B%22_type%22%3A%22terminal%22%2C%22_score%22%3A47670%2C%22_orthography%22%3A%22artichokes%22%2C%22_conf%22%3A7176%2C%22_endTimeMs%22%3A3180%2C%22_beginTimeMs%22%3A2260%7D%2C%7B%22_type%22%3A%22terminal%22%2C%22_score%22%3A41696%2C%22_orthography%22%3A%22perch%22%2C%22_conf%22%3A5950%2C%22_endTimeMs%22%3A4020%2C%22_beginTimeMs%22%3A3220%7D%5D%7D%2C%7B%22_score%22%3A342670%2C%22_startRule%22%3A%22whatthreewordsgrammar%23_main_%22%2C%22_conf%22%3A6474%2C%22_endTimeMs%22%3A6360%2C%22_beginTimeMs%22%3A1570%2C%22_lmScore%22%3A300%2C%22_items%22%3A%5B%7B%22_type%22%3A%22terminal%22%2C%22_score%22%3A34379%2C%22_orthography%22%3A%22tinge%22%2C%22_conf%22%3A6705%2C%22_endTimeMs%22%3A2250%2C%22_beginTimeMs%22%3A1580%7D%2C%7B%22_type%22%3A%22terminal%22%2C%22_score%22%3A47670%2C%22_orthography%22%3A%22artichokes%22%2C%22_conf%22%3A7176%2C%22_endTimeMs%22%3A3180%2C%22_beginTimeMs%22%3A2260%7D%2C%7B%22_type%22%3A%22terminal%22%2C%22_score%22%3A43800%2C%22_orthography%22%3A%22poached%22%2C%22_conf%22%3A6181%2C%22_endTimeMs%22%3A4060%2C%22_beginTimeMs%22%3A3220%7D%5D%7D%2C%7B%22_score%22%3A342783%2C%22_startRule%22%3A%22whatthreewordsgrammar%23_main_%22%2C%22_conf%22%3A6426%2C%22_endTimeMs%22%3A6360%2C%22_beginTimeMs%22%3A1570%2C%22_lmScore%22%3A300%2C%22_items%22%3A%5B%7B%22_type%22%3A%22terminal%22%2C%22_score%22%3A34340%2C%22_orthography%22%3A%22tent%22%2C%22_conf%22%3A6772%2C%22_endTimeMs%22%3A2250%2C%22_beginTimeMs%22%3A1580%7D%2C%7B%22_type%22%3A%22terminal%22%2C%22_score%22%3A47670%2C%22_orthography%22%3A%22artichokes%22%2C%22_conf%22%3A7176%2C%22_endTimeMs%22%3A3180%2C%22_beginTimeMs%22%3A2260%7D%2C%7B%22_type%22%3A%22terminal%22%2C%22_score%22%3A41696%2C%22_orthography%22%3A%22perch%22%2C%22_conf%22%3A5950%2C%22_endTimeMs%22%3A4020%2C%22_beginTimeMs%22%3A3220%7D%5D%7D%2C%7B%22_score%22%3A342822%2C%22_startRule%22%3A%22whatthreewordsgrammar%23_main_%22%2C%22_conf%22%3A6402%2C%22_endTimeMs%22%3A6360%2C%22_beginTimeMs%22%3A1570%2C%22_lmScore%22%3A300%2C%22_items%22%3A%5B%7B%22_type%22%3A%22terminal%22%2C%22_score%22%3A34379%2C%22_orthography%22%3A%22tinge%22%2C%22_conf%22%3A6705%2C%22_endTimeMs%22%3A2250%2C%22_beginTimeMs%22%3A1580%7D%2C%7B%22_type%22%3A%22terminal%22%2C%22_score%22%3A47670%2C%22_orthography%22%3A%22artichokes%22%2C%22_conf%22%3A7176%2C%22_endTimeMs%22%3A3180%2C%22_beginTimeMs%22%3A2260%7D%2C%7B%22_type%22%3A%22terminal%22%2C%22_score%22%3A41696%2C%22_orthography%22%3A%22perch%22%2C%22_conf%22%3A5950%2C%22_endTimeMs%22%3A4020%2C%22_beginTimeMs%22%3A3220%7D%5D%7D%5D%2C%22_resultType%22%3A%22NBest%22%7D"
    
    W3wGeocoder.shared.autosuggest(input: json.removingPercentEncoding ?? "", options: InputType(inputType: .voconHybrid), NumberResults(numberOfResults: 3), Focus(focus: CLLocationCoordinate2D(latitude: 51.4243877, longitude: -0.3474524))) { (suggestions, error) in

      XCTAssertEqual(suggestions?.count, 3)
      XCTAssertEqual(suggestions?.first?.words, "tend.artichokes.poached")
      XCTAssertNil(error)
      expectation.fulfill()
    }
    waitForExpectations(timeout: 3.0, handler: nil)
  }

  
  func testBadWords() {
    let expectation = self.expectation(description: "Bad Words")

    W3wGeocoder.shared.convertToCoordinates(words: "khekheflekh.khekheflekh.khekheflekh") { (place, error) in

      XCTAssertNil(place?.words)
      XCTAssertEqual(error?.code, "BadWords")

      expectation.fulfill()
    }
    waitForExpectations(timeout: 3.0, handler: nil)
  }



  func testIncompleteWords() {
    let expectation = self.expectation(description: "Invalida 3wa")
    W3wGeocoder.shared.convertToCoordinates(words: "index.raft") { (place, error) in

      XCTAssertNil(place?.words)
      XCTAssertNotNil(error)
      XCTAssertNil(place)

      expectation.fulfill()
    }
    waitForExpectations(timeout: 3.0, handler: nil)
  }



  
}
