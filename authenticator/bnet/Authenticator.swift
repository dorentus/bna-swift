//
//  Authenticator.swift
//  Authenticator
//
//  Created by Rox Dorentus on 14-6-5.
//  Copyright (c) 2014年 rubyist.today. All rights reserved.
//

import Foundation

struct Authenticator {
    let serial: Serial
    let secret: Secret
    let restorecode: Restorecode
    var region: String { return serial.region }

    init(serial: Serial, secret: Secret) {
        self.serial = serial
        self.secret = secret
        self.restorecode = Restorecode(serial, secret)
    }

    init(serial: String, secret: String) {
        self.init(serial: Serial(serial), secret: Secret(secret))
    }

    func getToken(timestamp: UInt64?) -> (String, Float) {
        /*
            current = (timestamp || Time.now.getutc.to_i) / 30

            digest = hmac_sha1_digest([current].pack('Q').reverse, secret.binary)

            start_position = digest.char_code_at(19) & 0xf

            token = digest.substring_at(start_position, length: 4).reverse.unpack('L')[0] & 0x7fffffff

            [sprintf('%08d', token % 1_0000_0000), (current + 1) * 30]
        */
        return ("", 0)
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