//
//  User.h
//  testWFDBExtendsion
//
//  Created by mba on 16/1/19.
//  Copyright © 2016年 ubmlib. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BaseUser.h"


/**
 *  在 WFDbExeension.plist 注明主键为username， 当前类的的key为User, 并且对应的表名也为User
 */
@interface User : NSObject

@property (strong, nonatomic) NSString *username;

@property (strong, nonatomic) NSMutableString *password;

@property (assign, nonatomic) NSInteger year;

@end
