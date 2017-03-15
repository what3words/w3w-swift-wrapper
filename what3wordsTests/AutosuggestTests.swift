//
//  AutosuggestTests.swift
//  what3words
//
//  Created by mihai on 14/03/2017.
//  Copyright © 2017 What3Words. All rights reserved.
//

import XCTest
import CoreLocation

@testable import what3words

class AutosuggestTests: XCTestCase {
  
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
  
  func testStandardBlend() {
    let expectation = self.expectation(description: "Autosuggest")
    W3wGeocoder.shared.standardBlend(addr: "plan.clips.a", completion: { (result, error) in
      if let blends = result?["blends"] as? [[String: Any]] {
        XCTAssertEqual(blends.count, 3)
        XCTAssertEqual(blends.first?["words"] as? String, "plan.clips.also")
      } else {
        XCTFail("Invalid response")
      }
      
      XCTAssertNil(error)
      expectation.fulfill()
    })
    waitForExpectations(timeout: 3.0, handler: nil)
  }
  
  func testStandardBlendLanguage() {
    let expectation = self.expectation(description: "Autosuggest")
    W3wGeocoder.shared.standardBlend(addr: "plan.clips.a", lang: "fr", completion: { (result, error) in
      if let blends = result?["blends"] as? [[String: Any]] {
        XCTAssertEqual(blends.count, 3)
        XCTAssertEqual(blends.first?["words"] as? String, "plat.clin.axer")
      } else {
        XCTFail("Invalid response")
      }
      
      XCTAssertNil(error)
      expectation.fulfill()
    })
    waitForExpectations(timeout: 3.0, handler: nil)
  }
  
  func testStandardBlendFocus() {
    let expectation = self.expectation(description: "Autosuggest")
    W3wGeocoder.shared.standardBlend(addr: "plan.clips.a", focus: CLLocationCoordinate2D(latitude: 51.4243877, longitude: -0.34745), completion: { (result, error) in
      if let blends = result?["blends"] as? [[String: Any]] {
        XCTAssertEqual(blends.count, 3)
        XCTAssertEqual(blends.first?["words"] as? String, "plan.clips.area")
      } else {
        XCTFail("Invalid response")
      }
      
      XCTAssertNil(error)
      expectation.fulfill()
    })
    waitForExpectations(timeout: 3.0, handler: nil)
  }
}
