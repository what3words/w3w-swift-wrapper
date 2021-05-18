# <img valign='top' src="https://what3words.com/assets/images/w3w_square_red.png" width="64" height="64" alt="what3words">&nbsp;w3w-swift-wrapper tutorial


Overview
--------

This is a tutorial for using what3words Swift API wrapper.

#### Authentication
To use this library you’ll need a what3words API key, which can be signed up for [here](https://what3words.com/select-plan).  If you wish to use the Voice API calls then you must add a Voice API plan to your [account](https://accounts.what3words.com/billing).


#### Install Components

Add the Swift Package at [https://github.com/what3words/w3w-swift-wrapper](https://github.com/what3words/w3w-swift-wrapper) to your project:

```
https://github.com/what3words/w3w-swift-wrapper.git
```


1. From Xcode's `File` menu choose `Swift Packages` then `Add Package Dependancy`.  
2. The `Choose Package Repository` window appears.  Add `https://github.com/what3words/w3w-swift-wrapper.git` in the search box, and click on `Next`. 
3. If you are satisfied with the selected version branch choices, click `Next` again.
4. You should then be shown "Package Product" `W3WSwiftWrapper`.  Choose `Finish`.

Xcode should now automatically install `w3w-swift-wrapper`

#### Write Code

In your ViewController add the following import statements to the top of the file:

```Swift
import W3WSwiftApi
import CoreLocation
```


Add the following to `viewDidLoad()` and **be sure to use you API key**:

```Swift
override func viewDidLoad() {
  super.viewDidLoad()

  // instantiate the API
  let api = What3WordsV3(apiKey: "YourApiKey")

  // get a three word address from lat,long coordinates
  let coords = CLLocationCoordinate2D(latitude: 51.4243877, longitude: -0.34745)
  api.convertTo3wa(coordinates: coords, language: "en") { square, error in
    if let e = error {
        print(e) // print an error if one happens (did you use your API key?)
      }
    
    if let words = square?.words {
      print("The address for \(coords.latitude),\(coords.longitude) is \(words)")
    }
  }
    
  // get lat,long coordinates from a three word address
  api.convertToCoordinates(words: "filled.count.soap") { square, error in
    if let coords = square?.coordinates {
      print("The coordinates for filled.count.soap is \(coords.latitude),\(coords.longitude)")
    }
  }
    
  // get a list of suggestions for a partial three word address
  api.autosuggest(text: "filled.count.soa", options: W3WOption.focus(coords)) { (suggestions, error) in
    print("Found:")
    for suggestion in suggestions ?? [] {
      print(" - ", suggestion.words ?? "")
    }
  }
  
}
```

#### Run The App

You should see the following output in your console:

```
The address for 51.4243877,-0.34745 is fled.this.that)
The coordinates for filled.count.soap is 51.520847,-0.195521
Found:
 -  filled.count.soap
 -  filled.count.loss
 -  will.count.soak
```

