//
//  MapViewController.swift
//  W3wComponents
//
//  Created by Dave Duprey on 31/05/2020.
//  Copyright © 2020 Dave Duprey. All rights reserved.
//

import UIKit
import MapKit
import W3WSwiftApi



// MARK:- W3MapView


/// A UIView derivative that can display a W3W grid
open class MapView: MKMapView, MKMapViewDelegate, UIGestureRecognizerDelegate {

  /// the what3words API
  public var api: What3WordsV3?
  
  /// MapKit class that hold the graphical lines
  var polygons: MKMultiPolyline?
  
  /// closure to call with any errors
  var onError: (W3WError) -> () = { _ in }
  
  
  // MARK: Inits and confiuration
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    configure()
  }
  
  
  required public init?(coder: NSCoder) {
    super.init(coder: coder)
    configure()
  }
  
  
  public func set(api: What3WordsV3) {
    self.api = api
  }
  
  
  func configure() {
    delegate = self
  }
  
  
  // MARK:- Command Functions
  
  
  /// centre the map, and get the grid to draw the grid at that place
  public func set(center: CLLocationCoordinate2D, latitudeSpan: Double, longitudeSpan: Double) {
    DispatchQueue.main.async {
      let coordinateRegion = MKCoordinateRegion(center: center, latitudinalMeters: latitudeSpan * 1000.0, longitudinalMeters: longitudeSpan * 1000.0)
      self.setRegion(coordinateRegion, animated: false)
      self.getGridSection()
    }
  }
  
  
  /// centre the map using a three word address
  public func set(center: String, latitudeSpan: Double, longitudeSpan: Double) {
    // call the API
    api?.convertToCoordinates(words: center) { square, error in
      
      // show the address on the map
      if let s = square {
        self.addAnnotation(square: s)
      }
      
      // centre the map
      DispatchQueue.main.async {
        if let coordinates = square?.coordinates {
          self.set(center: coordinates, latitudeSpan: latitudeSpan, longitudeSpan: longitudeSpan)
        }
      }
      
      // deal with any error
      if let e = error {
        self.onError(e)
      }
    }
  }

  
  /// add a map annotation showing a three word address
  func addAnnotation(square: W3WSquare) {
    DispatchQueue.main.async {
      self.addAnnotation(MapAnnotation(square: square))
    }
  }
  
  
  // MARK: Grid Functions
  
  /// calls api.gridSection() and gets the lines for the grid, then calls presentNewGrid() to present the map on the view
  func getGridSection() {
    // ask for a grid twice the size of the currently showing map area
    let sw = CLLocationCoordinate2D(latitude: region.center.latitude - region.span.latitudeDelta * 2.0, longitude: region.center.longitude - region.span.longitudeDelta * 2.0)
    let ne = CLLocationCoordinate2D(latitude: region.center.latitude + region.span.latitudeDelta * 2.0, longitude: region.center.longitude + region.span.longitudeDelta * 2.0)
    
    // call w3w api for lines
    self.api?.gridSection(southWest:sw, northEast:ne) { lines, error in
      self.presentNewGrid(lines: lines)
      
      if let e = error {
        self.onError(e)
      }
    }
  }

  
  /// show the grid on the view
  func presentNewGrid(lines: [W3WLine]?) {
    DispatchQueue.main.async {
      // make the MKMultiPolyLine
      self.makePolygons(lines: lines)
      
      // replace the overlay with a new one with the new lines
      if let overlay = self.polygons {
        self.removeOverlays(self.overlays)
        self.addOverlay(overlay)
      }
    }
  }
  

  /// makes an MKMultiPolyline from the grid lines
  func makePolygons(lines: [W3WLine]?) {
    var multiLine = [MKPolyline]()
    
    for line in lines ?? [] {
      multiLine.append(MKPolyline(coordinates: [line.start, line.end], count: 2))
    }
    
    polygons = MKMultiPolyline(multiLine)
  }
  
  
  
  /// remove the grid overlay
  func removeGrid() {
    DispatchQueue.main.async {
      self.removeOverlays(self.overlays)
    }
  }
  
  
  // MARK: MapView overrides

  
  /// when the map view asks for one, give it a renderer that can draw the lines
  public func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
    
    if let multiPolyLine = overlay as? MKMultiPolyline {
      let renderer = MKMultiPolylineRenderer(multiPolyline: multiPolyLine)
      renderer.strokeColor = UIColor.gray
      renderer.lineWidth = 0.5
      return renderer
      
    } else {
      return MKOverlayRenderer()
    }
  }

}


// MARK:- Map Annotation


/// an annotation that understands W3WSquare
class MapAnnotation: MKPointAnnotation {
  
  var square: W3WSquare?
  
  init(square: W3WSquare) {
    super.init()
    
    title = square.words
    if let coordinates = square.coordinates {
      coordinate = coordinates
    }
    
    self.square = square
  }
  
}

