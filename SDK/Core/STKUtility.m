//
//  STKUtility.m
//  StickerFactory
//
//  Created by Vadim Degterev on 26.06.15.
//  Copyright (c) 2015 908 Inc. All rights reserved.
//

#import "STKUtility.h"

@implementation STKUtility

+ (NSArray*)trimmedPackNameAndStickerNameWithMessage: (NSString*)message {
	NSCharacterSet* characterSet = [NSCharacterSet characterSetWithCharactersInString: @"[]"];
	NSString* packNameAndStickerName = [message stringByTrimmingCharactersInSet: characterSet];

	return [packNameAndStickerName componentsSeparatedByString: @"_"];
}

+ (NSString*)stickerIdWithMessage: (NSString*)message {
	NSCharacterSet* characterSet = [NSCharacterSet characterSetWithCharactersInString: @"[]"];

	return [message stringByTrimmingCharactersInSet: characterSet];
}

+ (NSString*)maxDensity {
	return @"xxhdpi";
}

+ (NSString*)scaleString {
	//Android style scale
	switch ((NSInteger) [UIScreen mainScreen].scale) {
		case 1:
			return @"mdpi";
		case 2:
			return @"xhdpi";
		case 3:
			return @"xxhdpi";
		default:
			return nil;
	}
}


#pragma mark - Colors

+ (UIColor*)defaultOrangeColor {
	return [UIColor colorWithRed: 1 green: 0.34 blue: 0.13 alpha: 1];
}

+ (UIColor*)defaultGreyColor {
	return [UIColor colorWithRed: 229.0f / 255.0f green: 229.0f / 255.0f blue: 234.0f / 255.0f alpha: 1];
}

+ (UIColor*)defaultPlaceholderGrayColor {
	return [UIColor colorWithRed: 142.0f / 255.0f green: 142.0f / 255.0f blue: 147.0f / 255.0f alpha: 1];
}

+ (UIColor*)defaultBlueColor {
	return [UIColor colorWithRed: 4.0f / 255.0f green: 122 / 255.0f blue: 1.0f alpha: 1];
}


#pragma mark - STKLog

void STKLog(NSString* format, ...) {
	va_list argumentList;
	va_start(argumentList, format);
#if DEBUG

	NSLogv(format, argumentList);
#endif
	va_end(argumentList);
}

@end
