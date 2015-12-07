//
//  NSStringExtension.m
//  IBY
//
//  Created by panshiyu on 14/11/7.
//  Copyright (c) 2014年 com.biyao. All rights reserved.
//

#import "NSStringExtension.h"
#import "CommonFunc.h"
#import <CommonCrypto/CommonDigest.h>
#import <CommonCrypto/CommonCryptor.h>
#define gkey            @"HDALd)9dkA*&1kS$CKSJ}{|A"
#define gIv             @"A8kz$fKC"
@implementation NSString (URLEncoding)

- (NSString*)generateMD5
{
    // Create pointer to the string as UTF8
    const char* ptr = [self UTF8String];

    // Create byte array of unsigned chars
    unsigned char md5Buffer[CC_MD5_DIGEST_LENGTH];

    // Create 16 byte MD5 hash value, store in buffer
    CC_MD5(ptr, strlen(ptr), md5Buffer);

    // Convert MD5 value in the buffer to NSString of hex values
    NSMutableString* output = [NSMutableString stringWithCapacity:CC_MD5_DIGEST_LENGTH * 2];
    for (int i = 0; i < CC_MD5_DIGEST_LENGTH; i++)
        [output appendFormat:@"%02x", md5Buffer[i]];

    return output;
}

- (NSString*)urlEncodeUsingEncoding:(NSStringEncoding)encoding
{
    return (NSString*)CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(NULL,
        (CFStringRef)self,
        NULL,
        (CFStringRef) @"!*'\"();:@&=+$,/?%#[]% ",
        CFStringConvertNSStringEncodingToEncoding(encoding)));
}
- (BOOL)isBYcardID
{
    NSError* error = nil;
    NSRegularExpression* regex = [NSRegularExpression regularExpressionWithPattern:@"^[\\d\\*]{,10}$"
                                                                           options:NSRegularExpressionCaseInsensitive
                                                                             error:&error];
    NSUInteger numberOfMatches = [regex numberOfMatchesInString:self options:0 range:NSMakeRange(0, [self length])];
    if (1 == numberOfMatches) {
        return YES;
    }
    return NO;
}
- (BOOL)isMobilePhoneNumber
{
    NSError* error = nil;
    NSRegularExpression* regex = [NSRegularExpression regularExpressionWithPattern:@"^1[\\d\\*]{10}$"
                                                                           options:NSRegularExpressionCaseInsensitive
                                                                             error:&error];
    NSUInteger numberOfMatches = [regex numberOfMatchesInString:self options:0 range:NSMakeRange(0, [self length])];
    if (1 == numberOfMatches) {
        return YES;
    }
    return NO;
}

- (NSString*)chineseMobileFormat
{
    if (![self isMobilePhoneNumber]) {
        return nil;
    }
    NSMutableString* str = [@"+86 " mutableCopy];
    [str appendString:self];
    [str insertString:@" " atIndex:7]; //第7个位置插入空格
    [str insertString:@" " atIndex:12];
    return [str copy];
}

- (BOOL)isZipcode
{

    NSError* error = nil;
    NSRegularExpression* regex = [NSRegularExpression regularExpressionWithPattern:@"^\\d{6}$"
                                                                           options:NSRegularExpressionCaseInsensitive
                                                                             error:&error];
    NSUInteger numberOfMatches = [regex numberOfMatchesInString:self options:0 range:NSMakeRange(0, [self length])];
    if (1 == numberOfMatches) {
        return YES;
    }
    return NO;
}

- (BOOL)isValidPassword
{
    if (self.length < 6 || self.length > 32) {
        return NO;
    }
    NSString* regex = @"^[0-9a-zA-Z@!#\\$%&'\\*\\+\\-\\/=\\?\\^_`{\\|}\\[\\]<>\\(\\)\"~,\\.:;\\\\]{6,32}$";
    NSPredicate* pred = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regex];
    BOOL isMatch = [pred evaluateWithObject:self];
    if (!isMatch) {
        return NO;
    }
    int matchCount = 0;
//  ^[0-9a-zA-Z@!#\\$%&'\\*\\+\\-\\/=\\?\\^_`{\\|}\\[\\]<>\\(\\)\"~,\\.:;\\\\]{6,32}$
    //判断是否包含数字
    NSString* regex1 = @".*[0-9]+.*";
    NSPredicate* pred1 = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regex1];
    BOOL isMatch1 = [pred1 evaluateWithObject:self];
    if (isMatch1) {
        matchCount++;
    }

    //判断是否包含小写字母
    NSString* regex2 = @".*[a-z]+.*";
    NSPredicate* pred2 = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regex2];
    BOOL isMatch2 = [pred2 evaluateWithObject:self];
    if (isMatch2) {
        matchCount++;
    }

    //判断是否包含大写字母
    NSString* regex3 = @".*[A-Z]+.*";
    NSPredicate* pred3 = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regex3];
    BOOL isMatch3 = [pred3 evaluateWithObject:self];
    if (isMatch3) {
        matchCount++;
    }

    //判断是否包含符号
    NSString* regex4 = @".*[\\W\\_]+.*";
    NSPredicate* pred4 = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regex4];
    BOOL isMatch4 = [pred4 evaluateWithObject:self];
    if (isMatch4) {
        matchCount++;
    }

    //不要太简单啦
    return (matchCount > 1);
}

- (CGSize)sizeWithFont:(UIFont*)font maxSize:(CGSize)maxSize
{
    return [self boundingRectWithSize:maxSize
                              options:(NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading)
                           attributes:@{ NSFontAttributeName : font }
                              context:nil]
        .size;
}

- (NSString*)append:(NSString*)str
{
    if (!str) {
        str = @"";
    }

    return [NSString stringWithFormat:@"%@%@", self, str];
}

- (NSString*)appendNum:(int)num
{
    return [NSString stringWithFormat:@"%@%d", self, num];
}

#pragma mark -

- (NSDictionary*)parseURLParams
{
    NSString* query = [self copy];
    NSMutableDictionary* params = [[NSMutableDictionary alloc] init];
    NSString *url = [query substringFromIndex:4];
    [params setObject:url forKey:@"url"];

    NSRange range = [query rangeOfString:@"?"];
    if (range.length > 0) {
        query = [query substringFromIndex:range.location + 1];
    }
    NSArray* pairs = [query componentsSeparatedByString:@"&"];
    for (NSString* pair in pairs) {
        NSArray* kv = [pair componentsSeparatedByString:@"="];
        if ([kv isKindOfClass:[NSArray class]] && kv.count == 2) {
            NSString* val =
                [kv[1] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
            [params setObject:val forKey:kv[0]];
        }
    }
    return [params copy];
}

#pragma mark -

- (NSString*)URLEncodedString
{

    return [self stringByAddingPercentEncodingWithAllowedCharacters:NSCharacterSet.URLQueryAllowedCharacterSet];

    
}
- (NSString*)URLEncodedStringForMweb
{
    static CFStringRef charset = CFSTR("!@#$%&*()+'\";:=,/?[] ");
    CFStringRef str = (__bridge CFStringRef)self;
    CFStringEncoding encoding = kCFStringEncodingUTF8;
    NSMutableString *newCountryString = [(NSString*)CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(NULL, str, NULL, charset, encoding)) mutableCopy];
   // [newCountryString replaceOccurrencesOfString:@"%20" withString:@"+" options:1 range:NSMakeRange(0, newCountryString.length)];
    return [newCountryString copy];
}
- (NSString*)URLDecodedString
{
    CFStringRef result = CFURLCreateStringByReplacingPercentEscapesUsingEncoding(kCFAllocatorDefault, (CFStringRef)self, CFSTR(""), kCFStringEncodingUTF8);
    NSString* tmpResult = CFBridgingRelease(result);
    return tmpResult;
}

- (NSString*)BYDESString
{
    return [CommonFunc encryptUseDES:self key:BYDES_EncryptionKey iv:BYDES_EncryptionIV];
}

+ (NSString *)hexStringFromStr:(NSData *)data
{
    Byte *bytes = (Byte *)[data bytes];
    //下面是Byte 转换为16进制。
    NSString *hexStr=@"";
    for(int i=0;i<[data length];i++)
        
    {
        NSString *newHexStr = [NSString stringWithFormat:@"%x",bytes[i]&0xff];///16进制数
        
        if([newHexStr length]==1)
            
            hexStr = [NSString stringWithFormat:@"%@0%@",hexStr,newHexStr];
        
        else
            
            hexStr = [NSString stringWithFormat:@"%@%@",hexStr,newHexStr];
    }
    return hexStr;
}

- (NSString *)encryptstr
{
    NSData* data = [self dataUsingEncoding:NSUTF8StringEncoding];
    size_t plainTextBufferSize = [data length];
    const void *vplainText = (const void *)[data bytes];
    
    CCCryptorStatus ccStatus;
    uint8_t *bufferPtr = NULL;
    size_t bufferPtrSize = 0;
    size_t movedBytes = 0;
    
    bufferPtrSize = (plainTextBufferSize + kCCBlockSize3DES) & ~(kCCBlockSize3DES - 1);
    bufferPtr = malloc( bufferPtrSize * sizeof(uint8_t));
    memset((void *)bufferPtr, 0x0, bufferPtrSize);
    
    const void *vkey = (const void *) [gkey UTF8String];
    const void *vinitVec = (const void *) [gIv UTF8String];
    
    ccStatus = CCCrypt(kCCEncrypt,
                       kCCAlgorithm3DES,
                       kCCOptionPKCS7Padding,
                       vkey,
                       kCCKeySize3DES,
                       vinitVec,
                       vplainText,
                       plainTextBufferSize,
                       (void *)bufferPtr,
                       bufferPtrSize,
                       &movedBytes);
    
    NSData *myData = [NSData dataWithBytes:(const void *)bufferPtr length:(NSUInteger)movedBytes];
    NSString *hex = [NSString hexStringFromStr:myData];
    
    return hex;
    
}

#pragma mark - trimhtml

- (NSString*)stripHtml
{
    NSRange r;
    NSString* s = [self copy];
    while ((r = [s rangeOfString:@"<[^>]+>" options:NSRegularExpressionSearch]).location != NSNotFound)
        s = [s stringByReplacingCharactersInRange:r withString:@""];
    return s;
}



@end

NSString* IntToString(int a)
{
    return [@(a) stringValue];
}
