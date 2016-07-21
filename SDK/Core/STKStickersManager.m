//
//  STKStickersClient.m
//  StickerFactory
//
//  Created by Vadim Degterev on 25.06.15.
//  Copyright (c) 2015 908 Inc. All rights reserved.
//

#import "STKStickersManager.h"
#import "DFImageManagerKit.h"
#import "STKUtility.h"
#import "STKAnalyticService.h"
#import "STKApiKeyManager.h"
#import "STKInAppProductsManager.h"
#import "STKCoreDataService.h"
#import "STKStickersConstants.h"
#import "NSString+MD5.h"
#import "STKStickersApiService.h"

#import "STKStickerController.h"

static BOOL downloadMaxIm = NO;

@interface STKStickersManager()

@end

@implementation STKStickersManager

#pragma mark - Validation

+ (BOOL)isStickerMessage:(NSString *)message {
//    NSString *regexPattern = @"^\\[\\[[a-zA-Z0-9]+_[a-zA-Z0-9]+\\]\\]$";
//    NSString *regexPattern = @"^\\[\\[[a-zA-Z0-9]+\\]\\]$";
    NSString *regexPattern = @"^\\[\\[(.*)\\]\\]";

    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regexPattern];
    
    BOOL isStickerMessage = [predicate evaluateWithObject:message];
    
    return isStickerMessage;
}

+ (BOOL)isOldFormatStickerMessage:(NSString *)message  {
    NSString *regexPattern = @"^\\[\\[[a-zA-Z0-9]+_[a-zA-Z0-9]+\\]\\]$";
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regexPattern];
    
    BOOL isStickerMessage = [predicate evaluateWithObject:message];
    
    return isStickerMessage;
}


#pragma mark - ApiKey

+ (void)initWithApiKey:(NSString *)apiKey {
    [STKApiKeyManager setApiKey:apiKey];
    [STKCoreDataService setupCoreData];
}

#pragma mark - User key

+ (void)setUserKey:(NSString *)userKey {
    NSString *hashUserKey = [[userKey stringByAppendingString:[STKApiKeyManager apiKey]] MD5Digest];
    [[NSUserDefaults standardUserDefaults] setObject:hashUserKey forKey:kUserKeyDefaultsKey];
}

+ (NSString *)userKey {
    return [[NSUserDefaults standardUserDefaults] stringForKey:kUserKeyDefaultsKey];
}

#pragma mark - Localization

+ (void)setLocalization:(NSString *)localization {
    [[NSUserDefaults standardUserDefaults] setObject:localization forKey:kLocalizationDefaultsKey];
}

+ (NSString *)localization {
    return [[NSUserDefaults standardUserDefaults] stringForKey:kLocalizationDefaultsKey];
}

#pragma mark - Srart time interval

+ (void)setStartTimeInterval {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setDouble:0 forKey:kLastUpdateIntervalKey];
    [defaults synchronize];
}

#pragma mark - Prices

+ (void)setPriceBWithLabel:(NSString *)priceLabel andValue:(CGFloat)priceValue {
    [[NSUserDefaults standardUserDefaults] setObject:priceLabel forKey:kPriceBLabel];
    [[NSUserDefaults standardUserDefaults] setFloat:priceValue forKey:kPriceBValue];
}

+ (NSString *)priceBLabel {
    return [[NSUserDefaults standardUserDefaults] stringForKey:kPriceBLabel];
}

+ (CGFloat)priceBValue {
    return [[NSUserDefaults standardUserDefaults] floatForKey:kPriceBValue];
}

+ (void)setPriceCwithLabel:(NSString *)priceLabel andValue:(CGFloat)priceValue {
    [[NSUserDefaults standardUserDefaults] setObject:priceLabel forKey:kPriceCLabel];
    [[NSUserDefaults standardUserDefaults] setFloat:priceValue forKey:kPriceCValue];
}

+ (NSString *)priceCLabel {
    return [[NSUserDefaults standardUserDefaults] stringForKey:kPriceCLabel];
}

+ (CGFloat)priceCValue {
    return [[NSUserDefaults standardUserDefaults] floatForKey:kPriceCValue];
}

#pragma mark - Subscriber

+ (void)setUserAsSubscriber:(BOOL)subscriber {
    [[NSUserDefaults standardUserDefaults] setBool:subscriber forKey:kIsSubscriber] ;
}

+ (BOOL)isSubscriber {
    return [[NSUserDefaults standardUserDefaults] boolForKey:kIsSubscriber];
}

#pragma mark - In-app product ids

+ (void)setPriceBProductId:(NSString *)priceBProductId andPriceCProductId:(NSString *)priceCProductId {
    [STKInAppProductsManager setPriceBproductId:priceBProductId];
    [STKInAppProductsManager setPriceCproductId:priceCProductId];
}

#pragma mark - max images

+ (void)setDownloadMaxImages:(BOOL)downloadMaxImages {
    downloadMaxIm = downloadMaxImages;
}

+ (BOOL)downloadMaxImages {
    return downloadMaxIm;
}

+ (void)sendDeviceToken:(NSData *)deviceToken
          failure:(void (^)(NSError *))failure {
    
    NSString * token = [NSString stringWithFormat:@"%@", deviceToken];
    //Format token as you need:
    token = [token stringByReplacingOccurrencesOfString:@" " withString:@""];
    token = [token stringByReplacingOccurrencesOfString:@">" withString:@""];
    token = [token stringByReplacingOccurrencesOfString:@"<" withString:@""];
    
    NSLog(@"My token is: %@", token);
    
    STKStickersApiService *apiServise = [STKStickersApiService new];
    [apiServise sendDeviceToken:token failure:^(NSError *error) {
        failure(error);
    }];
}

+ (void)getUserInfo:(NSDictionary *)info stickerController:(STKStickerController *)stickerController {
    NSString *packName = info[@"pack"];
    NSString *pushId = [NSString stringWithFormat:@"%@", info[@"push_id"]];
    
    [[STKAnalyticService sharedService] sendEventWithCategory:@"app_open" action:@"push" label:pushId value:nil];
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setObject:@"yes" forKey:@"isNotification"];
    [userDefaults synchronize];
    
    [stickerController showPackInfoControllerWithName:packName];
}

+ (void)setShopContentColor:(UIColor *)color {
    CGFloat red = 0.0, green = 0.0, blue = 0.0, alpha =0.0;
    [color getRed:&red green:&green blue:&blue alpha:&alpha];
    
    int r,g,b,a;
    
    r = (int)(255.0 * red);
    g = (int)(255.0 * green);
    b = (int)(255.0 * blue);
    a = (int)(255.0 * alpha);
    NSString *colorForShop = [NSString stringWithFormat:@"%02x%02x%02x", r, g, b];
    
    [[NSUserDefaults standardUserDefaults] setObject:colorForShop forKey:kShopColor];
 }

@end
