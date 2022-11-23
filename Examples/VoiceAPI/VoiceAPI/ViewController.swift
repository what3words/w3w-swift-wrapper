//
//  ViewController.swift
//  VoiceAPI
//
//  Created by Dave Duprey on 04/11/2020.
//

import UIKit
import W3WSwiftApi


class ViewController: UIViewController {

  // instantiate the API on launch: place your API key here
  // get your API key at: https://what3words.com/select-plan
  // upgrade your API key to voice here: https://accounts.what3words.com/billing
  var api = What3WordsV3(apiKey: "YourApiKey")

  // a button to talk and a text label for displaying results
  @IBOutlet weak var microphoneButton: UIButton!
  @IBOutlet weak var textLabel: UILabel!
  
  
  // called when the button is pressed
  @IBAction func microphoneButtonPressed(_ sender: Any) {
    microphoneButton.isEnabled = false

    // update the button and text to encourage the user
    textLabel.text = "Say a three word address"
    microphoneButton.setImage(UIImage(named: "white.fill.480"), for: .normal)

    // make a microphone object
    let microphone = W3WMicrophone()

    print("Starting recording")
    api.autosuggest(audio: microphone, language: "en") { suggestions, error in

      print("Finished recording")
      DispatchQueue.main.async {
        self.microphoneButton.setImage(UIImage(named: "white.480"), for: .normal)
        self.microphoneButton.transform = CGAffineTransform.init(scaleX: 0.8, y: 0.8)
        self.microphoneButton.isEnabled = true
      }

      // check for error, and display results
      if let e = error {
        self.show(error: String(describing: e))
      } else {
        self.show(suggestions: suggestions ?? [])
      }
    }
    
    // ask the microphone for amplitude updates and use them to scale the mic
    // for rudimentary user feedback while they talk
    microphone.volumeUpdate = { volume in
      DispatchQueue.main.async {
        self.microphoneButton.transform = CGAffineTransform.init(scaleX: 0.8 + volume * 0.2, y: 0.8 + volume * 0.2)
      }
    }
    
  }
  
  // display suggestion results in the text label
  func show(suggestions: [W3WSuggestion]) {
    var text = ""
    for suggestion in suggestions {
      text += (suggestion.words ?? "") + "\n"
    }
    
    DispatchQueue.main.async {
      self.textLabel.text = text
    }
  }
  
  
  // display any error in the text label
  func show(error: String) {
    DispatchQueue.main.async {
      self.textLabel.text = error
    }
  }
  
}

