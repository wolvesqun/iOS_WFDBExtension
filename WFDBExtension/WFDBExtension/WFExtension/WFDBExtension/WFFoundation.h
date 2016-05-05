//
//  WFFoundation.h
//  Wiki
//
//  Created by mba on 16/1/15.
//  Copyright © 2015年 ubmlib. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WFFoundation : NSObject

+ (BOOL)isClassFromFoundation:(Class)c;

+ (BOOL)ignoreFoundationClass:(Class)c;

@end
