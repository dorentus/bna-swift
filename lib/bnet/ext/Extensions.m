//
//  Extensions.m
//  bna
//
//  Created by Rox Dorentus on 14-6-8.
//  Copyright (c) 2014年 rubyist.today. All rights reserved.
//

#import "Extensions.h"
#import <CommonCrypto/CommonDigest.h>

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

@end