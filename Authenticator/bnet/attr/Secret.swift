//
//  Secret.swift
//  Authenticator
//
//  Created by Rox Dorentus on 14-6-5.
//  Copyright (c) 2014年 rubyist.today. All rights reserved.
//

import Foundation

class Secret: Printable {
    var text: String!
    var binary: UInt8[] { get { return hex2bin(text) } }
    var description: String { get { return text } }

    init(_ text: String) {
        var secret = text
        if Secret.isValid(&secret) {
            self.text = secret
        }
    }

    convenience init(_ binary: UInt8[]) {
        let secret = bin2hex(binary)
        self.init(secret)
    }

    class func isValid(inout secret: String) -> Bool {
        let text = secret.lowercaseString

        if text.matches("[0-9a-f]{40}") {
            secret = text
            return true
        }

        return false
    }
}