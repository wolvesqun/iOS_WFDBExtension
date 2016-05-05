//
//  WFDatabaseHelper.m
//  BaiduWiki
//
//  Created by PC on 11/10/15.
//  Copyright © 2015 mplib. All rights reserved.
//

#import "WFDatabaseHelper.h"

@implementation WFDatabaseHelper

/*** 数据库当前版本号 ***/
static const NSInteger  kWFdatabaseCurrentVersionCount = 0;

static FMDatabase *db = nil;
+ (FMDatabase *)getDataBase
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if(db == nil)
        {
            //目标路径
            NSString *docPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)objectAtIndex:0];
            NSString *sqlFilePath = [docPath stringByAppendingPathComponent:@"mysqlite.sqlite"];
            
            db = [FMDatabase databaseWithPath:sqlFilePath];
            [db open];
        }
    });
    return db;
}

+ (void)updateDatabase
{
    [self updateDB1];
}


+ (void)updateDB1
{
    if (![self tableExists:@"User"]) {
        [self executeUpdate:@"CREATE TABLE User (username text NOT NULL PRIMARY KEY,password text NOT NULL,year text NOT NULL)"];
    }
}


+ (BOOL)tableExists:(NSString *)tableName
{
    BOOL rs = NO;
    FMDatabase *db = [self getDataBase];
    FMResultSet *resultSet = [db executeQuery:@"select [sql] from sqlite_master where [type] = 'table' and lower(name) = ?", tableName];
    rs = [resultSet next];
    [resultSet close];
    
    return rs;
}

// -
+ (BOOL)executeUpdate:(NSString *)sql
{
    BOOL rs = NO;
    FMDatabase *db = [self getDataBase];
    [db beginTransaction];
    rs = [db executeUpdate:sql];
    [db commit];
    return rs;
}

@end
