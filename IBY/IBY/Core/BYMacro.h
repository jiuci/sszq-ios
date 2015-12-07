//
//  BYMacro.h
//  IBY
//
//  Created by panShiyu on 14-9-15.
//  Copyright (c) 2014年 com.biyao. All rights reserved.
//

#ifndef IBY_BYMacro_h
#define IBY_BYMacro_h

#define SYSTEM_VERSION_LESS_THAN(v)                      \
    ([[[UIDevice currentDevice] systemVersion] compare:v \
                                               options:NSNumericSearch] == NSOrderedAscending)
#define SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(v)       \
    ([[[UIDevice currentDevice] systemVersion] compare:v \
                                               options:NSNumericSearch] != NSOrderedAscending)

#define SCREEN_WIDTH [UIScreen mainScreen].bounds.size.width
#define SCREEN_HEIGHT [UIScreen mainScreen].bounds.size.height

#define SCREEN_PIXELUNIT (SCREEN_WIDTH/80)

#define SCREEN_BOUNDS_SIZE [UIScreen mainScreen].bounds.size

#define SCREEN_APPLICATIONFRAME_SIZE [UIScreen mainScreen].applicationFrame.size

#define BYColor333 HEXCOLOR(0x333333)
#define BYColor666 HEXCOLOR(0x666666)
#define BYColor999 HEXCOLOR(0x999999)
#define BYColorf5 HEXCOLOR(0xf5f5f5)
#define BYColorcc HEXCOLOR(0xcccccc)
#define BYColorf60 HEXCOLOR(0xff6600)
#define BYColorb768 HEXCOLOR(0xb768a5)
#define BYColorf49f26 HEXCOLOR(0xf49f26)
#define BYColor4DA6FF HEXCOLOR(0x4DA6FF)
#define BYColorNav HEXCOLOR(0x523669)
#define BYColorBG HEXCOLOR(0xeeeeee)
#define BYColorClear [UIColor clearColor]
#define BYColorWhite [UIColor whiteColor]
#define BYColorFF4C4C HEXCOLOR(0xff4c4c)

#define Font(x) [UIFont systemFontOfSize:x]
#define ItalicFont(x) [UIFont italicSystemFontOfSize:x]
#define BoldFont(x) [UIFont boldSystemFontOfSize:x]

#define RGBCOLOR(r, g, b)              \
    [UIColor colorWithRed:(r) / 255.0f \
                    green:(g) / 255.0f \
                     blue:(b) / 255.0f \
                    alpha:1]
#define RGBACOLOR(r, g, b, a)          \
    [UIColor colorWithRed:(r) / 255.0f \
                    green:(g) / 255.0f \
                     blue:(b) / 255.0f \
                    alpha:(a)]

#define HEXCOLOR(hexValue)                                                 \
    [UIColor colorWithRed:((CGFloat)((hexValue & 0xFF0000) >> 16)) / 255.0 \
                    green:((CGFloat)((hexValue & 0xFF00) >> 8)) / 255.0    \
                     blue:((CGFloat)(hexValue & 0xFF)) / 255.0             \
                    alpha:1.0]

#define HEXACOLOR(hexValue, alphaValue)                                    \
    [UIColor colorWithRed:((CGFloat)((hexValue & 0xFF0000) >> 16)) / 255.0 \
                    green:((CGFloat)((hexValue & 0xFF00) >> 8)) / 255.0    \
                     blue:((CGFloat)(hexValue & 0xFF)) / 255.0             \
                    alpha:(alphaValue)]

#define BYRectMake(x, y, width, height)          \
    CGRectMake(floor(x), floor(y), floor(width), \
               floor(height)) //防止frame出现小数，绘制模糊

#define BYRetinaRectMake(x, y, width, height)          \
    CGRectMake(floor(2*(x))/2.0, floor(2*(y))/2.0, floor(2*(width))/2.0, \
                floor(2*(height))/2.0) //防止frame出现小数，绘制模糊

#define BYPointMake(x, y) CGPointMake(x, y)

#define BYDesignCss @"<style>p img{width:100%!important;height:auto!important}p video{width:100%!important;height:auto!important}</style>"

//自定义log：发布时自动关闭
#ifdef DEBUG
#define BYLog(...) NSLog(__VA_ARGS__)
#else
#define BYLog(...)
#endif

#define BYLog_Class_Function BYLog(@"%@ %s", [self class], __FUNCTION__);

//随机色颜色
#define BYRandomColor                                     \
    [UIColor colorWithRed:arc4random_uniform(255) / 255.0 \
                    green:arc4random_uniform(255) / 255.0 \
                     blue:arc4random_uniform(255) / 255.0 \
                    alpha:255 / 255.0]

//切到主线程
#define within_main_thread(block, ...)                                                  \
    try {                                                                               \
    }                                                                                   \
    @finally                                                                            \
    {                                                                                   \
    }                                                                                   \
    do {                                                                                \
        if ([[NSThread currentThread] isMainThread]) {                                  \
            if (block) {                                                                \
                block(__VA_ARGS__);                                                     \
            }                                                                           \
        }                                                                               \
        else {                                                                          \
            if (block) {                                                                \
                dispatch_async(dispatch_get_main_queue(), ^() { block(__VA_ARGS__); }); \
            }                                                                           \
        }                                                                               \
    } while (0)

#endif
