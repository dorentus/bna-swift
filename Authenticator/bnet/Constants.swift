//
//  Constants.swift
//  Authenticator
//
//  Created by Rox Dorentus on 14-6-5.
//  Copyright (c) 2014年 rubyist.today. All rights reserved.
//

import Foundation

struct AuthenticatorConstants {
    static let CLIENT_MODEL = "bn/authenticator"
    static let RSA_MOD = "955e4bd989f3917d2f15544a7e0504eb9d7bb66b6f8a2fe470e453c779200e5e3ad2e43a02d06c4adbd8d328f1a426b83658e88bfd949b2af4eaf30054673a1419a250fa4cc1278d12855b5b25818d162c6e6ee2ab4a350d401d78f6ddb99711e72626b48bd8b5b0b7f3acf9ea3c9e0005fee59e19136cdb7c83f2ab8b0a2a99"
    static let RSA_KEY = 257
    static let AUTHENTICATOR_HOSTS = [
        "CN": "mobile-service.battlenet.com.cn",
        "EU": "m.eu.mobileservice.blizzard.com",
        "US": "m.us.mobileservice.blizzard.com",
    ]
    static let ENROLLMENT_REQUEST_PATH = "/enrollment/enroll.htm"
    static let TIME_REQUEST_PATH = "/enrollment/time.htm"
    static let RESTORE_INIT_REQUEST_PATH = "/enrollment/initiatePaperRestore.htm"
    static let RESTORE_VALIDATE_REQUEST_PATH = "/enrollment/validatePaperRestore.htm"
}