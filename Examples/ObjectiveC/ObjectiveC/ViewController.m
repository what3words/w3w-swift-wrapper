//
//  ViewController.m
//  ObjectiveC
//
//  Created by Dave Duprey on 20/09/2021.
//

@import W3WSwiftApi;
#import <MapKit/MapKit.h>
#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
  [super viewDidLoad];

  // create the API wrapper
  What3WordsObjC *api = [[What3WordsObjC alloc] initWithApiKey: @"YourApiKeyGoesHere"];
    
  // convert what3words address to (lat,long)
  [api convertToCoordinates: @"filled.count.soap" completion: ^(W3WObjcSquare *square, NSError *error) {
    NSLog(@"%@ is at (%f, %f)", square.words, square.coordinates.latitude, square.coordinates.longitude);

    // convert (lat,long) back to what3words address
    [api convertTo3wa:CLLocationCoordinate2DMake(square.coordinates.latitude, square.coordinates.longitude) language:@"en" completion: ^(W3WObjcSquare *square, NSError *error) {
      NSLog(@"(%f, %f) has address: %@", square.coordinates.latitude, square.coordinates.longitude, square.words);
    }];
    
  }];
  
  // create autosuggest options
  W3WObjcOptions *options = [[W3WObjcOptions alloc] init];
  [options addFocus:CLLocationCoordinate2DMake(51.520847, -0.195521)];

  // call autosuggest
  [api autosuggest:@"filled.count.soa" options:options completion: ^(NSArray<W3WObjcSuggestion *> *suggestions, NSError *error) {
    NSLog(@"Matches for 'filled.count.soa' are:");
    for (int i=0; i<suggestions.count; i++) {
      NSLog(@" - %@, near %@", suggestions[i].words, suggestions[i].nearestPlace);
    }
  }];
  

  // call autosuggest with coordinates
  [api autosuggestWithCoordinates:@"filled.count.soa" options:options completion: ^(NSArray<W3WObjcSquare *> *suggestions, NSError *error) {
    NSLog(@"Matches for 'filled.count.soa' are:");
    for (int i=0; i<suggestions.count; i++) {
      NSLog(@" - %@, near %@ (%f, %f)", suggestions[i].words, suggestions[i].nearestPlace, suggestions[i].coordinates.latitude, suggestions[i].coordinates.longitude);
    }
  }];
  
}


@end
