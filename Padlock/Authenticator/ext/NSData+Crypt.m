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

- (NSString *)hexString
{
    size_t length = self.length;
    uint8_t bytes[length];

    [self getBytes:&bytes length:length];

    NSMutableString *output = [NSMutableString stringWithCapacity:length * 2];

    for (int i = 0; i < CC_SHA1_DIGEST_LENGTH; i++)
    {
        [output appendFormat:@"%02x", bytes[i]];
    }

    return output;
}

- (NSString *)SHA1HexDigest
{
    NSMutableData *result = [NSMutableData dataWithLength:CC_SHA1_DIGEST_LENGTH];

    CC_SHA1(self.bytes, (CC_LONG)self.length, result.mutableBytes);

    return [result hexString];
}

- (NSString *)HMACSHA1HexDigestWithKey:(NSData *)keyData
{
    NSMutableData *result = [NSMutableData dataWithLength:CC_SHA1_DIGEST_LENGTH];
    CCHmac(kCCHmacAlgSHA1, keyData.bytes, keyData.length, self.bytes, self.length, result.mutableBytes);

    return [result hexString];
}

@end
