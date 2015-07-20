//
//  Secret.swift
//  Authenticator
//
//  Created by Rox Dorentus on 14-6-5.
//  Copyright (c) 2014年 rubyist.today. All rights reserved.
//

import Foundation

public struct Secret: CustomStringConvertible, Equatable {
    public let text: String
    public var binary: [UInt8] { return hex2bin(text) }
    public var description: String { return text }

    public init?(text: String) {
        if let secret = Secret.format(secret: text) {
            self.text = secret
        }
        else {
            return nil
        }
    }

    public init?(binary: [UInt8]) {
        self.init(text: bin2hex(binary))
    }

    public static func format(secret secret: String) -> String? {
        let text = secret.lowercaseString
        if text.matches("[0-9a-f]{40}") {
            return text
        }

        return nil
    }
}

public func ==(lhs: Secret, rhs: Secret) -> Bool {
    return lhs.text == rhs.text
}
