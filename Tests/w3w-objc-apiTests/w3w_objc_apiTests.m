////
////  File.m
////  
////
////  Created by Dave Duprey on 21/09/2021.
////
//
#import <XCTest/XCTest.h>
#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>
@import W3WSwiftApi;


@interface w3w_objc_apiTests : XCTestCase {
  What3WordsObjC *api;
}
@end

@implementation w3w_objc_apiTests


-(void)setUp
{
  NSString *api_key = NSProcessInfo.processInfo.environment[@"PROD_API_KEY"];
  if (api_key == NULL) {
    api_key = [self getApikeyFromFile];
    if (api_key == NULL) {
      NSLog(@"Environment variable PROD_API_KEY must be set");
      abort();
    }
  }
  api = [[What3WordsObjC alloc] initWithApiKey: api_key];
}


-(NSString *)getApikeyFromFile {
  NSURL *url = [NSURL fileURLWithPath: @"/tmp/key.txt"];
  NSString *key =  [NSString stringWithContentsOfURL: url  encoding: kCFStringEncodingUTF8 error: NULL];
  NSString *apikey = @"";
  
  if (key != NULL)
    {
    apikey = [key stringByTrimmingCharactersInSet: NSCharacterSet.whitespaceAndNewlineCharacterSet];
    }
  
  return apikey;
}


- (void)testConvertToCoordinates
{
  XCTestExpectation *expectation = [[XCTestExpectation alloc] initWithDescription:@"convert2coords"];
  
  // what3words address to (lat,long)
  [api convertToCoordinates: @"filled.count.soap" completion: ^(W3WObjcSquare *square, NSError *error) {
    XCTAssertNil(error);
    XCTAssertNotNil(square.coordinates);
    XCTAssertEqual(square.coordinates.latitude, 51.520847000000003);
    [expectation fulfill];
  }];
  
  [self waitForExpectations:[NSArray arrayWithObject:expectation] timeout:3.0];
}


- (void)testConvertTo3wa
{
  XCTestExpectation *expectation = [[XCTestExpectation alloc] initWithDescription:@"convert2coords"];
  
  // what3words address to (lat,long)
  [api convertTo3wa:CLLocationCoordinate2DMake(51.520847, -0.195521) language:@"en" completion: ^(W3WObjcSquare *square, NSError *error) {
    XCTAssertNil(error);
    XCTAssertNotNil(square.words);
    XCTAssertTrue([square.words isEqualToString:@"filled.count.soap"]);
    [expectation fulfill];
  }];
  
  [self waitForExpectations:[NSArray arrayWithObject:expectation] timeout:3.0];
}


- (void)testconvertTo3waLanguage {
  XCTestExpectation *expectation = [self expectationWithDescription:@"Convert to 3wa"];
  
  CLLocationCoordinate2D coordinates = CLLocationCoordinate2DMake(51.521238, -0.203607);
  
  [api convertTo3wa:coordinates language:@"de" completion:^(W3WObjcSquare *place, NSError *error)
  {
    XCTAssertNil(error);
    XCTAssertTrue([place.words isEqualToString:@"welche.tischtennis.bekannte"]);
    [expectation fulfill];
  }];
  
  [self waitForExpectationsWithTimeout:3.0 handler:nil];
}



- (void)testGridSection {
  XCTestExpectation *expectation = [self expectationWithDescription:@"Grid Section"];
  
  [api gridSection:52.208867 west_lng:0.117540 north_lat:52.207988 east_lng:0.116126 completion:^(NSArray<W3WObjcLine *> *grid, NSError *error)
   {
  XCTAssertNil(error);
  XCTAssertEqual([grid count], 96);
  XCTAssertNotNil(grid);
  
  [expectation fulfill];
  }];
  
  [self waitForExpectationsWithTimeout:3.0 handler:nil];
}


-(void)testLanguages {
  XCTestExpectation *expectation = [self expectationWithDescription:@"Available Languages"];
  
  [api availableLanguages:^(NSArray<W3WObjcLanguage *>*languages, NSError *error)
   {
  XCTAssertNil(error);
  XCTAssertGreaterThan([languages count], 10);
  XCTAssertNotNil(languages);
  
  [expectation fulfill];
  }];
  
  [self waitForExpectationsWithTimeout:3.0 handler:nil];
}



-(void)testAutosuggestCountry {
  XCTestExpectation *expectation = [self expectationWithDescription:@"Auto Suggest"];
  
  // create autosuggest options
  W3WObjcOptions *options = [[W3WObjcOptions alloc] init];
  [options addClipToCountry:@"de"];
  [options addNumberOfResults:5];

  [api autosuggest:@"geschaft.planter.carciofi" options:options completion:^(NSArray<W3WObjcSuggestion *> *suggestions, NSError *error)
   {
  XCTAssertNil(error);
  
  XCTAssertGreaterThan([suggestions count], 0);
  
  if ([suggestions count] > 0)
    {
    W3WObjcSuggestion *first_match = suggestions[0];
    
    // handle the response
    XCTAssertTrue(suggestions.count == 5);
    XCTAssertTrue([first_match.words isEqualToString:@"rischiare.piante.carciofi"]);
    }
  
  [expectation fulfill];
  }];
  
  [self waitForExpectationsWithTimeout:3.0 handler:nil];
}



-(void)testAutoSuggest {
  XCTestExpectation *expectation = [self expectationWithDescription:@"Auto Suggest"];
  
  [api autosuggest:@"geschaft.planter.carciofi" completion:^(NSArray<W3WObjcSuggestion *> *suggestions, NSError *error)
  {
  XCTAssertNil(error);
  
  XCTAssertGreaterThan([suggestions count], 0);
  
  if ([suggestions count] > 0)
    {
    // handle the response
    W3WObjcSuggestion *first_match = suggestions[0];
    
    XCTAssertTrue(suggestions.count == 3);
    XCTAssertTrue([first_match.words isEqualToString:@"esche.piante.carciofi"]);
    }
  
  [expectation fulfill];
  }];
  
  [self waitForExpectationsWithTimeout:5.0 handler:nil];
}


-(void)testAutoSuggestVoice {
  XCTestExpectation *expectation = [self expectationWithDescription:@"Auto Suggest"];
  
  NSString *voice_data = @"%7B%22_isInGrammar%22%3A%22yes%22%2C%22_isSpeech%22%3A%22yes%22%2C%22_hypotheses%22%3A%5B%7B%22_score%22%3A342516%2C%22_startRule%22%3A%22whatthreewordsgrammar%23_main_%22%2C%22_conf%22%3A6546%2C%22_endTimeMs%22%3A6360%2C%22_beginTimeMs%22%3A1570%2C%22_lmScore%22%3A300%2C%22_items%22%3A%5B%7B%22_type%22%3A%22terminal%22%2C%22_score%22%3A34225%2C%22_orthography%22%3A%22tend%22%2C%22_conf%22%3A6964%2C%22_endTimeMs%22%3A2250%2C%22_beginTimeMs%22%3A1580%7D%2C%7B%22_type%22%3A%22terminal%22%2C%22_score%22%3A47670%2C%22_orthography%22%3A%22artichokes%22%2C%22_conf%22%3A7176%2C%22_endTimeMs%22%3A3180%2C%22_beginTimeMs%22%3A2260%7D%2C%7B%22_type%22%3A%22terminal%22%2C%22_score%22%3A43800%2C%22_orthography%22%3A%22poached%22%2C%22_conf%22%3A6181%2C%22_endTimeMs%22%3A4060%2C%22_beginTimeMs%22%3A3220%7D%5D%7D%2C%7B%22_score%22%3A342631%2C%22_startRule%22%3A%22whatthreewordsgrammar%23_main_%22%2C%22_conf%22%3A6498%2C%22_endTimeMs%22%3A6360%2C%22_beginTimeMs%22%3A1570%2C%22_lmScore%22%3A300%2C%22_items%22%3A%5B%7B%22_type%22%3A%22terminal%22%2C%22_score%22%3A34340%2C%22_orthography%22%3A%22tent%22%2C%22_conf%22%3A6772%2C%22_endTimeMs%22%3A2250%2C%22_beginTimeMs%22%3A1580%7D%2C%7B%22_type%22%3A%22terminal%22%2C%22_score%22%3A47670%2C%22_orthography%22%3A%22artichokes%22%2C%22_conf%22%3A7176%2C%22_endTimeMs%22%3A3180%2C%22_beginTimeMs%22%3A2260%7D%2C%7B%22_type%22%3A%22terminal%22%2C%22_score%22%3A43800%2C%22_orthography%22%3A%22poached%22%2C%22_conf%22%3A6181%2C%22_endTimeMs%22%3A4060%2C%22_beginTimeMs%22%3A3220%7D%5D%7D%2C%7B%22_score%22%3A342668%2C%22_startRule%22%3A%22whatthreewordsgrammar%23_main_%22%2C%22_conf%22%3A6474%2C%22_endTimeMs%22%3A6360%2C%22_beginTimeMs%22%3A1570%2C%22_lmScore%22%3A300%2C%22_items%22%3A%5B%7B%22_type%22%3A%22terminal%22%2C%22_score%22%3A34225%2C%22_orthography%22%3A%22tend%22%2C%22_conf%22%3A6964%2C%22_endTimeMs%22%3A2250%2C%22_beginTimeMs%22%3A1580%7D%2C%7B%22_type%22%3A%22terminal%22%2C%22_score%22%3A47670%2C%22_orthography%22%3A%22artichokes%22%2C%22_conf%22%3A7176%2C%22_endTimeMs%22%3A3180%2C%22_beginTimeMs%22%3A2260%7D%2C%7B%22_type%22%3A%22terminal%22%2C%22_score%22%3A41696%2C%22_orthography%22%3A%22perch%22%2C%22_conf%22%3A5950%2C%22_endTimeMs%22%3A4020%2C%22_beginTimeMs%22%3A3220%7D%5D%7D%2C%7B%22_score%22%3A342670%2C%22_startRule%22%3A%22whatthreewordsgrammar%23_main_%22%2C%22_conf%22%3A6474%2C%22_endTimeMs%22%3A6360%2C%22_beginTimeMs%22%3A1570%2C%22_lmScore%22%3A300%2C%22_items%22%3A%5B%7B%22_type%22%3A%22terminal%22%2C%22_score%22%3A34379%2C%22_orthography%22%3A%22tinge%22%2C%22_conf%22%3A6705%2C%22_endTimeMs%22%3A2250%2C%22_beginTimeMs%22%3A1580%7D%2C%7B%22_type%22%3A%22terminal%22%2C%22_score%22%3A47670%2C%22_orthography%22%3A%22artichokes%22%2C%22_conf%22%3A7176%2C%22_endTimeMs%22%3A3180%2C%22_beginTimeMs%22%3A2260%7D%2C%7B%22_type%22%3A%22terminal%22%2C%22_score%22%3A43800%2C%22_orthography%22%3A%22poached%22%2C%22_conf%22%3A6181%2C%22_endTimeMs%22%3A4060%2C%22_beginTimeMs%22%3A3220%7D%5D%7D%2C%7B%22_score%22%3A342783%2C%22_startRule%22%3A%22whatthreewordsgrammar%23_main_%22%2C%22_conf%22%3A6426%2C%22_endTimeMs%22%3A6360%2C%22_beginTimeMs%22%3A1570%2C%22_lmScore%22%3A300%2C%22_items%22%3A%5B%7B%22_type%22%3A%22terminal%22%2C%22_score%22%3A34340%2C%22_orthography%22%3A%22tent%22%2C%22_conf%22%3A6772%2C%22_endTimeMs%22%3A2250%2C%22_beginTimeMs%22%3A1580%7D%2C%7B%22_type%22%3A%22terminal%22%2C%22_score%22%3A47670%2C%22_orthography%22%3A%22artichokes%22%2C%22_conf%22%3A7176%2C%22_endTimeMs%22%3A3180%2C%22_beginTimeMs%22%3A2260%7D%2C%7B%22_type%22%3A%22terminal%22%2C%22_score%22%3A41696%2C%22_orthography%22%3A%22perch%22%2C%22_conf%22%3A5950%2C%22_endTimeMs%22%3A4020%2C%22_beginTimeMs%22%3A3220%7D%5D%7D%2C%7B%22_score%22%3A342822%2C%22_startRule%22%3A%22whatthreewordsgrammar%23_main_%22%2C%22_conf%22%3A6402%2C%22_endTimeMs%22%3A6360%2C%22_beginTimeMs%22%3A1570%2C%22_lmScore%22%3A300%2C%22_items%22%3A%5B%7B%22_type%22%3A%22terminal%22%2C%22_score%22%3A34379%2C%22_orthography%22%3A%22tinge%22%2C%22_conf%22%3A6705%2C%22_endTimeMs%22%3A2250%2C%22_beginTimeMs%22%3A1580%7D%2C%7B%22_type%22%3A%22terminal%22%2C%22_score%22%3A47670%2C%22_orthography%22%3A%22artichokes%22%2C%22_conf%22%3A7176%2C%22_endTimeMs%22%3A3180%2C%22_beginTimeMs%22%3A2260%7D%2C%7B%22_type%22%3A%22terminal%22%2C%22_score%22%3A41696%2C%22_orthography%22%3A%22perch%22%2C%22_conf%22%3A5950%2C%22_endTimeMs%22%3A4020%2C%22_beginTimeMs%22%3A3220%7D%5D%7D%5D%2C%22_resultType%22%3A%22NBest%22%7D";
  
  // create autosuggest options
  W3WObjcOptions *options = [[W3WObjcOptions alloc] init];
  [options addInputType:W3WObjcInputTypeVoconHybrid];
  [options addNumberOfResults:3];
  [options addLanguage:@"en"];
  [options addFocus:CLLocationCoordinate2DMake(51.4243877, -0.3474524)];

  [api autosuggest:voice_data.stringByRemovingPercentEncoding options:options completion:^(NSArray<W3WObjcSuggestion *> *suggestions, NSError *error)
   {
   XCTAssertNil(error);
  
  if (suggestions.count > 0)
    {
    W3WObjcSuggestion *first_match = suggestions[0];
    NSString *expected_result = @"tend.artichokes.perch";
    
    XCTAssertTrue([first_match.words isEqualToString:expected_result]);
    }
  
  XCTAssertTrue(suggestions.count == 3);
  
  [expectation fulfill];
  }];
  
  [self waitForExpectationsWithTimeout:3.0 handler:nil];
}


-(void)testAutoSuggestGenericVoice {
  XCTestExpectation *expectation = [self expectationWithDescription:@"Auto Suggest"];
  
  // create autosuggest options
  W3WObjcOptions *options = [[W3WObjcOptions alloc] init];
  [options addInputType:W3WObjcInputTypeGenericVoice];
  [options addLanguage:@"en"];

  [api autosuggest:@"filled count soap" options:options completion:^(NSArray<W3WObjcSuggestion *> *suggestions, NSError *error)
   {
    XCTAssertNil(error);
    
    if (suggestions.count > 0)
      {
      W3WObjcSuggestion *first_match = suggestions[0];
      NSString *expected_result = @"filled.count.soap";
      
      XCTAssertTrue([first_match.words isEqualToString:expected_result]);
      }
    
    XCTAssertTrue(suggestions.count == 3);
    
    [expectation fulfill];
  }];
  
  [self waitForExpectationsWithTimeout:3.0 handler:nil];
}



-(void)testAutoSuggestBoundingBox {
  XCTestExpectation *expectation = [self expectationWithDescription:@"Auto Suggest"];
  
  // create autosuggest options
  W3WObjcOptions *options = [[W3WObjcOptions alloc] init];
  [options addClipToBoxSouthWest: CLLocationCoordinate2DMake(51.521, -0.323) northEast: CLLocationCoordinate2DMake(52.6, 2.3324)];

  [api autosuggest:@"thing.thing.thing" options:options completion:^(NSArray<W3WObjcSuggestion *> *suggestions, NSError *error)
   {
  XCTAssertNil(error);
  
  if (suggestions.count > 0)
    {
    W3WObjcSuggestion *first_match = suggestions[0];
    NSString *expected_result = @"things.thinks.thing";
    
    XCTAssertTrue([first_match.words isEqualToString:expected_result]);
    }
  
  XCTAssertTrue(suggestions.count == 3);
  
  [expectation fulfill];
  }];
  
  [self waitForExpectationsWithTimeout:3.0 handler:nil];
}



-(void)testAutoSuggestPreferLand {
  XCTestExpectation *expectation = [self expectationWithDescription:@"Auto Suggest"];
  
  // create autosuggest options
  W3WObjcOptions *options = [[W3WObjcOptions alloc] init];
  [options addPreferLand: NO];
  
  [api autosuggest:@"bisect.nourishment.genuineness" options:options completion:^(NSArray<W3WObjcSuggestion *> *suggestions, NSError *error)
   {
  XCTAssertNil(error);
  
  if (suggestions.count > 2)
    {
    W3WObjcSuggestion *first_match = suggestions[0];
    NSString *expected_result = @"ZZ";
    
    XCTAssertTrue([first_match.country isEqualToString:expected_result]);
    }
  
  XCTAssertTrue(suggestions.count == 3);
  
  [expectation fulfill];
  }];
  
  [self waitForExpectationsWithTimeout:3.0 handler:nil];
}



-(void)testAutoSuggestPolygon {
  XCTestExpectation *expectation = [self expectationWithDescription:@"Auto Suggest"];
  
  NSArray *polygon = @[
    [NSValue valueWithMKCoordinate: CLLocationCoordinate2DMake(51.0, 0.0)],
    [NSValue valueWithMKCoordinate: CLLocationCoordinate2DMake(51.0, 0.1)],
    [NSValue valueWithMKCoordinate: CLLocationCoordinate2DMake(51.1, 0.1)],
    [NSValue valueWithMKCoordinate: CLLocationCoordinate2DMake(51.1, 0.0)],
    [NSValue valueWithMKCoordinate: CLLocationCoordinate2DMake(51.0, 0.0)]
  ];
  
  // create autosuggest options
  W3WObjcOptions *options = [[W3WObjcOptions alloc] init];
  [options addClipToPolygon: polygon];

  [api autosuggest:@"scenes.irritated.sparkle" options:options completion:^(NSArray<W3WObjcSuggestion *> *suggestions, NSError *error)
   {
  XCTAssertNil(error);
  
  if (suggestions.count > 0)
    {
    W3WObjcSuggestion *first_match = suggestions[0];
    NSString *expected_result = @"scenes.irritated.sparkles";
    
    XCTAssertTrue([first_match.words isEqualToString:expected_result]);
    }
  
  [expectation fulfill];
  }];
  
  [self waitForExpectationsWithTimeout:3.0 handler:nil];
}
  


-(void)testAutoSuggestBoundingCircle {
  XCTestExpectation *expectation = [self expectationWithDescription:@"Auto Suggest"];
  
  // create autosuggest options
  W3WObjcOptions *options = [[W3WObjcOptions alloc] init];
  [options addClipToCircle: CLLocationCoordinate2DMake(51.521238, -0.203607) radius: 1.0];

  [api autosuggest:@"mitiger.tarir.prolong" options:options completion:^(NSArray<W3WObjcSuggestion *> *suggestions, NSError *error)
   {
  XCTAssertNil(error);
  
  if (suggestions.count > 0)
    {
    W3WObjcSuggestion *first_match = suggestions[0];
    NSString *expected_result = @"mitiger.tarir.prolonger";
    
    XCTAssertTrue([first_match.words isEqualToString:expected_result]);
    }
  
  [expectation fulfill];
  }];
  
  [self waitForExpectationsWithTimeout:3.0 handler:nil];
}



-(void)testAutoSuggestFocus {
  XCTestExpectation *expectation = [self expectationWithDescription:@"Auto Suggest"];
  
  // create autosuggest options
  W3WObjcOptions *options = [[W3WObjcOptions alloc] init];
  [options addFocus:CLLocationCoordinate2DMake(51.4243877, -0.34745)];

  [api autosuggest:@"geschaft.planter.carciofi" options:options completion:^(NSArray<W3WObjcSuggestion *> *suggestions, NSError *error)
   {
  XCTAssertNil(error);
  
  if (suggestions.count > 0)
    {
    W3WObjcSuggestion *first_match = suggestions[0];
    NSString *expected_result = @"restate.piante.carciofo";
    
    XCTAssertTrue([first_match.words isEqualToString:expected_result]);
    }
  
  [expectation fulfill];
  }];
  
  [self waitForExpectationsWithTimeout:3.0 handler:nil];
}


-(void)testAutoSuggestFocusNumberResults {
  XCTestExpectation *expectation = [self expectationWithDescription:@"Auto Suggest"];
  
  // create autosuggest options
  W3WObjcOptions *options = [[W3WObjcOptions alloc] init];
  [options addFocus:CLLocationCoordinate2DMake(51.4243877, -0.34745)];
  [options addNumberOfResults: 6];
  [options addNumberFocusResults: 1];

  [api autosuggest:@"geschaft.planter.carciofi" options:options completion:^(NSArray<W3WObjcSuggestion *> *suggestions, NSError *error)
   {
  XCTAssertNil(error);
  
  if (suggestions.count > 2)
    {
    W3WObjcSuggestion *first_match = suggestions[0];
    NSString *expected_result = @"restate.piante.carciofo";
    XCTAssertTrue([first_match.words isEqualToString:expected_result]);
    XCTAssertTrue([first_match.distanceToFocus isEqualToNumber:[NSNumber numberWithInt:51]]);
    
    //W3WObjcSuggestion *third_match = suggestions[2];
    //XCTAssertTrue([third_match.distanceToFocus isGreaterThan:[NSNumber numberWithInt:100]]);
    }
  
  [expectation fulfill];
  }];
  
  [self waitForExpectationsWithTimeout:3.0 handler:nil];
}


-(void)testAutoSuggestNumberResults {
  XCTestExpectation *expectation = [self expectationWithDescription:@"Auto Suggest"];
  
  // create autosuggest options
  W3WObjcOptions *options = [[W3WObjcOptions alloc] init];
  [options addNumberOfResults: 10];

  [api autosuggest:@"poi.poi.poi" options:options completion:^(NSArray<W3WObjcSuggestion *> *suggestions, NSError *error)
   {
    XCTAssertNil(error);
    XCTAssertTrue(suggestions.count == 10);
    [expectation fulfill];
  }];
  
  [self waitForExpectationsWithTimeout:3.0 handler:nil];
}



-(void)testAutoSuggestFallbackLanguage {
  XCTestExpectation *expectation = [self expectationWithDescription:@"Auto Suggest"];
  
  // create autosuggest options
  W3WObjcOptions *options = [[W3WObjcOptions alloc] init];
  [options addLanguage:@"de"];
  
  [api autosuggest:@"aaa.aaa.aaa" options:options completion:^(NSArray<W3WObjcSuggestion *> *suggestions, NSError *error)
   {
  XCTAssertNil(error);
  
  if (suggestions.count > 0)
    {
    W3WObjcSuggestion *first_match = suggestions[0];
    NSString *expected_result = @"saal.saal.saal";
    
    XCTAssertTrue([first_match.words isEqualToString:expected_result]);
    }
  
  [expectation fulfill];
  }];
  
  [self waitForExpectationsWithTimeout:3.0 handler:nil];
}


-(void)testBadWords {
  XCTestExpectation *expectation = [self expectationWithDescription:@"Convert to Coords"];
  
  NSString *words = @"aaa.bbb.ccc";
  
  [api convertToCoordinates:words completion:^(W3WObjcSquare *place, NSError *error)
   {
    XCTAssertTrue([error.localizedDescription isEqualToString:@"Words not found in what3words"]);
    [expectation fulfill];
  }];
  
  [self waitForExpectationsWithTimeout:3.0 handler:nil];
}



@end
