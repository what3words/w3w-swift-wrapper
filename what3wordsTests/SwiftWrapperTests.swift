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

    W3wGeocoder.setup(with: "<Your Secret Key>")
  }
  
  
  func testConvertToCoordinates() {
    let expectation = self.expectation(description: "Convert To Coordinates")
    W3wGeocoder.shared.convertToCoordinates(words: "index.home.raft") { (result, error) in

      if let words = result?["words"] as? String {
        XCTAssertEqual(words, "index.home.raft")
      } else {
        XCTFail("Invalid response")
      }

      XCTAssertNil(error)
      expectation.fulfill()
    }
    waitForExpectations(timeout: 3.0, handler: nil)
  }


  func testConvertTo3waDifferentLanguage() {
    let expectation = self.expectation(description: "Convert to Words")
    W3wGeocoder.shared.convertTo3wa(coordinates: CLLocationCoordinate2D(latitude: 51.521238, longitude: -0.203607), language: "fr") { (result, error) in

      if let words = result?["words"] as? String {
        XCTAssertEqual(words, "mitiger.tarir.prolonger")
      } else {
        XCTFail("Invalid response")
      }

      XCTAssertNil(error)
      expectation.fulfill()
    }
    waitForExpectations(timeout: 3.0, handler: nil)
  }


  func testConvertTo3wa() {
    let expectation = self.expectation(description: "Convert To 3wa")
    W3wGeocoder.shared.convertTo3wa(coordinates: CLLocationCoordinate2D(latitude: 51.521238, longitude: -0.203607)) { (result, error) in

      if let words = result?["words"] as? String {
        XCTAssertEqual(words, "index.home.raft")
      } else {
        XCTFail("Invalid response")
      }

      XCTAssertNil(error)
      expectation.fulfill()
    }
    waitForExpectations(timeout: 3.0, handler: nil)
  }



  func testInvalid3wa() {
    let expectation = self.expectation(description: "Invalida 3wa")
    W3wGeocoder.shared.convertToCoordinates(words: "index.raft") { (result, error) in
      XCTAssertNotNil(error)
      XCTAssertNil(result)
      expectation.fulfill()
    }
    waitForExpectations(timeout: 3.0, handler: nil)
  }



  func testGridSection() {
    let expectation = self.expectation(description: "Grid")
    W3wGeocoder.shared.gridSection(south_lat: 52.208867, west_lng: 0.117540, north_lat: 52.207988, east_lng: 0.116126) { (result, error) in

      let lines = result?["lines"] as? [[String: Any]]
      XCTAssertNotNil(lines)
      XCTAssertNotNil(result)
      XCTAssertNil(error)
      expectation.fulfill()
    }
    waitForExpectations(timeout: 3.0, handler: nil)
  }


  func testGridSection2() {
    let expectation = self.expectation(description: "Grid")

    let box = BoundingBox(southWest: CLLocationCoordinate2D(latitude: 52.208867, longitude:0.117540), northEast: CLLocationCoordinate2D(latitude: 52.207988, longitude:0.116126))

    W3wGeocoder.shared.gridSection(box:box) { (result, error) in

      print(result)

      let lines = result?["lines"] as? [[String: Any]]
      XCTAssertNotNil(lines)
      XCTAssertNotNil(result)
      XCTAssertNil(error)
      expectation.fulfill()
    }
    waitForExpectations(timeout: 3.0, handler: nil)
  }



  func testLanguages() {
    let expectation = self.expectation(description: "Languages")
    W3wGeocoder.shared.availableLanguages() { (result, error) in

      let languages = result?["languages"] as? [[String: Any]]
      XCTAssertNotNil(languages)

      if let languages = languages {
        XCTAssertNotNil(languages.first?["code"] as? String)
        XCTAssertNotNil(languages.first?["name"] as? String)
        XCTAssertNotNil(languages.first?["native_name"] as? String)
      }

      XCTAssertNotNil(result)
      XCTAssertNil(error)
      expectation.fulfill()
    }
    waitForExpectations(timeout: 3.0, handler: nil)
  }
  
  
  func testAutosuggest() {
    let expectation = self.expectation(description: "Autosuggest")
    W3wGeocoder.shared.autosuggest(input: "geschaft.planter.carciofi") { (result, error) in
    
      if let suggestions = result?["suggestions"] as? [[String: Any]] {
        XCTAssertEqual(suggestions.count, 3)
        XCTAssertEqual(suggestions.first?["words"] as? String, "esche.piante.carciofi")
      } else {
        XCTFail("Invalid response")
      }

      XCTAssertNil(error)
      expectation.fulfill()
    }
    waitForExpectations(timeout: 3.0, handler: nil)
  }

//options: BoundingBox(southWest: , northEast:


  func testAutosuggestWtihBoundingBox1() {
    let expectation = self.expectation(description: "Autosuggest")
    
    W3wGeocoder.shared.autosuggest(input: "geschaft.planter.carciofi", options:BoundingBox(south_lat: 51.521, west_lng: -0.343, north_lat: 52.6, east_lng: 2.3324)) { (result, error) in

    print(result)
    
      if let suggestions = result?["suggestions"] as? [[String: Any]] {
        XCTAssertEqual(suggestions.first?["words"] as? String, "restate.piante.carciofo")
      } else {
        XCTFail("Invalid response")
      }

      XCTAssertNil(error)
      expectation.fulfill()
    }
    waitForExpectations(timeout: 3.0, handler: nil)
  }



  func testAutosuggestWtihBoundingBox2() {
    let expectation = self.expectation(description: "Autosuggest")
    
    let southWest = CLLocationCoordinate2D(latitude: 51.521, longitude:-0.343)
    let northEast = CLLocationCoordinate2D(latitude: 52.6, longitude:2.3324)
    
    W3wGeocoder.shared.autosuggest(input: "geschaft.planter.carciofi", options:BoundingBox(southWest: southWest, northEast: northEast)) { (result, error) in

    print(result)
    
      if let suggestions = result?["suggestions"] as? [[String: Any]] {
        XCTAssertEqual(suggestions.first?["words"] as? String, "restate.piante.carciofo")
      } else {
        XCTFail("Invalid response")
      }

      XCTAssertNil(error)
      expectation.fulfill()
    }
    waitForExpectations(timeout: 3.0, handler: nil)
  }



  func testAutosuggestWithFocus() {
    let expectation = self.expectation(description: "Autosuggest")

    W3wGeocoder.shared.autosuggest(input: "geschaft.planter.carciofi", options: Focus(focus: CLLocationCoordinate2D(latitude: 51.4243877, longitude: -0.34745)),NumberFocusResults(numberFocusResults: 2)) { (result, error) in
    
    print(result)
   
      if let suggestions = result?["suggestions"] as? [[String: Any]] {
        XCTAssertEqual(suggestions.count, 3)
        XCTAssertEqual(suggestions.first?["words"] as? String, "restate.piante.carciofo")
      } else {
        XCTFail("Invalid response")
      }

      XCTAssertNil(error)
      expectation.fulfill()
    }
    waitForExpectations(timeout: 3.0, handler: nil)
  }


  
  func testAutosuggestWithCountry() {
    let expectation = self.expectation(description: "Autosuggest")

    W3wGeocoder.shared.autosuggest(input: "oui.oui.oui", options: BoundingCountry(country: "fr")) { (result, error) in

    print(result)
   
      if let suggestions = result?["suggestions"] as? [[String: Any]] {
        XCTAssertEqual(suggestions.count, 3)
        XCTAssertEqual(suggestions.first?["words"] as? String, "oust.souk.souk")
      } else {
        XCTFail("Invalid response")
      }

      XCTAssertNil(error)
      expectation.fulfill()
    }
    waitForExpectations(timeout: 3.0, handler: nil)
  }

  
  func testAutosuggestWithCircle1() {
    let expectation = self.expectation(description: "Autosuggest")

    W3wGeocoder.shared.autosuggest(input: "mitiger.tarir.prolong", options: BoundingCircle(lat: 51.521238, lng: -0.203607, kilometers: 1.0)) { (result, error) in

    print(result)
   
      if let suggestions = result?["suggestions"] as? [[String: Any]] {
        XCTAssertEqual(suggestions.count, 1)
        XCTAssertEqual(suggestions.first?["words"] as? String, "mitiger.tarir.prolonger")
      } else {
        XCTFail("Invalid response")
      }

      XCTAssertNil(error)
      expectation.fulfill()
    }
    waitForExpectations(timeout: 3.0, handler: nil)
  }


  
  func testAutosuggestWithCircle2() {
    let expectation = self.expectation(description: "Autosuggest")

    let centre = CLLocationCoordinate2D(latitude: 51.521238, longitude: -0.203607)

    W3wGeocoder.shared.autosuggest(input: "mitiger.tarir.prolong", options:BoundingCircle(centre: centre, kilometers: 1.0)) { (result, error) in

    print(result)
   
      if let suggestions = result?["suggestions"] as? [[String: Any]] {
        XCTAssertEqual(suggestions.count, 1)
        XCTAssertEqual(suggestions.first?["words"] as? String, "mitiger.tarir.prolonger")
      } else {
        XCTFail("Invalid response")
      }

      XCTAssertNil(error)
      expectation.fulfill()
    }
    waitForExpectations(timeout: 3.0, handler: nil)
  }

  
  func testAutosuggestWithPolygon() {
    let expectation = self.expectation(description: "Autosuggest")

    let centre = CLLocationCoordinate2D(latitude: 51.521238, longitude: -0.203607)

    let polygon = [
          CLLocationCoordinate2D(latitude:51.0, longitude:0.0),
          CLLocationCoordinate2D(latitude:51.0, longitude:0.1),
          CLLocationCoordinate2D(latitude:51.1, longitude:0.1),
          CLLocationCoordinate2D(latitude:51.1, longitude:0.0),
          CLLocationCoordinate2D(latitude:51.0, longitude:0.0),
          ];
    //,,,51.521,-0.343

    W3wGeocoder.shared.autosuggest(input: "scenes.irritated.sparkles", options:BoundingPolygon(polygon: polygon)) { (result, error) in

    print(result)
   
      if let suggestions = result?["suggestions"] as? [[String: Any]] {
        XCTAssertEqual(suggestions.count, 1)
        XCTAssertEqual(suggestions.first?["words"] as? String, "scenes.irritated.sparkles")
      } else {
        XCTFail("Invalid response")
      }

      XCTAssertNil(error)
      expectation.fulfill()
    }
    waitForExpectations(timeout: 3.0, handler: nil)
  }


  
  func testMultilingualAutosuggest() {
    let expectation = self.expectation(description: "Autosuggest")
    W3wGeocoder.shared.autosuggest(input: "geschaft.planter.carciofi", options: FallbackLanguage(language: "de")) { (result, error) in
      if let suggestions = result?["suggestions"] as? [[String: Any]] {
        XCTAssertEqual(suggestions.count, 3)
        XCTAssertEqual(suggestions.first?["words"] as? String, "esche.piante.carciofi")
      } else {
        XCTFail("Invalid response")
      }
      
      XCTAssertNil(error)
      expectation.fulfill()
    }
    waitForExpectations(timeout: 3.0, handler: nil)
  }



  func testAutosuggestNumberResults() {
    let expectation = self.expectation(description: "Autosuggest")
    W3wGeocoder.shared.autosuggest(input: "geschaft.planter.carciofi", options: NumberResults(numberOfResults: 5)) { (result, error) in
      if let suggestions = result?["suggestions"] as? [[String: Any]] {
        XCTAssertEqual(suggestions.count, 5)
        XCTAssertEqual(suggestions.first?["words"] as? String, "esche.piante.carciofi")
      } else {
        XCTFail("Invalid response")
      }
      
      XCTAssertNil(error)
      expectation.fulfill()
    }
    waitForExpectations(timeout: 3.0, handler: nil)
  }



  func testVoiceAutosuggest() {
    let expectation = self.expectation(description: "Autosuggest")
    
    let json = "%7B%22_isInGrammar%22%3A%22yes%22%2C%22_isSpeech%22%3A%22yes%22%2C%22_hypotheses%22%3A%5B%7B%22_score%22%3A342516%2C%22_startRule%22%3A%22whatthreewordsgrammar%23_main_%22%2C%22_conf%22%3A6546%2C%22_endTimeMs%22%3A6360%2C%22_beginTimeMs%22%3A1570%2C%22_lmScore%22%3A300%2C%22_items%22%3A%5B%7B%22_type%22%3A%22terminal%22%2C%22_score%22%3A34225%2C%22_orthography%22%3A%22tend%22%2C%22_conf%22%3A6964%2C%22_endTimeMs%22%3A2250%2C%22_beginTimeMs%22%3A1580%7D%2C%7B%22_type%22%3A%22terminal%22%2C%22_score%22%3A47670%2C%22_orthography%22%3A%22artichokes%22%2C%22_conf%22%3A7176%2C%22_endTimeMs%22%3A3180%2C%22_beginTimeMs%22%3A2260%7D%2C%7B%22_type%22%3A%22terminal%22%2C%22_score%22%3A43800%2C%22_orthography%22%3A%22poached%22%2C%22_conf%22%3A6181%2C%22_endTimeMs%22%3A4060%2C%22_beginTimeMs%22%3A3220%7D%5D%7D%2C%7B%22_score%22%3A342631%2C%22_startRule%22%3A%22whatthreewordsgrammar%23_main_%22%2C%22_conf%22%3A6498%2C%22_endTimeMs%22%3A6360%2C%22_beginTimeMs%22%3A1570%2C%22_lmScore%22%3A300%2C%22_items%22%3A%5B%7B%22_type%22%3A%22terminal%22%2C%22_score%22%3A34340%2C%22_orthography%22%3A%22tent%22%2C%22_conf%22%3A6772%2C%22_endTimeMs%22%3A2250%2C%22_beginTimeMs%22%3A1580%7D%2C%7B%22_type%22%3A%22terminal%22%2C%22_score%22%3A47670%2C%22_orthography%22%3A%22artichokes%22%2C%22_conf%22%3A7176%2C%22_endTimeMs%22%3A3180%2C%22_beginTimeMs%22%3A2260%7D%2C%7B%22_type%22%3A%22terminal%22%2C%22_score%22%3A43800%2C%22_orthography%22%3A%22poached%22%2C%22_conf%22%3A6181%2C%22_endTimeMs%22%3A4060%2C%22_beginTimeMs%22%3A3220%7D%5D%7D%2C%7B%22_score%22%3A342668%2C%22_startRule%22%3A%22whatthreewordsgrammar%23_main_%22%2C%22_conf%22%3A6474%2C%22_endTimeMs%22%3A6360%2C%22_beginTimeMs%22%3A1570%2C%22_lmScore%22%3A300%2C%22_items%22%3A%5B%7B%22_type%22%3A%22terminal%22%2C%22_score%22%3A34225%2C%22_orthography%22%3A%22tend%22%2C%22_conf%22%3A6964%2C%22_endTimeMs%22%3A2250%2C%22_beginTimeMs%22%3A1580%7D%2C%7B%22_type%22%3A%22terminal%22%2C%22_score%22%3A47670%2C%22_orthography%22%3A%22artichokes%22%2C%22_conf%22%3A7176%2C%22_endTimeMs%22%3A3180%2C%22_beginTimeMs%22%3A2260%7D%2C%7B%22_type%22%3A%22terminal%22%2C%22_score%22%3A41696%2C%22_orthography%22%3A%22perch%22%2C%22_conf%22%3A5950%2C%22_endTimeMs%22%3A4020%2C%22_beginTimeMs%22%3A3220%7D%5D%7D%2C%7B%22_score%22%3A342670%2C%22_startRule%22%3A%22whatthreewordsgrammar%23_main_%22%2C%22_conf%22%3A6474%2C%22_endTimeMs%22%3A6360%2C%22_beginTimeMs%22%3A1570%2C%22_lmScore%22%3A300%2C%22_items%22%3A%5B%7B%22_type%22%3A%22terminal%22%2C%22_score%22%3A34379%2C%22_orthography%22%3A%22tinge%22%2C%22_conf%22%3A6705%2C%22_endTimeMs%22%3A2250%2C%22_beginTimeMs%22%3A1580%7D%2C%7B%22_type%22%3A%22terminal%22%2C%22_score%22%3A47670%2C%22_orthography%22%3A%22artichokes%22%2C%22_conf%22%3A7176%2C%22_endTimeMs%22%3A3180%2C%22_beginTimeMs%22%3A2260%7D%2C%7B%22_type%22%3A%22terminal%22%2C%22_score%22%3A43800%2C%22_orthography%22%3A%22poached%22%2C%22_conf%22%3A6181%2C%22_endTimeMs%22%3A4060%2C%22_beginTimeMs%22%3A3220%7D%5D%7D%2C%7B%22_score%22%3A342783%2C%22_startRule%22%3A%22whatthreewordsgrammar%23_main_%22%2C%22_conf%22%3A6426%2C%22_endTimeMs%22%3A6360%2C%22_beginTimeMs%22%3A1570%2C%22_lmScore%22%3A300%2C%22_items%22%3A%5B%7B%22_type%22%3A%22terminal%22%2C%22_score%22%3A34340%2C%22_orthography%22%3A%22tent%22%2C%22_conf%22%3A6772%2C%22_endTimeMs%22%3A2250%2C%22_beginTimeMs%22%3A1580%7D%2C%7B%22_type%22%3A%22terminal%22%2C%22_score%22%3A47670%2C%22_orthography%22%3A%22artichokes%22%2C%22_conf%22%3A7176%2C%22_endTimeMs%22%3A3180%2C%22_beginTimeMs%22%3A2260%7D%2C%7B%22_type%22%3A%22terminal%22%2C%22_score%22%3A41696%2C%22_orthography%22%3A%22perch%22%2C%22_conf%22%3A5950%2C%22_endTimeMs%22%3A4020%2C%22_beginTimeMs%22%3A3220%7D%5D%7D%2C%7B%22_score%22%3A342822%2C%22_startRule%22%3A%22whatthreewordsgrammar%23_main_%22%2C%22_conf%22%3A6402%2C%22_endTimeMs%22%3A6360%2C%22_beginTimeMs%22%3A1570%2C%22_lmScore%22%3A300%2C%22_items%22%3A%5B%7B%22_type%22%3A%22terminal%22%2C%22_score%22%3A34379%2C%22_orthography%22%3A%22tinge%22%2C%22_conf%22%3A6705%2C%22_endTimeMs%22%3A2250%2C%22_beginTimeMs%22%3A1580%7D%2C%7B%22_type%22%3A%22terminal%22%2C%22_score%22%3A47670%2C%22_orthography%22%3A%22artichokes%22%2C%22_conf%22%3A7176%2C%22_endTimeMs%22%3A3180%2C%22_beginTimeMs%22%3A2260%7D%2C%7B%22_type%22%3A%22terminal%22%2C%22_score%22%3A41696%2C%22_orthography%22%3A%22perch%22%2C%22_conf%22%3A5950%2C%22_endTimeMs%22%3A4020%2C%22_beginTimeMs%22%3A3220%7D%5D%7D%5D%2C%22_resultType%22%3A%22NBest%22%7D"
    
    W3wGeocoder.shared.autosuggest(input: json.removingPercentEncoding ?? "", options: InputType(inputType: .voconHybrid), NumberResults(numberOfResults: 3), Focus(focus: CLLocationCoordinate2D(latitude: 51.4243877, longitude: -0.3474524))) { (result, error) in
      if let suggestions = result?["suggestions"] as? [[String: Any]] {
        XCTAssertEqual(suggestions.count, 3)
        XCTAssertEqual(suggestions.first?["words"] as? String, "tend.artichokes.poached")
      } else {
        XCTFail("Invalid response")
      }
      
      XCTAssertNil(error)
      expectation.fulfill()
    }
    waitForExpectations(timeout: 3.0, handler: nil)
  }

  
  func testBadWords() {
    let expectation = self.expectation(description: "Bad Words")

    W3wGeocoder.shared.convertToCoordinates(words: "khekheflekh.khekheflekh.khekheflekh") { (result, error) in

    if let e = error as? what3words.W3wGeocoder.W3wError {
        XCTAssertEqual(e.code, "BadWords")
    } else {
        XCTFail("Invalid response")
    }

      expectation.fulfill()
    }
    waitForExpectations(timeout: 3.0, handler: nil)
  }
  
  
}
