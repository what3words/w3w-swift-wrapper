//
//  File.swift
//  
//
//  Created by Dave Duprey on 07/11/2022.
//

import W3WSwiftCore


public extension W3WError {
    
    static func url(code: Int? = nil, message: String? = nil) -> W3WError {
        if let c = code {
            return .code(c, message ?? "")
        } else if let m = message {
            return .message(m)
        } else {
            return .unknown
        }
    }
    
    // MARK: Voice API error convenience
    
    static func voiceSocketError(code: Int? = nil, error: W3WError) -> W3WError {
        return W3WError.code(code ?? -1, error.description)
    }
}
  
