//
//  W3WSettings.swift
//  
//
//  Created by Dave Duprey on 29/09/2020.
//  Copyright © 2020 What3Words. All rights reserved.
//


public struct W3WSettings {
  
  /// URL for the what3words  API service
  static let apiUrl      = "https://api.what3words.com/v3"
  
  /// The version of this code
  static let apiVersion  = "3.9.6"
  
  /// what3words domains
  static var domains     = ["what3words.com", "w3w.io"]
  
  /// default language to use when none provided
  public static var defaultLanguage = "en"
  
  
  // MARK: Defaults
  
  
  /// debouncer delay for typing
  static var defaultDebounceDelay = 0.3
  
  
  // MARK: Constants
  
  /// There is a 4 kilometer limit for grid data
  public static var maxMetersDiagonalForGrid = 4000.0
  
  
  // MARK: Audio
  
  
  /// voice recordings max out at 4 seconds
  static let max_recording_length       = 4.0
  
  /// limit to prevent end of speech detection from triggering oo early
  static let min_voice_sample_length    = 2.5
  
  /// amount of time end of speech will wait for new utterances
  static let end_of_speech_quiet_time   = 0.75
  
  /// default sample rate for microphone
  static let defaultSampleRate          = Int32(44100)
  
  /// if no sound has happened, 0.25 is provided as a default upper amplitude limit
  static let defaulMaxAmplitude         = 0.25

  
  // MARK: Regex
  
  public static let regex_3wa_characters         = "^/*([^0-9`~!@#$%^&*()+\\-_=\\]\\[{\\}\\\\|'<,.>?/\";:£§º©®\\s]|[.｡。･・︒។։။۔።।]){0,}$"
  public static let regex_3wa_separator          = "[.｡。･・︒។։။۔።।]"
  public static let regex_3wa_mistaken_separator = "[.｡。･・︒។։။۔።। ,\\\\^_/+'&:;|　-]{1,2}"
  public static let regex_3wa_word               = "\\w+"
  public static let regex_exlusionary_word       = "[^0-9`~!@#$%^&*()+\\-_=\\]\\[{\\}\\\\|'<,.>?/\";:£§º©®\\s]{1,}"
  public static let regex_match                  = "^(?:/*\\w+[.｡。･・︒។։။۔።।]\\w+[.｡。･・︒។։။۔።।]\\w+|/*\\w+([\u{20}\u{A0}]\\w+){1,3}[.｡。･・︒។։။۔።।]\\w+([\u{20}\u{A0}]\\w+){1,3}[.｡。･・︒។։။۔።।]\\w+([\u{20}\u{A0}]\\w+){1,3})$"
  public static let regex_loose_match            = "^/*" + W3WSettings.regex_3wa_word + W3WSettings.regex_3wa_mistaken_separator + W3WSettings.regex_3wa_word + W3WSettings.regex_3wa_mistaken_separator + W3WSettings.regex_3wa_word + "$"
  public static let regex_search                 = W3WSettings.regex_3wa_word + W3WSettings.regex_3wa_separator + W3WSettings.regex_3wa_word + W3WSettings.regex_3wa_separator + W3WSettings.regex_3wa_word
  
}
