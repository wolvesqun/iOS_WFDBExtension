//
//  WFClassInfo.h
//  testWFDBExtendsion
//
//  Created by PC on 4/30/16.
//  Copyright © 2016 ubmlib. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <objc/runtime.h>

/**
 Type encoding's type.
 */
typedef NS_OPTIONS(NSUInteger, WFEncodingType) {
    WFEncodingTypeMask       = 0xFF, ///< mask of type value
    WFEncodingTypeUnknown    = 0, ///< unknown
    WFEncodingTypeVoid       = 1, ///< void
    WFEncodingTypeBool       = 2, ///< bool
    WFEncodingTypeInt8       = 3, ///< char / BOOL
    WFEncodingTypeUInt8      = 4, ///< unsigned char
    WFEncodingTypeInt16      = 5, ///< short
    WFEncodingTypeUInt16     = 6, ///< unsigned short
    WFEncodingTypeInt32      = 7, ///< int
    WFEncodingTypeUInt32     = 8, ///< unsigned int
    WFEncodingTypeInt64      = 9, ///< long long
    WFEncodingTypeUInt64     = 10, ///< unsigned long long
    WFEncodingTypeFloat      = 11, ///< float
    WFEncodingTypeDouble     = 12, ///< double
    WFEncodingTypeLongDouble = 13, ///< long double
    WFEncodingTypeObject     = 14, ///< id
    WFEncodingTypeClass      = 15, ///< Class
    WFEncodingTypeSEL        = 16, ///< SEL
    WFEncodingTypeBlock      = 17, ///< block
    WFEncodingTypePointer    = 18, ///< void*
    WFEncodingTypeStruct     = 19, ///< struct
    WFEncodingTypeUnion      = 20, ///< union
    WFEncodingTypeCString    = 21, ///< char*
    WFEncodingTypeCArray     = 22, ///< char[10] (for example)
    
    WFEncodingTypeQualifierMask   = 0xFF00,   ///< mask of qualifier
    WFEncodingTypeQualifierConst  = 1 << 8,  ///< const
    WFEncodingTypeQualifierIn     = 1 << 9,  ///< in
    WFEncodingTypeQualifierInout  = 1 << 10, ///< inout
    WFEncodingTypeQualifierOut    = 1 << 11, ///< out
    WFEncodingTypeQualifierBycopy = 1 << 12, ///< bycopy
    WFEncodingTypeQualifierByref  = 1 << 13, ///< byref
    WFEncodingTypeQualifierOneway = 1 << 14, ///< oneway
    
    WFEncodingTypePropertyMask         = 0xFF0000, ///< mask of property
    WFEncodingTypePropertyReadonly     = 1 << 16, ///< readonly
    WFEncodingTypePropertyCopy         = 1 << 17, ///< copy
    WFEncodingTypePropertyRetain       = 1 << 18, ///< retain
    WFEncodingTypePropertyNonatomic    = 1 << 19, ///< nonatomic
    WFEncodingTypePropertyWeak         = 1 << 20, ///< weak
    WFEncodingTypePropertyCustomGetter = 1 << 21, ///< getter=
    WFEncodingTypePropertyCustomSetter = 1 << 22, ///< setter=
    WFEncodingTypePropertyDynamic      = 1 << 23, ///< @dynamic
};

/// Foundation Class Type
typedef NS_ENUM (NSUInteger, WFEncodingNSType) {
    WFEncodingTypeNSUnknown = 0,
    WFEncodingTypeNSString,
    WFEncodingTypeNSMutableString,
    WFEncodingTypeNSValue,
    WFEncodingTypeNSNumber,
    WFEncodingTypeNSDecimalNumber,
    WFEncodingTypeNSData, // 数据
    WFEncodingTypeNSMutableData,
    WFEncodingTypeNSDate, // 日期
    WFEncodingTypeNSURL,
    WFEncodingTypeNSArray,
    WFEncodingTypeNSMutableArray,
    WFEncodingTypeNSDictionary,
    WFEncodingTypeNSMutableDictionary,
    WFEncodingTypeNSSet,
    WFEncodingTypeNSMutableSet,
};

/**
 Get the type from a Type-Encoding string.
 
 @discussion See also:
 https://developer.apple.com/library/mac/documentation/Cocoa/Conceptual/ObjCRuntimeGuide/Articles/ocrtTypeEncodings.html
 https://developer.apple.com/library/mac/documentation/Cocoa/Conceptual/ObjCRuntimeGuide/Articles/ocrtPropertyIntrospection.html
 
 @param typeEncoding  A Type-Encoding string.
 @return The encoding type.
 */
WFEncodingType WFEncodingGetType(const char *typeEncoding);

WFEncodingNSType WFClassGetNSType(Class cls);
BOOL WFEncodingTypeIsCNumber(WFEncodingType type);

NSNumber *WFCreateNSNumberFromID(__unsafe_unretained id value);
NSDate *WFNSDateFromString(__unsafe_unretained NSString *string);


#pragma mark - method
@interface WFClassMethodInfo : NSObject

@property (assign, nonatomic, readonly) Method method;
@property (strong, nonatomic, readonly) NSString *name;
@property (assign, nonatomic, readonly) SEL sel;
@property (assign, nonatomic, readonly) IMP imp;

- (instancetype)initWithMethod:(Method)method;


@end

#pragma mark - propery
@interface WFClassPropertyInfo : NSObject

@property (assign, nonatomic, readonly) objc_property_t property;
@property (assign, nonatomic, readonly) WFEncodingType  type;
@property (assign, nonatomic, readonly) SEL             setterSEL;
@property (assign, nonatomic, readonly) SEL             getterSEL;
@property (assign, nonatomic, readonly) Class           cls; // maybe nil
@property (strong, nonatomic, readonly) NSString        *typeEncoding;
@property (strong, nonatomic, readonly) NSString        *name;
@property (strong, nonatomic, readonly) NSString        *ivarName;


- (instancetype)initWithPropery:(objc_property_t)propery;

@end

#pragma mark - ivar
@interface WFClassIvarInfo : NSObject

@property (assign, nonatomic, readonly) Ivar ivar;
//@property ()

@end

#pragma mark - classinfo
@interface WFClassInfo : NSObject

@property (assign, nonatomic, readonly) Class               cls;
@property (assign, nonatomic, readonly) Class               superClass;

@property (strong, nonatomic, readonly) WFClassInfo         *superClassInfo;
@property (strong, nonatomic, readonly) NSMutableDictionary *propertyInfos;
@property (strong, nonatomic, readonly) NSMutableDictionary *methodInfos;
@property (strong, nonatomic, readonly) NSMutableDictionary *ivaInfos;

@property (strong, nonatomic, readonly) NSString            *classname;

//+ (instancetype)classInfoWithClass:(Class)cls;

- (instancetype)initWithClass:(Class)cls;

@end








