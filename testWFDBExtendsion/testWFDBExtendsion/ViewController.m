//
//  ViewController.m
//  testWFDBExtendsion
//
//  Created by mba on 15/1/19.
//  Copyright © 2015年 ubmlib. All rights reserved.
//

// code http://code.taobao.org/svn/ios-WFDBExtension/

// 技术交流群 ：148663441

#import "ViewController.h"
#import "User.h"
#import "WFDatabaseHelper.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    NSLog(@"%@", NSHomeDirectory());
    
    // 本框架暂时只支持NSString, NSData 和 基础数据类型int NSInterger float ...
    
    // 1. 建立数据库表 -> 可不使用这个，但一定要创建数据库表
    [WFDatabaseHelper updateDatabase];
    
    
    // 2. 保存数据
//    [self testAdd];
    
    // 3. 判断是否存在
//    [self testIS];
    
    // 4. 查询
    [self testQuery];
    
    // 5. 更新数据
//    [self testUpdate];
    
    // 6. 删除
//    [self testDelete];
    
}

- (void)testAdd
{
    [self myLog:@"######################### 添加操作 ########################"];
    // 2. 创建模型 -》并且在 WFDbExeension.plist 注明主键和是否是自动递增
    User *user = [[User alloc] init];
    user.username = @"u1";
    user.password = @"p1";
    user.year = 10;
    
    // 3. 保存到数据库
    [User DB_addWithBean:user];
}

- (void)testDelete
{
    [self myLog:@"######################### 删除操作 ########################"];
    BOOL rs = [User DB_deleteWithKey:@"u1"];
    if(rs){
        [self myLog:@"删除成功"];
    }else
    {
        [self myLog:@"删除失败"];
    }
}

- (void)testUpdate
{
    [self myLog:@"######################### 更新操作 ########################"];
    // 通过给定主键的value进行查询
    User *bean = [User DB_findWithKey:@"u1"];
    if(bean)
    {
        [self myLog:[NSString stringWithFormat:@"更新前数据 ====== %@", bean]];
        bean.password = @"ppppp";
        bean.year = 33;
        [User DB_updateWithBean:bean];
        
        // *** 通过自定义条件查询
        User *bean2 = [User DB_findWithWhereSQL:@{@"username = ?":@"u1"}];
        [self myLog:[NSString stringWithFormat:@"更新后数据 ====== %@", [bean2 description]]];
    }
    else
    {
        NSLog(@"当前用户不存在，请先添加");
    }
}

- (void)testQuery
{
    [self myLog:@"######################### 查询操作 ########################"];
    // 1. 查询所有
//    NSMutableArray *dataArray = [User DB_queryWithWhereSQL:nil];
//    for (User *bean in dataArray) {
//        [self myLog:bean.description];
//    }
    
    // 2. 查询个体
//    User *bean = [User DB_findWithKey:@"u1"];
    User *bean = [User DB_findWithWhereSQL:@{@"username = ?":@"u1"}];
    if(bean)
    {
        [self myLog:bean.description];
    }
    else
    {
        NSLog(@"没有查询到");
    }
    
}

- (void)testIS
{
    [self myLog:@"######################### 判断操作 ########################"];
    BOOL rs = [User DB_isExistWithKey:@"u1"];
    if(rs)
    {
        [self myLog:@"存在"];
    }
    else
    {
        [self myLog:@"不存在"];
    }
}

- (void)myLog:(NSString *)log
{
    NSLog(@"-------log = > %@", log);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
