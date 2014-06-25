//
//  functions.m
//  bna
//
//  Created by Rox Dorentus on 14-6-21.
//  Copyright (c) 2014年 rubyist.today. All rights reserved.
//

#include <stdlib.h>
#include <stdint.h>
#include "bigd.h"
#include "functions.h"

NSString *
mod_exp_hex(NSString * value, NSString * exp, NSString * mod)
{
    BIGD v_bd, exp_bd, mod_bd, result_bd;

    v_bd = bdNew();
    exp_bd = bdNew();
    mod_bd = bdNew();
    result_bd = bdNew();

    bdConvFromHex(v_bd, [value cStringUsingEncoding:NSASCIIStringEncoding]);
    bdConvFromHex(exp_bd, [exp cStringUsingEncoding:NSASCIIStringEncoding]);
    bdConvFromHex(mod_bd, [mod cStringUsingEncoding:NSASCIIStringEncoding]);

    bdModExp(result_bd, v_bd, exp_bd, mod_bd);

    bdFree(&v_bd);
    bdFree(&exp_bd);
    bdFree(&mod_bd);

    char * result_str;
    size_t nchars = bdConvToHex(result_bd, NULL, 0);
    result_str = malloc(nchars + 1);
    bdConvToHex(result_bd, result_str, nchars + 1);

    bdFree(&result_bd);

    NSString * result = [NSString stringWithCString:result_str encoding:NSASCIIStringEncoding];

    free(result_str);

    return result;
}