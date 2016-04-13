//
//  WFEncryptionHelper.m
//  WFUtils
//
//  Created by PC on 4/4/16.
//  Copyright © 2016 ibmlib. All rights reserved.
//

#import "WFEncryptionHelper.h"
#import <CommonCrypto/CommonDigest.h>
#import <CommonCrypto/CommonCryptor.h>

@implementation WFEncryptionHelper

#pragma mark - md5加密
+ (NSString *)MD5_Encrypt:(NSString *)key
{
    const char * cStrValue = [key UTF8String];
    unsigned char theResult[CC_MD5_DIGEST_LENGTH];
    CC_MD5(cStrValue, (uint32_t)strlen(cStrValue), theResult);
    return [NSString stringWithFormat:@"%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X",
            theResult[0], theResult[1], theResult[2], theResult[3],
            theResult[4], theResult[5], theResult[6], theResult[7],
            theResult[8], theResult[9], theResult[10], theResult[11],
            theResult[12], theResult[13], theResult[14], theResult[15]];
}

#pragma mark - AES
+ (NSData *)AES256_EncryptStringWithString:(NSString*)strSource andKey:(NSString*)key {
    NSData *dataSource = [strSource dataUsingEncoding:NSUTF8StringEncoding];
    return [self AES256_EncryptDataWithData:dataSource andKey:[WFEncryptionHelper MD5_Encrypt:key]];
}

+ (NSString *)AES256_DecryptStringWithData:(NSData*)dataSource andKey:(NSString*)key {
    NSData *decryptData = [self AES256_DecryptDataWithData:dataSource
                                                    andKey:[WFEncryptionHelper MD5_Encrypt:key]];
    return [[NSString alloc] initWithData:decryptData encoding:NSUTF8StringEncoding];
}

// -
+ (NSData *)AES256_EncryptDataWithData:(NSData *)data andKey:(NSString*)key {
    
    char keyPtr[kCCKeySizeAES256 + 1]; // room for terminator (unused)
    bzero(keyPtr, sizeof(keyPtr)); // fill with zeroes (for padding)
    
    [key getCString:keyPtr maxLength:sizeof(keyPtr) encoding:NSUTF8StringEncoding];
    
    NSUInteger dataLength = [data length];
    
    size_t bufferSize           = dataLength + kCCBlockSizeAES128;
    void* buffer                = malloc(bufferSize);
    
    size_t numBytesEncrypted    = 0;
    CCCryptorStatus cryptStatus = CCCrypt(kCCEncrypt, kCCAlgorithmAES128, kCCOptionPKCS7Padding,
                                          keyPtr, kCCKeySizeAES256,
                                          NULL /* initialization vector (optional) */,
                                          [data bytes], dataLength, /* input */
                                          buffer, bufferSize, /* output */
                                          &numBytesEncrypted);
    
    if (cryptStatus == kCCSuccess) {
        return [NSData dataWithBytesNoCopy:buffer length:numBytesEncrypted];
    }
    
    free(buffer);
    return nil;
}

// -
+ (NSData *)AES256_DecryptDataWithData:(NSData *)data andKey:(NSString*)key {
    
    char keyPtr[kCCKeySizeAES256 + 1]; // room for terminator (unused)
    bzero(keyPtr, sizeof(keyPtr)); // fill with zeroes (for padding)
    
    // fetch key data
    [key getCString:keyPtr maxLength:sizeof(keyPtr) encoding:NSUTF8StringEncoding];
    
    NSUInteger dataLength = [data length];
    
    size_t bufferSize           = dataLength + kCCBlockSizeAES128;
    void* buffer                = malloc(bufferSize);
    
    size_t numBytesDecrypted    = 0;
    CCCryptorStatus cryptStatus = CCCrypt(kCCDecrypt, kCCAlgorithmAES128, kCCOptionPKCS7Padding,
                                          keyPtr, kCCKeySizeAES256,
                                          NULL /* initialization vector (optional) */,
                                          [data bytes], dataLength, /* input */
                                          buffer, bufferSize, /* output */
                                          &numBytesDecrypted);
    
    if (cryptStatus == kCCSuccess) {
        return [NSData dataWithBytesNoCopy:buffer length:numBytesDecrypted];
    }
    
    free(buffer); //free the buffer;
    return nil;
}


#pragma mark - DES
/**
 *  采用des加密字符串, key内部md5加密过
 *  @param strSource 要加密的字符串
 *  @param key
 *
 *  @return 返回加密过后的NSData数据
 */
+ (NSData *)DES_EncryptStringWithString:(NSString *)strSource andKey:(NSString *)key
{
    NSData *data = [strSource dataUsingEncoding:NSUTF8StringEncoding];
    return [self DES_EncryptDataWithData:data andKey:[self MD5_Encrypt:key]];
}
+ (NSString *)DES_DecryptStringWithData:(NSData *)dataSource andKey:(NSString *)key
{
    NSData *data = [self DES_DecryptDataWithData:dataSource andKey:[self MD5_Encrypt:key]];
    return [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
}


+ (NSData *)DES_EncryptDataWithData:(NSData *)data andKey:(NSString *)key
{
    
    char keyPtr[kCCKeySizeAES256+1];
    bzero(keyPtr, sizeof(keyPtr));
    
    [key getCString:keyPtr maxLength:sizeof(keyPtr) encoding:NSUTF8StringEncoding];
    
    NSUInteger dataLength = [data length];
    
    size_t bufferSize = dataLength + kCCBlockSizeAES128;
    void *buffer = malloc(bufferSize);
    
    size_t numBytesEncrypted = 0;
    CCCryptorStatus cryptStatus = CCCrypt(kCCEncrypt, kCCAlgorithmDES,
                                          kCCOptionPKCS7Padding | kCCOptionECBMode,
                                          keyPtr, kCCBlockSizeDES,
                                          NULL,
                                          [data bytes], dataLength,
                                          buffer, bufferSize,
                                          &numBytesEncrypted);
    if (cryptStatus == kCCSuccess) {
        return [NSData dataWithBytesNoCopy:buffer length:numBytesEncrypted];
    }
    
    free(buffer);
    return nil;
}

+ (NSData *)DES_DecryptDataWithData:(NSData *)data andKey:(NSString *)key
{
    char keyPtr[kCCKeySizeAES256+1];
    bzero(keyPtr, sizeof(keyPtr));
    
    [key getCString:keyPtr maxLength:sizeof(keyPtr) encoding:NSUTF8StringEncoding];
    
    NSUInteger dataLength = [data length];
    
    size_t bufferSize = dataLength + kCCBlockSizeAES128;
    void *buffer = malloc(bufferSize);
    
    size_t numBytesDecrypted = 0;
    CCCryptorStatus cryptStatus = CCCrypt(kCCDecrypt, kCCAlgorithmDES,
                                          kCCOptionPKCS7Padding | kCCOptionECBMode,
                                          keyPtr, kCCBlockSizeDES,
                                          NULL,
                                          [data bytes], dataLength,
                                          buffer, bufferSize,
                                          &numBytesDecrypted);
    
    if (cryptStatus == kCCSuccess) {
        return [NSData dataWithBytesNoCopy:buffer length:numBytesDecrypted];
    }
    
    free(buffer);
    return nil;
}


@end
