//
//  STKUtility.m
//  StickerFactory
//
//  Created by Vadim Degterev on 26.06.15.
//  Copyright (c) 2015 908 Inc. All rights reserved.
//

#import <CommonCrypto/CommonDigest.h>
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
		default:;
	}

	return @"xxhdpi";
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


+ (NSBundle*)getResourceBundle {
	NSString* bundlePath = [[NSBundle mainBundle] pathForResource: @"ResBundle" ofType: @"bundle"];
	NSBundle* bundle = [NSBundle bundleWithPath: bundlePath];

	return bundle;
}

@end



@implementation NSString(MD5String)

- (NSString*)MD5Digest {
	const char* input = [self UTF8String];
	unsigned char result[CC_MD5_DIGEST_LENGTH];
	CC_MD5(input, (CC_LONG) strlen(input), result);

	NSMutableString* digest = [NSMutableString stringWithCapacity: CC_MD5_DIGEST_LENGTH * 2];
	for (NSInteger i = 0; i < CC_MD5_DIGEST_LENGTH; i++) {
		[digest appendFormat: @"%02x", result[i]];
	}

	return digest;
}

@end

@implementation NSBundle (CustomBundle)

+ (NSBundle*)stkBundle {
	return [NSBundle mainBundle];
}

+ (NSArray*)loadNibNamed: (NSString*)name owner: (id)owner options: (NSDictionary*)options {
	return [[NSBundle mainBundle] loadNibNamed: name owner: owner options: options];
}

@end


@implementation UIViewController (CustomBundle)

+ (instancetype)viewControllerFromNib: (NSString*)nibName {
	return [[self alloc] initWithNibName: nibName bundle: [NSBundle mainBundle]];
}

@end
