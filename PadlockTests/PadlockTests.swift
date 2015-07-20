//
//  PadlockTests.swift
//  PadlockTests
//
//  Created by Rox Dorentus on 2014-6-25.
//  Copyright (c) 2014年 rubyist.today. All rights reserved.
//

import XCTest
import Padlock

class PadlockTests: XCTestCase {
    let serial = "CN-1402-1943-1283"
    let secret = "4202aa2182640745d8a807e0fe7e34b30c1edb23"
    let restorecode = "4CKBN08QEB"

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func testSHA1() {
        XCTAssertEqual("356a192b7913b04c54574d18c28d46e6395428ab", sha1_hexdigest("1"))
        XCTAssertEqual("15714dbb066e5379b6d4fd70f061dbf0b4a0978b", sha1_hexdigest([213, 94, 11, 68, 151, 187, 76, 141, 91, 5, 4, 160, 11, 152, 204, 54, 111, 43, 36, 225]))
    }

    func testHMACSHA1() {
        XCTAssertEqual("7480bfb8a50d1c8797cb137e9258d1c899713b1d", hmac_sha1_hexdigest("aaa", key: "bbb"))
    }

    func testModExp() {
        XCTAssertEqual("3", mod_exp_hex("64", exp: "5", mod: "d"))
        XCTAssertEqual("299", mod_exp_hex("955e4bd989f3917d2f15544a7e0504eb9d7bb66b6f8a2fe470e453c779200e5e3ad2e43a02d06c4adbd8d328f1a426b83658e88bfd949b2af4eaf30054673a1419a250fa4cc1278d12855b5b25818d162c6e6ee2ab4a350d401d78f6ddb99711e72626b48bd8b5b0b7f3acf9ea3c9e0005fee59e19136cdb7c83f2ab8b0a2a99", exp: "101", mod: "400"))
    }

    func testEquatableSerials() {
        let s0 = Serial(text: serial)!
        let s1 = Serial(text: s0.prettified)!

        XCTAssertEqual(s0, s1)
    }

    func testEquatableSecrets() {
        let s0 = Secret(text: secret)!
        let s1 = Secret(binary: s0.binary)!

        XCTAssertEqual(s0, s1)
    }

    func testEquatableRestorecodes() {
        let sl = Serial(text: serial)!
        let st = Secret(text: secret)!

        let r0 = Restorecode(serial: sl, secret: st)!
        let r1 = Restorecode(text: restorecode)!
        let r2 = Restorecode(serial: serial, secret: secret)!

        XCTAssertEqual(r0.text, restorecode)
        XCTAssertEqual(r0, r1)
        XCTAssertEqual(r1, r2)
    }

    func testRestorecode() {
        let a = Authenticator(serial: serial, secret: secret)!
        let r = Restorecode(serial: serial, secret: secret)!

        XCTAssertEqual(a.restorecode, r)
    }

    func testTokens() {
        let a = Authenticator(serial: serial, secret: secret)!

        let (t0, _) = a.token(1347279358)
        XCTAssertEqual("61459300", t0)

        let (t1, _) = a.token(1347279360)
        XCTAssertEqual("75939986", t1)

        let (t2, _) = a.token(1370448000)
        XCTAssertEqual("59914793", t2)
    }

    func testSyncTime() {
        let expectation = expectationWithDescription("time synced")
        Authenticator.syncTime(region: .US) {
            time, _ in
            if let time = time {
                XCTAssertEqualWithAccuracy(NSTimeIntervalSince1970 + NSDate().timeIntervalSinceReferenceDate, time, accuracy: 10.0)
                expectation.fulfill()
            }
        }
        waitForExpectationsWithTimeout(5.0, handler: nil)
    }

    func testRequestAuthenticator() {
        let expectation = expectationWithDescription("authenticator get")
        Authenticator.request(region: .CN) {
            authenticator, _ in
            if let _ = authenticator {
                expectation.fulfill()
            }
        }
        waitForExpectationsWithTimeout(5.0, handler: nil)
    }

    func testRestoreAuthenticator() {
        let expectation = expectationWithDescription("authenticator restored")
        Authenticator.restore(serial: "CN-1402-1943-1283", restorecode: "4CKBN08QEB") {
            authenticator, _ in
            if let a = authenticator {
                XCTAssertEqual("4202aa2182640745d8a807e0fe7e34b30c1edb23", a.secret.description)
                expectation.fulfill()
            }
        }
        waitForExpectationsWithTimeout(5.0, handler: nil)
    }

}
