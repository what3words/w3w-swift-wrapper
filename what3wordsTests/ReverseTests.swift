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

class ReverseTests: XCTestCase {
  
  override class func setUp() {
    super.setUp()
    
    guard let path = Bundle(for: self.classForCoder()).path(forResource: "Config", ofType: "plist") else {
      fatalError("Couldn't find Config.plist file")
    }
    
    guard let config = NSDictionary(contentsOfFile: path), let apiKey = config["API_KEY"] as? String else {
      fatalError("Couldn't find API_KEY value in Config.plist")
    }
    W3wGeocoder.setup(with: apiKey)
  }
  
  func testForwardGeocode() {
    let expectation = self.expectation(description: "Forward Geocode")
    W3wGeocoder.shared.forwardGeocode(addr: "index.home.raft") { (result, error) in
      
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
  
  func testForwardGeocodeDifferentLanguage() {
    let expectation = self.expectation(description: "Forward Geocode")
    W3wGeocoder.shared.forwardGeocode(addr: "index.home.raft", lang: "fr") { (result, error) in
      
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
  
  func testReverseGeocode() {
    let expectation = self.expectation(description: "Reverse Geocode")
    W3wGeocoder.shared.reverseGeocode(coords: CLLocationCoordinate2D(latitude: 51.521238, longitude: -0.203607)) { (result, error) in
      
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
  
  func testReverseGeocodeDifferentLanguage() {
    let expectation = self.expectation(description: "Reverse Geocode")
    W3wGeocoder.shared.reverseGeocode(coords: CLLocationCoordinate2D(latitude: 51.521238, longitude: -0.203607), lang: "fr") { (result, error) in
      
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
  
  func testAutosuggest() {
    let expectation = self.expectation(description: "Autosuggest")
    W3wGeocoder.shared.autosuggest(addr: "geschaft.planter.carciofi") { (result, error) in
      if let suggestions = result?["suggestions"] as? [[String: Any]] {
        XCTAssertEqual(suggestions.count, 3)
        XCTAssertEqual(suggestions.first?["words"] as? String, "restart.planted.carsick")
      } else {
        XCTFail("Invalid response")
      }
      
      XCTAssertNil(error)
      expectation.fulfill()
    }
    waitForExpectations(timeout: 3.0, handler: nil)
  }
  
  func testAutosuggestFocus() {
    let expectation = self.expectation(description: "Autosuggest")
    W3wGeocoder.shared.autosuggest(addr: "geschaft.planter.carciofi", focus: CLLocationCoordinate2D(latitude: 51.4243877, longitude: -0.34745), count: 1) { (result, error) in
      if let suggestions = result?["suggestions"] as? [[String: Any]] {
        XCTAssertEqual(suggestions.count, 1)
        XCTAssertEqual(suggestions.first?["words"] as? String, "hesitant.planted.carsick")
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
    W3wGeocoder.shared.forwardGeocode(addr: "index.raft") { (result, error) in
      XCTAssertNotNil(error)
      XCTAssertNil(result)
      expectation.fulfill()
    }
    waitForExpectations(timeout: 3.0, handler: nil)
  }
  
  func testGrid() {
    let expectation = self.expectation(description: "Grid")
    W3wGeocoder.shared.grid(bbox: "52.208867,0.117540,52.207988,0.116126") { (result, error) in
      
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
    W3wGeocoder.shared.languages { (result, error) in
      
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
}
