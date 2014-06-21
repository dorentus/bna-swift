//
//  Serial.swift
//  Authenticator
//
//  Created by Rox Dorentus on 14-6-5.
//  Copyright (c) 2014年 rubyist.today. All rights reserved.
//

import Foundation

class Serial: Printable, Equatable {
    var normalized: String!
    var binary: UInt8[] { return normalized.bytes }
    var prettified: String {
        let suffix = normalized.substringFromIndex(2).scan(".{4}").joinedBy("-")
        return "\(stringify_region(region))\(suffix)"
    }
    var region: Authenticator.Region { return extract_region(normalized.substringToIndex(2))! }
    var description: String { return prettified }

    init(_ text: String) {
        var serial = text
        if Serial.isValid(&serial) {
            self.normalized = serial
        }
    }

    convenience init(_ binary: UInt8[]) {
        let serial = NSString(bytes: binary, length: countElements(binary), encoding: NSASCIIStringEncoding)
        self.init(serial)
    }

    class func isValid(inout serial: String) -> Bool {
        let text = serial.uppercaseString.stringByReplacingOccurrencesOfString("-", withString: "")

        if extract_region(text.substringToIndex(2)) && text.matches("^[A-Z]{2}\\d{12}$") {
            serial = text
            return true
        }

        return false
    }
}

func ==(lhs: Serial, rhs: Serial) -> Bool {
    return lhs.normalized == rhs.normalized
}
