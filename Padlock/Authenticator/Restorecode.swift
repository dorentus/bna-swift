//
//  Restorecode.swift
//  Authenticator
//
//  Created by Rox Dorentus on 14-6-5.
//  Copyright (c) 2014年 rubyist.today. All rights reserved.
//

import Foundation

class Restorecode: Printable, Equatable {
    let text: String!
    var binary: UInt8[] {
        return text.bytes.map { i in RESTORECODE_MAP_INVERSE[i]! }
    }
    var description: String { return text }

    init(_ text: String) {
        let code = Restorecode.format(restorecode: text)
        if !code {
            NSException.raise(NSInvalidArgumentException, format: "invalid restorecode", arguments: CVaListPointer(fromUnsafePointer: UnsafePointer()))
        }
        self.text = code!
    }

    convenience init(_ serial: Serial, _ secret: Secret) {
        let bytes = sha1_digest(serial.binary + secret.binary)
        let s = countElements(bytes)-10
        let last_10_bytes = [] + bytes[s..s+10]
        let parts:Array<String> = last_10_bytes.map({ i in
            let c = RESTORECODE_MAP[UInt8(i & 0x1f)]!
            return NSString(format: "%c", c)
            })
        self.init(parts.joinedBy(""))
    }

    class func format(#restorecode: String) -> String? {
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

extension Restorecode {
    class func withText(text: String) -> Restorecode? {
        if let code = self.format(restorecode: text) {
            return Restorecode(code)
        }

        return nil
    }

    class func withSerial(serial: String, secret: String) -> Restorecode? {
        let sr = Serial.withText(serial)
        let sc = Secret.withText(secret)

        if !sr || !sc {
            return nil
        }

        return Restorecode(sr!, sc!)
    }
}
