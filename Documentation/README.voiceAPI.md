# <img valign='top' src="https://what3words.com/assets/images/w3w_square_red.png" width="64" height="64" alt="what3words">&nbsp;Voice API


# Overview

The what3words Swift API wrapper converts a spoken 3 word address in audio to a list of three word address suggestions.

# Authentication

To use this library you’ll need a what3words API key, which can be signed up for [here](https://what3words.com/select-plan), and then you will have to add a Voice API plan in your [account](https://accounts.what3words.com/billing).

# Example

An iOS UIKit example using the VoiceAPI is provided in this package: [./Examples/VoiceAPI/VoiceAPI.xcodeproj](./Examples/VoiceAPI/VoiceAPI.xcodeproj)

# Installation

The Voice API wrapper is included in what3words' [Swift API Wrapper](https://github.com/what3words/w3w-swift-wrapper) code.  Installation instructions can be found in it's [README](README.md).

## Usage

### Import

In any swift file you use the what3words API, use the following :

```swift
import W3WSwiftApi
```

### Initialise

Initialize the W3W API class:

```swift
let api = What3WordsV3(apiKey: "YourApiKey")
```

##### Example
This example instantiates a `W3WMicrophone` which provides an audio stream to `autosuggest(audio:)` which begins recording when `autosuggest` is called.

```swift
// instantiate the API
let api = What3WordsV3(apiKey: "YourApiKey")

// make a microphone
let microphone = W3WMicrophone()

// call autosuggest
api.autosuggest(audio: microphone, language: "en") { suggestions, error in
  for suggestion in suggestions ?? [] {
    print(suggestion.words ?? "no suggestions")
  }
}
```


The `W3WMicrophone` class uses the device's microphone and provides an audio stream to `autosuggest(audio:)`.  The `autosuggest(audio:)` function is clever enough to call `microphone.start()` if it sees that a W3WMicrophone is passed in.

### Options

The same options are available as in the core API calls which are laid out in the [API documentation](https://developer.what3words.com/public-api/docs#autosuggest).

##### Example

Ask for results focused around particular coordinates:

```swift
// coords
let coords = CLLocationCoordinate2D(latitude: 51.4243877, longitude: -0.34745)

// make options
let options = W3WOptions().focus(coords)

// call autosuggest
api.autosuggest(audio: microphone, language: "en", options: options) { suggestions, error in
  for suggestion in suggestions ?? [] {
    print(suggestion.words ?? "no suggestions", suggestion.nearestPlace ?? "")
  }
}
```


#### Languages

You can call `availableVoiceLanguages(completion:)` to get a list of currently supported languages:

```Swift
api.availableVoiceLanguages() { languages, error in
  for language in languages ?? [] {
    print(language.code, language.name, language.nativeName)
  }
}

```

#### User Feedback

You may want to show microphone feedback graphically in your app. The W3WMicrophone class has a closure variable that is called intermittently providing audio amplitude information:

```Swift
public var volumeUpdate: (Double) -> ()
```

This is called with a value between 0 and 1 indicating relative volume.  For example you might have something like the following in your code:

```Swift
microphone?.volumeUpdate = { volume in 
  yourViewController.updateMicrophoneView(volume: volume)
}
```

### Bring your own audio data

To use an audio stream that is not captured by W3WMicrophone, perhaps something streaming in, or a bespoke device, use `W3WAudioStream` and pass it to `autosuggest(audio: W3WAudioStream)` instead.  Call `add(samples:)` while there is data to send and call `endSamples()` after the last data.

##### Example:

```Swift
// instantiate the API
let api = What3WordsV3(apiKey: "YourApiKey")

// make the audio stream
let audio = W3WAudioStream(sampleRate: 44100, encoding: .pcm_f32le)

// call autosuggest
api.autosuggest(audio: audio, language: "en") { suggestions, error in
  yourSoundObject.stop()
  for suggestion in suggestions ?? [] {
    print(suggestion.words ?? "no suggestions")
  }
}

// start sending audio data to autosuggest via the audio stream
while (yourSoundObject.isProducingAudio() {
	audio.add(samples: yourSoundObject.getNextSampleSet())
}
audio.endSamples()

```

### Alternatively...

The Voice API is implemented as an `extension` to the `What3WordsV3` class containing an additional `autosuggest(audio:)` function. This `autosuggest(audio:)` function calls the same function in the `W3WVoiceApi` class

This is done to allow the easy separation of the Voice API code from the main API functions, if for some reason that is wanted.

In the unlikely case you specifically want the voiceAPI without the main API functions as well, you can instantiate the `W3WVoiceApi` object separately:

```swift
let voiceApi = W3WVoiceApi(apiKey: "YourApiKey")
```

The two functions are the same: `autosuggest(audio:completion:)` and `availableVoiceLanguages(completion:)`.


