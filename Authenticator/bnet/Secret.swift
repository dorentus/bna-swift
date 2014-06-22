//
//  Secret.swift
//  Authenticator
//
//  Created by Rox Dorentus on 14-6-5.
//  Copyright (c) 2014年 rubyist.today. All rights reserved.
//

import Foundation

class Secret: Printable, Equatable {
    var text: String
    var binary: UInt8[] { return hex2bin(text) }
    var description: String { return text }

    init(_ text: String) {
        let secret = Secret.format(secret: text)
        if !secret {
            NSException.raise(NSInvalidArgumentException, format: "invalid secret", arguments: CVaListPointer(fromUnsafePointer: UnsafePointer()))
        }
        self.text = secret!
    }

    class func format(#secret: String) -> String? {
        let text = secret.lowercaseString

        if text.matches("[0-9a-f]{40}") {
            return text
        }

        return nil
    }
}

func ==(lhs: Secret, rhs: Secret) -> Bool {
    return lhs.text == rhs.text
}

extension Secret {
    class func withText(text: String) -> Secret? {
        if let secret = self.format(secret: text) {
            return Secret(secret)
        }

        return nil
    }

    class func withBinary(binary: UInt8[]) -> Secret? {
        let secret = bin2hex(binary)
        return withText(secret)
    }
}
