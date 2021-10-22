import XCTest
import CoreLocation
import AVFoundation
@testable import W3WSwiftApi


final class w3w_swift_apiTests: XCTestCase {


  var headers = [String:String]()
  var api:What3WordsV3!
  
  // run all tests twice, once with no custom headers and one with
  override func invokeTest() {
    super.invokeTest()
  }
  
  
  override func setUp() {
    super.setUp()
    
    if let apikey = ProcessInfo.processInfo.environment["APIKEY"] {
      api = What3WordsV3(apiKey: apikey, apiUrl: W3WSettings.apiUrl, customHeaders: headers)
    } else {
      print("Environment variable APIKEY must be set")
      abort()
    }
  }
  
  
  func testConvertToCoordinates() {
    let expectation = self.expectation(description: "Convert To Coordinates")
    api.convertToCoordinates(words: "index.home.raft") { (place, error) in
      
      XCTAssertEqual(place?.words, "index.home.raft")
      XCTAssertNil(error)
      
      expectation.fulfill()
    }
    waitForExpectations(timeout: 3.0, handler: nil)
  }
  
  
  func testConvertTo3waDifferentLanguage() {
    let expectation = self.expectation(description: "Convert to Words")
    api.convertTo3wa(coordinates: CLLocationCoordinate2D(latitude: 51.521238, longitude: -0.203607), language: "fr") { (place, error) in
      
      XCTAssertEqual(place?.words, "mitiger.tarir.prolonger")
      XCTAssertNil(error)
      
      expectation.fulfill()
    }
    waitForExpectations(timeout: 3.0, handler: nil)
  }
  
  
  func testConvertTo3wa() {
    let expectation = self.expectation(description: "Convert To 3wa")
    api.convertTo3wa(coordinates: CLLocationCoordinate2D(latitude: 51.521238, longitude: -0.203607), language: "en") { (place, error) in
      
      XCTAssertEqual(place?.words, "index.home.raft")
      XCTAssertNil(error)
      
      expectation.fulfill()
    }
    waitForExpectations(timeout: 3.0, handler: nil)
  }
  
  
  
  func testGridSection() {
    let expectation = self.expectation(description: "Grid")
    api.gridSection(south_lat: 52.208867, west_lng: 0.117540, north_lat: 52.207988, east_lng: 0.116126) { (grid, error) in
      
      XCTAssertNotNil(grid)
      if let g = grid {
        XCTAssertGreaterThan(g.count, 0, "Grid lines missing")
      }
      XCTAssertNil(error)
      expectation.fulfill()
    }
    waitForExpectations(timeout: 3.0, handler: nil)
  }
  
  
  func testGridSection2() {
    let expectation = self.expectation(description: "Grid")
    
    api.gridSection(southWest: CLLocationCoordinate2D(latitude: 52.208867, longitude:0.117540), northEast: CLLocationCoordinate2D(latitude: 52.207988, longitude:0.116126)) { (grid, error) in
      
      if let g = grid {
        XCTAssertGreaterThan(g.count, 0, "Grid lines missing")
      }
      XCTAssertNotNil(grid)
      XCTAssertNil(error)
      expectation.fulfill()
    }
    waitForExpectations(timeout: 3.0, handler: nil)
  }
  
  
  
  func testLanguages() {
    let expectation = self.expectation(description: "Languages")
    api.availableLanguages() { (languages, error) in
      
      XCTAssertNotNil(languages)
      if let l = languages {
        XCTAssertGreaterThan(l.count, 0, "No languages returned")
      }
      XCTAssertNotNil(languages?.first?.code)
      XCTAssertNotNil(languages?.first?.name)
      XCTAssertNotNil(languages?.first?.nativeName)
      XCTAssertNil(error)
      expectation.fulfill()
    }
    waitForExpectations(timeout: 3.0, handler: nil)
  }
  
  #if !os(watchOS)
  func testVoiceLanguages() {
    let expectation = self.expectation(description: "Languages")
    api.availableVoiceLanguages() { (languages, error) in
      
      XCTAssertNotNil(languages)
      if let l = languages {
        XCTAssertGreaterThan(l.count, 0, "No languages returned")
      }
      XCTAssertNotNil(languages?.first?.code)
      XCTAssertNotNil(languages?.first?.name)
      XCTAssertNotNil(languages?.first?.nativeName)
      XCTAssertNil(error)
      expectation.fulfill()
    }
    waitForExpectations(timeout: 3.0, handler: nil)
  }
  #endif
  
  func testAutosuggest() {
    let expectation = self.expectation(description: "Autosuggest")
    api.autosuggest(text: "geschaft.planter.carciofi") { (suggestions, error) in
      
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
    
    api.autosuggest(text: "geschaft.planter.carciofi", options:W3WOption.clipToBox(southWest: CLLocationCoordinate2D(latitude: 51.521, longitude: -0.343), northEast: CLLocationCoordinate2D(latitude: 52.6, longitude: 2.3324))) { suggestions, error in
      
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
    
    api.autosuggest(text: "geschaft.planter.carciofi", options:W3WOption.clipToBox(southWest: southWest, northEast: northEast)) { (suggestions, error) in
      
      XCTAssertEqual(suggestions?.count, 2)
      XCTAssertEqual(suggestions?.first?.words, "restate.piante.carciofo")
      XCTAssertNil(error)
      
      expectation.fulfill()
    }
    waitForExpectations(timeout: 3.0, handler: nil)
  }
  
  
  
  func testAutosuggestWithFocus() {
    let expectation = self.expectation(description: "Autosuggest")
    
    api.autosuggest(text: "geschaft.planter.carciofi", options: W3WOptions().focus(CLLocationCoordinate2D(latitude: 51.4243877, longitude: -0.34745)).numberOfResults(3)) { (suggestions, error) in
      
      XCTAssertEqual(suggestions?.count, 3)
      XCTAssertEqual(suggestions?.first?.words, "restate.piante.carciofo")
      XCTAssertNil(error)
      
      expectation.fulfill()
    }
    waitForExpectations(timeout: 3.0, handler: nil)
  }
  
  
  
  func testAutosuggestUsingOptionArray() {
    let expectation = self.expectation(description: "Autosuggest")
    
    api.autosuggest(text: "geschaft.planter.carciofi", options: [W3WOption.focus(CLLocationCoordinate2D(latitude: 51.4243877, longitude: -0.34745)), W3WOption.numberOfResults(3)]) { (suggestions, error) in
      
      XCTAssertEqual(suggestions?.count, 3)
      XCTAssertEqual(suggestions?.first?.words, "restate.piante.carciofo")
      XCTAssertNil(error)
      
      expectation.fulfill()
    }
    waitForExpectations(timeout: 3.0, handler: nil)
  }
  
  
  
  func testAutosuggestWithCountry() {
    let expectation = self.expectation(description: "Autosuggest")
    
    api.autosuggest(text: "oui.oui.oui", options: W3WOption.clipToCountry("fr")) { (suggestions, error) in
      
      XCTAssertEqual(suggestions?.count, 3)
      XCTAssertEqual(suggestions?.first?.words, "oust.souk.souk")
      XCTAssertNil(error)
      
      expectation.fulfill()
    }
    waitForExpectations(timeout: 3.0, handler: nil)
  }
  
  
  func testAutosuggestWithCountries() {
    let expectation = self.expectation(description: "Autosuggest")
    
    api.autosuggest(text: "fill.coun.soa", options: W3WOption.clipToCountries(["DE", "CA"])) { (suggestions, error) in
      
      XCTAssertEqual(suggestions?.count, 3)
      XCTAssertEqual(suggestions?[0].country, "DE")
      XCTAssertEqual(suggestions?[1].country, "CA")
      XCTAssertNil(error)
      
      expectation.fulfill()
    }
    waitForExpectations(timeout: 3.0, handler: nil)
  }
  
  
  func testAutosuggestWithCircle1() {
    let expectation = self.expectation(description: "Autosuggest")
    
    api.autosuggest(text: "mitiger.tarir.prolong", options: W3WOption.clipToCircle(center: CLLocationCoordinate2D(latitude: 51.521238, longitude: -0.203607), radius: 1.0)) { (suggestions, error) in
      
      XCTAssertEqual(suggestions?.count, 1)
      XCTAssertEqual(suggestions?.first?.words, "mitiger.tarir.prolonger")
      XCTAssertNil(error)
      
      expectation.fulfill()
    }
    waitForExpectations(timeout: 3.0, handler: nil)
  }
  
  
  func testAutosuggestWithFocusAndPreferLand() {
    let expectation = self.expectation(description: "Autosuggest")
    
    api.autosuggest(text: "bisect.nourishment.genuineness", options: W3WOptions().preferLand(false).focus(CLLocationCoordinate2D(latitude: 50.842404, longitude: 4.361177))) { (suggestions, error) in
      
      XCTAssertEqual(suggestions?.count, 3)
      if ((suggestions?.count ?? 0) > 2) {
        XCTAssertEqual(suggestions?[2].country, "ZZ")
      }
      XCTAssertNil(error)
      
      expectation.fulfill()
    }
    waitForExpectations(timeout: 3.0, handler: nil)
  }
  
  
  func testAutosuggestWithCircle2() {
    let expectation = self.expectation(description: "Autosuggest")
    
    let centre = CLLocationCoordinate2D(latitude: 51.521238, longitude: -0.203607)
    
    api.autosuggest(text: "mitiger.tarir.prolong", options: W3WOption.clipToCircle(center: centre, radius: 1.0)) { (suggestions, error) in
      
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
    
    api.autosuggest(text: "scenes.irritated.sparkle", options: W3WOption.clipToPolygon(polygon)) { (suggestions, error) in
      
      XCTAssertEqual(suggestions?.count, 1)
      XCTAssertEqual(suggestions?.first?.words, "scenes.irritated.sparkles")
      XCTAssertNil(error)
      
      expectation.fulfill()
    }
    
    waitForExpectations(timeout: 3.0, handler: nil)
  }
  
  
  
  func testMultilingualAutosuggest() {
    let expectation = self.expectation(description: "Autosuggest")
    api.autosuggest(text: "aaa.aaa.aaa", options: W3WOption.language("de")) { (suggestions, error) in
      
      XCTAssertEqual(suggestions?.count, 3)
      XCTAssertEqual(suggestions?.first?.words, "saal.saal.saal")
      XCTAssertNil(error)
      
      expectation.fulfill()
    }
    waitForExpectations(timeout: 3.0, handler: nil)
  }
  
  
  
  func testAutosuggestNumberResults() {
    let expectation = self.expectation(description: "Autosuggest")
    api.autosuggest(text: "geschaft.planter.carciofi", options: W3WOption.numberOfResults(5)) { (suggestions, error) in
      
      XCTAssertEqual(suggestions?.count, 5)
      XCTAssertEqual(suggestions?.first?.words, "esche.piante.carciofi")
      XCTAssertNil(error)
      
      expectation.fulfill()
    }
    waitForExpectations(timeout: 3.0, handler: nil)
  }
  
  
  func testAutosuggestWithCoordinates() {
    let expectation = self.expectation(description: "Autosuggest")
    api.autosuggestWithCoordinates(text: "filled.count.soap") { (suggestions, error) in
      
      XCTAssertEqual(suggestions?.count, 3)
      XCTAssertEqual(suggestions?.first?.words, "filled.count.soap")
      XCTAssertEqual(suggestions?.first?.coordinates?.longitude, -0.195521)
      XCTAssertNil(error)
      
      expectation.fulfill()
    }
    waitForExpectations(timeout: 3.0, handler: nil)
  }
  
  
  func testAutosuggestWithCoordinatesFocus() {
    let expectation = self.expectation(description: "Autosuggest")
    api.autosuggestWithCoordinates(text: "geschaft.planter.carciofi", options: W3WOptions().focus(CLLocationCoordinate2D(latitude: 51.4243877, longitude: -0.34745)).numberOfResults(3)) { (suggestions, error) in
      
      XCTAssertEqual(suggestions?.count, 3)
      XCTAssertEqual(suggestions?.first?.words, "restate.piante.carciofo")
      XCTAssertNil(error)
      
      expectation.fulfill()
    }
    waitForExpectations(timeout: 3.0, handler: nil)
  }
  
  
  func testAutosuggestWithCoordinatesLanguage() {
    let expectation = self.expectation(description: "Autosuggest")
    api.autosuggestWithCoordinates(text: "aaa.aaa.aaa", options: W3WOption.language("de")) { (suggestions, error) in
      
      XCTAssertEqual(suggestions?.count, 3)
      XCTAssertEqual(suggestions?.first?.words, "saal.saal.saal")
      XCTAssertEqual(suggestions?.first?.southWestBounds?.latitude, 53.16478)
      XCTAssertNil(error)
      
      expectation.fulfill()
    }
    waitForExpectations(timeout: 3.0, handler: nil)
  }
  
  
  func testAutosuggestWithCoordinatesFocusAndPreferedLand() {
    let expectation = self.expectation(description: "Autosuggest")
    api.autosuggestWithCoordinates(
      text: "bisect.nourishment.genuineness",
      options: [W3WOption.preferLand(false), W3WOption.focus(CLLocationCoordinate2D(latitude: 50.842404, longitude: 4.361177))]) { (suggestions, error) in
      
      XCTAssertEqual(suggestions?.count, 3)
      if ((suggestions?.count ?? 0) > 2) {
        XCTAssertEqual(suggestions?[2].country, "ZZ")
      }
      XCTAssertNil(error)
      
      expectation.fulfill()
    }
    waitForExpectations(timeout: 3.0, handler: nil)
  }
  

  

  
  // GET https://api.what3words.com/v3/autosuggest?input=%7B%22_isInGrammar%22%3A%22yes%22%2C%22_isSpeech%22%3A%22yes%22%2C%22_hypotheses%22%3A%5B%7B%22_score%22%3A342516%2C%22_startRule%22%3A%22whatthreewordsgrammar%23_main_%22%2C%22_conf%22%3A6546%2C%22_endTimeMs%22%3A6360%2C%22_beginTimeMs%22%3A1570%2C%22_lmScore%22%3A300%2C%22_items%22%3A%5B%7B%22_type%22%3A%22terminal%22%2C%22_score%22%3A34225%2C%22_orthography%22%3A%22tend%22%2C%22_conf%22%3A6964%2C%22_endTimeMs%22%3A2250%2C%22_beginTimeMs%22%3A1580%7D%2C%7B%22_type%22%3A%22terminal%22%2C%22_score%22%3A47670%2C%22_orthography%22%3A%22artichokes%22%2C%22_conf%22%3A7176%2C%22_endTimeMs%22%3A3180%2C%22_beginTimeMs%22%3A2260%7D%2C%7B%22_type%22%3A%22terminal%22%2C%22_score%22%3A43800%2C%22_orthography%22%3A%22poached%22%2C%22_conf%22%3A6181%2C%22_endTimeMs%22%3A4060%2C%22_beginTimeMs%22%3A3220%7D%5D%7D%2C%7B%22_score%22%3A342631%2C%22_startRule%22%3A%22whatthreewordsgrammar%23_main_%22%2C%22_conf%22%3A6498%2C%22_endTimeMs%22%3A6360%2C%22_beginTimeMs%22%3A1570%2C%22_lmScore%22%3A300%2C%22_items%22%3A%5B%7B%22_type%22%3A%22terminal%22%2C%22_score%22%3A34340%2C%22_orthography%22%3A%22tent%22%2C%22_conf%22%3A6772%2C%22_endTimeMs%22%3A2250%2C%22_beginTimeMs%22%3A1580%7D%2C%7B%22_type%22%3A%22terminal%22%2C%22_score%22%3A47670%2C%22_orthography%22%3A%22artichokes%22%2C%22_conf%22%3A7176%2C%22_endTimeMs%22%3A3180%2C%22_beginTimeMs%22%3A2260%7D%2C%7B%22_type%22%3A%22terminal%22%2C%22_score%22%3A43800%2C%22_orthography%22%3A%22poached%22%2C%22_conf%22%3A6181%2C%22_endTimeMs%22%3A4060%2C%22_beginTimeMs%22%3A3220%7D%5D%7D%2C%7B%22_score%22%3A342668%2C%22_startRule%22%3A%22whatthreewordsgrammar%23_main_%22%2C%22_conf%22%3A6474%2C%22_endTimeMs%22%3A6360%2C%22_beginTimeMs%22%3A1570%2C%22_lmScore%22%3A300%2C%22_items%22%3A%5B%7B%22_type%22%3A%22terminal%22%2C%22_score%22%3A34225%2C%22_orthography%22%3A%22tend%22%2C%22_conf%22%3A6964%2C%22_endTimeMs%22%3A2250%2C%22_beginTimeMs%22%3A1580%7D%2C%7B%22_type%22%3A%22terminal%22%2C%22_score%22%3A47670%2C%22_orthography%22%3A%22artichokes%22%2C%22_conf%22%3A7176%2C%22_endTimeMs%22%3A3180%2C%22_beginTimeMs%22%3A2260%7D%2C%7B%22_type%22%3A%22terminal%22%2C%22_score%22%3A41696%2C%22_orthography%22%3A%22perch%22%2C%22_conf%22%3A5950%2C%22_endTimeMs%22%3A4020%2C%22_beginTimeMs%22%3A3220%7D%5D%7D%2C%7B%22_score%22%3A342670%2C%22_startRule%22%3A%22whatthreewordsgrammar%23_main_%22%2C%22_conf%22%3A6474%2C%22_endTimeMs%22%3A6360%2C%22_beginTimeMs%22%3A1570%2C%22_lmScore%22%3A300%2C%22_items%22%3A%5B%7B%22_type%22%3A%22terminal%22%2C%22_score%22%3A34379%2C%22_orthography%22%3A%22tinge%22%2C%22_conf%22%3A6705%2C%22_endTimeMs%22%3A2250%2C%22_beginTimeMs%22%3A1580%7D%2C%7B%22_type%22%3A%22terminal%22%2C%22_score%22%3A47670%2C%22_orthography%22%3A%22artichokes%22%2C%22_conf%22%3A7176%2C%22_endTimeMs%22%3A3180%2C%22_beginTimeMs%22%3A2260%7D%2C%7B%22_type%22%3A%22terminal%22%2C%22_score%22%3A43800%2C%22_orthography%22%3A%22poached%22%2C%22_conf%22%3A6181%2C%22_endTimeMs%22%3A4060%2C%22_beginTimeMs%22%3A3220%7D%5D%7D%2C%7B%22_score%22%3A342783%2C%22_startRule%22%3A%22whatthreewordsgrammar%23_main_%22%2C%22_conf%22%3A6426%2C%22_endTimeMs%22%3A6360%2C%22_beginTimeMs%22%3A1570%2C%22_lmScore%22%3A300%2C%22_items%22%3A%5B%7B%22_type%22%3A%22terminal%22%2C%22_score%22%3A34340%2C%22_orthography%22%3A%22tent%22%2C%22_conf%22%3A6772%2C%22_endTimeMs%22%3A2250%2C%22_beginTimeMs%22%3A1580%7D%2C%7B%22_type%22%3A%22terminal%22%2C%22_score%22%3A47670%2C%22_orthography%22%3A%22artichokes%22%2C%22_conf%22%3A7176%2C%22_endTimeMs%22%3A3180%2C%22_beginTimeMs%22%3A2260%7D%2C%7B%22_type%22%3A%22terminal%22%2C%22_score%22%3A41696%2C%22_orthography%22%3A%22perch%22%2C%22_conf%22%3A5950%2C%22_endTimeMs%22%3A4020%2C%22_beginTimeMs%22%3A3220%7D%5D%7D%2C%7B%22_score%22%3A342822%2C%22_startRule%22%3A%22whatthreewordsgrammar%23_main_%22%2C%22_conf%22%3A6402%2C%22_endTimeMs%22%3A6360%2C%22_beginTimeMs%22%3A1570%2C%22_lmScore%22%3A300%2C%22_items%22%3A%5B%7B%22_type%22%3A%22terminal%22%2C%22_score%22%3A34379%2C%22_orthography%22%3A%22tinge%22%2C%22_conf%22%3A6705%2C%22_endTimeMs%22%3A2250%2C%22_beginTimeMs%22%3A1580%7D%2C%7B%22_type%22%3A%22terminal%22%2C%22_score%22%3A47670%2C%22_orthography%22%3A%22artichokes%22%2C%22_conf%22%3A7176%2C%22_endTimeMs%22%3A3180%2C%22_beginTimeMs%22%3A2260%7D%2C%7B%22_type%22%3A%22terminal%22%2C%22_score%22%3A41696%2C%22_orthography%22%3A%22perch%22%2C%22_conf%22%3A5950%2C%22_endTimeMs%22%3A4020%2C%22_beginTimeMs%22%3A3220%7D%5D%7D%5D%2C%22_resultType%22%3A%22NBest%22%7D&language=en&focus=51.4243877,-0.3474524&input-type=vocon-hybrid&key=
  func testVoiceAutosuggestWithCoordinatesVoice() {
    let expectation = self.expectation(description: "AutosuggestWithCoordinatesVoice")
    
    let json = "%7B%22_isInGrammar%22%3A%22yes%22%2C%22_isSpeech%22%3A%22yes%22%2C%22_hypotheses%22%3A%5B%7B%22_score%22%3A342516%2C%22_startRule%22%3A%22whatthreewordsgrammar%23_main_%22%2C%22_conf%22%3A6546%2C%22_endTimeMs%22%3A6360%2C%22_beginTimeMs%22%3A1570%2C%22_lmScore%22%3A300%2C%22_items%22%3A%5B%7B%22_type%22%3A%22terminal%22%2C%22_score%22%3A34225%2C%22_orthography%22%3A%22tend%22%2C%22_conf%22%3A6964%2C%22_endTimeMs%22%3A2250%2C%22_beginTimeMs%22%3A1580%7D%2C%7B%22_type%22%3A%22terminal%22%2C%22_score%22%3A47670%2C%22_orthography%22%3A%22artichokes%22%2C%22_conf%22%3A7176%2C%22_endTimeMs%22%3A3180%2C%22_beginTimeMs%22%3A2260%7D%2C%7B%22_type%22%3A%22terminal%22%2C%22_score%22%3A43800%2C%22_orthography%22%3A%22poached%22%2C%22_conf%22%3A6181%2C%22_endTimeMs%22%3A4060%2C%22_beginTimeMs%22%3A3220%7D%5D%7D%2C%7B%22_score%22%3A342631%2C%22_startRule%22%3A%22whatthreewordsgrammar%23_main_%22%2C%22_conf%22%3A6498%2C%22_endTimeMs%22%3A6360%2C%22_beginTimeMs%22%3A1570%2C%22_lmScore%22%3A300%2C%22_items%22%3A%5B%7B%22_type%22%3A%22terminal%22%2C%22_score%22%3A34340%2C%22_orthography%22%3A%22tent%22%2C%22_conf%22%3A6772%2C%22_endTimeMs%22%3A2250%2C%22_beginTimeMs%22%3A1580%7D%2C%7B%22_type%22%3A%22terminal%22%2C%22_score%22%3A47670%2C%22_orthography%22%3A%22artichokes%22%2C%22_conf%22%3A7176%2C%22_endTimeMs%22%3A3180%2C%22_beginTimeMs%22%3A2260%7D%2C%7B%22_type%22%3A%22terminal%22%2C%22_score%22%3A43800%2C%22_orthography%22%3A%22poached%22%2C%22_conf%22%3A6181%2C%22_endTimeMs%22%3A4060%2C%22_beginTimeMs%22%3A3220%7D%5D%7D%2C%7B%22_score%22%3A342668%2C%22_startRule%22%3A%22whatthreewordsgrammar%23_main_%22%2C%22_conf%22%3A6474%2C%22_endTimeMs%22%3A6360%2C%22_beginTimeMs%22%3A1570%2C%22_lmScore%22%3A300%2C%22_items%22%3A%5B%7B%22_type%22%3A%22terminal%22%2C%22_score%22%3A34225%2C%22_orthography%22%3A%22tend%22%2C%22_conf%22%3A6964%2C%22_endTimeMs%22%3A2250%2C%22_beginTimeMs%22%3A1580%7D%2C%7B%22_type%22%3A%22terminal%22%2C%22_score%22%3A47670%2C%22_orthography%22%3A%22artichokes%22%2C%22_conf%22%3A7176%2C%22_endTimeMs%22%3A3180%2C%22_beginTimeMs%22%3A2260%7D%2C%7B%22_type%22%3A%22terminal%22%2C%22_score%22%3A41696%2C%22_orthography%22%3A%22perch%22%2C%22_conf%22%3A5950%2C%22_endTimeMs%22%3A4020%2C%22_beginTimeMs%22%3A3220%7D%5D%7D%2C%7B%22_score%22%3A342670%2C%22_startRule%22%3A%22whatthreewordsgrammar%23_main_%22%2C%22_conf%22%3A6474%2C%22_endTimeMs%22%3A6360%2C%22_beginTimeMs%22%3A1570%2C%22_lmScore%22%3A300%2C%22_items%22%3A%5B%7B%22_type%22%3A%22terminal%22%2C%22_score%22%3A34379%2C%22_orthography%22%3A%22tinge%22%2C%22_conf%22%3A6705%2C%22_endTimeMs%22%3A2250%2C%22_beginTimeMs%22%3A1580%7D%2C%7B%22_type%22%3A%22terminal%22%2C%22_score%22%3A47670%2C%22_orthography%22%3A%22artichokes%22%2C%22_conf%22%3A7176%2C%22_endTimeMs%22%3A3180%2C%22_beginTimeMs%22%3A2260%7D%2C%7B%22_type%22%3A%22terminal%22%2C%22_score%22%3A43800%2C%22_orthography%22%3A%22poached%22%2C%22_conf%22%3A6181%2C%22_endTimeMs%22%3A4060%2C%22_beginTimeMs%22%3A3220%7D%5D%7D%2C%7B%22_score%22%3A342783%2C%22_startRule%22%3A%22whatthreewordsgrammar%23_main_%22%2C%22_conf%22%3A6426%2C%22_endTimeMs%22%3A6360%2C%22_beginTimeMs%22%3A1570%2C%22_lmScore%22%3A300%2C%22_items%22%3A%5B%7B%22_type%22%3A%22terminal%22%2C%22_score%22%3A34340%2C%22_orthography%22%3A%22tent%22%2C%22_conf%22%3A6772%2C%22_endTimeMs%22%3A2250%2C%22_beginTimeMs%22%3A1580%7D%2C%7B%22_type%22%3A%22terminal%22%2C%22_score%22%3A47670%2C%22_orthography%22%3A%22artichokes%22%2C%22_conf%22%3A7176%2C%22_endTimeMs%22%3A3180%2C%22_beginTimeMs%22%3A2260%7D%2C%7B%22_type%22%3A%22terminal%22%2C%22_score%22%3A41696%2C%22_orthography%22%3A%22perch%22%2C%22_conf%22%3A5950%2C%22_endTimeMs%22%3A4020%2C%22_beginTimeMs%22%3A3220%7D%5D%7D%2C%7B%22_score%22%3A342822%2C%22_startRule%22%3A%22whatthreewordsgrammar%23_main_%22%2C%22_conf%22%3A6402%2C%22_endTimeMs%22%3A6360%2C%22_beginTimeMs%22%3A1570%2C%22_lmScore%22%3A300%2C%22_items%22%3A%5B%7B%22_type%22%3A%22terminal%22%2C%22_score%22%3A34379%2C%22_orthography%22%3A%22tinge%22%2C%22_conf%22%3A6705%2C%22_endTimeMs%22%3A2250%2C%22_beginTimeMs%22%3A1580%7D%2C%7B%22_type%22%3A%22terminal%22%2C%22_score%22%3A47670%2C%22_orthography%22%3A%22artichokes%22%2C%22_conf%22%3A7176%2C%22_endTimeMs%22%3A3180%2C%22_beginTimeMs%22%3A2260%7D%2C%7B%22_type%22%3A%22terminal%22%2C%22_score%22%3A41696%2C%22_orthography%22%3A%22perch%22%2C%22_conf%22%3A5950%2C%22_endTimeMs%22%3A4020%2C%22_beginTimeMs%22%3A3220%7D%5D%7D%5D%2C%22_resultType%22%3A%22NBest%22%7D"
    
    api.autosuggestWithCoordinates(text: json.removingPercentEncoding ?? "",
                    options: [
                      W3WOption.inputType(.voconHybrid),
                      W3WOption.language("en"),
                      W3WOption.numberOfResults(3),
                      W3WOption.focus(CLLocationCoordinate2D(latitude: 51.4243877, longitude: -0.3474524))
                    ]) { (suggestions, error) in
      
      XCTAssertEqual(suggestions?.count, 3)
      XCTAssertEqual(suggestions?.first?.words, "tend.artichokes.perch")
      XCTAssertEqual(Int(suggestions?.first?.coordinates?.latitude ?? 0.0), 47)
      XCTAssertNil(error)
      expectation.fulfill()
    }
    waitForExpectations(timeout: 3.0, handler: nil)
  }
  
  
  
  // GET https://api.what3words.com/v3/autosuggest?input=%7B%22_isInGrammar%22%3A%22yes%22%2C%22_isSpeech%22%3A%22yes%22%2C%22_hypotheses%22%3A%5B%7B%22_score%22%3A342516%2C%22_startRule%22%3A%22whatthreewordsgrammar%23_main_%22%2C%22_conf%22%3A6546%2C%22_endTimeMs%22%3A6360%2C%22_beginTimeMs%22%3A1570%2C%22_lmScore%22%3A300%2C%22_items%22%3A%5B%7B%22_type%22%3A%22terminal%22%2C%22_score%22%3A34225%2C%22_orthography%22%3A%22tend%22%2C%22_conf%22%3A6964%2C%22_endTimeMs%22%3A2250%2C%22_beginTimeMs%22%3A1580%7D%2C%7B%22_type%22%3A%22terminal%22%2C%22_score%22%3A47670%2C%22_orthography%22%3A%22artichokes%22%2C%22_conf%22%3A7176%2C%22_endTimeMs%22%3A3180%2C%22_beginTimeMs%22%3A2260%7D%2C%7B%22_type%22%3A%22terminal%22%2C%22_score%22%3A43800%2C%22_orthography%22%3A%22poached%22%2C%22_conf%22%3A6181%2C%22_endTimeMs%22%3A4060%2C%22_beginTimeMs%22%3A3220%7D%5D%7D%2C%7B%22_score%22%3A342631%2C%22_startRule%22%3A%22whatthreewordsgrammar%23_main_%22%2C%22_conf%22%3A6498%2C%22_endTimeMs%22%3A6360%2C%22_beginTimeMs%22%3A1570%2C%22_lmScore%22%3A300%2C%22_items%22%3A%5B%7B%22_type%22%3A%22terminal%22%2C%22_score%22%3A34340%2C%22_orthography%22%3A%22tent%22%2C%22_conf%22%3A6772%2C%22_endTimeMs%22%3A2250%2C%22_beginTimeMs%22%3A1580%7D%2C%7B%22_type%22%3A%22terminal%22%2C%22_score%22%3A47670%2C%22_orthography%22%3A%22artichokes%22%2C%22_conf%22%3A7176%2C%22_endTimeMs%22%3A3180%2C%22_beginTimeMs%22%3A2260%7D%2C%7B%22_type%22%3A%22terminal%22%2C%22_score%22%3A43800%2C%22_orthography%22%3A%22poached%22%2C%22_conf%22%3A6181%2C%22_endTimeMs%22%3A4060%2C%22_beginTimeMs%22%3A3220%7D%5D%7D%2C%7B%22_score%22%3A342668%2C%22_startRule%22%3A%22whatthreewordsgrammar%23_main_%22%2C%22_conf%22%3A6474%2C%22_endTimeMs%22%3A6360%2C%22_beginTimeMs%22%3A1570%2C%22_lmScore%22%3A300%2C%22_items%22%3A%5B%7B%22_type%22%3A%22terminal%22%2C%22_score%22%3A34225%2C%22_orthography%22%3A%22tend%22%2C%22_conf%22%3A6964%2C%22_endTimeMs%22%3A2250%2C%22_beginTimeMs%22%3A1580%7D%2C%7B%22_type%22%3A%22terminal%22%2C%22_score%22%3A47670%2C%22_orthography%22%3A%22artichokes%22%2C%22_conf%22%3A7176%2C%22_endTimeMs%22%3A3180%2C%22_beginTimeMs%22%3A2260%7D%2C%7B%22_type%22%3A%22terminal%22%2C%22_score%22%3A41696%2C%22_orthography%22%3A%22perch%22%2C%22_conf%22%3A5950%2C%22_endTimeMs%22%3A4020%2C%22_beginTimeMs%22%3A3220%7D%5D%7D%2C%7B%22_score%22%3A342670%2C%22_startRule%22%3A%22whatthreewordsgrammar%23_main_%22%2C%22_conf%22%3A6474%2C%22_endTimeMs%22%3A6360%2C%22_beginTimeMs%22%3A1570%2C%22_lmScore%22%3A300%2C%22_items%22%3A%5B%7B%22_type%22%3A%22terminal%22%2C%22_score%22%3A34379%2C%22_orthography%22%3A%22tinge%22%2C%22_conf%22%3A6705%2C%22_endTimeMs%22%3A2250%2C%22_beginTimeMs%22%3A1580%7D%2C%7B%22_type%22%3A%22terminal%22%2C%22_score%22%3A47670%2C%22_orthography%22%3A%22artichokes%22%2C%22_conf%22%3A7176%2C%22_endTimeMs%22%3A3180%2C%22_beginTimeMs%22%3A2260%7D%2C%7B%22_type%22%3A%22terminal%22%2C%22_score%22%3A43800%2C%22_orthography%22%3A%22poached%22%2C%22_conf%22%3A6181%2C%22_endTimeMs%22%3A4060%2C%22_beginTimeMs%22%3A3220%7D%5D%7D%2C%7B%22_score%22%3A342783%2C%22_startRule%22%3A%22whatthreewordsgrammar%23_main_%22%2C%22_conf%22%3A6426%2C%22_endTimeMs%22%3A6360%2C%22_beginTimeMs%22%3A1570%2C%22_lmScore%22%3A300%2C%22_items%22%3A%5B%7B%22_type%22%3A%22terminal%22%2C%22_score%22%3A34340%2C%22_orthography%22%3A%22tent%22%2C%22_conf%22%3A6772%2C%22_endTimeMs%22%3A2250%2C%22_beginTimeMs%22%3A1580%7D%2C%7B%22_type%22%3A%22terminal%22%2C%22_score%22%3A47670%2C%22_orthography%22%3A%22artichokes%22%2C%22_conf%22%3A7176%2C%22_endTimeMs%22%3A3180%2C%22_beginTimeMs%22%3A2260%7D%2C%7B%22_type%22%3A%22terminal%22%2C%22_score%22%3A41696%2C%22_orthography%22%3A%22perch%22%2C%22_conf%22%3A5950%2C%22_endTimeMs%22%3A4020%2C%22_beginTimeMs%22%3A3220%7D%5D%7D%2C%7B%22_score%22%3A342822%2C%22_startRule%22%3A%22whatthreewordsgrammar%23_main_%22%2C%22_conf%22%3A6402%2C%22_endTimeMs%22%3A6360%2C%22_beginTimeMs%22%3A1570%2C%22_lmScore%22%3A300%2C%22_items%22%3A%5B%7B%22_type%22%3A%22terminal%22%2C%22_score%22%3A34379%2C%22_orthography%22%3A%22tinge%22%2C%22_conf%22%3A6705%2C%22_endTimeMs%22%3A2250%2C%22_beginTimeMs%22%3A1580%7D%2C%7B%22_type%22%3A%22terminal%22%2C%22_score%22%3A47670%2C%22_orthography%22%3A%22artichokes%22%2C%22_conf%22%3A7176%2C%22_endTimeMs%22%3A3180%2C%22_beginTimeMs%22%3A2260%7D%2C%7B%22_type%22%3A%22terminal%22%2C%22_score%22%3A41696%2C%22_orthography%22%3A%22perch%22%2C%22_conf%22%3A5950%2C%22_endTimeMs%22%3A4020%2C%22_beginTimeMs%22%3A3220%7D%5D%7D%5D%2C%22_resultType%22%3A%22NBest%22%7D&language=en&focus=51.4243877,-0.3474524&input-type=vocon-hybrid&key=
  func testVoiceAutosuggest() {
    let expectation = self.expectation(description: "Autosuggest")
    
    let json = "%7B%22_isInGrammar%22%3A%22yes%22%2C%22_isSpeech%22%3A%22yes%22%2C%22_hypotheses%22%3A%5B%7B%22_score%22%3A342516%2C%22_startRule%22%3A%22whatthreewordsgrammar%23_main_%22%2C%22_conf%22%3A6546%2C%22_endTimeMs%22%3A6360%2C%22_beginTimeMs%22%3A1570%2C%22_lmScore%22%3A300%2C%22_items%22%3A%5B%7B%22_type%22%3A%22terminal%22%2C%22_score%22%3A34225%2C%22_orthography%22%3A%22tend%22%2C%22_conf%22%3A6964%2C%22_endTimeMs%22%3A2250%2C%22_beginTimeMs%22%3A1580%7D%2C%7B%22_type%22%3A%22terminal%22%2C%22_score%22%3A47670%2C%22_orthography%22%3A%22artichokes%22%2C%22_conf%22%3A7176%2C%22_endTimeMs%22%3A3180%2C%22_beginTimeMs%22%3A2260%7D%2C%7B%22_type%22%3A%22terminal%22%2C%22_score%22%3A43800%2C%22_orthography%22%3A%22poached%22%2C%22_conf%22%3A6181%2C%22_endTimeMs%22%3A4060%2C%22_beginTimeMs%22%3A3220%7D%5D%7D%2C%7B%22_score%22%3A342631%2C%22_startRule%22%3A%22whatthreewordsgrammar%23_main_%22%2C%22_conf%22%3A6498%2C%22_endTimeMs%22%3A6360%2C%22_beginTimeMs%22%3A1570%2C%22_lmScore%22%3A300%2C%22_items%22%3A%5B%7B%22_type%22%3A%22terminal%22%2C%22_score%22%3A34340%2C%22_orthography%22%3A%22tent%22%2C%22_conf%22%3A6772%2C%22_endTimeMs%22%3A2250%2C%22_beginTimeMs%22%3A1580%7D%2C%7B%22_type%22%3A%22terminal%22%2C%22_score%22%3A47670%2C%22_orthography%22%3A%22artichokes%22%2C%22_conf%22%3A7176%2C%22_endTimeMs%22%3A3180%2C%22_beginTimeMs%22%3A2260%7D%2C%7B%22_type%22%3A%22terminal%22%2C%22_score%22%3A43800%2C%22_orthography%22%3A%22poached%22%2C%22_conf%22%3A6181%2C%22_endTimeMs%22%3A4060%2C%22_beginTimeMs%22%3A3220%7D%5D%7D%2C%7B%22_score%22%3A342668%2C%22_startRule%22%3A%22whatthreewordsgrammar%23_main_%22%2C%22_conf%22%3A6474%2C%22_endTimeMs%22%3A6360%2C%22_beginTimeMs%22%3A1570%2C%22_lmScore%22%3A300%2C%22_items%22%3A%5B%7B%22_type%22%3A%22terminal%22%2C%22_score%22%3A34225%2C%22_orthography%22%3A%22tend%22%2C%22_conf%22%3A6964%2C%22_endTimeMs%22%3A2250%2C%22_beginTimeMs%22%3A1580%7D%2C%7B%22_type%22%3A%22terminal%22%2C%22_score%22%3A47670%2C%22_orthography%22%3A%22artichokes%22%2C%22_conf%22%3A7176%2C%22_endTimeMs%22%3A3180%2C%22_beginTimeMs%22%3A2260%7D%2C%7B%22_type%22%3A%22terminal%22%2C%22_score%22%3A41696%2C%22_orthography%22%3A%22perch%22%2C%22_conf%22%3A5950%2C%22_endTimeMs%22%3A4020%2C%22_beginTimeMs%22%3A3220%7D%5D%7D%2C%7B%22_score%22%3A342670%2C%22_startRule%22%3A%22whatthreewordsgrammar%23_main_%22%2C%22_conf%22%3A6474%2C%22_endTimeMs%22%3A6360%2C%22_beginTimeMs%22%3A1570%2C%22_lmScore%22%3A300%2C%22_items%22%3A%5B%7B%22_type%22%3A%22terminal%22%2C%22_score%22%3A34379%2C%22_orthography%22%3A%22tinge%22%2C%22_conf%22%3A6705%2C%22_endTimeMs%22%3A2250%2C%22_beginTimeMs%22%3A1580%7D%2C%7B%22_type%22%3A%22terminal%22%2C%22_score%22%3A47670%2C%22_orthography%22%3A%22artichokes%22%2C%22_conf%22%3A7176%2C%22_endTimeMs%22%3A3180%2C%22_beginTimeMs%22%3A2260%7D%2C%7B%22_type%22%3A%22terminal%22%2C%22_score%22%3A43800%2C%22_orthography%22%3A%22poached%22%2C%22_conf%22%3A6181%2C%22_endTimeMs%22%3A4060%2C%22_beginTimeMs%22%3A3220%7D%5D%7D%2C%7B%22_score%22%3A342783%2C%22_startRule%22%3A%22whatthreewordsgrammar%23_main_%22%2C%22_conf%22%3A6426%2C%22_endTimeMs%22%3A6360%2C%22_beginTimeMs%22%3A1570%2C%22_lmScore%22%3A300%2C%22_items%22%3A%5B%7B%22_type%22%3A%22terminal%22%2C%22_score%22%3A34340%2C%22_orthography%22%3A%22tent%22%2C%22_conf%22%3A6772%2C%22_endTimeMs%22%3A2250%2C%22_beginTimeMs%22%3A1580%7D%2C%7B%22_type%22%3A%22terminal%22%2C%22_score%22%3A47670%2C%22_orthography%22%3A%22artichokes%22%2C%22_conf%22%3A7176%2C%22_endTimeMs%22%3A3180%2C%22_beginTimeMs%22%3A2260%7D%2C%7B%22_type%22%3A%22terminal%22%2C%22_score%22%3A41696%2C%22_orthography%22%3A%22perch%22%2C%22_conf%22%3A5950%2C%22_endTimeMs%22%3A4020%2C%22_beginTimeMs%22%3A3220%7D%5D%7D%2C%7B%22_score%22%3A342822%2C%22_startRule%22%3A%22whatthreewordsgrammar%23_main_%22%2C%22_conf%22%3A6402%2C%22_endTimeMs%22%3A6360%2C%22_beginTimeMs%22%3A1570%2C%22_lmScore%22%3A300%2C%22_items%22%3A%5B%7B%22_type%22%3A%22terminal%22%2C%22_score%22%3A34379%2C%22_orthography%22%3A%22tinge%22%2C%22_conf%22%3A6705%2C%22_endTimeMs%22%3A2250%2C%22_beginTimeMs%22%3A1580%7D%2C%7B%22_type%22%3A%22terminal%22%2C%22_score%22%3A47670%2C%22_orthography%22%3A%22artichokes%22%2C%22_conf%22%3A7176%2C%22_endTimeMs%22%3A3180%2C%22_beginTimeMs%22%3A2260%7D%2C%7B%22_type%22%3A%22terminal%22%2C%22_score%22%3A41696%2C%22_orthography%22%3A%22perch%22%2C%22_conf%22%3A5950%2C%22_endTimeMs%22%3A4020%2C%22_beginTimeMs%22%3A3220%7D%5D%7D%5D%2C%22_resultType%22%3A%22NBest%22%7D"
    
    api.autosuggest(text: json.removingPercentEncoding ?? "",
      options: [
        W3WOption.inputType(.voconHybrid),
        W3WOption.language("en"),
        W3WOption.numberOfResults(3),
        W3WOption.focus(CLLocationCoordinate2D(latitude: 51.4243877, longitude: -0.3474524))
      ]) { (suggestions, error) in
      
      XCTAssertEqual(suggestions?.count, 3)
      XCTAssertEqual(suggestions?.first?.words, "tend.artichokes.perch")
      XCTAssertNil(error)
      expectation.fulfill()
    }
    waitForExpectations(timeout: 3.0, handler: nil)
  }
  
  
  func testGenericVoiceAutosuggest() {
    let expectation = self.expectation(description: "Autosuggest")
    
    api.autosuggest(text: "filled count soap", options: W3WOption.inputType(.genericVoice), W3WOption.language("en"), W3WOption.numberOfResults(3)) { (suggestions, error) in
      
      XCTAssertEqual(suggestions?.count, 3)
      XCTAssertEqual(suggestions?.first?.words, "filled.count.soap")
      XCTAssertNil(error)
      expectation.fulfill()
    }
    waitForExpectations(timeout: 3.0, handler: nil)
  }
  
  
  func testAutosuggestNmdp() {
    let expectation = self.expectation(description: "Autosuggest")
    
    let input = "anticipated.comradely.helpful:1.46; anticipated.comradeship.helpful:1.46; anticipated.comrades.yoga:3.04; anticipated.comrades.owns:3.04; anticipated.comrades.cons:3.04; anticipated.comrades.toga:3.04; anticipated.comparisons.helpful:3.38; anticipated.comrades.only:3.84; "

    api.autosuggest(text: input, options: W3WOption.inputType(.nmdpAsr), W3WOption.language("en")) { (suggestions, error) in
      
      XCTAssertEqual(suggestions?.count, 3)
      XCTAssertEqual(suggestions?.first?.words, "anticipated.anticipated.anticipation")
      expectation.fulfill()
    }

    waitForExpectations(timeout: 3.0, handler: nil)
  }
  
  
  func testAutosuggestSelection() {
    let expectation = self.expectation(description: "Autosuggest Selection")
    
    api.autosuggestSelection(selection: "text.text.text", rank: 1, rawInput: "text.text.tex", sourceApi: .text)
    
    // function doesn't return anything, so there is nothing to test, this is included just for syntax checking
    XCTAssertNil(nil)
    expectation.fulfill()
    
    waitForExpectations(timeout: 3.0, handler: nil)
  }
  
  
  func testAutosuggestSelection2() {
    let expectation = self.expectation(description: "Autosuggest Selection")
    
    api.autosuggestSelection(selection: "voice.voice.voice", rank: 2, rawInput: "voice.voice.voic", sourceApi: .voice)
    
    // function doesn't return anything, so there is nothing to test, this is included just for syntax checking
    XCTAssertNil(nil)
    expectation.fulfill()
    
    waitForExpectations(timeout: 3.0, handler: nil)
  }
  
  
  func testBadWords() {
    let expectation = self.expectation(description: "Bad Words")
    
    api.convertToCoordinates(words: "khekheflekh.khekheflekh.khekheflekh") { (place, error) in
      
      XCTAssertNil(place?.words)
      XCTAssertEqual(error, W3WError.badWords)
      
      expectation.fulfill()
    }
    waitForExpectations(timeout: 3.0, handler: nil)
  }
  
  
  
  func testIncompleteWords() {
    let expectation = self.expectation(description: "Invalida 3wa")
    api.convertToCoordinates(words: "index.raft") { (place, error) in
      
      XCTAssertEqual(error, W3WError.badWords)
      XCTAssertNil(place?.words)
      XCTAssertNotNil(error)
      XCTAssertNil(place)
      
      expectation.fulfill()
    }
    waitForExpectations(timeout: 3.0, handler: nil)
  }
  
  
  func testBadCoordinates() {
    let expectation = self.expectation(description: "BadCoordinates")
    api.convertTo3wa(coordinates: CLLocationCoordinate2D(latitude: -1000.0, longitude: 400.0), language: "en") { (place, error) in
      
      XCTAssertEqual(error, W3WError.badCoordinates)
      expectation.fulfill()
    }
    waitForExpectations(timeout: 3.0, handler: nil)
  }
  
  
  
  func testBadLanguage() {
    let expectation = self.expectation(description: "BadLanguage")
    api.convertTo3wa(coordinates: CLLocationCoordinate2D(latitude: 50.0, longitude: -0.1), language: "27") { (place, error) in
      
      XCTAssertEqual(error, W3WError.badLanguage)
      expectation.fulfill()
    }
    waitForExpectations(timeout: 3.0, handler: nil)
  }
  
  
  func testBadClipToPolygon() {
    let expectation = self.expectation(description: "BadClipToPolygon")
    
    let polygon = [
      CLLocationCoordinate2D(latitude: -1000.0, longitude: 400.0),
      CLLocationCoordinate2D(latitude: -1.0, longitude: 10000000.0),
      CLLocationCoordinate2D(latitude: 0.0, longitude: 0.0),
      CLLocationCoordinate2D(latitude: .pi, longitude: 42.0),
    ]
    
    api.autosuggest(text: "filled.count.so", options: W3WOption.clipToPolygon(polygon)) { (suggestions, error) in
      XCTAssertEqual(error, W3WError.badClipToPolygon)
      expectation.fulfill()
    }
    waitForExpectations(timeout: 3.0, handler: nil)
  }
  
  
  func testBadClipToBoundingBox() {
    let expectation = self.expectation(description: "BadClipToBoundingBox")
    
    let sw = CLLocationCoordinate2D(latitude: 0.0, longitude: 0.0)
    let ne = CLLocationCoordinate2D(latitude: -45.0, longitude: 85.0)
    
    api.autosuggest(text: "filled.count.so", options: W3WOption.clipToBox(southWest: sw, northEast: ne)) { (suggestions, error) in
      XCTAssertEqual(error, W3WError.badClipToBoundingBox)
      expectation.fulfill()
    }
    waitForExpectations(timeout: 3.0, handler: nil)
  }
  
  
  
  func testBadClipToCountry() {
    let expectation = self.expectation(description: "BadClipToCountry")
    
    api.autosuggest(text: "filled.count.so", options: W3WOption.clipToCountry("42")) { (suggestions, error) in
      XCTAssertEqual(error, W3WError.badClipToCountry)
      expectation.fulfill()
    }
    waitForExpectations(timeout: 3.0, handler: nil)
  }

  
  // MARK: - Autosuggest Helper Tests


  func testAutosuggestHelper() {
    let expectation = self.expectation(description: "Voice API")

    let somewhereInLondon = CLLocationCoordinate2D(latitude: 51.520847,longitude: -0.195521)

    let helper = W3WAutosuggestHelper(api)
    helper.update(text: "filled.count.so", options: W3WOption.focus(somewhereInLondon)) { error in
      XCTAssertEqual(3, helper.getSuggestionCount())
      XCTAssertEqual("filled.count.soap", helper.getSuggestion(row: 0)?.words)
      expectation.fulfill()
    }

    waitForExpectations(timeout: 30.0, handler: nil)
  }


  func testAutosuggestHelperOptions() {
    let expectation = self.expectation(description: "Voice API")

    let somewhereInLondon = CLLocationCoordinate2D(latitude: 51.520847,longitude: -0.195521)

    let helper = W3WAutosuggestHelper(api)
    helper.update(text: "filled.count.so", options: W3WOptions().focus(somewhereInLondon)) { error in
      XCTAssertEqual(3, helper.getSuggestionCount())
      XCTAssertEqual("filled.count.soap", helper.getSuggestion(row: 0)?.words)
      expectation.fulfill()
    }

    waitForExpectations(timeout: 30.0, handler: nil)
  }


  func testAutosuggestHelperOptionArray() {
    let expectation = self.expectation(description: "Voice API")

    let somewhereInLondon = CLLocationCoordinate2D(latitude: 51.520847,longitude: -0.195521)

    let helper = W3WAutosuggestHelper(api)
    helper.update(text: "filled.count.so", options: [W3WOption.focus(somewhereInLondon)]) { error in
      XCTAssertEqual(3, helper.getSuggestionCount())
      XCTAssertEqual("filled.count.soap", helper.getSuggestion(row: 0)?.words)
      expectation.fulfill()
    }

    waitForExpectations(timeout: 30.0, handler: nil)
  }



  func testAutosuggestSelected() {
    let expectation = self.expectation(description: "Voice API")

    let somewhereInLondon = CLLocationCoordinate2D(latitude: 51.520847,longitude: -0.195521)

    let helper = W3WAutosuggestHelper(api)
    helper.update(text: "filled.count.soa", options: W3WOptions().focus(somewhereInLondon)) { error in
      helper.selected(row: 0) { square, error in
        XCTAssertEqual("filled.count.soap", square?.words)
        XCTAssertEqual(51.520847000000003, square?.coordinates?.latitude)
        expectation.fulfill()
      }
    }

    waitForExpectations(timeout: 30.0, handler: nil)
  }



  func testAutosuggestHelperDebouncer() {
    let expectation = self.expectation(description: "Voice API")

    let somewhereInLondon = CLLocationCoordinate2D(latitude: 51.520847,longitude: -0.195521)

    let helper = W3WAutosuggestHelper(api)

    // "daring.lion.race" is used, but because 3 more are immediately sent in, only the last one, "filled.count.soap", should return
    helper.update(text: "daring.lion.race", options: W3WOption.focus(somewhereInLondon)) { error in
      XCTAssertEqual("filled.count.soap", helper.getSuggestion(row: 0)?.words)
      expectation.fulfill()
    }

    helper.update(text: "index.home.raft", options: W3WOption.focus(somewhereInLondon)) { error in XCTAssertTrue(false) }
    helper.update(text: "deed.tulip.judge", options: W3WOption.focus(somewhereInLondon)) { error in XCTAssertTrue(false) }
    helper.update(text: "filled.count.soap", options: W3WOption.focus(somewhereInLondon)) { error in XCTAssertTrue(false) }

    waitForExpectations(timeout: 30.0, handler: nil)
  }
  

  
  // MARK: - Voice API tests

#if !os(watchOS)
  /// test for a timeout error
  func testVoiceApiTimoutError() {
    let expectation = self.expectation(description: "Voice API")
    
    let stream = W3WAudioStream(sampleRate: 44100, encoding: .pcm_f32le)
    
    api.autosuggest(audio: stream, language: "en") { suggestions, error in
      XCTAssertNotNil(error)
      expectation.fulfill()
    }
    
    waitForExpectations(timeout: 30.0, handler: nil)
  }


  func testVoiceApi() {
    let expectation = self.expectation(description: "Voice API")
    
    let somewhereInLondon = CLLocationCoordinate2D(latitude: 51.520847,longitude: -0.195521)
    
    if let resource = try? Resource(name: "test", type: "dat") {

      // load a file of raw audio data containing a mono stream of 32 bit float data samples
      if let data = try? Data(contentsOf: resource.url) {
      
        // set the stream to accept PCM 32 bit float audio data at 44.1kHz sample rate
        let audio = W3WAudioStream(sampleRate: 44100, encoding: .pcm_f32le)
        
        // assign the audio stream to an autosuggest call
        api.autosuggest(audio: audio, language: "en", options: W3WOption.focus(somewhereInLondon)) { suggestions, error in

          XCTAssertNil(error)

          if suggestions?.first?.words == "filled.count.soap" {
            expectation.fulfill()
          }
        }
        
        // finally, send the audio data.  This can be called repeatedly as new data become available if you want to live stream
        audio.add(samples: data)
        
        // tell the server no more data will come (optional, you can instead let end of speach detection terminate the process)
        audio.endSamples()
        
        waitForExpectations(timeout: 60.0, handler: nil)
      }
    }
    
  }


//  func callVoiceAutosuggest(data: Data, completion: @escaping () -> ()) {
//    let somewhereInLondon = CLLocationCoordinate2D(latitude: 51.520847,longitude: -0.195521)
//
//    // set the stream to accept PCM 32 bit float audio data at 44.1kHz sample rate
//    let audio = W3WAudioStream(sampleRate: 44100, encoding: .pcm_f32le)
//
//    // assign the audio stream to an autosuggest call
//    api.autosuggest(audio: audio, language: "en", options: W3WOption.focus(somewhereInLondon)) { suggestions, error in
//
//      if error != nil {
//        print(error!)
//      }
//
//      XCTAssertNil(error)
//      XCTAssertEqual(suggestions?.first?.words, "filled.count.soap")
//
//      completion()
//    }
//
//    // finally, send the audio data.  This can be called repeatedly as new data become available if you want to live stream
//    audio.add(samples: data)
//
//    // tell the server no more data will come (optional, you can instead let end of speach detection terminate the process)
//    audio.endSamples()
//  }


//func testVoiceMultipleTimes() {
//  let expectation = self.expectation(description: "Voice API Multiple")
//
//  if let resource = try? Resource(name: "test", type: "dat") {
//
//    // load a file of raw audio data containing a mono stream of 32 bit float data samples
//    if let data = try? Data(contentsOf: resource.url) {
//      self.callVoiceAutosuggest(data: data) {
//        self.callVoiceAutosuggest(data: data) {
//          self.callVoiceAutosuggest(data: data) {
//            expectation.fulfill()
//          }
//        }
//      }
//
//      waitForExpectations(timeout: 30.0, handler: nil)
//    }
//  }
//
//}

#endif

}


struct Resource {
  let name: String
  let type: String
  let url: URL

  init(name: String, type: String, sourceFile: StaticString = #file) throws {
    self.name = name
    self.type = type

    let testCaseURL = URL(fileURLWithPath: "\(sourceFile)", isDirectory: false)
    let testsFolderURL = testCaseURL.deletingLastPathComponent()
    let resourcesFolderURL = testsFolderURL.deletingLastPathComponent().appendingPathComponent("Resources", isDirectory: true)
    self.url = resourcesFolderURL.appendingPathComponent("\(name).\(type)", isDirectory: false)
  }
}
