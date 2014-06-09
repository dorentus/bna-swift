//
//  Serial.swift
//  bna
//
//  Created by Rox Dorentus on 14-6-5.
//  Copyright (c) 2014年 rubyist.today. All rights reserved.
//

import Foundation

extension Authenticator {
    struct Serial {
        static let VALID_REGIONS_REGEX = Array(AUTHENTICATOR_HOSTS.keys).joinedBy("|")

        var normalized: String!
        var prettified: String {
            let suffix = normalized.substringFromIndex(2).scan(".{4}").joinedBy("-")
            return "\(region)\(suffix)"
        }
        var region: String { return normalized.substringToIndex(2) }

        init(_ text: String) {
            var serial = text
            if Serial.isValid(&serial) {
                self.normalized = serial
            }
        }

        func toString() -> String { return prettified }

        static func isValid(inout serial: String) -> Bool {
            let text = serial.uppercaseString.stringByReplacingOccurrencesOfString("-", withString: "")

            if text.matches("\(VALID_REGIONS_REGEX)\\d{12}") {
                serial = text
                return true
            }

            return false
        }
    }
}