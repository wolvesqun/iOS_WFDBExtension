//
//  WFIvar.m
//  Wiki
//
//  Created by mba on 16/1/15.
//  Copyright © 2016年 ubmlib. All rights reserved.
//

#import "WFIvar.h"
#import "WFType.h"

@implementation WFIvar

+ (instancetype)beanWithIvar:(Ivar)ivar
{
    WFIvar *ivarObject = objc_getAssociatedObject(self, ivar);
    if (ivarObject == nil) {
        ivarObject = [[self alloc] init];
        ivarObject.ivar = ivar;
        objc_setAssociatedObject(self, ivar, ivarObject, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    return ivarObject;
}
/**
 *  设置成员变量
 */
- (void)setIvar:(Ivar)ivar
{
    _ivar = ivar;
    
    
    
    // 1.成员变量名
    _name = @(ivar_getName(ivar));
    
    // 2.属性名
    if ([_name hasPrefix:@"_"]) {
        _propertyName = [_name stringByReplacingCharactersInRange:NSMakeRange(0, 1) withString:@""];
    } else {
        _propertyName = _name;
    }
    
    // 3.成员变量的类型符
    NSString *code = @(ivar_getTypeEncoding(ivar));
    _type = [WFType beanWithCode:code];
}

@end
