//
//  AppDelegate.m
//  WFDBExtension
//
//  Created by PC on 5/2/16.
//  Copyright © 2016 ibmlib. All rights reserved.
//

#import "AppDelegate.h"
#import "User.h"
#import "WFDatabaseHelper.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
    NSLog(@"%@", NSHomeDirectory());
    
    [WFDatabaseHelper updateDatabase];
    
    
//    [self testSave];
//    [self testExist];
    [self testQueryAll];
    
    return YES;
}

- (void)testSave
{
    BOOL isEmpty = [User DB_isEmpty:nil];
    
    User *bean = [User new];
    bean.username = @"u1";
    bean.password = @"p1";
    bean.male = YES;
    bean.age = 18;
    
    [User DB_addWithBean:bean];
}

- (void)testExist
{
    BOOL exist = [User DB_isExistWithWhereSQL:@{@"username = ?":@"u1"}];
}

- (void)testQueryAll
{
//    NSMutableArray *dtArray = [User DB_queryWithWhereSQL:nil andOrderby:nil];
    User *bean = [User DB_findWithWhereSQL:@{@"username = ?":@"u1"}];
}

@end
