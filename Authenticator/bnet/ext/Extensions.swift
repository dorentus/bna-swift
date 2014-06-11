//
//  Extensions.swift
//  Authenticator
//
//  Created by Rox Dorentus on 14-6-6.
//  Copyright (c) 2014年 rubyist.today. All rights reserved.
//

import Foundation

extension Array {
    func joinedBy(joiner: String) -> String! {
        return self.reduce(nil) { (m: String?, v: Element) in
            if let s = m {
                return "\(s)\(joiner)\(v)"
            } else {
                return "\(v)"
            }
        }
    }
}

extension String {
    var length: Int { get { return countElements(self) } }
    var bytes: UInt8[] { get { return Array(self.utf8) } }

    func matches(pattern: String) -> Bool {
        let regex = NSRegularExpression.regularExpressionWithPattern(pattern, options: .DotMatchesLineSeparators, error: nil)
        return regex.numberOfMatchesInString(self, options: nil, range: NSMakeRange(0, self.length)) > 0
    }

    func scan(pattern: String) -> String[] {
        let regex = NSRegularExpression.regularExpressionWithPattern(pattern, options: .DotMatchesLineSeparators, error: nil)
        let matches = regex.matchesInString(self, options: nil, range: NSMakeRange(0, self.length))

        return matches.map { m in
            (self as NSString).substringWithRange((m as NSTextCheckingResult).rangeAtIndex(0))
        }
    }
}

func hex2bin(hex: String) -> UInt8[] {
    var str = hex
    if hex.length % 2 != 0 {
        str = "0" + hex
    }

    return str.scan(".{2}").map({ s in
        UInt8(strtol((s as NSString).UTF8String, nil, 16))
    })
}

func bin2hex(bin: UInt8[]) -> String {
    return bin.map({ c in NSString(format: "%02x", c) }).joinedBy("")
}

func sha1_hexdigest(bin: UInt8[]) -> String {
    let data = NSData(bytes: bin, length: countElements(bin))
    return data.SHA1HexDigest()
}

func sha1_digest(bin: UInt8[]) -> UInt8[] {
    return hex2bin(sha1_hexdigest(bin))
}

func hmac_sha1_hexdigest<T>(input: T, key: T) -> String {
    var input_bytes: UInt8[]
    var key_bytes: UInt8[]

    if let bytes = input as? UInt8[] {
        input_bytes = bytes
    } else {
        input_bytes = "\(input)".bytes
    }

    if let bytes = key as? UInt8[] {
        key_bytes = bytes
    } else {
        key_bytes = "\(key)".bytes
    }

    let input_data = NSData(bytes: input_bytes, length: countElements(input_bytes))
    let key_data = NSData(bytes: key_bytes, length: countElements(key_bytes))

    return input_data.HMACSHA1HexDigestWithKey(key_data)
}

func hmac_sha1_digest<T>(input: T, key: T) -> UInt8[] {
    return hex2bin(hmac_sha1_hexdigest(input, key))
}
