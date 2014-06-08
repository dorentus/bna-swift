//
//  Authenticator.swift
//  bna
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
        self.restorecode = Restorecode(serial: serial, secret: secret)
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