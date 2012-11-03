//
//  Url.h
//  Pagerank Checker
//
//  Created by pei hao on 12-11-2.
//  Copyright (c) 2012年 pei hao. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Url : NSManagedObject

@property (nonatomic, retain) NSString * address;
@property (nonatomic, retain) NSNumber * pagerank;
@property (nonatomic, retain) NSString * title;

@end
