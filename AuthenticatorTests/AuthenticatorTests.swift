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

    func testRestorecode() {
        let sl = Serial(serial)
        let st = Secret(secret)

        let r0 = Restorecode(sl, st)
        let r1 = Restorecode(restorecode)
        let r2 = Restorecode(serial, secret)

        XCTAssertEqual(r0.text, restorecode)
        XCTAssertEqual(r0.text!, r1.text!)
        XCTAssertEqual(r1.text!, r2.text!)
    }
}
