//
//  WFDbExtensionIdConfigBean.h
//  Wiki
//
//  Created by mba on 16/1/18.
//  Copyright © 2016年 ubmlib. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WFDbExtensionIdConfigBean : NSObject

/*** 主键名 ***/
@property (strong, nonatomic) NSString *primarykey;

/*** 主键是否为自动递增类型（自动递增类型将在数据库插入忽视） -》YES为自动递增 ***/
@property (assign, nonatomic) BOOL pkAutoIncrement;

+ (id)beanWithDict:(NSDictionary *)dict;

@end
