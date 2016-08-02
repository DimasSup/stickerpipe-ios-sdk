//
//  UIImage+Tint.m
//  StickerFactory
//
//  Created by Vadim Degterev on 29.06.15.
//  Copyright (c) 2015 908 Inc. All rights reserved.
//

#import "UIImage+Tint.h"

@implementation UIImage (Tint)

- (UIImage*)imageWithImageTintColor: (UIColor*)color {
	// Construct new image the same size as this one.
	if (color) {
		UIGraphicsBeginImageContextWithOptions(self.size, NO, self.scale);
		CGContextRef context = UIGraphicsGetCurrentContext();
		CGContextTranslateCTM(context, 0, self.size.height);
		CGContextScaleCTM(context, 1.0, -1.0);
		CGContextSetBlendMode(context, kCGBlendModeNormal);
		CGRect rect = CGRectMake(0, 0, self.size.width, self.size.height);
		CGContextClipToMask(context, rect, self.CGImage);
		[color setFill];
		CGContextFillRect(context, rect);
		UIImage* newImage = UIGraphicsGetImageFromCurrentImageContext();
		UIGraphicsEndImageContext();
		return newImage;

	}
	return self;
}

+ (UIImage*)convertImageToGrayScale: (UIImage*)image {

//    CIImage *beginImage = [CIImage imageWithCGImage:image.CGImage];
//    CIFilter *filter = [CIFilter filterWithName:@"CIPhotoEffectTonal"];
//    [filter setValue:beginImage forKey:@"inputImage"];
//    CIImage *output = [filter outputImage];
//    
//    CIContext *context = [CIContext contextWithOptions:nil];
//    CGImageRef cgiimage = [context createCGImage:output fromRect:output.extent];
//    UIImage *newImage = [UIImage imageWithCGImage:cgiimage];
//    
//    CGImageRelease(cgiimage);

	UIGraphicsBeginImageContextWithOptions(image.size, NO, 0.0f);

	CGContextRef ctx = UIGraphicsGetCurrentContext();
	CGRect area = CGRectMake(0, 0, image.size.width, image.size.height);

	CGContextScaleCTM(ctx, 1, -1);
	CGContextTranslateCTM(ctx, 0, -area.size.height);

	CGContextSetBlendMode(ctx, kCGBlendModeMultiply);

	CGContextSetAlpha(ctx, 0.7);

	CGContextDrawImage(ctx, area, image.CGImage);

	UIImage* newImage = UIGraphicsGetImageFromCurrentImageContext();

	UIGraphicsEndImageContext();

	return newImage;
}

@end
