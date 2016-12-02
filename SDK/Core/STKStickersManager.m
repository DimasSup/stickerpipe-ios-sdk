//
//  STKStickersClient.m
//  StickerFactory
//
//  Created by Vadim Degterev on 25.06.15.
//  Copyright (c) 2015 908 Inc. All rights reserved.
//

#import <CoreData/CoreData.h>
#import "STKStickersManager.h"
#import "STKAnalyticService.h"
#import "STKApiKeyManager.h"
#import "STKInAppProductsManager.h"
#import "STKStickersConstants.h"
#import "STKStickerController.h"
#import "STKWebserviceManager.h"
#import "STKUtility.h"
#import "STKStickersEntityService.h"
#import "NSPersistentStoreCoordinator+STKAdditions.h"
#import "NSManagedObjectContext+STKAdditions.h"

static BOOL downloadMaxIm = NO;


@implementation STKStickersManager

#pragma mark - Validation

+ (BOOL)isStickerMessage: (NSString*)message {
	NSString* regexPattern = @"^\\[\\[(.*)\\]\\]";

	NSPredicate* predicate = [NSPredicate predicateWithFormat: @"SELF MATCHES %@", regexPattern];

	return [predicate evaluateWithObject: message];
}

+ (BOOL)isOldFormatStickerMessage: (NSString*)message {
	NSString* regexPattern = @"^\\[\\[[a-zA-Z0-9]+_[a-zA-Z0-9]+\\]\\]$";
	NSPredicate* predicate = [NSPredicate predicateWithFormat: @"SELF MATCHES %@", regexPattern];

	BOOL isStickerMessage = [predicate evaluateWithObject: message];

	return isStickerMessage;
}


#pragma mark - ApiKey

+ (void)initWithApiKey: (NSString*)apiKey {
	[STKApiKeyManager setApiKey: apiKey];

	NSPersistentStoreCoordinator* coordinator = [NSPersistentStoreCoordinator stk_defaultPersistentsStoreCoordinator];

	[NSManagedObjectContext stk_setupContextStackWithPersistanceStore: coordinator];
}

#pragma mark - User key

+ (void)setUserKey: (NSString*)userKey {
	NSString* hashUserKey = [[userKey stringByAppendingString: [STKApiKeyManager apiKey]] MD5Digest];
	[[NSUserDefaults standardUserDefaults] setObject: hashUserKey forKey: kUserKeyDefaultsKey];
}

+ (NSString*)userKey {
	return [[NSUserDefaults standardUserDefaults] stringForKey: kUserKeyDefaultsKey];
}

#pragma mark - Localization

+ (void)setLocalization: (NSString*)localization {
	[[NSUserDefaults standardUserDefaults] setObject: localization forKey: kLocalizationDefaultsKey];
}

+ (NSString*)localization {
	return [[NSUserDefaults standardUserDefaults] stringForKey: kLocalizationDefaultsKey];
}

#pragma mark - Prices

+ (void)setPriceBWithLabel: (NSString*)priceLabel andValue: (CGFloat)priceValue {
	[[NSUserDefaults standardUserDefaults] setObject: priceLabel forKey: kPriceBLabel];
	[[NSUserDefaults standardUserDefaults] setFloat: priceValue forKey: kPriceBValue];
}

+ (NSString*)priceBLabel {
	return [[NSUserDefaults standardUserDefaults] stringForKey: kPriceBLabel];
}

+ (CGFloat)priceBValue {
	return [[NSUserDefaults standardUserDefaults] floatForKey: kPriceBValue];
}

+ (void)setPriceCwithLabel: (NSString*)priceLabel andValue: (CGFloat)priceValue {
	[[NSUserDefaults standardUserDefaults] setObject: priceLabel forKey: kPriceCLabel];
	[[NSUserDefaults standardUserDefaults] setFloat: priceValue forKey: kPriceCValue];
}

+ (NSString*)priceCLabel {
	return [[NSUserDefaults standardUserDefaults] stringForKey: kPriceCLabel];
}

+ (CGFloat)priceCValue {
	return [[NSUserDefaults standardUserDefaults] floatForKey: kPriceCValue];
}

#pragma mark - Subscriber

+ (void)setUserAsSubscriber: (BOOL)subscriber {
	[[NSUserDefaults standardUserDefaults] setBool: subscriber forKey: kIsSubscriber];
}

+ (BOOL)isSubscriber {
	return [[NSUserDefaults standardUserDefaults] boolForKey: kIsSubscriber];
}

#pragma mark - In-app product ids

+ (void)setPriceBProductId: (NSString*)priceBProductId andPriceCProductId: (NSString*)priceCProductId {
	[STKInAppProductsManager setPriceBproductId: priceBProductId];
	[STKInAppProductsManager setPriceCproductId: priceCProductId];
}

#pragma mark - max images

+ (void)setDownloadMaxImages: (BOOL)downloadMaxImages {
	downloadMaxIm = downloadMaxImages;
}

+ (BOOL)downloadMaxImages {
	return downloadMaxIm;
}

+ (void)sendDeviceToken: (NSData*)deviceToken
				failure: (void (^)(NSError*))failure {

	NSString* token = [NSString stringWithFormat: @"%@", deviceToken];
	//Format token as you need:
	token = [token stringByReplacingOccurrencesOfString: @" " withString: @""];
	token = [token stringByReplacingOccurrencesOfString: @">" withString: @""];
	token = [token stringByReplacingOccurrencesOfString: @"<" withString: @""];

	NSLog(@"My token is: %@", token);

	[[STKWebserviceManager sharedInstance] sendDeviceToken: token failure: ^ (NSError* error) {
		failure(error);
	}];
}

+ (void)getUserInfo: (NSDictionary*)info stickerController: (STKStickerController*)stickerController {
	NSString* packName = info[@"pack"];
	NSString* pushId = [NSString stringWithFormat: @"%@", info[@"push_id"]];

	[[STKAnalyticService sharedService] sendEventWithCategory: @"app_open" action: @"push" label: pushId value: nil];

	NSUserDefaults* userDefaults = [NSUserDefaults standardUserDefaults];
	[userDefaults setObject: @"yes" forKey: @"isNotification"];
	[userDefaults synchronize];

	[stickerController showPackInfoControllerWithName: packName];
}

+ (void)setShopContentColor: (UIColor*)color {
	CGFloat red = 0.0, green = 0.0, blue = 0.0, alpha = 0.0;
	[color getRed: &red green: &green blue: &blue alpha: &alpha];

	int r, g, b;

	r = (int) (255.0 * red);
	g = (int) (255.0 * green);
	b = (int) (255.0 * blue);
	NSString* colorForShop = [NSString stringWithFormat: @"%02x%02x%02x", r, g, b];

	[[NSUserDefaults standardUserDefaults] setObject: colorForShop forKey: kShopColor];
}

+ (void)setStartTimeInterval {
//TODO: -temp, remove

	NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];

	if ([defaults doubleForKey: kLastUpdateIntervalKey] == 0) {
		STKLog(@"-setStartTimeInterval calls automatically after each initialization of STKStickerController; you don't need to call it by yourself");
	}

	[defaults setDouble: 0 forKey: kLastUpdateIntervalKey];
}

@end
