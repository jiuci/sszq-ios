//
//  UIImageExtend.m
//  DVMobile
//
//  Created by pan Shiyu on 14/11/1.
//  Copyright (c) 2014年 mobile. All rights reserved.
//

#import "UIImageExtend.h"

@implementation UIImage (helper)

- (UIImage*)resizableImage
{
    CGFloat top = floor(self.size.height / 2);
    CGFloat bottom = self.size.height - top - 1;
    CGFloat left = floor(self.size.width / 2);
    CGFloat right = self.size.width - left - 1;
    return [self resizableImageWithCapInsets:UIEdgeInsetsMake(top, left, bottom, right)];
}

- (UIImage *)image:(UIImage*)image byScalingToSize:(CGSize)targetSize {
    UIImage *sourceImage = image;
    UIImage *newImage = nil;
    
    UIGraphicsBeginImageContext(targetSize);
    
    CGRect thumbnailRect = CGRectZero;
    thumbnailRect.origin = CGPointZero;
    thumbnailRect.size.width  = targetSize.width;
    thumbnailRect.size.height = targetSize.height;
    
    [sourceImage drawInRect:thumbnailRect];
    
    newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return newImage ;
}


- (UIImage*)resizableImageOffset:(float)offset
{
    CGFloat top = floor(self.size.height / 2);
    CGFloat bottom = self.size.height - top - 1;
    CGFloat left = offset;
    CGFloat right = self.size.width - left - 1;
    return [self resizableImageWithCapInsets:UIEdgeInsetsMake(top, left, bottom, right)];
}


+ (UIImage*)imageFromColor:(UIColor*)color forSize:(CGSize)size withCornerRadius:(CGFloat)radius
{
    CGRect rect = CGRectMake(0, 0, size.width, size.height);
    UIGraphicsBeginImageContext(rect.size);

    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);

    UIImage* image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();

    // Begin a new image that will be the new image with the rounded corners
    // (here with the size of an UIImageView)
    UIGraphicsBeginImageContext(size);

    // Add a clip before drawing anything, in the shape of an rounded rect
    [[UIBezierPath bezierPathWithRoundedRect:rect cornerRadius:radius] addClip];
    // Draw your image
    [image drawInRect:rect];

    // Get the image, here setting the UIImageView image
    image = UIGraphicsGetImageFromCurrentImageContext();

    // Lets forget about that we were drawing
    UIGraphicsEndImageContext();

    return image;
}

@end
