//
//  NSObject+WFDatabase.m
//  Wiki
//
//  Created by mba on 16/1/15.
//  Copyright © 2016年 ubmlib. All rights reserved.
//

#import "NSObject+WFDatabase.h"
#import "WFIvar.h"
#import "WFDatabaseHelper.h"
#import "WFType.h"
#import "WFDBExtensioinConst.h"
#import "WFFoundation.h"


@implementation NSObject (WFDatabase)

#pragma mark - 增删改查
+ (BOOL)DB_addWithBean:(id)bean
{
    BOOL rs = NO;
    NSString *tablename = [self getClassName];
    if(tablename && [self hasProperty])
    {
        
        NSMutableString *propertysStr = [NSMutableString stringWithString:@"("];
        NSMutableString *valuesCode = [NSMutableString stringWithString:@"("];
        
        NSMutableArray *valueArray = [NSMutableArray array];
        
        WFDbExtensionIdConfigBean *configBean = [self getConfigBean];
        [self enumerateIvarsWithBlockByWF:^(WFIvar *ivar)
         {
             if(ivar.type.typeClass && [WFFoundation ignoreFoundationClass:ivar.type.typeClass]) return;
             
             if(ivar.type.isKVCDisabled || configBean.autoContentAccessingProxy ) return;
             
             id propertyValue = [bean valueForKey:ivar.propertyName];
             
             if(propertyValue == nil || propertysStr == [NSNull class]) return;
             
             [propertysStr appendFormat:@" %@,", ivar.propertyName];
             [valuesCode appendString:@" ?,"];
             
             [valueArray addObject:propertyValue];
             
         }];
        [propertysStr deleteCharactersInRange:NSMakeRange(propertysStr.length - 1, 1)];
        [propertysStr appendString:@")"];
        
        [valuesCode deleteCharactersInRange:NSMakeRange(valuesCode.length - 1, 1)];
        [valuesCode appendString:@")"];
        
        NSString *sql = [NSString stringWithFormat:@"insert into %@ %@ values %@", tablename, propertysStr, valuesCode];
        
        FMDatabase *database = [WFDatabaseHelper getDataBase];
        rs = [database executeUpdate:sql withArgumentsInArray:valueArray];
        [database commit];
    }
    
    return rs;
}

+ (BOOL)DB_deleteWithKey:(NSString *)key
{
    BOOL rs = NO;
    WFDbExtensionIdConfigBean *configBean = [self getConfigBean];
    if(configBean && configBean.primarykey) rs = [self DB_deleteWithWhereSQL:@{[NSString stringWithFormat:@"%@ = ?", configBean.primarykey] : key}];
    return rs;
}

+ (BOOL)DB_deleteWithWhereSQL:(NSDictionary *)whereSQLParam
{
    BOOL rs = NO;
    NSString *tablename = [self getClassName];
    if(tablename && whereSQLParam)
    {
        NSString *whereSQLString = [self buildWhereSQL:whereSQLParam.allKeys];
        NSArray *valueArray = [self buildWhereSQLValueArray:whereSQLParam];
        
        NSString *sql = [NSString stringWithFormat:@"delete from %@ %@", tablename, whereSQLString];
        FMDatabase *database = [WFDatabaseHelper getDataBase];
        rs = [database executeUpdate:sql withArgumentsInArray:valueArray];
        [database commit];
    }
    return rs;
}

+ (BOOL)DB_updateWithBean:(id)bean
{
    BOOL rs = NO;
    NSString *tablename = [self  getClassName];
    WFDbExtensionIdConfigBean *configBean = [self getConfigBean];
    if(bean && tablename && configBean.primarykey)
    {
        NSMutableString *propertysStr = [NSMutableString string];

        NSMutableArray *valueArray = [NSMutableArray array];
        
        [self enumerateIvarsWithBlockByWF:^(WFIvar *ivar)
         {
             if(ivar.type.typeClass && [WFFoundation ignoreFoundationClass:ivar.type.typeClass]) return;
             
             id propertyvalue = [bean valueForKey:ivar.propertyName];
             if(propertyvalue && ![configBean.primarykey isEqualToString:ivar.propertyName]) // 不是主键
             {
                 [propertysStr appendFormat:@" %@ = ?,", ivar.propertyName];
                 [valueArray addObject:propertyvalue];
             }
         }];
        [propertysStr deleteCharactersInRange:NSMakeRange(propertysStr.length - 1, 1)];
        [valueArray addObject:[bean valueForKey:configBean.primarykey]];
        
        NSString *sql = [NSString stringWithFormat:@"update %@ set %@ where %@ = ?", tablename, propertysStr, configBean.primarykey];
        FMDatabase *database = [WFDatabaseHelper getDataBase];
        rs = [database executeUpdate:sql withArgumentsInArray:valueArray];
        [database commit];
    }
    
    return rs;
}

+ (BOOL)DB_updateWithSetupSQL:(NSDictionary *)setupSQL andWhereSQL:(NSDictionary *)whereSQL
{
    BOOL rs = NO;
    NSString *tablename = [self  getClassName];
    if(setupSQL && setupSQL.count > 0 && whereSQL && whereSQL.count > 0 && tablename)
    {
        NSArray *setupValueArray = [self buildWhereSQLValueArray:setupSQL];
        NSArray *whereValueArray = [self buildWhereSQLValueArray:whereSQL];
        NSMutableArray *valueArray = [NSMutableArray arrayWithArray:setupValueArray];
        [valueArray addObjectsFromArray:whereValueArray];
      
        NSString *sql = [NSString stringWithFormat:@"update %@ set %@ where %@", tablename, [self buildSetupSQL:setupSQL.allKeys], [self buildWhereSQL:whereSQL.allKeys]];
        FMDatabase *database = [WFDatabaseHelper getDataBase];
        rs = [database executeUpdate:sql withArgumentsInArray:valueArray];
        [database commit];
    }
    
    return rs;
}

+ (NSMutableArray *)DB_queryWithWhereSQL:(NSDictionary *)whereSQLParam
{
    NSMutableArray *dataArray = nil;
    NSString *tablename = [self getClassName];
    if(tablename)
    {
        NSString *sql = [NSString stringWithFormat:@"select * from %@ %@", tablename, [self buildWhereSQL:whereSQLParam.allKeys]];
        NSArray *valueArray = [self buildWhereSQLValueArray:whereSQLParam];
        FMDatabase *database = [WFDatabaseHelper getDataBase];
        FMResultSet *rsSet = [database executeQuery:sql withArgumentsInArray:valueArray];
        while ([rsSet next])
        {
            if(dataArray == nil)
            {
                dataArray = [NSMutableArray array];
            }
            [dataArray addObject:[self beanWithResultSet:rsSet]];
        }
        [rsSet close];
    }
    return dataArray;
}

+ (id)DB_findWithKey:(NSString *)key
{
    id bean = nil;
    WFDbExtensionIdConfigBean *configBean = [self getConfigBean];
    if(configBean.primarykey) bean = [self DB_findWithWhereSQL:@{[NSString stringWithFormat:@"%@ = ?", configBean.primarykey] : key}];
    return bean;
}

+ (id)DB_findWithWhereSQL:(NSDictionary *)whereSQLParam
{
    id bean = nil;
    NSString *tablename = [self getClassName];
    if(tablename && whereSQLParam)
    {
        NSString *sql = [NSString stringWithFormat:@"select * from %@ %@", tablename, [self buildWhereSQL:whereSQLParam.allKeys]];
        NSArray *valueArray = [self buildWhereSQLValueArray:whereSQLParam];
        FMDatabase *database = [WFDatabaseHelper getDataBase];
        FMResultSet *rsSet = [database executeQuery:sql withArgumentsInArray:valueArray];
        if([rsSet next])
        {
           bean = [self beanWithResultSet:rsSet];
        }
        
        [rsSet close];
    }
    return bean;
}

+ (BOOL)DB_isExistWithKey:(NSString *)key
{
    BOOL rs = NO;
    WFDbExtensionIdConfigBean *configbean = [self getConfigBean];
    if(configbean.primarykey)
    {
        rs = [self DB_isExistWithWhereSQL:@{[NSString stringWithFormat:@"%@ = ?", configbean.primarykey] : key}];
    }
    return rs;
}

+ (BOOL)DB_isExistWithWhereSQL:(NSDictionary *)whereSQLParam
{
    return ![self DB_isEmpty:whereSQLParam];
}

+ (BOOL)DB_isEmpty:(NSDictionary *)whereSQLParam
{
    BOOL rs = NO;
    NSString *tablename = [self getClassName];
    if(tablename)
    {
        NSString *sql = [NSString stringWithFormat:@"select count(*) from %@ %@",tablename, [self buildWhereSQL:whereSQLParam.allKeys]];
        NSArray *valueArray = [self buildWhereSQLValueArray:whereSQLParam];
        FMDatabase *database = [WFDatabaseHelper getDataBase];
        FMResultSet *rsSet = [database executeQuery:sql withArgumentsInArray:valueArray];
        if([rsSet next])
        {
            rs = [rsSet intForColumnIndex:0] == 0;
        }
        [rsSet close];
    }
    
    return rs;
}

// - 构建 查询条件
+ (NSString *)buildWhereSQL:(NSArray *)whereSQLParamArray
{
    NSMutableString *whereSQLString = [NSMutableString stringWithString:@" where 1 = 1"];
    for (NSString *whereSQL in whereSQLParamArray) {
        [whereSQLString appendFormat:@" and %@", whereSQL];
    }
    return whereSQLString;
}
+ (NSString *)buildSetupSQL:(NSArray *)setupSQLArray
{
    NSMutableString *whereSQLString = [NSMutableString stringWithString:@" where 1 = 1"];
    for (NSString *whereSQL in setupSQLArray) {
        [whereSQLString appendFormat:@" %@ = ?,", whereSQL];
    }
    [whereSQLString substringToIndex:whereSQLString.length - 1];
    return whereSQLString;
}
// - 构建 查询条件的参数
+ (NSArray *)buildWhereSQLValueArray:(NSDictionary *)whereSQLParamDict
{
    NSMutableArray *valueArray = [NSMutableArray arrayWithCapacity:whereSQLParamDict.count];
    for (NSString *key in whereSQLParamDict.allKeys)
    {
        NSString *value = [whereSQLParamDict objectForKey:key];
        [valueArray addObject:value];
    }
    return valueArray;
}

/**
 *  获取类名 -》对应数据库表名
 */
+ (NSString *)getClassName
{
    static const char kWFCacheClassname;
    
    NSString *classname = objc_getAssociatedObject(self, &kWFCacheClassname);
    if(classname == nil)
    {
        classname =  [NSString stringWithUTF8String:object_getClassName([self class])] ;
        objc_setAssociatedObject(self, &kWFCacheClassname, classname, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    return classname;
}

+ (BOOL)hasProperty
{
    unsigned int outCount;
    free(class_copyPropertyList([self class], &outCount));
    return outCount > 0;
}

+ (BOOL)isFoundationStringClass:(WFIvar *)ivar
{
    if(ivar.type.typeClass && ivar.type.typeClass == [NSString class])
    {
        return YES;
    }
    return NO;
}

+ (id)beanWithResultSet:(FMResultSet *)rSet
{
    id bean = [[self alloc] init];
    [self enumerateIvarsWithBlockByWF:^(WFIvar *ivar)
     {
         if(ivar.type.typeClass && [WFFoundation ignoreFoundationClass:ivar.type.typeClass]) return;
         
         id value = nil;
         if([ivar.type.typeClass isSubclassOfClass:[NSData class]])
         {
             value = [rSet dataForColumn:ivar.propertyName];
         }
         else if (ivar.type.typeClass == nil) // 基础数据类型
         {
             value = [rSet stringForColumn:ivar.propertyName];
         }
         else if([ivar.type.typeClass isSubclassOfClass:[NSString class]])
         {
             value = [rSet stringForColumn:ivar.propertyName];
         }
         
         if(value)
         {
             [bean setValue:value forKey:ivar.propertyName];
         }

     }];
    
    return bean;
}

+ (void)enumerateIvarsWithBlockByWF:(void(^)(WFIvar *ivar))block
{
    if(!block) return;
    
    static const char kWFCacheIvars;
    
    NSMutableArray *cachedIvarArray = objc_getAssociatedObject(self, &kWFCacheIvars);
    if(cachedIvarArray == nil)
    {
        cachedIvarArray = [NSMutableArray array];
        
        [self enumerateClassesWithBlockByWF:^(__unsafe_unretained Class clazz, BOOL *stop)
         {
             // 1.获得所有的成员变量
             unsigned int outCount = 0;
             Ivar *ivars = class_copyIvarList(clazz, &outCount);
             
             // 2.遍历每一个成员变量
             for (unsigned int i = 0; i<outCount; i++) {
                 WFIvar *bean = [WFIvar beanWithIvar:ivars[i]];
                 bean.srcClass = clazz;
                 
                 [cachedIvarArray addObject:bean];
             }
             
             // 3.释放内存
             free(ivars);
         }];
        
        objc_setAssociatedObject(self, &kWFCacheIvars, cachedIvarArray, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    
    for (WFIvar *bean in cachedIvarArray) {
        block(bean);
    }
    
}

+ (void)enumerateClassesWithBlockByWF:(void(^)(Class clazz, BOOL *stop))block
{
    // 1.没有block就直接返回
    if (block == nil) return;
    
    // 2.停止遍历的标记
    BOOL stop = NO;
    
    // 3.当前正在遍历的类
    Class c = self;
    
    // 4.开始遍历每一个类
    while (c && !stop) {
        // 4.1.执行操作
        block(c, &stop);
        
        // 4.2.获得父类
        c = class_getSuperclass(c);
        
        if ([WFFoundation isClassFromFoundation:c]) break;
    }
}

+ (WFDbExtensionIdConfigBean *)getConfigBean
{
    NSString *tbname = [self getClassName];
    return [WFDBExtensioinConst getConfigBeanWithTbname:tbname];
}



@end
