//
//  WFFoundation.m
//  Wiki
//
//  Created by mba on 16/1/15.
//  Copyright © 2016年 ubmlib. All rights reserved.
//

#import "WFFoundation.h"

static NSSet *_foundationClasses;
static NSSet *_ignoreFoundationClasses;

@implementation WFFoundation

+ (void)load
{
    _foundationClasses = [NSSet setWithObjects:
                          [NSObject class],
                          [NSNumber class],
                          [NSDecimalNumber class],
                          [NSData class],
                          [NSMutableData class],
                          [NSString class],
                          [NSMutableString class], nil];
    
    _ignoreFoundationClasses = [NSSet setWithObjects:
                                [NSArray class],
                                [NSMutableArray class],
                                [NSURL class],
                                [NSDictionary class],
                                [NSMutableDictionary class],nil];
}

+ (BOOL)isClassFromFoundation:(Class)c
{
    return [_foundationClasses containsObject:c];
}

+ (BOOL)ignoreFoundationClass:(Class)c
{
    return [_ignoreFoundationClasses containsObject:c];
}

@end
