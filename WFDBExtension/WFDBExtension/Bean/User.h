//
//  User.h
//  WFDBExtension
//
//  Created by PC on 5/3/16.
//  Copyright © 2016 ibmlib. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NSObject+WFExtensionDataBase.h"

@interface User : NSObject<WFDataBaseDelegate>

@property (copy, nonatomic) NSString *username;
@property (copy, nonatomic) NSString *password;

@property (assign, nonatomic, getter=isMale) BOOL male;

@property (assign, nonatomic) NSInteger age;

@property (copy, nonatomic) void(^(BLock_loginCallback))();

@end
