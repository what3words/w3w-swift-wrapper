////
////  File.swift
////  
////
////  Created by Dave Duprey on 07/11/2022.
////
//
//import Foundation
//
//
//public enum W3WWebSocketError : Error, CustomStringConvertible {
//  case memory
//  case needMoreInput
//  case invalidHeader
//  case invalidAddress
//  case final
//  case network(String)
//  case libraryError(String)
//  case payloadError(String)
//  case protocolError(String)
//  case invalidResponse(String)
//  case invalidCompressionOptions(String)
//  public var description : String {
//    switch self {
//    case .memory: return "Memory"
//    case .needMoreInput: return "NeedMoreInput"
//    case .invalidAddress: return "InvalidAddress"
//    case .invalidHeader: return "InvalidHeader"
//    case .final: return "FinalError"
//    case let .invalidResponse(details): return "InvalidResponse(\(details))"
//    case let .invalidCompressionOptions(details): return "InvalidCompressionOptions(\(details))"
//    case let .libraryError(details): return "LibraryError(\(details))"
//    case let .protocolError(details): return "ProtocolError(\(details))"
//    case let .payloadError(details): return "PayloadError(\(details))"
//    case let .network(details): return "Network(\(details))"
//    }
//  }
//  public var details : String {
//    switch self {
//    case .invalidResponse(let details): return details
//    case .invalidCompressionOptions(let details): return details
//    case .libraryError(let details): return details
//    case .protocolError(let details): return details
//    case .payloadError(let details): return details
//    case .network(let details): return details
//    default: return ""
//    }
//  }
//}
