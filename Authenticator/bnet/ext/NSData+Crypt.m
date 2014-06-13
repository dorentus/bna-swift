//
//  NSData+Crypt.m
//  Authenticator
//
//  Created by Zhang Yi on 2014-6-11.
//  Copyright (c) 2014年 rubyist.today. All rights reserved.
//

#import "NSData+Crypt.h"
#import <CommonCrypto/CommonDigest.h>
#import <CommonCrypto/CommonHMAC.h>

@implementation NSData (Crypto)

- (NSString *)SHA1HexDigest
{
    uint8_t digest[CC_SHA1_DIGEST_LENGTH];

    CC_SHA1(self.bytes, (CC_LONG)self.length, digest);

    NSMutableString *output = [NSMutableString stringWithCapacity:CC_SHA1_DIGEST_LENGTH * 2];

    for (int i = 0; i < CC_SHA1_DIGEST_LENGTH; i++)
    {
        [output appendFormat:@"%02x", digest[i]];
    }

    return output;
}

- (NSString *)HMACSHA1HexDigestWithKey:(NSData *)keyData
{
    NSMutableData *result = [NSMutableData dataWithLength:CC_SHA1_DIGEST_LENGTH];
    CCHmac(kCCHmacAlgSHA1, keyData.bytes, keyData.length, self.bytes, self.length, result.mutableBytes);

    NSMutableString *output = [NSMutableString stringWithCapacity:CC_SHA1_DIGEST_LENGTH * 2];
    uint8_t digest[CC_SHA1_DIGEST_LENGTH];

    [result getBytes:&digest length:CC_SHA1_DIGEST_LENGTH];

    for (int i = 0; i < CC_SHA1_DIGEST_LENGTH; i++)
    {
        [output appendFormat:@"%02x", digest[i]];
    }
    
    return output;
}

@end
