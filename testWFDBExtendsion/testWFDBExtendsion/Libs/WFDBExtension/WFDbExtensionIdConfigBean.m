//
//  WFDbExtensionIdConfigBean.m
//  Wiki
//
//  Created by mba on 16/1/18.
//  Copyright © 2016年 ubmlib. All rights reserved.
//

#import "WFDbExtensionIdConfigBean.h"

@implementation WFDbExtensionIdConfigBean

+ (id)beanWithDict:(NSDictionary *)dict
{
    
    WFDbExtensionIdConfigBean *bean = [WFDbExtensionIdConfigBean new];
    bean.primarykey = [dict objectForKey:@"primarykey"];
    NSString *autoincrement = [dict objectForKey:@"pkAutoIncrement"];
    if(autoincrement && ([autoincrement isEqualToString:@"YES"] || [autoincrement isEqualToString:@"true"]))
    {
        bean.pkAutoIncrement = YES;
    }
    else
    {
        bean.pkAutoIncrement = NO;
    }
    return bean;
}

@end
