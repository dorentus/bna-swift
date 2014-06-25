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
    var region: Region { return serial.region }

    init(_ serial: Serial, _ secret: Secret) {
        self.serial = serial
        self.secret = secret
    }

    class func withSerial(serial: String, secret: String) -> Authenticator? {
        let sr = Serial.withText(serial)
        let sc = Secret.withText(secret)

        if !sr || !sc {
            return nil
        }

        return Authenticator(sr!, sc!)
    }

    class func withSerial(serial: UInt8[], secret: UInt8[]) -> Authenticator? {
        let sr = Serial.withBinary(serial)
        let sc = Secret.withBinary(secret)

        if !sr || !sc {
            return nil
        }

        return Authenticator(sr!, sc!)
    }

    func token(timestamp: NSTimeInterval = { NSTimeIntervalSince1970 + NSDate().timeIntervalSinceReferenceDate }()) -> (String, Double) {
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

    class func request(#region: Region, completion: ((Authenticator?, NSError?) -> Void)) {
        let key = get_otp(37)
        let text = ("\x01" + key + region.toRaw() + CLIENT_MODEL).leftFixedString(length: 56, pad: "\0")
        let payload = rsa_encrypt(text)

        http_request(region: region, path: .Enroll, body: payload) {
            bytes, error in
            if error {
                completion(nil, error)
            }
            else {
                let decrypted = decrypt_response(Array(bytes![8..45]), key.bytes)
                let serial_bytes = Array(decrypted[20..37])
                let secret_bytes = Array(decrypted[0..20])

                let authenticator = Authenticator.withSerial(serial_bytes, secret: secret_bytes)
                completion(authenticator, nil)  // TODO: handles nil authenticator
            }
        }
    }

    class func restore(#serial: Serial, restorecode: Restorecode, completion: ((Authenticator?, NSError?) -> Void)) {
        http_request(region: serial.region, path: .RestoreInit, body: serial.binary) {
            challenge, error in
            if error {
                completion(nil, error)
                return
            }

            let digest = hmac_sha1_digest(serial.binary + challenge, restorecode.binary)
            let key = get_otp(20)

            let payload = serial.binary + rsa_encrypt(digest + key.bytes)

            http_request(region: serial.region, path: .RestoreValidate, body: payload) {
                bytes, error in
                if error {
                    completion(nil, error)
                }
                else {
                    let secret_bytes = decrypt_response(bytes, key.bytes)
                    let authenticator = Authenticator.withSerial(serial.binary, secret: secret_bytes)
                    completion(authenticator, nil)  // TODO: handles nil authenticator
                }
            }
        }
    }

    class func restore(#serial: String, restorecode: String, completion: ((Authenticator?, NSError?) -> Void)) {
        let s = Serial.withText(serial)
        let r = Restorecode.withText(restorecode)
        if !s || !r {
            completion(nil, nil)  // TODO: report error
        }
        else {
            restore(serial: s!, restorecode: r!, completion)
        }
    }

    class func syncTime(#region: Region, completion: ((NSTimeInterval?, NSError?) -> Void)) {
        http_request(region: region, path: .Time, body: nil) {
            bytes, error in
            if error {
                completion(nil, error)
            }
            else {
                let mm = Array(enumerate(bytes!)).reduce(0.0) {
                    rem, pair in
                    let (index, byte) = pair
                    let exp = Double(7 - index) * 8
                    return rem + Double(byte) * pow(2, exp)
                }
                completion(mm / 1000, nil)
            }
        }
    }
}
