//
//  Serial.swift
//  Authenticator
//
//  Created by Rox Dorentus on 14-6-5.
//  Copyright (c) 2014年 rubyist.today. All rights reserved.
//

import Foundation

class Serial {
    var normalized: String!
    var prettified: String {
        get {
            let suffix = normalized.substringFromIndex(2).scan(".{4}").joinedBy("-")
            return "\(region)\(suffix)"
        }
    }
    var region: String { get { return normalized.substringToIndex(2) } }

    init(_ text: String) {
        var serial = text
        if Serial.isValid(&serial) {
            self.normalized = serial
        }
    }

    func toString() -> String { return prettified }

    class func isValid(inout serial: String) -> Bool {
        let text = serial.uppercaseString.stringByReplacingOccurrencesOfString("-", withString: "")
        let valid_regions_pattern = Array(AuthenticatorConstants.AUTHENTICATOR_HOSTS.keys).joinedBy("|")

        if text.matches("\(valid_regions_pattern)\\d{12}") {
            serial = text
            return true
        }

        return false
    }
}