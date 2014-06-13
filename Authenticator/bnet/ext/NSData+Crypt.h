//
//  NSData+Crypt.h
//  Authenticator
//
//  Created by Zhang Yi on 2014-6-11.
//  Copyright (c) 2014年 rubyist.today. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSData (Crypto)

- (NSString *)SHA1HexDigest;
- (NSString *)HMACSHA1HexDigestWithKey:(NSData *)keyData;

@end
