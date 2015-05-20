//
//  Restorecode.swift
//  Authenticator
//
//  Created by Rox Dorentus on 14-6-5.
//  Copyright (c) 2014年 rubyist.today. All rights reserved.
//

import Foundation

struct Restorecode: Printable, Equatable {
    static let RESTORECODE_MAP: [UInt8: UInt8] = [
        0:  48,  1: 49,  2: 50,  3: 51,  4: 52,
        5:  53,  6: 54,  7: 55,  8: 56,  9: 57,
        10: 65, 11: 66, 12: 67, 13: 68, 14: 69,
        15: 70, 16: 71, 17: 72, 18: 74, 19: 75,
        20: 77, 21: 78, 22: 80, 23: 81, 24: 82,
        25: 84, 26: 85, 27: 86, 28: 87, 29: 88,
        30: 89, 31: 90, 32: 91
    ]
    static let RESTORECODE_MAP_INVERSE: [UInt8: UInt8] = {
        var dict: [UInt8: UInt8] = [:]
        for (key, value) in RESTORECODE_MAP {
            dict[value] = key
        }
        return dict
    }()

    let text: String
    var binary: [UInt8] {
        return text.bytes.map { i in Restorecode.RESTORECODE_MAP_INVERSE[i]! }
    }
    var description: String { return text }

    init?(text: String) {
        if let code = Restorecode.format(restorecode: text) {
            self.text = code
        }
        else {
            return nil
        }
    }

    init?(serial: Serial, secret: Secret) {
        let bytes = sha1_digest(serial.binary + secret.binary)
        let s = count(bytes) - 10
        let last_10_bytes = [] + bytes[s ..< s+10]
        let parts = last_10_bytes.map { i -> String in
            let c = Restorecode.RESTORECODE_MAP[i & 0x1f]!
            return String(format: "%c", c)
        }
        self.init(text: "".join(parts))
    }

    init?(serial: String, secret: String) {
        if let serial = Serial(text: serial), secret = Secret(text: secret) {
            self.init(serial: serial, secret: secret)
        }
        else {
            return nil
        }
    }

    static func format(#restorecode: String) -> String? {
        let text = restorecode.uppercaseString
        if text.matches("[0-9A-Z]{10}") {
            return text
        }

        return nil
    }
}

func ==(lhs: Restorecode, rhs: Restorecode) -> Bool {
    return lhs.text == rhs.text
}
