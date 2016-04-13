//
//  WFIvar.h
//  Wiki
//
//  Created by mba on 16/1/15.
//  Copyright © 2016年 ubmlib. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <objc/runtime.h>

@class WFType;
@interface WFIvar : NSObject

/** 成员变量 */
@property (assign, nonatomic) Ivar ivar;
/** 成员名 */
@property (copy, nonatomic) NSString *name;
/** 成员属性名 */
@property (readonly, nonatomic) NSString *propertyName;
/** 成员变量的类型 */
@property (nonatomic, readonly) WFType  *type;
/** 成员来源于哪个类（可能是父类） */
@property (assign, nonatomic) Class srcClass;

/**
 *  初始化
 */
+ (instancetype)beanWithIvar:(Ivar)ivar;

@end
