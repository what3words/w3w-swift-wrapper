import CoreLocation
import W3WSwiftCore


import XCTest
@testable import W3WSwiftApi

class MockW3WProtocolV3 {
    
        var autosuggestClosure: (String, [W3WOption]?, W3WSuggestionsResponse) -> Void = { _, _, _ in }
        
        public func autosuggest(text: String, completion: @escaping W3WSuggestionsResponse) {
            autosuggest(text: text, options: nil, completion: completion)
        }
        
        public func autosuggest(text: String, options: [W3WOption]?, completion: @escaping W3WSuggestionsResponse) {
            autosuggestClosure(text, options, completion)
        }
        
        public func isValid3wa(words: String, completion: @escaping (Bool) -> ()) {
            autosuggest(text: words) { suggestions, error in
                
                for suggestion in suggestions ?? [] {
                    let w1 = suggestion.words?.trimmingCharacters(in: CharacterSet(charactersIn: "/")).lowercased()
                    let w2 = words.trimmingCharacters(in: CharacterSet(charactersIn: "/")).lowercased()
                    
                    if w1 == w2 {
                        completion(true)
                        return
                    }
                }
                
                completion(false)
            }
        }
}


final class w3w_swift_wrapper_code_coverageTests: XCTestCase {
  
    var sut: MockW3WProtocolV3! // System Under Test
    
    override func setUp() {
        super.setUp()
        sut = MockW3WProtocolV3() // Initialize W3WProtocolV4 instance
    }
    
    override func tearDown() {
        sut = nil
        super.tearDown()
    }
    
    func testIsValid3wa_Autosuggest() {
        // Given
        let expectation = self.expectation(description: "isValid3wa completion handler called")
        let testWords = "invalid.words.here"
      
        // Mock the autosuggest function to return an error
        sut.autosuggestClosure = { _, _, completion in
                   completion(nil, nil)
        }
        
        // When
        sut.isValid3wa(words: testWords) { isValid in
            // Then
            XCTAssertFalse(isValid, "isValid should be false when autosuggest returns an error")
            
            expectation.fulfill()
        }
        
        waitForExpectations(timeout: 5, handler: nil)
    }
    
    
    
}
  

