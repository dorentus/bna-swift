//
//  Secret.swift
//  Authenticator
//
//  Created by Rox Dorentus on 14-6-5.
//  Copyright (c) 2014年 rubyist.today. All rights reserved.
//

import Foundation

struct Secret: Printable, Equatable {
    let text: String
    var binary: [UInt8] { return hex2bin(text) }
    var description: String { return text }

    init?(text: String) {
        if let secret = Secret.format(secret: text) {
            self.text = secret
        }
        else {
            return nil
        }
    }

    init?(binary: [UInt8]) {
        self.init(text: bin2hex(binary))
    }

    static func format(#secret: String) -> String? {
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
