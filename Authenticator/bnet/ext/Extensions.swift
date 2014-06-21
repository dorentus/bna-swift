//
//  Extensions.swift
//  Authenticator
//
//  Created by Rox Dorentus on 14-6-6.
//  Copyright (c) 2014年 rubyist.today. All rights reserved.
//

import Foundation

let CLIENT_MODEL = "bn/authenticator"
let RSA_MOD = "955e4bd989f3917d2f15544a7e0504eb9d7bb66b6f8a2fe470e453c779200e5e3ad2e43a02d06c4adbd8d328f1a426b83658e88bfd949b2af4eaf30054673a1419a250fa4cc1278d12855b5b25818d162c6e6ee2ab4a350d401d78f6ddb99711e72626b48bd8b5b0b7f3acf9ea3c9e0005fee59e19136cdb7c83f2ab8b0a2a99"
let RSA_KEY = "101"
let RESTORECODE_MAP: Dictionary<UInt8, UInt8> = [
    0:  48,  1: 49,  2: 50,  3: 51,  4: 52,
    5:  53,  6: 54,  7: 55,  8: 56,  9: 57,
    10: 65, 11: 66, 12: 67, 13: 68, 14: 69,
    15: 70, 16: 71, 17: 72, 18: 74, 19: 75,
    20: 77, 21: 78, 22: 80, 23: 81, 24: 82,
    25: 84, 26: 85, 27: 86, 28: 87, 29: 88,
    30: 89, 31: 90, 32: 91
]
let RESTORECODE_MAP_INVERSE: Dictionary<UInt8, UInt8> = {
    var dict = Dictionary<UInt8, UInt8>()
    for (key, value) in RESTORECODE_MAP {
        dict[value] = key
    }
    return dict
}()

enum Region: String {
    case CN = "CN"
    case EU = "EU"
    case US = "US"
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

func http_request(#region: Region, #path: RequestPath, #body: Array<UInt8>?, completion: ((Array<UInt8>!, NSError?) -> Void)) {
    let host = REQUEST_HOSTS[region]!
    let url = NSURL(string: "http://\(host)\(path.toRaw())")
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
    let result_hex = mod_exp_hex(input_hex, RSA_KEY, RSA_MOD)
    return hex2bin(result_hex)
}

func rsa_encrypt(input: String) -> UInt8[] {
    return rsa_encrypt(input.bytes)
}
