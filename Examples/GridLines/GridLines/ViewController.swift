//
//  ViewController.swift
//  GridLines
//
//  Created by Dave Duprey on 25/03/2021.
//

import UIKit
import W3WSwiftApi


class ViewController: UIViewController {

  let api = What3WordsV3(apiKey: "YourApiKey")
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    let map = MapView(frame: view.frame)
    map.set(api: api)
    map.set(center: "filled.count.soap", latitudeSpan: 0.05, longitudeSpan: 0.05)
    
    map.onError = { error in
      self.showError(error: error)
    }
    
    self.view = map
  }
  
  
  // MARK: Show an Error
  
  /// display an error using a UIAlertController, error messages conform to CustomStringConvertible
  func showError(error: Error) {
    DispatchQueue.main.async {
      let alert = UIAlertController(title: "Error", message: String(describing: error), preferredStyle: .alert)
      alert.addAction(UIAlertAction(title: "Dismiss", style: .cancel, handler: nil))
      self.present(alert, animated: true)
    }
  }


}

