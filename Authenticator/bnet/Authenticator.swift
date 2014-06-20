//
//  Authenticator.swift
//  Authenticator
//
//  Created by Rox Dorentus on 14-6-5.
//  Copyright (c) 2014年 rubyist.today. All rights reserved.
//

import Foundation

class Authenticator {
    let serial: Serial
    let secret: Secret
    var restorecode: Restorecode { return Restorecode(serial, secret) }
    var region: String { return serial.region }

    init(_ serial: Serial, _ secret: Secret) {
        self.serial = serial
        self.secret = secret
    }

    convenience init(_ serial: String, _ secret: String) {
        self.init(Serial(serial), Secret(secret))
    }

    func tokenAtTime(timestamp: NSTimeInterval = { NSTimeIntervalSince1970 + NSDate().timeIntervalSinceReferenceDate }()) -> (String, Double) {

        let t = UInt32(timestamp / 30)

        let t0 = UInt8((t & 0xff000000) >> 24)
        let t1 = UInt8((t & 0x00ff0000) >> 16)
        let t2 = UInt8((t & 0x0000ff00) >> 8)
        let t3 = UInt8((t & 0x000000ff) >> 0)

        let digest_input = [0, 0, 0, 0, t0, t1, t2, t3]
        let digest_key = secret.binary

        let digest = hmac_sha1_digest(digest_input, digest_key)
        let start_position = Int(digest[19] & 0xf)
        let bytes = digest[start_position..(start_position+4)]

        let token = (UInt32(bytes[0]) << 24) + (UInt32(bytes[1]) << 16) + (UInt32(bytes[2]) << 8) + UInt32(bytes[3])

        let token_str = NSString(format: "%08d", (token & 0x7fffffff) % 100000000) as String

        let next_timestamp = NSTimeInterval(t + 1) * 30.0
        let progress = 1.0 - (next_timestamp - timestamp) / 30.0

        return (token_str, progress)
    }
/*
    init(region: String) {
        // TODO: request for a new authenticator
    }

    init(serial: Serial, restorecode: Restorecode) {
        // TODO: request to restore an authenticator
    }

    func getToken(timestamp: UInt64?) -> (String, Float) {

    }

    static func requestServerTime(region: String) -> UInt64 {

    }
*/
}