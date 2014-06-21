//
//  Restorecode.swift
//  Authenticator
//
//  Created by Rox Dorentus on 14-6-5.
//  Copyright (c) 2014年 rubyist.today. All rights reserved.
//

import Foundation

class Restorecode: Printable, Equatable {
    struct Constants {
        static let RESTORECODE_MAP: Dictionary<UInt8, UInt8> = [
            0:  48,  1: 49,  2: 50,  3: 51,  4: 52,
            5:  53,  6: 54,  7: 55,  8: 56,  9: 57,
            10: 65, 11: 66, 12: 67, 13: 68, 14: 69,
            15: 70, 16: 71, 17: 72, 18: 74, 19: 75,
            20: 77, 21: 78, 22: 80, 23: 81, 24: 82,
            25: 84, 26: 85, 27: 86, 28: 87, 29: 88,
            30: 89, 31: 90, 32: 91
        ]
        static let RESTORECODE_MAP_INVERSE: Dictionary<UInt8, UInt8> = {
            var dict = Dictionary<UInt8, UInt8>()
            for (key, value) in RESTORECODE_MAP {
                dict[value] = key
            }
            return dict
        }()
    }

    let text: String!
    var binary: UInt8[] {
        return text.bytes.map { i in Constants.RESTORECODE_MAP_INVERSE[i]! }
    }
    var description: String { return text }

    init(_ text: String) {
        var code = text
        if Restorecode.isValid(&code) {
            self.text = code
        }
    }

    convenience init(_ serial: Serial, _ secret: Secret) {
        let bytes = sha1_digest(serial.binary + secret.binary)
        let s = countElements(bytes)-10
        let last_10_bytes = [] + bytes[s..s+10]
        let parts:Array<String> = last_10_bytes.map({ i in
            let c = Constants.RESTORECODE_MAP[UInt8(i & 0x1f)]!
            return NSString(format: "%c", c)
        })
        self.init(parts.joinedBy(""))
    }

    convenience init(_ serial: String, _ secret: String) {
        self.init(Serial(serial), Secret(secret))
    }

    class func isValid(inout restorecode: String) -> Bool {
        let text = restorecode.uppercaseString
        if text.matches("[0-9A-Z]{10}") {
            restorecode = text
            return true
        }

        return false
    }
}

func ==(lhs: Restorecode, rhs: Restorecode) -> Bool {
    return lhs.text == rhs.text
}
