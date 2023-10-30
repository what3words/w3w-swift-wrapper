import CoreLocation
import W3WSwiftCore


import XCTest
@testable import W3WSwiftVoiceApi

final class w3w_swift_wrapperTests: XCTestCase {
  
  
  var api:W3WVoiceApi!
  
  
  override func setUp() {
    super.setUp()
    
    if let apikey = ProcessInfo.processInfo.environment["PROD_API_KEY"] {
      api = W3WVoiceApi(apiKey: apikey)
    } else if let apikey = getApikeyFromFile() {
      api = W3WVoiceApi(apiKey: apikey)
    } else {
      print("Environment variable PROD_API_KEY must be set")
      abort()
    }
  }
  
  
  func getApikeyFromFile() -> String? {
    var apikey: String? = nil
    
    let url = URL(fileURLWithPath: "/tmp/key.txt")
    if let key = try? String(contentsOf: url, encoding: .utf8) {
      apikey = key.trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    return apikey
  }
  
  
  // MARK: - Voice API tests
  
  
#if !os(watchOS)
  func testVoiceLanguages() {
    let expectation = self.expectation(description: "Languages")

    api.availableVoiceLanguages() { (languages, error) in

      XCTAssertNotNil(languages)
      if let l = languages {
        XCTAssertGreaterThan(l.count, 0, "No languages returned")
      }
      XCTAssertNotNil(languages?.first?.code)
      //XCTAssertNotNil(languages?.first?.name)
      //XCTAssertNotNil(languages?.first?.nativeName)
      XCTAssertNil(error)
      expectation.fulfill()
    }
    waitForExpectations(timeout: 3.0, handler: nil)
  }
#endif

  
  
  //#if !os(watchOS)
  //  /// test for a timeout error
  //  func testVoiceApiTimoutError() {
  //    XCTAssertTrue(false)
  //    //    let expectation = self.expectation(description: "Voice API")
  //    //
  //    //    let stream = W3WAudioStream(sampleRate: 44100, encoding: .pcm_f32le)
  //    //
  //    //    api.autosuggest(audio: stream, language: "en") { suggestions, error in
  //    //      XCTAssertNotNil(error)
  //    //      expectation.fulfill()
  //    //    }
  //    //
  //    //    waitForExpectations(timeout: 30.0, handler: nil)
  //  }
  
#if os(iOS)
  func testVoiceApi() {
    XCTAssertTrue(false)
//    let expectation = self.expectation(description: "Voice API")
//    
//    let somewhereInLondon = CLLocationCoordinate2D(latitude: 51.520847,longitude: -0.195521)
//    
//    if let resource = try? Resource(name: "test", type: "dat") {
//      
//      // load a file of raw audio data containing a mono stream of 32 bit float data samples
//      if let data = try? Data(contentsOf: resource.url) {
//        
//        // set the stream to accept PCM 32 bit float audio data at 44.1kHz sample rate
//        let audio = W3WAudioStream(sampleRate: 44100, encoding: .pcm_f32le)
//        
//        // assign the audio stream to an autosuggest call
//        api.autosuggest(audio: audio, language: "en", options: W3WOption.focus(somewhereInLondon)) { suggestions, error in
//          
//          XCTAssertNil(error)
//          
//          if suggestions?.first?.words == "filled.count.soap" {
//            expectation.fulfill()
//          }
//        }
//        
//        // finally, send the audio data.  This can be called repeatedly as new data become available if you want to live stream
//        audio.add(samples: data)
//        
//        // tell the server no more data will come
//        audio.endSamples()
//        
//        waitForExpectations(timeout: 60.0, handler: nil)
//      }
//    }
    
  }
#endif
  
  
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
  
}
  

