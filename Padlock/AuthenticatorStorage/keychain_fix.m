//
//  keychain_fix.m
//  bna
//
//  Created by Rox Dorentus on 2014-6-25.
//  Copyright (c) 2014年 rubyist.today. All rights reserved.
//

#import "keychain_fix.h"

NSString *
get_kSecAttrAccount()
{
    return (__bridge id)kSecAttrAccount;
}
