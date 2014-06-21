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
    var length: Int { return countElements(self) }
    var bytes: UInt8[] { return Array(self.utf8) }

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

    func leftFixedString(#length: Int, pad: Character) -> String {
        if self.length <= length {
            let diff = length - self.length
            var suffix = ""
            for i in 0 .. diff {
                suffix += pad
            }
            return self + suffix
        }
        else {
            return self.substringToIndex(length)
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

func sha1_hexdigest(input: String) -> String {
    return sha1_hexdigest(input.bytes)
}

func sha1_hexdigest(input_bytes: UInt8[]) -> String {
    let data = NSData(bytes: input_bytes, length: countElements(input_bytes))
    return data.SHA1HexDigest()
}

func sha1_digest(input: String) -> UInt8[] {
    return hex2bin(sha1_hexdigest(input))
}

func sha1_digest(input: UInt8[]) -> UInt8[] {
    return hex2bin(sha1_hexdigest(input))
}

func hmac_sha1_hexdigest(input_bytes: UInt8[], key_bytes: UInt8[]) -> String {
    let input_data = NSData(bytes: input_bytes, length: countElements(input_bytes))
    let key_data = NSData(bytes: key_bytes, length: countElements(key_bytes))

    return input_data.HMACSHA1HexDigestWithKey(key_data)
}

func hmac_sha1_hexdigest(input: String, key: String) -> String {
    return hmac_sha1_hexdigest(input.bytes, key.bytes)
}

func hmac_sha1_digest(input: UInt8[], key: UInt8[]) -> UInt8[] {
    return hex2bin(hmac_sha1_hexdigest(input, key))
}

func hmac_sha1_digest(input: String, key: String) -> UInt8[] {
    return hex2bin(hmac_sha1_hexdigest(input, key))
}

func http_request(#region: String, #path: String, #body: Array<UInt8>?, completion: ((Array<UInt8>!, NSError?) -> Void)) {
    let host = AuthenticatorConstants.AUTHENTICATOR_HOSTS[region]
    let url = NSURL(string: "http://\(host)\(path)")
    let request = NSMutableURLRequest(URL: url)
    request.setValue("application/octet-stream", forHTTPHeaderField: "Content-Type")
    if let body = body {
        request.HTTPMethod = "POST"
        request.HTTPBody = NSData(bytes: body, length: countElements(body))
    }

    NSURLConnection.sendAsynchronousRequest(request, queue: NSOperationQueue.currentQueue()) {
        (response, data, error) in
        if let error = error {
            completion(nil, error)
        }
        else {
            let ptr = UnsafePointer<UInt8>(data!.bytes)
            let bytes = Array<UInt8>(UnsafeArray<UInt8>(start:ptr, length:data!.length))
            completion(bytes, nil)
        }
    }
}

func get_otp(length: Int) -> String {
    var result: String = ""
    while true {
        if result.length >= length {
            break
        }
        result += sha1_hexdigest(String(arc4random()))
    }
    return result.substringToIndex(length)
}

func decrypt_response(input: UInt8[], key: UInt8[]) -> UInt8[] {
    let length = countElements(input)

    assert(length == countElements(key))

    var result: UInt8[] = []
    for index in (0 .. length) {
        result.append(input[index] ^ key[index])
    }

    return result
}

func rsa_encrypt(input: UInt8[]) -> UInt8[] {
    let input_hex = bin2hex(input)
    let result_hex = mod_exp_hex(input_hex, AuthenticatorConstants.RSA_KEY, AuthenticatorConstants.RSA_MOD)
    return hex2bin(result_hex)
}

func rsa_encrypt(input: String) -> UInt8[] {
    return rsa_encrypt(input.bytes)
}
