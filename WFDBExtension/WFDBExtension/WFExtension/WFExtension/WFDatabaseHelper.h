//
//  WFDatabaseHelper.h
//  BaiduWiki
//
//  Created by PC on 11/10/15.
//  Copyright © 2015 mplib. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FMDatabase.h"

@interface WFDatabaseHelper : NSObject

+ (FMDatabase *)getDataBase;

+ (void)updateDatabase;

@end
