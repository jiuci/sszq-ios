//
//  UIImageExtend.h
//  DVMobile
//
//  Created by pan Shiyu on 14/11/1.
//  Copyright (c) 2014年 mobile. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (helper)
- (UIImage*)resizableImage;
- (UIImage *)image:(UIImage*)image byScalingToSize:(CGSize)targetSize;
- (UIImage*)resizableImageOffset:(float)offset;
+ (UIImage*)imageFromColor:(UIColor*)color forSize:(CGSize)size withCornerRadius:(CGFloat)radius;
@end
