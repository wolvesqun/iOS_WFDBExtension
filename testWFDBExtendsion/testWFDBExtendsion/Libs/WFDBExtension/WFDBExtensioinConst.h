//
//  WFDBExtensioinConst.h
//  Wiki
//
//  Created by mba on 16/1/15.
//  Copyright © 2016年 ubmlib. All rights reserved.
//

// code http://code.taobao.org/svn/ios-WFDBExtension/
// 技术交流群 ：148663441

#import <Foundation/Foundation.h>
#import "WFDbExtensionIdConfigBean.h"


/**
 *  类型（属性类型）
 */
extern NSString *const kWFTypeInt;
extern NSString *const kWFTypeFloat;
extern NSString *const kWFTypeDouble;
extern NSString *const kWFTypeLong;
extern NSString *const kWFTypeLongLong;
extern NSString *const kWFTypeChar;
extern NSString *const kWFTypeBOOL;
extern NSString *const kWFTypePointer;

extern NSString *const kWFTypeIvar;
extern NSString *const kWFTypeMethod;
extern NSString *const kWFTypeBlock;
extern NSString *const kWFTypeClass;
extern NSString *const kWFTypeSEL;
extern NSString *const kWFTypeId;

@interface WFDBExtensioinConst : NSObject

+ (WFDbExtensionIdConfigBean *)getConfigBeanWithTbname:(NSString *)tbname;

@end
