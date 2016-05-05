//
//  WFClassInfo.m
//  testWFDBExtendsion
//
//  Created by PC on 4/30/16.
//  Copyright © 2016 ubmlib. All rights reserved.
//

#import "WFClassInfo.h"

#define force_inline __inline__ __attribute__((always_inline))

WFEncodingType WFEncodingGetType(const char *typeEncoding) {
    char *type = (char *)typeEncoding;
    if (!type) return WFEncodingTypeUnknown;
    size_t len = strlen(type);
    if (len == 0) return WFEncodingTypeUnknown;
    
    WFEncodingType qualifier = 0;
    bool prefix = true;
    while (prefix) {
        switch (*type) {
            case 'r': {
                qualifier |= WFEncodingTypeQualifierConst;
                type++;
            } break;
            case 'n': {
                qualifier |= WFEncodingTypeQualifierIn;
                type++;
            } break;
            case 'N': {
                qualifier |= WFEncodingTypeQualifierInout;
                type++;
            } break;
            case 'o': {
                qualifier |= WFEncodingTypeQualifierOut;
                type++;
            } break;
            case 'O': {
                qualifier |= WFEncodingTypeQualifierBycopy;
                type++;
            } break;
            case 'R': {
                qualifier |= WFEncodingTypeQualifierByref;
                type++;
            } break;
            case 'V': {
                qualifier |= WFEncodingTypeQualifierOneway;
                type++;
            } break;
            default: { prefix = false; } break;
        }
    }
    
    len = strlen(type);
    if (len == 0) return WFEncodingTypeUnknown | qualifier;
    
    switch (*type) {
        case 'v': return WFEncodingTypeVoid | qualifier;
        case 'B': return WFEncodingTypeBool | qualifier;
        case 'c': return WFEncodingTypeInt8 | qualifier;
        case 'C': return WFEncodingTypeUInt8 | qualifier;
        case 's': return WFEncodingTypeInt16 | qualifier;
        case 'S': return WFEncodingTypeUInt16 | qualifier;
        case 'i': return WFEncodingTypeInt32 | qualifier;
        case 'I': return WFEncodingTypeUInt32 | qualifier;
        case 'l': return WFEncodingTypeInt32 | qualifier;
        case 'L': return WFEncodingTypeUInt32 | qualifier;
        case 'q': return WFEncodingTypeInt64 | qualifier;
        case 'Q': return WFEncodingTypeUInt64 | qualifier;
        case 'f': return WFEncodingTypeFloat | qualifier;
        case 'd': return WFEncodingTypeDouble | qualifier;
        case 'D': return WFEncodingTypeLongDouble | qualifier;
        case '#': return WFEncodingTypeClass | qualifier;
        case ':': return WFEncodingTypeSEL | qualifier;
        case '*': return WFEncodingTypeCString | qualifier;
        case '^': return WFEncodingTypePointer | qualifier;
        case '[': return WFEncodingTypeCArray | qualifier;
        case '(': return WFEncodingTypeUnion | qualifier;
        case '{': return WFEncodingTypeStruct | qualifier;
        case '@': {
            if (len == 2 && *(type + 1) == '?')
                return WFEncodingTypeBlock | qualifier;
            else
                return WFEncodingTypeObject | qualifier;
        }
        default: return WFEncodingTypeUnknown | qualifier;
    }
}



/// Get the Foundation class type from property info.
WFEncodingNSType WFClassGetNSType(Class cls) {
    if (!cls) return WFEncodingTypeNSUnknown;
    if ([cls isSubclassOfClass:[NSMutableString class]]) return WFEncodingTypeNSMutableString;
    if ([cls isSubclassOfClass:[NSString class]]) return WFEncodingTypeNSString;
    if ([cls isSubclassOfClass:[NSDecimalNumber class]]) return WFEncodingTypeNSDecimalNumber;
    if ([cls isSubclassOfClass:[NSNumber class]]) return WFEncodingTypeNSNumber;
    if ([cls isSubclassOfClass:[NSValue class]]) return WFEncodingTypeNSValue;
    if ([cls isSubclassOfClass:[NSMutableData class]]) return WFEncodingTypeNSMutableData;
    if ([cls isSubclassOfClass:[NSData class]]) return WFEncodingTypeNSData;
    if ([cls isSubclassOfClass:[NSDate class]]) return WFEncodingTypeNSDate;
    if ([cls isSubclassOfClass:[NSURL class]]) return WFEncodingTypeNSURL;
    if ([cls isSubclassOfClass:[NSMutableArray class]]) return WFEncodingTypeNSMutableArray;
    if ([cls isSubclassOfClass:[NSArray class]]) return WFEncodingTypeNSArray;
    if ([cls isSubclassOfClass:[NSMutableDictionary class]]) return WFEncodingTypeNSMutableDictionary;
    if ([cls isSubclassOfClass:[NSDictionary class]]) return WFEncodingTypeNSDictionary;
    if ([cls isSubclassOfClass:[NSMutableSet class]]) return WFEncodingTypeNSMutableSet;
    if ([cls isSubclassOfClass:[NSSet class]]) return WFEncodingTypeNSSet;
    return WFEncodingTypeNSUnknown;
}

/// Whether the type is c number.
BOOL WFEncodingTypeIsCNumber(WFEncodingType type) {
    switch (type & WFEncodingTypeMask) {
        case WFEncodingTypeBool:
        case WFEncodingTypeInt8:
        case WFEncodingTypeUInt8:
        case WFEncodingTypeInt16:
        case WFEncodingTypeUInt16:
        case WFEncodingTypeInt32:
        case WFEncodingTypeUInt32:
        case WFEncodingTypeInt64:
        case WFEncodingTypeUInt64:
        case WFEncodingTypeFloat:
        case WFEncodingTypeDouble:
        case WFEncodingTypeLongDouble: return YES;
        default: return NO;
    }
}

NSDate *WFNSDateFromString(__unsafe_unretained NSString *string) {
    typedef NSDate* (^YYNSDateParseBlock)(NSString *string);
#define kParserNum 34
    static YYNSDateParseBlock blocks[kParserNum + 1] = {0};
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        {
            /*
             2014-01-20  // Google
             */
            NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
            formatter.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"];
            formatter.timeZone = [NSTimeZone timeZoneForSecondsFromGMT:0];
            formatter.dateFormat = @"yyyy-MM-dd";
            blocks[10] = ^(NSString *string) { return [formatter dateFromString:string]; };
        }
        
        {
            /*
             2014-01-20 12:24:48
             2014-01-20T12:24:48   // Google
             2014-01-20 12:24:48.000
             2014-01-20T12:24:48.000
             */
            NSDateFormatter *formatter1 = [[NSDateFormatter alloc] init];
            formatter1.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"];
            formatter1.timeZone = [NSTimeZone timeZoneForSecondsFromGMT:0];
            formatter1.dateFormat = @"yyyy-MM-dd'T'HH:mm:ss";
            
            NSDateFormatter *formatter2 = [[NSDateFormatter alloc] init];
            formatter2.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"];
            formatter2.timeZone = [NSTimeZone timeZoneForSecondsFromGMT:0];
            formatter2.dateFormat = @"yyyy-MM-dd HH:mm:ss";
            
            NSDateFormatter *formatter3 = [[NSDateFormatter alloc] init];
            formatter3.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"];
            formatter3.timeZone = [NSTimeZone timeZoneForSecondsFromGMT:0];
            formatter3.dateFormat = @"yyyy-MM-dd'T'HH:mm:ss.SSS";
            
            NSDateFormatter *formatter4 = [[NSDateFormatter alloc] init];
            formatter4.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"];
            formatter4.timeZone = [NSTimeZone timeZoneForSecondsFromGMT:0];
            formatter4.dateFormat = @"yyyy-MM-dd HH:mm:ss.SSS";
            
            blocks[19] = ^(NSString *string) {
                if ([string characterAtIndex:10] == 'T') {
                    return [formatter1 dateFromString:string];
                } else {
                    return [formatter2 dateFromString:string];
                }
            };
            
            blocks[23] = ^(NSString *string) {
                if ([string characterAtIndex:10] == 'T') {
                    return [formatter3 dateFromString:string];
                } else {
                    return [formatter4 dateFromString:string];
                }
            };
        }
        
        {
            /*
             2014-01-20T12:24:48Z        // Github, Apple
             2014-01-20T12:24:48+0800    // Facebook
             2014-01-20T12:24:48+12:00   // Google
             2014-01-20T12:24:48.000Z
             2014-01-20T12:24:48.000+0800
             2014-01-20T12:24:48.000+12:00
             */
            NSDateFormatter *formatter = [NSDateFormatter new];
            formatter.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"];
            formatter.dateFormat = @"yyyy-MM-dd'T'HH:mm:ssZ";
            
            NSDateFormatter *formatter2 = [NSDateFormatter new];
            formatter2.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"];
            formatter2.dateFormat = @"yyyy-MM-dd'T'HH:mm:ss.SSSZ";
            
            blocks[20] = ^(NSString *string) { return [formatter dateFromString:string]; };
            blocks[24] = ^(NSString *string) { return [formatter dateFromString:string]?: [formatter2 dateFromString:string]; };
            blocks[25] = ^(NSString *string) { return [formatter dateFromString:string]; };
            blocks[28] = ^(NSString *string) { return [formatter2 dateFromString:string]; };
            blocks[29] = ^(NSString *string) { return [formatter2 dateFromString:string]; };
        }
        
        {
            /*
             Fri Sep 04 00:12:21 +0800 2015 // Weibo, Twitter
             Fri Sep 04 00:12:21.000 +0800 2015
             */
            NSDateFormatter *formatter = [NSDateFormatter new];
            formatter.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"];
            formatter.dateFormat = @"EEE MMM dd HH:mm:ss Z yyyy";
            
            NSDateFormatter *formatter2 = [NSDateFormatter new];
            formatter2.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"];
            formatter2.dateFormat = @"EEE MMM dd HH:mm:ss.SSS Z yyyy";
            
            blocks[30] = ^(NSString *string) { return [formatter dateFromString:string]; };
            blocks[34] = ^(NSString *string) { return [formatter2 dateFromString:string]; };
        }
    });
    if (!string) return nil;
    if (string.length > kParserNum) return nil;
    YYNSDateParseBlock parser = blocks[string.length];
    if (!parser) return nil;
    return parser(string);
#undef kParserNum
}


/// Parse a number value from 'id'.
NSNumber *WFCreateNSNumberFromID(__unsafe_unretained id value) {
    static NSCharacterSet *dot;
    static NSDictionary *dic;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        dot = [NSCharacterSet characterSetWithRange:NSMakeRange('.', 1)];
        dic = @{@"TRUE" :   @(YES),
                @"True" :   @(YES),
                @"true" :   @(YES),
                @"FALSE" :  @(NO),
                @"False" :  @(NO),
                @"false" :  @(NO),
                @"YES" :    @(YES),
                @"Yes" :    @(YES),
                @"yes" :    @(YES),
                @"NO" :     @(NO),
                @"No" :     @(NO),
                @"no" :     @(NO),
                @"NIL" :    (id)kCFNull,
                @"Nil" :    (id)kCFNull,
                @"nil" :    (id)kCFNull,
                @"NULL" :   (id)kCFNull,
                @"Null" :   (id)kCFNull,
                @"null" :   (id)kCFNull,
                @"(NULL)" : (id)kCFNull,
                @"(Null)" : (id)kCFNull,
                @"(null)" : (id)kCFNull,
                @"<NULL>" : (id)kCFNull,
                @"<Null>" : (id)kCFNull,
                @"<null>" : (id)kCFNull};
    });
    
    if (!value || value == (id)kCFNull) return nil;
    if ([value isKindOfClass:[NSNumber class]]) return value;
    if ([value isKindOfClass:[NSString class]]) {
        NSNumber *num = dic[value];
        if (num) {
            if (num == (id)kCFNull) return nil;
            return num;
        }
        if ([(NSString *)value rangeOfCharacterFromSet:dot].location != NSNotFound) {
            const char *cstring = ((NSString *)value).UTF8String;
            if (!cstring) return nil;
            double num = atof(cstring);
            if (isnan(num) || isinf(num)) return nil;
            return @(num);
        } else {
            const char *cstring = ((NSString *)value).UTF8String;
            if (!cstring) return nil;
            return @(atoll(cstring));
        }
    }
    return nil;
}

@implementation WFClassMethodInfo

- (instancetype)initWithMethod:(Method)method
{
    if(method == nil) return nil;
    if(self = [super init])
    {
        _method = method;
        
    }
    return self;
}

@end

@implementation WFClassPropertyInfo

- (instancetype)initWithPropery:(objc_property_t)property
{
    if(property == nil) return nil;
    if(self = [super init])
    {
        _property = property;
        
        _name = [NSString stringWithUTF8String:property_getName(property)];
        
        WFEncodingType type = 0;
        unsigned count = 0;
        // 
        objc_property_attribute_t *attrList = property_copyAttributeList(property, &count);
        for (unsigned int i = 0; i < count; i ++) {
            switch (attrList[i].name[0]) { // char 类型
                case 'T': {
                    _typeEncoding = [NSString stringWithUTF8String:attrList[i].name];
                    type = WFEncodingGetType(attrList[i].value);
                    if((type & WFEncodingTypeMask) == WFEncodingTypeObject) // @\"NSString\" => 1 + 1 + 8 + 1
                    {
                        size_t len = strlen(attrList[i].value);
                        if(len > 3)
                        {
                            char name[len - 2];
                            name[len - 3] = '\0';
                            memcpy(name, attrList[i].value + 2, len - 3);
//                            NSLog(@"%s", name);
                            _cls = objc_getClass(name);
                        }
                    }
                }break;
                case 'V':{
                    if(attrList[i].value)
                    {
                        _ivarName = [NSString stringWithUTF8String:attrList[i].value];
                    }
                }break;
                case 'R':{
                    type |= WFEncodingTypePropertyReadonly;
                }break;
                case 'C':{
                    type |= WFEncodingTypePropertyCopy;
                }break;
                case '&':{
                    type |= WFEncodingTypePropertyRetain;
                }break;
                case 'N':{
                    type |= WFEncodingTypePropertyNonatomic;
                }break;
                case 'D':{
                    type |= WFEncodingTypePropertyDynamic;
                }break;
                case 'W':{
                    type |= WFEncodingTypePropertyWeak;
                }break;
                case 'G':{
                    type |= WFEncodingTypePropertyCustomGetter;
                    if(attrList[i].value)
                    {
                        _getterSEL = NSSelectorFromString([NSString stringWithUTF8String:attrList[i].value]);
                    }
                }break;
                case 'S':{
                    type |= WFEncodingTypePropertyCustomSetter;
                    if(attrList[i].value)
                    {
                        _setterSEL = NSSelectorFromString([NSString stringWithUTF8String:attrList[i].value]);
                    }
                }break;
                
                    
                default:
                    break;
            }
          
//            NSLog(@"==%@ , name = %s, value = %s",_name, attrList[i].name, attrList[i].value);
        }
        _type = type;
        
        if(_name.length > 0)
        {
            if(_getterSEL == nil)
            {
                _getterSEL = NSSelectorFromString(_name);
            }
            if(_setterSEL == nil)
            {
                _setterSEL = NSSelectorFromString([NSString stringWithFormat:@"set%@%@:",[_name substringToIndex:1].uppercaseString, [_name substringFromIndex:1]]);
            }
        }
        
       
    }
    return self;
}

@end

@implementation WFClassInfo

+ (instancetype)classInfoWithClass:(Class)cls
{
    if(cls == nil) return nil;
    
    static CFMutableDictionaryRef clsCache;
    static CFMutableDictionaryRef metaCache;
    static dispatch_semaphore_t lock;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        clsCache = CFDictionaryCreateMutable(CFAllocatorGetDefault(), 0, &kCFTypeDictionaryKeyCallBacks, &kCFTypeDictionaryValueCallBacks);
        metaCache = CFDictionaryCreateMutable(CFAllocatorGetDefault(), 0, &kCFTypeDictionaryKeyCallBacks, &kCFTypeDictionaryValueCallBacks);
        lock = dispatch_semaphore_create(1);
    });
    
    dispatch_semaphore_wait(lock, DISPATCH_TIME_FOREVER);
    WFClassInfo *classInfo = CFDictionaryGetValue(clsCache, (__bridge const void *)(cls));
    if(classInfo == nil)
    {
        classInfo = [[WFClassInfo alloc] initWithClass:cls];
        if(classInfo) CFDictionarySetValue(clsCache, (__bridge const void *)(cls), (__bridge const void *)(classInfo));

    }
    dispatch_semaphore_signal(lock);
    
    return classInfo;
}

- (instancetype)initWithClass:(Class)cls
{
    if(cls == nil) return nil;
    if(self = [super init])
    {
        _cls = cls;
        _classname = [NSString stringWithUTF8String:class_getName(cls)];
        _superClass = class_getSuperclass(cls);
        
        [self updateClassInfo];
    }
    return self;
}

- (void)updateClassInfo
{
    unsigned int count = 0;
    
    //
    objc_property_t *properties = class_copyPropertyList(self.cls, &count);
    if(properties && count > 0)
    {
        _propertyInfos = [NSMutableDictionary dictionary];
        for (unsigned int i = 0; i < count; i ++) {
            WFClassPropertyInfo *classInfo = [[WFClassPropertyInfo alloc] initWithPropery:properties[i]];
            if(classInfo && classInfo.name) {
                [_propertyInfos setObject:classInfo forKey:classInfo.name];
            }
        }
        free(properties);
    }
    
    
}

@end


