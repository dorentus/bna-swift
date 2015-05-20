//
//  AuthenticatorStorage.swift
//  AuthenticatorStorage
//
//  Created by Rox Dorentus on 2014-6-23.
//  Copyright (c) 2014年 rubyist.today. All rights reserved.
//

import Foundation
import SSKeychain

class AuthenticatorStorage {
    class func sharedStorage() -> AuthenticatorStorage {
        struct Singleton {
            static let instance = AuthenticatorStorage()
        }
        return Singleton.instance
    }

    let KEYCHAIN_SERVICE = "bna_authenticators"
    let USERDEFAULTS_KEY = "bna_authenticator_serials"

    let userDefaults: UserDefaults
    let keychain: Keychain

    var serials: [String] {
        let a = userDefaults.serials
        let b = keychain.serials
        return a - (a - b) + (b - a)
    }

    init() {
        self.userDefaults = UserDefaults(USERDEFAULTS_KEY)
        self.keychain = Keychain(KEYCHAIN_SERVICE)
    }

    var count: Int {
        return serials.count
    }

    subscript(index: Int) -> Authenticator? {
        if index < 0 || index >= count {
            return nil
        }

        let serial = serials[index]
        if let secret = self.keychain.secretForSerial(serial) {
            return Authenticator(serial: serial, secret: secret)
        }

        return nil
    }

    func add(authenticator: Authenticator) -> Bool {
        if exists(authenticator) {
            return false
        }

        return self.keychain.add(authenticator) && self.userDefaults.add(authenticator)
    }

    func del(authenticator: Authenticator) -> Bool {
        return self.keychain.del(authenticator) && self.userDefaults.del(authenticator)
    }

    func move(#from: Int, to: Int) -> Bool {
        return self.userDefaults.move(from: from, to: to)
    }

    func exists(serial: String) -> Bool {
        if find(self.serials, serial) != nil {
            return true
        }

        return false
    }

    func exists(authenticator: Authenticator) -> Bool {
        return exists(authenticator.serial.description)
    }

}

extension AuthenticatorStorage {

    class UserDefaults {
        let key: String
        var serials: [String] {
            return NSUserDefaults.standardUserDefaults().objectForKey(key) as? [String] ?? []
        }

        init(_ key: String) {
            self.key = key
        }

        func add(authenticator: Authenticator) -> Bool {
            let serial = authenticator.serial.description

            if exists(serial) {
                return false
            }

            var serials = self.serials
            serials.append(serial)
            replaceAndSave(serials)

            return true
        }

        func del(authenticator: Authenticator) -> Bool {
            let serial = authenticator.serial.description

            var serials = self.serials
            if let index = find(serials, serial) {
                serials.removeAtIndex(index)
                replaceAndSave(serials)

                return true
            }

            return false
        }

        func move(#from: Int, to: Int) -> Bool {
            var serials = self.serials
            let count = serials.count
            if from < 0 || from >= count || to < 0 || to >= count {
                return false
            }

            let a = serials.removeAtIndex(from)
            serials.insert(a, atIndex: to)
            replaceAndSave(serials)

            return true
        }

        func exists(serial: String) -> Bool {
            if find(serials, serial) != nil {
                return true
            }

            return false
        }

        func replaceAndSave(serials: [String]) {
            NSUserDefaults.standardUserDefaults().setObject(serials, forKey: key)
        }
    }

    class Keychain {
        let service: String
        var serials: [String] {
            if let accounts = SSKeychain.accountsForService(service) as? [NSDictionary] {
                return accounts.map {
                    return $0[kSecAttrAccount as! String] as! String
                }
            }

            return []
        }

        init(_ service: String) {
            self.service = service
        }

        func add(authenticator: Authenticator) -> Bool {
            return SSKeychain.setPassword(authenticator.secret.description, forService: service, account: authenticator.serial.description)
        }

        func del(authenticator: Authenticator) -> Bool {
            return SSKeychain.deletePasswordForService(service, account: authenticator.serial.description)
        }
        
        func secretForSerial(serial: String) -> String? {
            return SSKeychain.passwordForService(service, account: serial)
        }
    }
}
