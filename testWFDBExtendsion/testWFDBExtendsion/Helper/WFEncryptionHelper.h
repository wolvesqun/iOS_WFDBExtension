//
//  WFEncryptionHelper.h
//  WFUtils
//
//  Created by PC on 4/4/16.
//  Copyright © 2016 ibmlib. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 *  加密解密帮助类
 */
@interface WFEncryptionHelper : NSObject


#pragma mark - MD5加密->不可逆
+ (NSString *)MD5_Encrypt:(NSString *)key;

#pragma mark - AES(非对称加密)
// - 采用AES加密|解密字符串, key内部md5加密过
+ (NSData *)AES256_EncryptStringWithString:(NSString*)strSource andKey:(NSString*)key;
+ (NSString *)AES256_DecryptStringWithData:(NSData*)dataSource andKey:(NSString*)key;

// - 采用AES加密|解密字符串，key内部未加密过
+ (NSData *)AES256_EncryptDataWithData:(NSData *)data andKey:(NSString*)key;
+ (NSData *)AES256_DecryptDataWithData:(NSData *)data andKey:(NSString*)key;


#pragma mark - DES(对称加密)
// - 采用DES加密|解密字符串, key内部md5加密过
+ (NSData *)DES_EncryptStringWithString:(NSString *)strSource andKey:(NSString *)key;
+ (NSString *)DES_DecryptStringWithData:(NSData *)dataSource andKey:(NSString *)key;

// - 采用DES加密|解密字符串，key内部未加密过
+ (NSData *)DES_EncryptDataWithData:(NSData *)data andKey:(NSString *)key;
+ (NSData *)DES_DecryptDataWithData:(NSData *)data andKey:(NSString *)key;

@end
