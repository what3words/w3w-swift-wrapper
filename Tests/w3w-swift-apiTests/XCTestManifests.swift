import XCTest

#if !canImport(ObjectiveC)
public func allTests() -> [XCTestCaseEntry] {
    return [
      testCase(w3w_swift_apiTests.allTests),
      testCase(w3w_objc_apiTests.allTests),
    ]
}
#endif
