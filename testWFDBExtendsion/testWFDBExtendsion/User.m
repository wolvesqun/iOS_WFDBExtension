//
//  User.m
//  testWFDBExtendsion
//
//  Created by mba on 15/1/19.
//  Copyright © 2015年 ubmlib. All rights reserved.
//

#import "User.h"

@implementation User

- (NSString *)description
{
    return [NSString stringWithFormat:@"username = %@, password = %@, year = %d", self.username, self.password, (int)self.year];
}

@end
