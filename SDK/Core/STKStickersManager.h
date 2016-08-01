//
//  STKStickersClient.h
//  StickerFactory
//
//  Created by Vadim Degterev on 25.06.15.
//  Copyright (c) 2015 908 Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@class STKStickerController;

@interface STKStickersManager : NSObject

+ (void)initWithApiKey: (NSString*)apiKey;

+ (void)setUserKey: (NSString*)userKey;
+ (NSString*)userKey;

+ (void)setLocalization: (NSString*)localization;
+ (NSString*)localization;

+ (BOOL)isStickerMessage: (NSString*)message;

+ (BOOL)isOldFormatStickerMessage: (NSString*)message;

+ (void)setStartTimeInterval;

+ (void)setPriceBWithLabel: (NSString*)priceLabel
				  andValue: (CGFloat)priceValue;

+ (NSString*)priceBLabel;
+ (CGFloat)priceBValue;

+ (void)setPriceCwithLabel: (NSString*)priceLabel
				  andValue: (CGFloat)priceValue;

+ (NSString*)priceCLabel;
+ (CGFloat)priceCValue;

+ (void)setUserAsSubscriber: (BOOL)subscriber;
+ (BOOL)isSubscriber;

+ (void)setPriceBProductId: (NSString*)priceBProductId andPriceCProductId: (NSString*)priceCProductId;

+ (void)setDownloadMaxImages: (BOOL)downloadMaxImages;
+ (BOOL)downloadMaxImages;

+ (void)sendDeviceToken: (NSData*)deviceToken
				failure: (void (^)(NSError*))failure;

+ (void)getUserInfo: (NSDictionary*)info stickerController: (STKStickerController*)stickerController;

+ (void)setShopContentColor: (UIColor*)color;

@end
