//
//  Extensions.swift
//  bna
//
//  Created by Rox Dorentus on 14-6-6.
//  Copyright (c) 2014年 rubyist.today. All rights reserved.
//

import Foundation

extension Array {
    func joinedBy(joiner: String) -> String! {
        return self.reduce(nil) { (m: String?, v: Element) in m? ? "\(m)\(joiner)\(v)" : "\(v)" }
    }
}

extension String {
    var length: Int { return countElements(self) }
    var bytes: UInt8[] { return Array(self.utf8) }

    func matches(pattern: String) -> Bool {
        let regex = NSRegularExpression.regularExpressionWithPattern(pattern, options: .DotMatchesLineSeparators, error: nil)
        return regex.numberOfMatchesInString(self, options: nil, range: NSMakeRange(0, self.length)) > 0
    }

    func scan(pattern: String) -> String[] {
        let regex = NSRegularExpression.regularExpressionWithPattern(pattern, options: .DotMatchesLineSeparators, error: nil)
        let matches = regex.matchesInString(self, options: nil, range: NSMakeRange(0, self.length))

        return matches.map({ (m: AnyObject) -> String in
            (self as NSString).substringWithRange((m as NSTextCheckingResult).rangeAtIndex(0))
        })
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

func hmac_sha1_hexdigest(input: UInt8[], key: UInt8[]) -> String {
    let input_data = NSData(bytes: input, length: countElements(input))
    let key_data = NSData(bytes: key, length: countElements(key))
    return input_data.HMACSHA1HexDigestWithKey(key_data)
}

func hmac_sha1_hexdigest(input: String, key: String) -> String {
    return hmac_sha1_hexdigest(input.bytes, key.bytes)
}

func hmac_sha1_digest(input: UInt8[], key: UInt8[]) -> UInt8[] {
    return hex2bin(hmac_sha1_hexdigest(input, key))
}

func hmac_sha1_digest(input: String, key: String) -> UInt8[] {
    return hmac_sha1_digest(input.bytes, key.bytes)
}
