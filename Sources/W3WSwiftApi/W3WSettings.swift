//
//  W3WSettings.swift
//  
//
//  Created by Dave Duprey on 29/09/2020.
//  Copyright © 2020 What3Words. All rights reserved.
//


public struct W3WSettings {
  
  static let apiUrl      = "https://api.what3words.com/v3"
  static let apiVersion  = "3.6.7"
  
  static var domains     = ["what3words.com", "w3w.io"]
  
  public static var defaultLanguage = "en"
  
  // regex
  public static let regex_3wa_characters         = "^/*([^0-9`~!@#$%^&*()+\\-_=\\]\\[{\\}\\\\|'<,.>?/\";:£§º©®\\s]|[.｡。･・︒។։။۔።।]){0,}$"
  public static let regex_3wa_separator          = "[.｡。･・︒។։။۔።।]"
  public static let regex_3wa_mistaken_separator = "[.｡。･・︒។։။۔።। ,\\-_/+'&\\:;|]{1,2}"
  public static let regex_3wa_word               = "\\w+"
  public static let regex_match                  = "^/*" + W3WSettings.regex_3wa_word + W3WSettings.regex_3wa_separator + W3WSettings.regex_3wa_word + W3WSettings.regex_3wa_separator + W3WSettings.regex_3wa_word + "$"
  public static let regex_loose_match            = "^/*" + W3WSettings.regex_3wa_word + W3WSettings.regex_3wa_mistaken_separator + W3WSettings.regex_3wa_word + W3WSettings.regex_3wa_mistaken_separator + W3WSettings.regex_3wa_word + "$"

}
