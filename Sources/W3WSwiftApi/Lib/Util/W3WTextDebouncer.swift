//
//  File.swift
//  
//
//  Created by Dave Duprey on 06/07/2020.
//

import Foundation


/// calls a closure with a `String` no faster than a certain frequency
public class W3WTextDebouncer {
  
  /// the minimum time between calls
  private let delay: TimeInterval
  
  /// to keep track of how long elapsed since the last call
  private var timer: Timer?
  
  /// the closure to call
  var handler: (String) -> Void
  
  
  /// initialize
  /// - parameters
  ///   - delay: the minimum time between calls
  ///   - handler: the closure to call
  public init(delay: TimeInterval, handler: @escaping (String) -> Void) {
    self.delay = delay
    self.handler = handler
  }
  
  
  /// to indicate a call should be made
  public func call(text: String) {
    if #available(iOS 10.0, watchOS 3.0, *) {
    timer?.invalidate()
    timer = Timer.scheduledTimer(withTimeInterval: delay, repeats: false, block: { [weak self] _ in  self?.handler(text)})
    } else {
    timer?.invalidate()
    timer = Timer.scheduledTimer(timeInterval: delay, target: self, selector: #selector(callTheBlock), userInfo: nil, repeats: false)
    }
  }

  
  /// This is for iOS 9 and earlier compatibility
  @objc
  func callTheBlock(text: String) {
    self.handler(text)
  }

  /// stop the timer
  func invalidate() {
    timer?.invalidate()
    timer = nil
  }
}
