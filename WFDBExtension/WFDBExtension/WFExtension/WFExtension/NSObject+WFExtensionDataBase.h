//
//  NSObject+WFExtensionDataBase.h
//  WFExtension
//
//  Created by PC on 4/30/16.
//  Copyright © 2016 ibmlib. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol WFDataBaseDelegate <NSObject>

@required
/**
 *  this is the table's indentifier
 */
- (NSString *)getId;

@optional
/**
 *  if not implements, and the defalult value is NO;
 */
- (BOOL)isAutoIncrementForId;

@end

@interface NSObject (WFExtensionDataBase)

/**
 *  save bean to db
 */
+ (BOOL)DB_addWithBean:(id)bean;

/**
 *  @name delete rows with idvalue
 */
+ (BOOL)DB_deleteWithIdValue:(id)idValue;
+ (BOOL)DB_deleteWithWhereSQL:(NSDictionary *)whereSQLParam;

/**
 *  update option
 */
+ (BOOL)DB_updateWithBean:(id)bean;
+ (BOOL)DB_updateWithSetupSQL:(NSDictionary *)setupParam andWhereSQL:(NSDictionary *)whereSQLParam;

/**
 *  find bean by giving id value
 */
+ (id)DB_findWithIdValue:(id)idValue;
+ (id)DB_findWithWhereSQL:(NSDictionary *)whereSQLParam;
+ (NSMutableArray *)DB_queryWithWhereSQL:(NSDictionary *)whereSQLParam andOrderby:(NSDictionary *)orderby;

/**
 *  check exist
 */
+ (BOOL)DB_isExistWithWhereSQL:(NSDictionary *)whereSQLParam;
+ (BOOL)DB_isEmpty:(NSDictionary *)whereSQLParam;

@end
