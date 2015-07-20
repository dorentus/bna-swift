//
//  Serial.swift
//  Authenticator
//
//  Created by Rox Dorentus on 14-6-5.
//  Copyright (c) 2014年 rubyist.today. All rights reserved.
//

import Foundation

public struct Serial {
    public let region: Region
    
}

extension Serial: StringLiteralConvertible {

}

//public struct Serial: CustomStringConvertible, Equatable {
//    public let normalized: String
//    public var binary: [UInt8] { return normalized.bytes }
//
//    public var prettified: String {
//        let suffix = "-".join((normalized as NSString).substringFromIndex(2).scan(".{4}"))
//        return "\(region.rawValue)\(suffix)"
//    }
//    public var region: Region {
//        return Region(rawValue: (normalized as NSString).substringToIndex(2))!
//    }
//    public var description: String { return prettified }
//
//    public init?(text: String) {
//        if let serial = Serial.format(serial: text) {
//            self.normalized = serial
//        }
//        else {
//            return nil
//        }
//    }
//
//    public init?(binary: [UInt8]) {
//        if let text = String(bytes: binary, encoding: NSASCIIStringEncoding) {
//            self.init(text: text)
//        }
//        else {
//            return nil
//        }
//    }
//
//    public static func format(serial serial: String) -> String? {
//        let text = serial.uppercaseString.stringByReplacingOccurrencesOfString("-", withString: "")
//        if Region(rawValue: (text as NSString).substringToIndex(2)) != nil && text.matches("^[A-Z]{2}\\d{12}$") {
//            return text
//        }
//
//        return nil
//    }
//}
//
//public func ==(lhs: Serial, rhs: Serial) -> Bool {
//    return lhs.normalized == rhs.normalized
//}
