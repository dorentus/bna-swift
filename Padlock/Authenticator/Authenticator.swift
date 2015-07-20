//
//  Authenticator.swift
//  Authenticator
//
//  Created by Rox Dorentus on 14-6-5.
//  Copyright (c) 2014年 rubyist.today. All rights reserved.
//

import Foundation

public struct Authenticator {
    public let serial: Serial
    public let secret: Secret
    public var restorecode: Restorecode { return Restorecode(serial: serial, secret: secret)! }
    public var region: Region { return serial.region }

    public init(serial: Serial, secret: Secret) {
        self.serial = serial
        self.secret = secret
    }

    public init?(serial: String, secret: String) {
        if let serial = Serial(text: serial), secret = Secret(text: secret) {
            self.init(serial: serial, secret: secret)
        }
        else {
            return nil
        }
    }

    public init?(serial: [UInt8], secret: [UInt8]) {
        if let serial = Serial(binary: serial), secret = Secret(binary: secret) {
            self.init(serial: serial, secret: secret)
        }
        else {
            return nil
        }
    }
}

extension Authenticator {
    public func token(timestamp: NSTimeInterval = current_epoch()) -> (String, Double) {
        let t = UInt32(timestamp / 30)

        let t0 = UInt8((t & 0xff000000) >> 24)
        let t1 = UInt8((t & 0x00ff0000) >> 16)
        let t2 = UInt8((t & 0x0000ff00) >> 8)
        let t3 = UInt8((t & 0x000000ff) >> 0)

        let digest_input = [0, 0, 0, 0, t0, t1, t2, t3]
        let digest_key = secret.binary

        let digest = hmac_sha1_digest(digest_input, key: digest_key)
        let start_position = Int(digest[19] & 0xf)
        let bytes = digest[start_position ..< (start_position+4)]


        let r0 = (UInt32(bytes[0]) << 24)
        let r1 = (UInt32(bytes[1]) << 16)
        let r2 = (UInt32(bytes[2]) << 8)
        let r3 = UInt32(bytes[3])
        let token = r0 + r1 + r2 + r3

        let token_str = NSString(format: "%08d", (token & 0x7fffffff) % 100000000) as String

        return (token_str, Authenticator.progress(timestamp))
    }

    public static func progress(timestamp: NSTimeInterval = current_epoch()) -> Double {
        let t = UInt32(timestamp / 30)
        let next_timestamp = NSTimeInterval(t + 1) * 30.0
        let progress = 1.0 - (next_timestamp - timestamp) / 30.0

        return progress
    }
}

extension Authenticator {
    public static func request(region region: Region, completion: ((Authenticator?, NSError?) -> Void)) {
        let key = get_otp(37)
        let text = ("\u{1}" + key + region.rawValue + CLIENT_MODEL).leftFixedString(length: 56, pad: "\0")
        let payload = rsa_encrypt(text)

        http_request(region: region, path: .Enroll, body: payload) {
            bytes, error in
            if error != nil {
                completion(nil, error)
            }
            else {
                let decrypted = decrypt_response(Array(bytes![8..<45]), key: key.bytes)
                let serial_bytes = Array(decrypted[20..<37])
                let secret_bytes = Array(decrypted[0..<20])

                let authenticator = Authenticator(serial: serial_bytes, secret: secret_bytes)
                completion(authenticator, nil)  // TODO: handles nil authenticator
            }
        }
    }

    public static func restore(serial serial: Serial, restorecode: Restorecode, completion: ((Authenticator?, NSError?) -> Void)) {
        http_request(region: serial.region, path: .RestoreInit, body: serial.binary) {
            challenge, error in
            if error != nil {
                completion(nil, error)
                return
            }

            let digest = hmac_sha1_digest(serial.binary + challenge, key: restorecode.binary)
            let key = get_otp(20)

            let payload = serial.binary + rsa_encrypt(digest + key.bytes)

            http_request(region: serial.region, path: .RestoreValidate, body: payload) {
                bytes, error in
                if error != nil {
                    completion(nil, error)
                }
                else {
                    let secret_bytes = decrypt_response(bytes, key: key.bytes)
                    let authenticator = Authenticator(serial: serial.binary, secret: secret_bytes)
                    completion(authenticator, nil)  // TODO: handles nil authenticator
                }
            }
        }
    }

    public static func restore(serial serial: String, restorecode: String, completion: ((Authenticator?, NSError?) -> Void)) {
        if let serial = Serial(text: serial), restorecode = Restorecode(text: restorecode) {
            restore(serial: serial, restorecode: restorecode, completion: completion)
        }
        else {
            completion(nil, nil)  // TODO: report error
        }
    }

    public static func syncTime(region region: Region, completion: ((NSTimeInterval?, NSError?) -> Void)) {
        http_request(region: region, path: .Time, body: nil) {
            bytes, error in
            if error != nil {
                completion(nil, error)
            }
            else {
                let mm = Array((bytes!).enumerate()).reduce(0.0) {
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
