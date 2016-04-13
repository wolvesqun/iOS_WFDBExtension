//
//  WFDBExtensioinConst.m
//  Wiki
//
//  Created by mba on 16/1/15.
//  Copyright © 2016年 ubmlib. All rights reserved.
//

#import "WFDBExtensioinConst.h"

/**
 *  成员变量类型（属性类型）
 */
NSString *const kWFTypeInt = @"i";
NSString *const kWFTypeFloat = @"f";
NSString *const kWFTypeDouble = @"d";
NSString *const kWFTypeLong = @"q";
NSString *const kWFTypeLongLong = @"q";
NSString *const kWFTypeChar = @"c";
NSString *const kWFTypeBOOL = @"c";
NSString *const kWFTypePointer = @"*";

NSString *const kWFTypeIvar = @"^{objc_ivar=}";
NSString *const kWFTypeMethod = @"^{objc_method=}";
NSString *const kWFTypeBlock = @"@?";
NSString *const kWFTypeClass = @"#";
NSString *const kWFTypeSEL = @":";
NSString *const kWFTypeId = @"@";

@implementation WFDBExtensioinConst

+ (NSDictionary *)getConfigDict
{
    static NSDictionary *dict = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if(dict == nil)
        {
            NSString *filepath = [[NSBundle mainBundle] pathForResource:@"WFDbExeension.plist" ofType:nil];
            dict = [NSDictionary  dictionaryWithContentsOfFile:filepath];
        }
    });
    return dict;
}

+ (WFDbExtensionIdConfigBean *)getConfigBeanWithTbname:(NSString *)tbname
{
    static NSMutableDictionary *beanDicts = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if(beanDicts == nil)
        {
            beanDicts = [NSMutableDictionary dictionary];
            
            NSDictionary *dict= [self getConfigDict];
            for (NSString *key in [dict allKeys]) {
                NSDictionary *childDict = [dict objectForKey:key];
                WFDbExtensionIdConfigBean *bean = [WFDbExtensionIdConfigBean beanWithDict:childDict];
                if(bean)
                {
                    [beanDicts setObject:bean forKey:key];
                }
                
            }
        }
    });
    return [beanDicts objectForKey:tbname];
}

@end
