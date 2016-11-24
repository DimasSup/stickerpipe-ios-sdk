//
// Created by vlad on 7/27/16.
// Copyright (c) 2016 908 Inc. All rights reserved.
//

@class AFHTTPSessionManager;
@class STKSearchModel;

@interface STKWebserviceManager : NSObject
+ (instancetype)sharedInstance;

//
// KVO compatible
@property (nonatomic, readonly) BOOL networkReachable;
//

- (void)searchStickersWithSearchModel: (STKSearchModel*)searchModel completion: (void (^)(NSArray* stickers))completion;

- (void)loadStickerPackWithName: (NSString*)packName andPricePoint: (NSString*)pricePoint
						success: (void (^)(id))success
						failure: (void (^)(NSError*))failure;

- (void)getStickersPacksForUserWithSuccess: (void (^)(id response, NSTimeInterval lastModifiedDate))success
								   failure: (void (^)(NSError* error))failure;

- (void)sendStatistics: (NSArray*)statisticsArray
			   success: (void (^)(id response))success
			   failure: (void (^)(NSError* error))failure;

- (void)getStickerPackWithName: (NSString*)packName
					   success: (void (^)(id response))success
					   failure: (void (^)(NSError* error))failure;

- (void)getStickerInfoWithId: (NSString*)contentId
					 success: (void (^)(id response))success
					 failure: (void (^)(NSError*))failure;


- (void)deleteStickerPackWithName: (NSString*)packName
						  success: (void (^)(id))success
						  failure: (void (^)(NSError*))failure;

- (void)sendDeviceToken: (NSString*)token
				failure: (void (^)(NSError*))failure;

- (void)sendAnErrorWithCategory: (NSString*)category p1: (NSString*)p1 p2: (NSString*)p2;
//
// check networkReachable after calling it; idempotent method
- (void)startCheckingNetwork;
//

//TODO:rename it
- (NSString*)stickerUrl;

- (NSURL*)imageUrlForStickerMessage: (NSString*)stickerMessage andDensity: (NSString*)density;
- (NSURL*)imageUrlForStickerPanelWithMessage: (NSString*)stickerMessage;
- (NSURL*)tabImageUrlForPackName: (NSString*)name;
- (NSURL*)mainImageUrlForPackName: (NSString*)name;
@end
