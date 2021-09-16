//
//  File.swift
//  
//
//  Created by Dave Duprey on 16/09/2021.
//

import Foundation
import MapKit



/// Objective-C compatible Suggestion object
@objcMembers public class W3WObjcSuggestion: NSObject {
  public var words: NSString?
  public var country: NSString?
  public var nearestPlace: NSString?
  public var distanceToFocus: NSNumber?
  public var language: NSString?
  
  public init(words: String?, country: String?, nearestPlace: String?, distanceToFocus: NSNumber?, language: String?) {
    self.words            = words as NSString?
    self.country          = country as NSString?
    self.nearestPlace     = nearestPlace as NSString?
    self.distanceToFocus  = NSNumber(nonretainedObject: distanceToFocus)
    self.language         = language as NSString?
  }
}


/// ObjC enum for autosuggest input type option
@objc public enum W3WObjcInputType: Int {
  case text
  case voconHybrid
  case nmdpAsr
  case genericVoice
  case speechmatics
  case mihup
}


/// ObjC compatible option object for autosuggest calls
@objcMembers public class W3WObjcOptions: NSObject {
  public var options = [W3WOption]()
  
  /// location of the user to help autosuggest provide more relevant suggestions
  public func addFocus(_ focus: CLLocationCoordinate2D) {
    options.append(W3WOption.focus(focus))
  }
  
  /// language to use for the voice API
  public func addVoiceLanguage(_ voiceLanguage: String) {
    options.append(W3WOption.voiceLanguage(voiceLanguage))
  }
  
  /// number of results that will use the focus option
  public func addNumberFocusResults(_ numberFocusResults: Int) {
    options.append(W3WOption.numberFocusResults(numberFocusResults))
  }
  
  /// the number of results to return in total
  public func addNumberOfResults(_ numberOfResults: Int) {
    options.append(W3WOption.numberOfResults(numberOfResults))
  }
  
  /// tells autosuggest to only return results from one country
  public func addClipToCountry(_ clipToCountry: String) {
    options.append(W3WOption.clipToCountry(clipToCountry))
  }
  
  /// tells autosuggest to limit results to particular countries
  public func addClipToCountries(_ clipToCountries: [String]) {
    options.append(W3WOption.clipToCountries(clipToCountries))
  }
  
  /// limit results to a particular geographic circle
  public func addClipToCircle(_ center:CLLocationCoordinate2D, radius: Double) {
    options.append(W3WOption.clipToCircle(center: center, radius: radius))
  }
  
  /// limit results to a geographic rectangle
  public func addClipToBoxSouthWest(_ southWest:CLLocationCoordinate2D, northEast:CLLocationCoordinate2D) {
    options.append(W3WOption.clipToBox(southWest: southWest, northEast: northEast))
  }
  
  /// limit results to a geographic polygon
  public func addClipToPolygon(_ clipToPolygon: [CLLocationCoordinate2D]) {
    options.append(W3WOption.clipToPolygon(clipToPolygon))
  }
  
  /// gives preference to land based addresses
  public func addPreferLand(_ preferLand: Bool) {
    options.append(W3WOption.preferLand(preferLand))
  }
  
  
  /// tells autosuggest which type of data is being passed to it (not relevant for autosuggest component)
  public func addInputType(_ inputType: W3WObjcInputType) {
    var it: W3WOption?
    
    switch inputType {
    case .genericVoice:
      it = W3WOption.inputType(.genericVoice)
    case .mihup:
      it = W3WOption.inputType(.mihup)
    case .nmdpAsr:
      it = W3WOption.inputType(.nmdpAsr)
    case .speechmatics:
      it = W3WOption.inputType(.speechmatics)
    case .text:
      it = W3WOption.inputType(.text)
    case .voconHybrid:
      it = W3WOption.inputType(.voconHybrid)
    }
    
    if let i = it {
      options.append(i)
    }
  }
}
