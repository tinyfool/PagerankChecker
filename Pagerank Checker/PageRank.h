//
//  PageRank.h
//  Pagerank Checker
//
//  Created by pei hao on 12-11-3.
//  Copyright (c) 2012年 pei hao. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PageRank : NSObject

-(int)getPagerank:(NSString*)url;
-(NSUInteger)strtonum:(NSString*)str withCheck:(NSInteger)check andMagic:(NSInteger)magic;
-(NSInteger)makehash:(NSString*)string;
-(NSString*)checksum:(NSInteger)hashnum;
@end
