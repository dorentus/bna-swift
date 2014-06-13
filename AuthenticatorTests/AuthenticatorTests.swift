//
//  AuthenticatorTests.swift
//  AuthenticatorTests
//
//  Created by Zhang Yi on 2014-6-11.
//  Copyright (c) 2014年 rubyist.today. All rights reserved.
//

import XCTest
import Authenticator

class AuthenticatorTests: XCTestCase {
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

    func testEquatableSerials() {
        let s0 = Serial(serial)
        let s1 = Serial(s0.prettified)

        XCTAssertEqual(s0, s1);
    }

    func testEquatableSecrets() {
        let s0 = Secret(secret)
        let s1 = Secret(s0.binary)

        XCTAssertEqual(s0, s1);
    }

    func testEquatableRestorecodes() {
        let sl = Serial(serial)
        let st = Secret(secret)

        let r0 = Restorecode(sl, st)
        let r1 = Restorecode(restorecode)
        let r2 = Restorecode(serial, secret)

        XCTAssertEqual(r0.text, restorecode)
        XCTAssertEqual(r0, r1)
        XCTAssertEqual(r1, r2)
    }
}
