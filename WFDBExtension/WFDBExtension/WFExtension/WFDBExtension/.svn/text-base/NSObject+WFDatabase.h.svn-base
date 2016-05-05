//
//  NSObject+WFDatabase.h
//  Wiki
//
//  Created by wolvesqun on 16/1/15.
//  Copyright © 2016年 ubmlib. All rights reserved.
//

// code http://code.taobao.org/svn/ios-WFDBExtension/

// 技术交流群 ：148663441

#import <Foundation/Foundation.h>
#import <objc/runtime.h>
#import "FMDatabase.h"


@interface NSObject (WFDatabase)

/**
 *  保存数据到数据库
 */
+ (BOOL)DB_addWithBean:(id)bean;

/**
 *  通过主键key删除记录
 *
 *  @param key : key为主键的value
 */
+ (BOOL)DB_deleteWithKey:(NSString *)key;

/**
 *  通过条件删除对应的记录
 *
 *  @param whereSQLParam : 删除条件（删除用户名为u1 并且 年龄 大于1 { @"username = ?":@"u1", @"age > ?":@"1"} ）
 */
+ (BOOL)DB_deleteWithWhereSQL:(NSDictionary *)whereSQLParam;

// - 更新数据
+ (BOOL)DB_updateWithBean:(id)bean;
+ (BOOL)DB_updateWithSetupSQL:(NSDictionary *)setupSQL andWhereSQL:(NSDictionary *)whereSQL;


/**
 *  通过条件查询所有数据
 *  
 *  @param whereSQLParam : 查询条件，（如果为空，默认查询所有); eq -》（查询年龄 大于1 { @"age > ?" : @"1"} ）
 */
+ (NSMutableArray *)DB_queryWithWhereSQL:(NSDictionary *)whereSQLParam;

// - 获取某条记录
+ (id)DB_findWithKey:(NSString *)key;
+ (id)DB_findWithWhereSQL:(NSDictionary *)whereSQLParam;

// - 根据相关条件判断是否存在记录
+ (BOOL)DB_isExistWithKey:(NSString *)key;
+ (BOOL)DB_isExistWithWhereSQL:(NSDictionary *)whereSQLParam;

// - 判空
+ (BOOL)DB_isEmpty:(NSDictionary *)whereSQLParam;



@end
