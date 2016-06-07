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

+ (void) initWitApiKey:(NSString*) apiKey;

+ (void)setUserKey:(NSString *)userKey;
+ (NSString *)userKey;

+ (void)setLocalization:(NSString *)localization;
+ (NSString *)localization;

- (void) getStickerForMessage:(NSString*) message
                     progress:(void(^)(double progress)) progress
                      success:(void(^)(UIImage *sticker))success
                      failure:(void(^)(NSError *error, NSString *errorMessage)) failure;

+ (BOOL) isStickerMessage:(NSString*) message;

+ (BOOL) isOldFormatStickerMessage:(NSString*) message;

+ (void)setStartTimeInterval;

+ (void)setPriceBWithLabel:(NSString *)priceLabel
                  andValue:(CGFloat)priceValue;

+ (NSString *)priceBLabel;
+ (CGFloat)priceBValue;

+ (void)setPriceCwithLabel:(NSString *)priceLabel
                  andValue:( CGFloat)priceValue;

+ (NSString *)priceCLabel;
+ (CGFloat)priceCValue;

+ (void)setUserIsSubscriber:(BOOL)isSubscriber;
+ (BOOL)isSubscriber;

+ (void)setPriceBProductId:(NSString *)priceBProductId andPriceCProductId:(NSString *)priceCProductId;

+ (void)setDownloadMaxImages:(BOOL)downloadMaxImages;
+ (BOOL)downloadMaxImages;

+ (void)sendDeviceToken:(NSData *)deviceToken
                failure:(void (^)(NSError *))failure;

+ (void)getUserInfo:(NSDictionary *)info stickerController:(STKStickerController *)stickerController;

@end
