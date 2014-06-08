//
//  Secret.swift
//  bna
//
//  Created by Rox Dorentus on 14-6-5.
//  Copyright (c) 2014年 rubyist.today. All rights reserved.
//

import Foundation

extension Authenticator {
    struct Secret {
        var text: String!
        var binary: UInt8[] { return hex2bin(text) }

        init(text: String) {
            var secret = text
            if Secret.isValid(&secret) {
                self.text = secret
            }
        }

        init(binary: UInt8[]) {
            var secret = bin2hex(binary)
            self.init(text: secret)
        }

        func toString() -> String { return text }

        static func isValid(inout secret: String) -> Bool {
            let text = secret.lowercaseString

            if text.matches("[0-9a-f]{40}") {
                secret = text
                return true
            }

            return false
        }
    }
}