//
//  STKUtility.h
//  StickerFactory
//
//  Created by Vadim Degterev on 26.06.15.
//  Copyright (c) 2015 908 Inc. All rights reserved.
//


@interface STKUtility : NSObject

+ (NSArray*)trimmedPackNameAndStickerNameWithMessage: (NSString*)message;
+ (NSString*)stickerIdWithMessage: (NSString*)message;

+ (NSString*)scaleString;
+ (NSString*)maxDensity;

//Colors
+ (UIColor*)defaultOrangeColor;
+ (UIColor*)defaultGreyColor;
+ (UIColor*)defaultPlaceholderGrayColor;
+ (UIColor*)defaultBlueColor;

void STKLog(NSString* format, ...);

@end
