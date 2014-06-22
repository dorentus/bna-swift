//
//  Serial.swift
//  Authenticator
//
//  Created by Rox Dorentus on 14-6-5.
//  Copyright (c) 2014年 rubyist.today. All rights reserved.
//

import Foundation

class Serial: Printable, Equatable {
    var normalized: String
    var binary: UInt8[] { return normalized.bytes }
    var prettified: String {
        let suffix = normalized.substringFromIndex(2).scan(".{4}").joinedBy("-")
        return "\(region.toRaw())\(suffix)"
    }
    var region: Region { return Region.fromRaw(normalized.substringToIndex(2))! }
    var description: String { return prettified }

    init(_ text: String) {
        let serial = Serial.format(serial: text)
        if !serial {
            NSException.raise(NSInvalidArgumentException, format: "invalid serial", arguments: CVaListPointer(fromUnsafePointer: UnsafePointer()))
        }
        self.normalized = serial!
    }

    class func format(#serial: String) -> String? {
        let text = serial.uppercaseString.stringByReplacingOccurrencesOfString("-", withString: "")
        if Region.fromRaw(text.substringToIndex(2)) && text.matches("^[A-Z]{2}\\d{12}$") {
            return text
        }

        return nil
    }
}

func ==(lhs: Serial, rhs: Serial) -> Bool {
    return lhs.normalized == rhs.normalized
}

extension Serial {
    class func withText(text: String) -> Serial? {
        if let serial = self.format(serial: text) {
            return Serial(serial)
        }

        return nil
    }

    class func withBinary(binary: UInt8[]) -> Serial? {
        let serial = NSString(bytes: binary, length: countElements(binary), encoding: NSASCIIStringEncoding)
        return withText(serial)
    }
}
