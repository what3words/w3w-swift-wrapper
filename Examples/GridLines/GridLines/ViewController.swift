//
//  ViewController.swift
//  GridLines
//
//  Created by Dave Duprey on 25/03/2021.
//

import UIKit
import MapKit
import W3WSwiftApi


class ViewController: UIViewController, MKMapViewDelegate, UIGestureRecognizerDelegate {

  // MARK: Variables
  
  /// The what3words API
  let api = What3WordsV3(apiKey: "YourApiKey")

  /// MapKit class that hold the graphical lines
  var polygons: MKMultiPolyline?


  /// Convenience wrapper to get view as MKMapView
  public var mapView: MKMapView {
    return self.view as! MKMapView
  }
  
  
  // MARK: Initialise

  
  /// assign the `MKMapView` to `view`
  public override func loadView() {
    view = MKMapView()
  }

  
  override func viewDidLoad() {
    super.viewDidLoad()
    mapView.delegate = self
    
    api.convertToCoordinates(words: "filled.count.soap") { square, error in
      self.showErrorIfAny(error: error)

      if let coordinates = square?.coordinates {
        DispatchQueue.main.async {
          self.mapView.setRegion(MKCoordinateRegion(center: coordinates, latitudinalMeters: 50.0, longitudinalMeters: 50.0), animated: false)
          self.mapView.addAnnotation(MapAnnotation(square: square))
          self.getGridSection()
        }
      }
    }
  }
  
  
  // MARK: Grid Functions
  
  
  /// calls api.gridSection() and gets the lines for the grid, then calls presentNewGrid() to present the map on the view
  /// IMPORTANT:
  /// typically you would call this in a mapViewDidChangeVisibleRegion(_ mapView:) call, but be sure to debounce or
  /// throttle the frequency api.gridSection is called.  mapViewDidChangeVisibleRegion can be called extremly rapidly
  /// as the user scrolls around the view.  typically we make sure it's called less than three times a second
  func getGridSection() {
    // ask for a grid twice the size of the currently showing map area
    let sw = CLLocationCoordinate2D(latitude: mapView.region.center.latitude - mapView.region.span.latitudeDelta * 1.5, longitude: mapView.region.center.longitude - mapView.region.span.longitudeDelta * 1.5)
    let ne = CLLocationCoordinate2D(latitude: mapView.region.center.latitude + mapView.region.span.latitudeDelta * 1.5, longitude: mapView.region.center.longitude + mapView.region.span.longitudeDelta * 1.5)
    
    // call w3w api for lines
    self.api.gridSection(southWest:sw, northEast:ne) { lines, error in
      self.showErrorIfAny(error: error)
      self.presentNewGrid(lines: lines)
    }
  }
  
  
  /// show the grid on the view
  func presentNewGrid(lines: [W3WLine]?) {
    DispatchQueue.main.async {
      // make the MKMultiPolyLine
      self.makePolygons(lines: lines)
      
      // replace the overlay with a new one with the new lines
      if let overlay = self.polygons {
        self.mapView.removeOverlays(self.mapView.overlays)
        self.mapView.addOverlay(overlay)
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
      self.mapView.removeOverlays(self.mapView.overlays)
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

  
  // MARK: Show an Error
  
  /// display an error using a UIAlertController, error messages conform to CustomStringConvertible
  func showErrorIfAny(error: Error?) {
    if let e = error {
      DispatchQueue.main.async {
        let alert = UIAlertController(title: "Error", message: String(describing: e), preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Dismiss", style: .cancel, handler: nil))
        self.present(alert, animated: true)
      }
    }
  }


}




// MARK:- Map Annotation


/// an annotation that understands W3WSquare
class MapAnnotation: MKPointAnnotation {
  
  var square: W3WSquare?
  
  init(square: W3WSquare?) {
    super.init()
    
    if let s = square {
      title = s.words
      if let coordinates = s.coordinates {
        coordinate = coordinates
      }
    }
    
    self.square = square
  }
  
}

