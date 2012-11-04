//
//  PageRank.m
//  Pagerank Checker
//
//  Created by pei hao on 12-11-3.
//  Copyright (c) 2012年 pei hao. All rights reserved.
//

#import "PageRank.h"
#import "NSString+UrlEncode.h"
@implementation PageRank


-(int)getPagerank:(NSString*)url {

    NSString* host = @"toolbarqueries.google.com";
    NSString* ch = [self checksum:[self makehash:url]];
    NSString* urlPatten = @"http://%@/tbr?client=navclient-auto&ch=%@&features=Rank&q=info:%@";
    NSString* queryUrl = [NSString stringWithFormat:urlPatten,host,ch,url];
    NSStringEncoding enc = NSASCIIStringEncoding;
    NSString* retStr = [NSString stringWithContentsOfURL:[NSURL URLWithString:queryUrl]
                                            usedEncoding:&enc
                                                   error:nil];
    NSLog(@"%@",queryUrl);
    NSLog(@"%@:%d",retStr,retStr.length);
    if (retStr.length==0) {
        return -2;
    }
    NSArray* ret = [retStr componentsSeparatedByString:@":"];
    if ([ret count]!=3) {
        return -1;
    }
    return [[ret objectAtIndex:2] intValue];
}

-(NSUInteger)strtonum:(NSString*)str withCheck:(NSInteger)check andMagic:(NSInteger)magic {
    
    long int32unit = 4294967296; // 2^32
    NSUInteger length = str.length;
    const char* buffer = [str cStringUsingEncoding:NSUTF8StringEncoding];
    for (int i = 0; i < length; i++) {
        
        check *= magic;
        /* If the float is beyond the boundaries of integer (usually +/- 2.15e+9 = 2^31),
         *	the result of converting to integer is undefined.
         *	@see http://www.php.net/manual/en/language.types.integer.php
         */
        if (check >= int32unit) {
            check = (check - int32unit * (int) (check / int32unit));
            check = (check < -2147483648) ? (check + int32unit) : check;
        }
        check += (int)buffer[i];
    }
    return check;
}


-(NSInteger)makehash:(NSString*)string {
    
    NSInteger check1 = [self strtonum:string withCheck:0x1505 andMagic:0x21];
    NSInteger check2 = [self strtonum:string withCheck:0 andMagic:0x1003f];
    check1 >>= 2;
    check1 = ((check1 >> 4) & 0x3ffffc0 ) | (check1 & 0x3f);
    check1 = ((check1 >> 4) & 0x3ffc00 ) | (check1 & 0x3ff);
    check1 = ((check1 >> 4) & 0x3c000 ) | (check1 & 0x3fff);
    NSInteger t1 = ((((check1 & 0x3c0) << 4) | (check1 & 0x3c)) <<2 ) | (check2 & 0xf0f);
    NSInteger t2 = ((((check1 & 0xffffc000) << 4) | (check1 & 0x3c00)) << 0xa) | (check2 & 0xf0f0000);
    return (t1 | t2);
}


-(NSString*)checksum:(NSInteger)hashnum {
    
    int checkbyte = 0;
    int flag = 0;
    NSString* hashstr = [NSString stringWithFormat:@"%lu",hashnum];
    NSInteger length = hashstr.length;
    for (NSInteger i = length - 1;  i >= 0;  i --) {
        
        NSRange index = NSMakeRange(i,1);
        int re = [[hashstr substringWithRange:index] intValue];
        if (1 == (flag % 2)) {
            
            re += re;
            re = (int)(re / 10) + (re % 10);
        }
        checkbyte += re;
        flag ++;
    }
    checkbyte %= 10;
    if (0 != checkbyte) {
        
        checkbyte = 10 - checkbyte;
        if (1 == (flag % 2) ) {
            if (1 == (checkbyte % 2)) {
                checkbyte += 9;
            }
            checkbyte >>= 1;
        }
    }
    return [NSString stringWithFormat:@"7%d%@",checkbyte,hashstr];
}
@end
