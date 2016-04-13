//
//  WFType.m
//  Wiki
//
//  Created by mba on 16/1/15.
//  Copyright © 2016年 ubmlib. All rights reserved.
//

#import "WFType.h"
#import "WFDBExtensioinConst.h"
#import "WFFoundation.h"

@implementation WFType

static NSMutableDictionary *_cachedTypes;
+ (void)load
{
    _cachedTypes = [NSMutableDictionary dictionary];
}

+ (instancetype)beanWithCode:(NSString *)code
{
    WFType *type = _cachedTypes[code];
    if (type == nil) {
        type = [[self alloc] init];
        type.code = code;
        _cachedTypes[code] = type;
    }
    return type;
}

- (void)setCode:(NSString *)code
{
    _code = code;
    
    if(code == nil || code.length == 0) return;
    
    if ([code isEqualToString:kWFTypeId]) {
        _idType = YES;
    } else if (code.length == 0) {
        _KVCDisabled = YES;
    } else if (code.length > 3 && [code hasPrefix:@"@\""]) {
        // 去掉@"和"，截取中间的类型名称
        _code = [code substringWithRange:NSMakeRange(2, code.length - 3)];
        _typeClass = NSClassFromString(_code);
        _fromFoundation = [WFFoundation isClassFromFoundation:_typeClass];
    } else if ([code isEqualToString:kWFTypeSEL] ||
               [code isEqualToString:kWFTypeIvar] ||
               [code isEqualToString:kWFTypeMethod]) {
        _KVCDisabled = YES;
    }
}

@end
