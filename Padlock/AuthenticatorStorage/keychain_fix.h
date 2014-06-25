//
//  keychain_fix.h
//  bna
//
//  Created by Rox Dorentus on 2014-6-25.
//  Copyright (c) 2014年 rubyist.today. All rights reserved.
//

#import <Foundation/Foundation.h>

// WORKAROUND:
//   kSecAttrAccount: Unmanaged<AnyObject>!
//   having problem handling Unmanaged in Swift code:
//     kSecAttrAccount.takeUnretainedValue() causing compiler fault
NSString * get_kSecAttrAccount();
