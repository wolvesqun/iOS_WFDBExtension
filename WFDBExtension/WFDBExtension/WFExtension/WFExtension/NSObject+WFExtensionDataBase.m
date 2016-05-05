//
//  NSObject+WFExtensionDataBase.m
//  WFExtension
//
//  Created by PC on 4/30/16.
//  Copyright © 2016 ibmlib. All rights reserved.
//

#import "NSObject+WFExtensionDataBase.h"
#import "WFClassInfo.h"
#import "FMDatabase.h"
#import "WFDatabaseHelper.h"
#import <objc/message.h>



#pragma mark - @interface ***********
#pragma mark -


/// Get the Foundation class type from property info.
static BOOL WFClassTypeIsInsertObjcType(WFEncodingNSType type) {
    BOOL isValide = NO;
    switch (type & WFEncodingTypeMask) {
        case WFEncodingTypeNSString:
        {
            isValide = YES;
        }break;
        case WFEncodingTypeNSMutableString:
        {
            isValide = YES;
        }break;
        case WFEncodingTypeNSDate: // time
        {
            isValide = YES;
        }break;
        case WFEncodingTypeNSData:
        {
            isValide = YES;
        }break;
        case WFEncodingTypeNSMutableData:{
            isValide = YES;
        }break;
        case WFEncodingTypeNSNumber:
        {
            isValide = YES;
        }break;
            
        default:
            break;
    }
    return isValide;
}


@interface WF_DBMetaClassProperyInfo : NSObject
{
    @package
    NSString            *_name;
    WFEncodingType      _encodingType;   // property type
    WFEncodingNSType    _nsType;         // object - c type
    WFClassPropertyInfo *_propertyInfo;    //
    
    BOOL _isCNumber;
    BOOL _isStructAvailableForKeyedArchiver;
    BOOL _isKVCCompatible;
    
    Class _cls;
    Class _superClass;
    Class _genericCls;
    
    SEL _getter;
    SEL _setter;
}

@end


@interface WF_DBMetaClassInfo : NSObject

@property (strong, nonatomic, readonly) WFClassInfo *classInfo;
@property (strong, nonatomic, readonly) NSArray     *allProperyArray; // WF_DBMetaClassProperyInfo


@end

#pragma mark - implementation ***********


@implementation WF_DBMetaClassProperyInfo

+ (instancetype)metaWithProperyInfo:(WFClassInfo *)clsInfo andPropertyInfo:(WFClassPropertyInfo *)propertyInfo generic:(Class)genericCls
{
    WF_DBMetaClassProperyInfo *metaProperty = [WF_DBMetaClassProperyInfo new];
    metaProperty->_name = propertyInfo.name;
    metaProperty->_encodingType = propertyInfo.type;
    metaProperty->_propertyInfo = propertyInfo;
    metaProperty->_genericCls = genericCls;
    
    if((metaProperty->_encodingType & WFEncodingTypeMask) == WFEncodingTypeObject)
    {
        metaProperty->_nsType = WFClassGetNSType(propertyInfo.cls);
    }
    else
    {
        metaProperty->_isCNumber = WFEncodingTypeIsCNumber(metaProperty->_encodingType);
    }
    if ((metaProperty->_encodingType & WFEncodingTypeMask) == WFEncodingTypeStruct) {
        /*
         It seems that NSKeyedUnarchiver cannot decode NSValue except these structs:
         */
        static NSSet *types = nil;
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            NSMutableSet *set = [NSMutableSet new];
            // 32 bit
            [set addObject:@"{CGSize=ff}"];
            [set addObject:@"{CGPoint=ff}"];
            [set addObject:@"{CGRect={CGPoint=ff}{CGSize=ff}}"];
            [set addObject:@"{CGAffineTransform=ffffff}"];
            [set addObject:@"{UIEdgeInsets=ffff}"];
            [set addObject:@"{UIOffset=ff}"];
            // 64 bit
            [set addObject:@"{CGSize=dd}"];
            [set addObject:@"{CGPoint=dd}"];
            [set addObject:@"{CGRect={CGPoint=dd}{CGSize=dd}}"];
            [set addObject:@"{CGAffineTransform=dddddd}"];
            [set addObject:@"{UIEdgeInsets=dddd}"];
            [set addObject:@"{UIOffset=dd}"];
            types = set;
        });
        if ([types containsObject:propertyInfo.typeEncoding]) {
            metaProperty->_isStructAvailableForKeyedArchiver = YES;
        }
    }
    
    if(propertyInfo.getterSEL)
    {
        if([clsInfo.cls instancesRespondToSelector:propertyInfo.getterSEL])
        {
            metaProperty->_getter = propertyInfo.getterSEL;
        }
    }
    if(propertyInfo.setterSEL)
    {
        if([clsInfo.cls instancesRespondToSelector:propertyInfo.setterSEL])
        {
            metaProperty->_setter = propertyInfo.setterSEL;
        }
    }
    
    if(metaProperty->_getter && metaProperty->_setter)
    {
        /*
         KVC invalid type:
         long double
         pointer (such as SEL/CoreFoundation object)
         */
        switch (metaProperty->_encodingType & WFEncodingTypeMask) {
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
            case WFEncodingTypeObject:
            case WFEncodingTypeClass:
            case WFEncodingTypeBlock:
            case WFEncodingTypeStruct:
            case WFEncodingTypeUnion: {
                metaProperty->_isKVCCompatible = YES;
            } break;
            default: break;
        }
    }
    
    return metaProperty;
}

@end


@implementation WF_DBMetaClassInfo

+ (instancetype)metaWithClass:(Class)cls
{
    if(cls == nil) return nil;
    
    static CFMutableDictionaryRef classCache;
//    static CFMutableDictionaryRef
    static dispatch_once_t onceToken;
    static dispatch_semaphore_t lock;
    dispatch_once(&onceToken, ^{
        classCache = CFDictionaryCreateMutable(CFAllocatorGetDefault(), 0, &kCFTypeDictionaryKeyCallBacks, &kCFTypeDictionaryValueCallBacks);
        lock = dispatch_semaphore_create(1);
    });
    dispatch_semaphore_wait(lock, DISPATCH_TIME_FOREVER);
    WF_DBMetaClassInfo *metaClass = CFDictionaryGetValue(classCache, (__bridge const void *)(cls));
    if(metaClass == nil)
    {
        metaClass = [[WF_DBMetaClassInfo alloc] initWithClass:cls];
        if(metaClass) CFDictionarySetValue(classCache, (__bridge const void *)(cls), (__bridge const void *)(metaClass));
    }
    dispatch_semaphore_signal(lock);
    
    return metaClass;
}

- (instancetype)initWithClass:(Class)cls
{
    if(cls == nil) return nil;
    WFClassInfo *classInfo = [[WFClassInfo alloc] initWithClass:cls];
    if(classInfo == nil) return nil;
    
    if(self = [super init])
    {
        _classInfo = classInfo;
        
        WFClassInfo *currentClassInfo = _classInfo;
        
        NSMutableDictionary *dictProperty = [NSMutableDictionary dictionary];
        
        while (currentClassInfo && currentClassInfo.superClass != nil) {
            for(WFClassPropertyInfo *propertyInfo in currentClassInfo.propertyInfos.allValues)
            {
                if(propertyInfo.name == nil) continue;
                
                WF_DBMetaClassProperyInfo *metaPropertyInfo = [WF_DBMetaClassProperyInfo metaWithProperyInfo:classInfo andPropertyInfo:propertyInfo generic:nil];
                
                if(metaPropertyInfo->_name == nil) continue;
                
                if(metaPropertyInfo->_setter == nil || metaPropertyInfo->_getter == nil) continue;
                
                if([dictProperty objectForKey:metaPropertyInfo->_name]) continue;
                
                if(WFClassTypeIsInsertObjcType(metaPropertyInfo->_nsType) ||
                   metaPropertyInfo->_isCNumber)
                {
                    dictProperty[metaPropertyInfo->_name] = metaPropertyInfo;
                }
            }
            currentClassInfo = currentClassInfo.superClassInfo;
        }
        if(dictProperty.count > 0)
        {
            _allProperyArray = dictProperty.allValues.copy;
        }
        
        
    }
    return self;
}



@end

#pragma mark -

static  NSNumber *WFBeanCreateNumberFromProperty(__unsafe_unretained id bean,
                       __unsafe_unretained WF_DBMetaClassProperyInfo *meta)
{
    switch (meta->_encodingType & WFEncodingTypeMask) {
        case WFEncodingTypeBool: {
            return @(((bool (*)(id, SEL))(void *) objc_msgSend)((id)bean, meta->_getter));
        }
        case WFEncodingTypeInt8: {
            return @(((int8_t (*)(id, SEL))(void *) objc_msgSend)((id)bean, meta->_getter));
        }
        case WFEncodingTypeUInt8: {
            return @(((uint8_t (*)(id, SEL))(void *) objc_msgSend)((id)bean, meta->_getter));
        }
        case WFEncodingTypeInt16: {
            return @(((int16_t (*)(id, SEL))(void *) objc_msgSend)((id)bean, meta->_getter));
        }
        case WFEncodingTypeUInt16: {
            return @(((uint16_t (*)(id, SEL))(void *) objc_msgSend)((id)bean, meta->_getter));
        }
        case WFEncodingTypeInt32: {
            return @(((int32_t (*)(id, SEL))(void *) objc_msgSend)((id)bean, meta->_getter));
        }
        case WFEncodingTypeUInt32: {
            return @(((uint32_t (*)(id, SEL))(void *) objc_msgSend)((id)bean, meta->_getter));
        }
        case WFEncodingTypeInt64: {
            return @(((int64_t (*)(id, SEL))(void *) objc_msgSend)((id)bean, meta->_getter));
        }
        case WFEncodingTypeUInt64: {
            return @(((uint64_t (*)(id, SEL))(void *) objc_msgSend)((id)bean, meta->_getter));
        }
        case WFEncodingTypeFloat: {
            float num = ((float (*)(id, SEL))(void *) objc_msgSend)((id)bean, meta->_getter);
            if (isnan(num) || isinf(num)) return nil;
            return @(num);
        }
        case WFEncodingTypeDouble: {
            double num = ((double (*)(id, SEL))(void *) objc_msgSend)((id)bean, meta->_getter);
            if (isnan(num) || isinf(num)) return nil;
            return @(num);
        }
        case WFEncodingTypeLongDouble: {
            double num = ((long double (*)(id, SEL))(void *) objc_msgSend)((id)bean, meta->_getter);
            if (isnan(num) || isinf(num)) return nil;
            return @(num);
        }
        default: return nil;
    }
}
/**
 *  check the property object is samed as the bean of the transform object
 *
 *  @param bean -> should  not be nil
 *  @param metaPropertyArray -> should not be nil
 */
static BOOL WFClassTypeIsSameObjcType(__unsafe_unretained id bean,__unsafe_unretained NSArray *metaProperyArray)
{
    for (WF_DBMetaClassProperyInfo *metaPropertyInfo in metaProperyArray)
    {
        if(WFClassTypeIsInsertObjcType(metaPropertyInfo->_nsType))
        {
            id value = [bean valueForKey:metaPropertyInfo->_name];
            if([value isKindOfClass:metaPropertyInfo->_cls])
            {
                return NO;
            }
        }
    }
    return YES;
}

static id WFBeanObjectValueFromProperty(__unsafe_unretained id bean, __unsafe_unretained WF_DBMetaClassProperyInfo *metaProperty)
{
    id value = nil;
    
    if(WFClassTypeIsInsertObjcType(metaProperty->_nsType))
    {
        value = ((id(*)(id, SEL))(void *)objc_msgSend)(bean, metaProperty->_getter);
    }
    else if (metaProperty->_isCNumber)
    {
        value = WFBeanCreateNumberFromProperty(bean, metaProperty);
    }
    
    if(value && [value isKindOfClass:[NSNull class]])
    {
        value = nil;
    }
    
    return value;
}

static void WFBeanSetNumberToProperty(__unsafe_unretained id model,
                                                  __unsafe_unretained FMResultSet *rsSet,
                                                  __unsafe_unretained WF_DBMetaClassProperyInfo *meta) {
    switch (meta->_encodingType & WFEncodingTypeMask) {
        case WFEncodingTypeBool: {
            ((void (*)(id, SEL, bool))(void *) objc_msgSend)((id)model, meta->_setter, [rsSet boolForColumn:meta->_name]);
        } break;
        case WFEncodingTypeInt8: {
            ((void (*)(id, SEL, int8_t))(void *) objc_msgSend)((id)model, meta->_setter, (int8_t)[rsSet intForColumn:meta->_name]);
        } break;
        case WFEncodingTypeUInt8: {
            ((void (*)(id, SEL, uint8_t))(void *) objc_msgSend)((id)model, meta->_setter, (uint8_t)[rsSet intForColumn:meta->_name]);
        } break;
        case WFEncodingTypeInt16: {
            ((void (*)(id, SEL, int16_t))(void *) objc_msgSend)((id)model, meta->_setter, (int16_t)[rsSet intForColumn:meta->_name]);
        } break;
        case WFEncodingTypeUInt16: {
            ((void (*)(id, SEL, uint16_t))(void *) objc_msgSend)((id)model, meta->_setter, (uint16_t)[rsSet intForColumn:meta->_name]);
        } break;
        case WFEncodingTypeInt32: {
            ((void (*)(id, SEL, int32_t))(void *) objc_msgSend)((id)model, meta->_setter, (int32_t)[rsSet intForColumn:meta->_name]);
        }
        case WFEncodingTypeUInt32: {
            ((void (*)(id, SEL, uint32_t))(void *) objc_msgSend)((id)model, meta->_setter, (uint32_t)[rsSet intForColumn:meta->_name]);
        } break;
        case WFEncodingTypeInt64: {
            ((void (*)(id, SEL, uint64_t))(void *) objc_msgSend)((id)model, meta->_setter, (uint64_t)[rsSet intForColumn:meta->_name]);
        } break;
        case WFEncodingTypeUInt64: {
            ((void (*)(id, SEL, uint64_t))(void *) objc_msgSend)((id)model, meta->_setter, (uint64_t)[rsSet intForColumn:meta->_name]);
        } break;
        case WFEncodingTypeFloat: {
            float f = [rsSet doubleForColumn:meta->_name];
            if (isnan(f) || isinf(f)) f = 0;
            ((void (*)(id, SEL, float))(void *) objc_msgSend)((id)model, meta->_setter, f);
        } break;
        case WFEncodingTypeDouble: {
            float d = [rsSet doubleForColumn:meta->_name];
            if (isnan(d) || isinf(d)) d = 0;
            ((void (*)(id, SEL, double))(void *) objc_msgSend)((id)model, meta->_setter, d);
        } break;
        case WFEncodingTypeLongDouble: {
            float d = [rsSet doubleForColumn:meta->_name];
            if (isnan(d) || isinf(d)) d = 0;
            ((void (*)(id, SEL, long double))(void *) objc_msgSend)((id)model, meta->_setter, (long double)d);
        } // break; commented for code coverage in next line
        default: break;
    }
}

/**
 Set value to model with a property meta.
 
 @discussion Caller should hold strong reference to the parameters before this function returns.
 
 @param model Should not be nil.
 @param value Should not be nil, but can be NSNull.
 @param meta  Should not be nil, and meta->_setter should not be nil.
 */
static void WFDBSetValueForProperty(__unsafe_unretained id model,
                                     __unsafe_unretained FMResultSet *rsSet,
                                     __unsafe_unretained WF_DBMetaClassProperyInfo *meta)
{
    if (meta->_isCNumber) {
        WFBeanSetNumberToProperty(model, rsSet, meta);
    } else if (meta->_nsType) {
        if (rsSet == (id)kCFNull) {
            ((void (*)(id, SEL, id))(void *) objc_msgSend)((id)model, meta->_setter, (id)nil);
        } else {
            switch (meta->_nsType) {
                case WFEncodingTypeNSString:
                case WFEncodingTypeNSMutableString: {
                    id value = [rsSet stringForColumn:meta->_name];
                    if ([value isKindOfClass:[NSString class]]) {
                        if (meta->_nsType == WFEncodingTypeNSString) {
                            ((void (*)(id, SEL, id))(void *) objc_msgSend)((id)model, meta->_setter, value);
                        } else {
                            ((void (*)(id, SEL, id))(void *) objc_msgSend)((id)model, meta->_setter, ((NSString *)value).mutableCopy);
                        }
                    } else if ([value isKindOfClass:[NSNumber class]]) {
                        ((void (*)(id, SEL, id))(void *) objc_msgSend)((id)model,
                                                                       meta->_setter,
                                                                       (meta->_nsType == WFEncodingTypeNSString) ?
                                                                       ((NSNumber *)value).stringValue :
                                                                       ((NSNumber *)value).stringValue.mutableCopy);
                    } else if ([value isKindOfClass:[NSData class]]) {
                        NSMutableString *string = [[NSMutableString alloc] initWithData:value encoding:NSUTF8StringEncoding];
                        ((void (*)(id, SEL, id))(void *) objc_msgSend)((id)model, meta->_setter, string);
                    } else if ([value isKindOfClass:[NSURL class]]) {
                        ((void (*)(id, SEL, id))(void *) objc_msgSend)((id)model,
                                                                       meta->_setter,
                                                                       (meta->_nsType == WFEncodingTypeNSString) ?
                                                                       ((NSURL *)value).absoluteString :
                                                                       ((NSURL *)value).absoluteString.mutableCopy);
                    } else if ([value isKindOfClass:[NSAttributedString class]]) {
                        ((void (*)(id, SEL, id))(void *) objc_msgSend)((id)model,
                                                                       meta->_setter,
                                                                       (meta->_nsType == WFEncodingTypeNSString) ?
                                                                       ((NSAttributedString *)value).string :
                                                                       ((NSAttributedString *)value).string.mutableCopy);
                    }
                } break;
                    
                case WFEncodingTypeNSValue:
                case WFEncodingTypeNSNumber:
                case WFEncodingTypeNSDecimalNumber: {
                    id value = @([rsSet doubleForColumn:meta->_name]);
                    if (meta->_nsType == WFEncodingTypeNSNumber) {
                        ((void (*)(id, SEL, id))(void *) objc_msgSend)((id)model, meta->_setter, WFCreateNSNumberFromID(value));
                    } else if (meta->_nsType == WFEncodingTypeNSDecimalNumber) {
                        if ([value isKindOfClass:[NSDecimalNumber class]]) {
                            ((void (*)(id, SEL, id))(void *) objc_msgSend)((id)model, meta->_setter, value);
                        } else if ([value isKindOfClass:[NSNumber class]]) {
                            NSDecimalNumber *decNum = [NSDecimalNumber decimalNumberWithDecimal:[((NSNumber *)value) decimalValue]];
                            ((void (*)(id, SEL, id))(void *) objc_msgSend)((id)model, meta->_setter, decNum);
                        } else if ([value isKindOfClass:[NSString class]]) {
                            NSDecimalNumber *decNum = [NSDecimalNumber decimalNumberWithString:value];
                            NSDecimal dec = decNum.decimalValue;
                            if (dec._length == 0 && dec._isNegative) {
                                decNum = nil; // NaN
                            }
                            ((void (*)(id, SEL, id))(void *) objc_msgSend)((id)model, meta->_setter, decNum);
                        }
                    } else { // WFEncodingTypeNSValue
                        if ([value isKindOfClass:[NSValue class]]) {
                            ((void (*)(id, SEL, id))(void *) objc_msgSend)((id)model, meta->_setter, value);
                        }
                    }
                } break;
                    
                case WFEncodingTypeNSData:
                case WFEncodingTypeNSMutableData: {
                    id value = [rsSet dataForColumn:meta->_name];
                    if ([value isKindOfClass:[NSData class]]) {
                        if (meta->_nsType == WFEncodingTypeNSData) {
                            ((void (*)(id, SEL, id))(void *) objc_msgSend)((id)model, meta->_setter, value);
                        } else {
                            NSMutableData *data = ((NSData *)value).mutableCopy;
                            ((void (*)(id, SEL, id))(void *) objc_msgSend)((id)model, meta->_setter, data);
                        }
                    } else if ([value isKindOfClass:[NSString class]]) {
                        NSData *data = [(NSString *)value dataUsingEncoding:NSUTF8StringEncoding];
                        if (meta->_nsType == WFEncodingTypeNSMutableData) {
                            data = ((NSData *)data).mutableCopy;
                        }
                        ((void (*)(id, SEL, id))(void *) objc_msgSend)((id)model, meta->_setter, data);
                    }
                } break;
                    
                case WFEncodingTypeNSDate: {
                    id value = [rsSet dateForColumn:meta->_name];
                    if ([value isKindOfClass:[NSDate class]]) {
                        ((void (*)(id, SEL, id))(void *) objc_msgSend)((id)model, meta->_setter, value);
                    } else if ([value isKindOfClass:[NSString class]]) {
                        ((void (*)(id, SEL, id))(void *) objc_msgSend)((id)model, meta->_setter, WFNSDateFromString(value));
                    }
                } break;
                    
                case WFEncodingTypeNSURL:break;
                    
                    
                    
                default: break;
            }
        }
    } else {
//        BOOL isNull = (value == (id)kCFNull);
//        switch (meta->_encodingType & WFEncodingTypeMask) {
//            case WFEncodingTypeObject: {
//                if (isNull) {
//                    ((void (*)(id, SEL, id))(void *) objc_msgSend)((id)model, meta->_setter, (id)nil);
//                } else if ([value isKindOfClass:meta->_cls] || !meta->_cls) {
//                    ((void (*)(id, SEL, id))(void *) objc_msgSend)((id)model, meta->_setter, (id)value);
//                } else if ([value isKindOfClass:[NSDictionary class]]) {
//                    NSObject *one = nil;
//                    if (meta->_getter) {
//                        one = ((id (*)(id, SEL))(void *) objc_msgSend)((id)model, meta->_getter);
//                    }
//                    
//                }
//            } break;
//                
//            case WFEncodingTypeClass: {
//                if (isNull) {
//                    ((void (*)(id, SEL, Class))(void *) objc_msgSend)((id)model, meta->_setter, (Class)NULL);
//                } else {
//                    Class cls = nil;
//                    if ([value isKindOfClass:[NSString class]]) {
//                        cls = NSClassFromString(value);
//                        if (cls) {
//                            ((void (*)(id, SEL, Class))(void *) objc_msgSend)((id)model, meta->_setter, (Class)cls);
//                        }
//                    } else {
//                        cls = object_getClass(value);
//                        if (cls) {
//                            if (class_isMetaClass(cls)) {
//                                ((void (*)(id, SEL, Class))(void *) objc_msgSend)((id)model, meta->_setter, (Class)value);
//                            }
//                        }
//                    }
//                }
//            } break;
//                
//            case  WFEncodingTypeSEL: {
//                if (isNull) {
//                    ((void (*)(id, SEL, SEL))(void *) objc_msgSend)((id)model, meta->_setter, (SEL)NULL);
//                } else if ([value isKindOfClass:[NSString class]]) {
//                    SEL sel = NSSelectorFromString(value);
//                    if (sel) ((void (*)(id, SEL, SEL))(void *) objc_msgSend)((id)model, meta->_setter, (SEL)sel);
//                }
//            } break;
//                
//            case WFEncodingTypeBlock:
//            case WFEncodingTypeStruct:
//            case WFEncodingTypeUnion:
//            case WFEncodingTypeCArray:
//            case WFEncodingTypePointer:
//            case WFEncodingTypeCString: {
//                if (isNull) {
//                    ((void (*)(id, SEL, void *))(void *) objc_msgSend)((id)model, meta->_setter, (void *)NULL);
//                } else if ([value isKindOfClass:[NSValue class]]) {
//                    NSValue *nsValue = value;
//                    if (nsValue.objCType && strcmp(nsValue.objCType, "^v") == 0) {
//                        ((void (*)(id, SEL, void *))(void *) objc_msgSend)((id)model, meta->_setter, nsValue.pointerValue);
//                    }
//                }
//            } // break; commented for code coverage in next line
//                
//            default: break;
//        }
    }
}



typedef struct {
    void *_keySQLString;       ///<
    void *_valueSQLArray;      ///< id (self)
} WFSQLKeyValueStruct;



@implementation NSObject (WFExtensionDataBase)

#pragma mark - 增删改查
+ (BOOL)DB_addWithBean:(id)bean
{
    BOOL rs = NO;
    WF_DBMetaClassInfo *metaClass = [WF_DBMetaClassInfo metaWithClass:self.class];
    if(metaClass != nil && metaClass.classInfo.classname && WFClassTypeIsSameObjcType(bean, metaClass.allProperyArray))
    {
        NSMutableString *propertysStr = [NSMutableString stringWithString:@"("];
        NSMutableString *valuesCode = [NSMutableString stringWithString:@"("];
        
        NSMutableArray *valueArray = [NSMutableArray array];
        
        [metaClass.allProperyArray enumerateObjectsUsingBlock:^(WF_DBMetaClassProperyInfo * metaProperty, NSUInteger idx, BOOL * _Nonnull stop)
         {
             if([[bean getId] isEqualToString:metaProperty->_name]) // table identifier
             {
                 if([bean respondsToSelector:@selector(isAutoIncrementForId)] &&
                    [bean isAutoIncrementForId])
                 {
                     return;
                 }
             }
             id propertyValue = WFBeanObjectValueFromProperty(bean, metaProperty);
             if(propertyValue)
             {
                 [propertysStr appendFormat:@" %@,", metaProperty->_name];
                 [valuesCode appendString:@" ?,"];
                 [valueArray addObject:propertyValue];
             }
         }];
        
        
        [propertysStr deleteCharactersInRange:NSMakeRange(propertysStr.length - 1, 1)];
        [propertysStr appendString:@")"];
        
        [valuesCode deleteCharactersInRange:NSMakeRange(valuesCode.length - 1, 1)];
        [valuesCode appendString:@")"];
        
        NSString *sql = [NSString stringWithFormat:@"insert into %@ %@ values %@", metaClass.classInfo.classname, propertysStr, valuesCode];
        
        FMDatabase *database = [WFDatabaseHelper getDataBase];
        rs = [database executeUpdate:sql withArgumentsInArray:valueArray];
        [database commit];
    }
    else
    {
        [self myLog:@"Object type is error"];
    }
    return rs;
}

+ (BOOL)DB_deleteWithIdValue:(id)idValue
{
    if(idValue == nil || idValue == (id)kCFNull) return NO;
    WF_DBMetaClassInfo *metaClass = [WF_DBMetaClassInfo metaWithClass:self.class];
    return [self DB_deleteWithWhereSQL:@{[NSString stringWithFormat:@"%@ = ?", metaClass.classInfo.classname]:idValue}];
}

+ (BOOL)DB_deleteWithWhereSQL:(NSDictionary *)whereSQLParam
{
    if(whereSQLParam.count == 0 || ![self checkDictionaryParameter:whereSQLParam]) {
        return NO;
    }
    BOOL rs = NO;
    
    WF_DBMetaClassInfo *metaClass = [WF_DBMetaClassInfo metaWithClass:self.class];
    if(metaClass != nil && metaClass.classInfo.classname)
    {
        NSString *sql = [NSString stringWithFormat:@"delete from %@ %@", metaClass.classInfo.classname, [self buildWhereSQL:whereSQLParam.allKeys]];
        FMDatabase *database = [WFDatabaseHelper getDataBase];
        rs = [database executeUpdate:sql withArgumentsInArray:[self buildParameterSQLValue:whereSQLParam]];
        [database commit];
    }
    
    return rs;
}

+ (BOOL)DB_updateWithBean:(id)bean
{
    if(![bean respondsToSelector:@selector(getId)] || [bean getId].length == 0) return NO;
    BOOL rs = NO;
    WF_DBMetaClassInfo *metaClass = [WF_DBMetaClassInfo metaWithClass:self.class];
    if(metaClass != nil && metaClass.classInfo.classname && WFClassTypeIsSameObjcType(bean, metaClass.allProperyArray))
    {
        NSMutableString *setupSQL = [NSMutableString string];
        NSMutableArray *valueArray = [NSMutableArray array];
        __block id idValue = nil;
        [metaClass.allProperyArray enumerateObjectsUsingBlock:^(WF_DBMetaClassProperyInfo * metaProperty, NSUInteger idx, BOOL * _Nonnull stop)
         {
             id propertyValue = WFBeanObjectValueFromProperty(bean, metaProperty);
             if([[bean getId] isEqualToString:metaProperty->_name]) // table identifier
             {
                 idValue = propertyValue;
             }
             else
             {
                 if(propertyValue != nil && ![propertyValue isKindOfClass:[NSNull class]])
                 {
                     [setupSQL appendFormat:@" %@ = ?,", metaProperty->_name];
                     [valueArray addObject:propertyValue];
                 }
             }
         }];
        
        if(idValue == nil) return NO;
        
        [valueArray addObject:idValue];
        
        /// [whereSQLString appendFormat:@" %@ = ?,", obj];
        
        NSString *sql = [NSString stringWithFormat:@"update %@ set %@ where %@ = ?", metaClass.classInfo.classname, setupSQL, [bean getId]];
        
        FMDatabase *database = [WFDatabaseHelper getDataBase];
        rs = [database executeUpdate:sql withArgumentsInArray:valueArray];
        [database commit];
    }
    else
    {
        [self myLog:@"Object type is error"];
    }
    return rs;
}

+ (BOOL)DB_updateWithSetupSQL:(NSDictionary *)setupParam andWhereSQL:(NSDictionary *)whereSQLParam
{
    if(setupParam.count == 0 || ![self checkDictionaryParameter:setupParam]) {
        return NO;
    }
    if(whereSQLParam.count == 0 || ![self checkDictionaryParameter:whereSQLParam]) {
        return NO;
    }
    BOOL rs = NO;
    WF_DBMetaClassInfo *metaClass = [WF_DBMetaClassInfo metaWithClass:self.class];
    if(metaClass != nil && metaClass.classInfo.classname)
    {
        NSMutableArray *valueArray = [NSMutableArray arrayWithArray:[self buildParameterSQLValue:setupParam]];
        [valueArray addObjectsFromArray:[self buildParameterSQLValue:whereSQLParam]];
        
        NSString *sql = [NSString stringWithFormat:@"update %@ set %@ where %@", metaClass.classInfo.classname, [self buildSetupSQL:setupParam.allKeys], [self buildWhereSQL:whereSQLParam.allKeys]];
        FMDatabase *database = [WFDatabaseHelper getDataBase];
        rs = [database executeUpdate:sql withArgumentsInArray:valueArray];
        [database commit];
    }
    return NO;
}

+ (id)DB_findWithIdValue:(id)idValue
{
    if(idValue == nil || idValue == (id)kCFNull) return nil;
    WF_DBMetaClassInfo *metaClass = [WF_DBMetaClassInfo metaWithClass:self.class];
    return [self DB_findWithWhereSQL:@{[NSString stringWithFormat:@"%@ = ?", metaClass.classInfo.classname]:idValue}];
}
+ (id)DB_findWithWhereSQL:(NSDictionary *)whereSQLParam
{
    if(whereSQLParam.count == 0 || ![self checkDictionaryParameter:whereSQLParam]) {
        return nil;
    }
    id bean = nil;
    WF_DBMetaClassInfo *metaClass = [WF_DBMetaClassInfo metaWithClass:self.class];
    if(metaClass != nil && metaClass.classInfo.classname)
    {
        
        NSString *sql = [NSString stringWithFormat:@"select * from %@ %@", metaClass.classInfo.classname, [self buildWhereSQL:whereSQLParam.allKeys]];
        FMDatabase *database = [WFDatabaseHelper getDataBase];
        FMResultSet *rsSet = [database executeQuery:sql withArgumentsInArray:[self buildParameterSQLValue:whereSQLParam]];
        
        if([rsSet next])
        {
            bean = [self beanWithResultSet:rsSet];
        }
        [rsSet close];
    }
    return bean;
}
+ (NSMutableArray *)DB_queryWithWhereSQL:(NSDictionary *)whereSQLParam andOrderby:(NSDictionary *)orderby
{
    if(whereSQLParam.count > 0 && ![self checkDictionaryParameter:whereSQLParam]) {
        return nil;
    }
    if(orderby.count > 0 && ![self checkDictionaryParameter:orderby]) {
        return nil;
    }
    NSMutableArray *dataArray = nil;
    WF_DBMetaClassInfo *metaClass = [WF_DBMetaClassInfo metaWithClass:self.class];
    
    if(metaClass != nil && metaClass.classInfo.classname)
    {
        
        NSString *sql = [NSString stringWithFormat:@"select * from %@ %@ %@", metaClass.classInfo.classname, [self buildWhereSQL:whereSQLParam.allKeys], [self buildOrderbySQL:orderby]];
        FMDatabase *database = [WFDatabaseHelper getDataBase];
        FMResultSet *rsSet = [database executeQuery:sql withArgumentsInArray:[self buildParameterSQLValue:whereSQLParam]];
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

+ (BOOL)DB_isExistWithWhereSQL:(NSDictionary *)whereSQLParam
{
    return ![self DB_isEmpty:whereSQLParam];
}

+ (BOOL)DB_isEmpty:(NSDictionary *)whereSQLParam
{
    if(whereSQLParam.count == 0 || ![self checkDictionaryParameter:whereSQLParam]) {
        return YES;
    }
    BOOL rs = YES;
    WF_DBMetaClassInfo *metaClass = [WF_DBMetaClassInfo metaWithClass:self.class];
    if(metaClass != nil && metaClass.classInfo.classname)
    {
        NSString *sql = [NSString stringWithFormat:@"select count(*) from %@ %@",metaClass.classInfo.classname, [self buildWhereSQL:whereSQLParam.allKeys]];
        FMDatabase *database = [WFDatabaseHelper getDataBase];
        FMResultSet *rsSet = [database executeQuery:sql withArgumentsInArray:[self buildParameterSQLValue:whereSQLParam]];
        if([rsSet next])
        {
            rs = [rsSet intForColumnIndex:0] == 0;
        }
        [rsSet close];
    }
    return rs;
}

#pragma mark - 构建 查询条件

// - 构建 查询条件
+ (NSString *)buildWhereSQL:(NSArray *)keyArray
{
    NSMutableString *whereSQLString = [NSMutableString stringWithString:@" where 1 = 1"];
    [keyArray enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop)
    {
        [whereSQLString appendFormat:@" and %@", obj];
    }];
    return whereSQLString;
}

+ (NSString *)buildSetupSQL:(NSArray *)keyArray
{
    NSMutableString *whereSQLString = [NSMutableString string];
    [keyArray enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [whereSQLString appendFormat:@" %@ = ?,", obj];
    }];
    return whereSQLString;
}
+ (NSArray *)buildParameterSQLValue:(NSDictionary *)parameter
{
    NSMutableArray *dtArray = nil;
    if(parameter.allKeys.count > 0)
    {
        dtArray = [NSMutableArray arrayWithCapacity:parameter.allKeys.count];
        for (NSString *key in parameter.allKeys) {
            [dtArray addObject:[parameter objectForKey:key]];
        }
    }
    return dtArray;
}
//+ (WFSQLKeyValueStruct)buildWhereSQLKeyValue:(NSDictionary *)parameter
//{
//    WFSQLKeyValueStruct keyValue;
//    NSMutableString *whereSQLString = [NSMutableString stringWithString:@" where 1 = 1"];
//    NSMutableArray *dtArray = [NSMutableArray arrayWithCapacity:parameter.count];
//    [parameter enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull whereSQL, id  _Nonnull obj, BOOL * _Nonnull stop)
//     {
//         [whereSQLString appendFormat:@" and %@", whereSQL];
//         [dtArray addObject:obj];
//     }];
//    keyValue._keySQLString = CFBridgingRetain(whereSQLString);
//    keyValue._valueSQLArray = CFBridgingRetain(dtArray);
//    return keyValue;
//}

//+ (WFSQLKeyValueStruct)buildSetupSQLKeyValue:(NSDictionary *)parameter
//{
//    WFSQLKeyValueStruct keyValue = {0};
//    NSMutableString *whereSQLString = [NSMutableString string];
//    NSMutableArray *dtArray = [NSMutableArray arrayWithCapacity:parameter.count];
//    [parameter enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull whereSQL, id  _Nonnull obj, BOOL * _Nonnull stop)
//     {
//         [whereSQLString appendFormat:@" %@ = ?,", whereSQL];
//         [dtArray addObject:obj];
//     }];
//    keyValue._keySQLString = (__bridge void *)(whereSQLString);
//    keyValue._valueSQLArray= (__bridge void *)(dtArray);
//    return keyValue;
//}

+ (NSString *)buildOrderbySQL:(NSDictionary *)orderbyDic
{
    if(orderbyDic.count == 0) return @"";
    NSMutableString *orberbySQL = [NSMutableString string];
    [orberbySQL appendString:@" order by "];
    for (NSString *key in orderbyDic.allKeys) {
        NSString *value = [orderbyDic objectForKey:key];
        [orberbySQL appendFormat:@"%@ %@ ", key, value];
    }
    return orberbySQL;
}
//+ (NSString *)buildWhereSQL:(NSArray *)whereSQLArray
//{
//    NSMutableString *whereSQLString = [NSMutableString stringWithString:@" where 1 = 1"];
//    for (NSString *whereSQL in whereSQLArray) {
//        [whereSQLString appendFormat:@" and %@", whereSQL];
//    }
//    return whereSQLString;
//}
//+ (NSString *)buildSetupSQL:(NSArray *)setupSQLArray
//{
//    NSMutableString *whereSQLString = [NSMutableString string];
//    for (NSString *setSQL in setupSQLArray) {
//        [whereSQLString appendFormat:@" %@ = ?,", setSQL];
//    }
//    [whereSQLString substringToIndex:whereSQLString.length - 1];
//    return whereSQLString;
//}

+ (BOOL)checkDictionaryParameter:(NSDictionary *)parameter
{
    for (NSString *key in parameter.allKeys) {
        if(key.length > 0 && ![key isKindOfClass:[NSString class]])
        {
            [self myLog:@"key is not String type"];
            return NO;
        }
        else
        {
            id value = [parameter objectForKey:key];
            if([value isKindOfClass:[NSNull class]])
            {
                [self myLog:[NSString stringWithFormat:@"the value of key '%@' is NSNull", key]];
                return NO;
            }
        }
    }
    return YES;
}

+ (id)beanWithResultSet:(FMResultSet *)rSet
{
    id bean = [[self alloc] init];
    WF_DBMetaClassInfo *metaClass = [WF_DBMetaClassInfo metaWithClass:self.class];
    [metaClass.allProperyArray enumerateObjectsUsingBlock:^(WF_DBMetaClassProperyInfo * metaProperty, NSUInteger idx, BOOL * _Nonnull stop)
     {
         WFDBSetValueForProperty(bean, rSet, metaProperty);
     }];
    return bean;
}

+ (void)myLog:(NSString *)logMessage
{
    NSLog(@"=== occur error, %@", logMessage);
}


@end
