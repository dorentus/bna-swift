//
//  Extensions.swift
//  Authenticator
//
//  Created by Rox Dorentus on 14-6-6.
//  Copyright (c) 2014年 rubyist.today. All rights reserved.
//

import Foundation
import CommonCrypto
import BigDigits

let CLIENT_MODEL = "bn/authenticator"
let RSA_MOD = "955e4bd989f3917d2f15544a7e0504eb9d7bb66b6f8a2fe470e453c779200e5e3ad2e43a02d06c4adbd8d328f1a426b83658e88bfd949b2af4eaf30054673a1419a250fa4cc1278d12855b5b25818d162c6e6ee2ab4a350d401d78f6ddb99711e72626b48bd8b5b0b7f3acf9ea3c9e0005fee59e19136cdb7c83f2ab8b0a2a99"
let RSA_KEY = "101"

public enum Region: String {
    case CN = "CN"
    case EU = "EU"
    case US = "US"
    public static let allValues = [CN, EU, US]
}
enum RequestPath: String {
    case Enroll = "/enrollment/enroll.htm"
    case Time = "/enrollment/time.htm"
    case RestoreInit = "/enrollment/initiatePaperRestore.htm"
    case RestoreValidate = "/enrollment/validatePaperRestore.htm"
}

let REQUEST_HOSTS = [
    Region.CN: "mobile-service.battlenet.com.cn",
    Region.EU: "m.eu.mobileservice.blizzard.com",
    Region.US: "m.us.mobileservice.blizzard.com",
]

func -<T: Equatable>(lhs: [T], rhs: [T]) -> [T] {
    var result = lhs
    for v in rhs {
        if let index = find(result, v) {
            result.removeAtIndex(index)
        }
    }
    return result
}

extension NSData {
    func hexString() -> String {
        var bytes = [UInt8](count: self.length, repeatedValue: 0)
        self.getBytes(&bytes, length: self.length)

        return "".join(bytes.map { String(format: "%02x", $0) } )
    }

    func SHA1HexDigest() -> String {
        let result = NSMutableData(length: Int(CC_SHA1_DIGEST_LENGTH))!
        CC_SHA1(self.bytes, CC_LONG(self.length), unsafeBitCast(result.mutableBytes, UnsafeMutablePointer<UInt8>.self))
        return result.hexString()
    }

    func HMACSHA1HexDigest(key: NSData) -> String {
        let result = NSMutableData(length: Int(CC_SHA1_DIGEST_LENGTH))!
        CCHmac(CCHmacAlgorithm(kCCHmacAlgSHA1), key.bytes, key.length, self.bytes, self.length, result.mutableBytes)
        return result.hexString()
    }
}

extension String {
    var length: Int { return count(self) }
    var bytes: [UInt8] { return Array(self.utf8) }

    func matches(pattern: String) -> Bool {
        let regex = NSRegularExpression(pattern: pattern, options: .DotMatchesLineSeparators, error: nil)
        return regex?.numberOfMatchesInString(self, options: nil, range: NSMakeRange(0, self.length)) > 0
    }

    func scan(pattern: String) -> [String] {
        let regex = NSRegularExpression(pattern: pattern, options: .DotMatchesLineSeparators, error: nil)
        let matches = regex?.matchesInString(self, options: nil, range: NSMakeRange(0, self.length)) ?? []

        return matches.map { m in
            (self as NSString).substringWithRange((m as! NSTextCheckingResult).rangeAtIndex(0))
        }
    }

    func leftFixedString(#length: Int, pad: Character) -> String {
        if self.length <= length {
            let diff = length - self.length
            var suffix = ""
            for i in 0 ..< diff {
                suffix += "\(pad)"
            }
            return self + suffix
        }
        else {
            return (self as NSString).substringToIndex(length)
        }
    }
}

func hex2bin(hex: String) -> [UInt8] {
    var str = hex
    if hex.length % 2 != 0 {
        str = "0" + hex
    }

    return str.scan(".{2}").map({ s in
        UInt8(strtol((s as NSString).UTF8String, nil, 16))
    })
}

func bin2hex(bin: [UInt8]) -> String {
    if count(bin) == 0 {
        return ""
    }
    return "".join(bin.map({ c in String(format: "%02x", c) }))
}

public func sha1_hexdigest(input: String) -> String {
    return sha1_hexdigest(input.bytes)
}

public func sha1_hexdigest(input_bytes: [UInt8]) -> String {
    let data = NSData(bytes: input_bytes, length: count(input_bytes))
    return data.SHA1HexDigest()
}

func sha1_digest(input: String) -> [UInt8] {
    return hex2bin(sha1_hexdigest(input))
}

func sha1_digest(input: [UInt8]) -> [UInt8] {
    return hex2bin(sha1_hexdigest(input))
}

func hmac_sha1_hexdigest(input_bytes: [UInt8], key_bytes: [UInt8]) -> String {
    let input_data = NSData(bytes: input_bytes, length: count(input_bytes))
    let key_data = NSData(bytes: key_bytes, length: count(key_bytes))

    return input_data.HMACSHA1HexDigest(key_data)
}

public func hmac_sha1_hexdigest(input: String, key: String) -> String {
    return hmac_sha1_hexdigest(input.bytes, key.bytes)
}

func hmac_sha1_digest(input: [UInt8], key: [UInt8]) -> [UInt8] {
    return hex2bin(hmac_sha1_hexdigest(input, key))
}

func hmac_sha1_digest(input: String, key: String) -> [UInt8] {
    return hex2bin(hmac_sha1_hexdigest(input, key))
}

func http_request(#region: Region, #path: RequestPath, #body: Array<UInt8>?, completion: ((Array<UInt8>!, NSError?) -> Void)) {
    let host = REQUEST_HOSTS[region]!
    let url = NSURL(string: "http://\(host)\(path.rawValue)")
    let request = NSMutableURLRequest(URL: url!)
    request.setValue("application/octet-stream", forHTTPHeaderField: "Content-Type")
    if let body = body {
        request.HTTPMethod = "POST"
        request.HTTPBody = NSData(bytes: body, length: count(body))
    }

    NSURLConnection.sendAsynchronousRequest(request, queue: NSOperationQueue.currentQueue()) {
        (response, data, error) in
        if let error = error {
            completion(nil, error)
        }
        else if (response as! NSHTTPURLResponse).statusCode != 200 {
            completion(nil, nil)    // TODO: report error
        }
        else {
            var bytes = [UInt8](count: data.length, repeatedValue: 0)
            data.getBytes(&bytes, length: data.length)
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
    return (result as NSString).substringToIndex(length)
}

func decrypt_response(input: [UInt8], key: [UInt8]) -> [UInt8] {
    let length = count(input)

    assert(length == count(key))

    var result: [UInt8] = []
    for index in (0 ..< length) {
        result.append(input[index] ^ key[index])
    }

    return result
}

func rsa_encrypt(input: [UInt8]) -> [UInt8] {
    let input_hex = bin2hex(input)
    let result_hex = mod_exp_hex(input_hex, RSA_KEY, RSA_MOD)
    return hex2bin(result_hex)
}

func rsa_encrypt(input: String) -> [UInt8] {
    return rsa_encrypt(input.bytes)
}

func current_epoch() -> NSTimeInterval {
    return NSTimeIntervalSince1970 + NSDate().timeIntervalSinceReferenceDate
}

public func mod_exp_hex(value: String, exp: String, mod: String) -> String {
    var v_bd = bdNew()
    var exp_bd = bdNew()
    var mod_bd = bdNew()
    var result_bd = bdNew()

    bdConvFromHex(v_bd, value.cStringUsingEncoding(NSASCIIStringEncoding)!)
    bdConvFromHex(exp_bd, exp.cStringUsingEncoding(NSASCIIStringEncoding)!)
    bdConvFromHex(mod_bd, mod.cStringUsingEncoding(NSASCIIStringEncoding)!)

    bdModExp(result_bd, v_bd, exp_bd, mod_bd)

    bdFree(&v_bd)
    bdFree(&exp_bd)
    bdFree(&mod_bd)

    let n_chars = bdConvToHex(result_bd, nil, 0)
    var result_bytes = [CChar](count: n_chars + 1, repeatedValue: 0)
    bdConvToHex(result_bd, &result_bytes, n_chars + 1)

    bdFree(&result_bd)

    return String(CString: &result_bytes, encoding: NSASCIIStringEncoding)!
}
