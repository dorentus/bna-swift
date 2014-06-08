//
//  Restorecode.swift
//  bna
//
//  Created by Rox Dorentus on 14-6-5.
//  Copyright (c) 2014年 rubyist.today. All rights reserved.
//

import Foundation

extension Authenticator {
    struct Restorecode {
        static let RESTORECODE_MAP: Dictionary = [
            0:  48,  1: 49,  2: 50,  3: 51,  4: 52,
            5:  53,  6: 54,  7: 55,  8: 56,  9: 57,
            10: 65, 11: 66, 12: 67, 13: 68, 14: 69,
            15: 70, 16: 71, 17: 72, 18: 74, 19: 75,
            20: 77, 21: 78, 22: 80, 23: 81, 24: 82,
            25: 84, 26: 85, 27: 86, 28: 87, 29: 88,
            30: 89, 31: 90, 32: 91
        ]
        static var RESTORECODE_MAP_INVERSE: Dictionary<Int, Int> {
            var dict = Dictionary<Int, Int>()
            for (key, value) in RESTORECODE_MAP {
                dict[value] = key
            }
            return dict
        }

        let text: String!
        var binary: String {
            let parts:Array<String> = text.bytes.map({ i in
                let c = Restorecode.RESTORECODE_MAP_INVERSE[Int(i)]!
                return NSString(format: "%c", c)
            })
            return parts.joinedBy("")
        }

        init(serial: Serial, secret: Secret) {
            let bytes = sha1_digest(serial.normalized.bytes + secret.binary)
            let s = countElements(bytes)-10
            let last_10_bytes = [] + bytes[s..s+10]
            let parts:Array<String> = last_10_bytes.map({ i in
                let c = Restorecode.RESTORECODE_MAP[Int(i & 0x1f)]!
                return NSString(format: "%c", c)
            })
            let restorecode = parts.joinedBy("")
            self.init(text: restorecode)
        }

        init(serial: String, secret: String) {
            self.init(serial: Serial(text: serial), secret: Secret(text: secret))
        }

        init(text: String) {
            var code = text
            if Restorecode.isValid(&code) {
                self.text = code
            }
        }

        func toString() -> String { return self.text }

        static func isValid(inout restorecode: String) -> Bool {
            let text = restorecode.uppercaseString
            if text.matches("[0-9A-Z]{10}") {
                restorecode = text
                return true
            }

            return false
        }
    }
}