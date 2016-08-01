
//
//  STKStickersEntityService.m
//  StickerPipe
//
//  Created by Vadim Degterev on 27.07.15.
//  Copyright (c) 2015 908 Inc. All rights reserved.
//

#import "STKStickersEntityService.h"
#import "STKStickersCache.h"
#import "STKStickersSerializer.h"
#import "STKStickerPackObject.h"
#import "STKUtility.h"
#import "STKStickersConstants.h"
#import "STKStickerPack.h"
#import "STKWebserviceManager.h"

@interface STKStickersEntityService ()

@property (nonatomic) STKStickersCache* cacheEntity;
@property (nonatomic) STKStickersSerializer* serializer;
@property (nonatomic) dispatch_queue_t queue;

@end

@implementation STKStickersEntityService

static STKConstStringKey kLastModifiedDateKey = @"kLastModifiedDateKey";
static const NSUInteger kFirstNewStickers = 3;
static const NSTimeInterval kUpdatesDelay = 900.0; //15 min

- (instancetype)init {
	if (self = [super init]) {
		self.cacheEntity = [STKStickersCache new];
		self.serializer = [STKStickersSerializer new];
		self.queue = dispatch_queue_create("com.stickers.service", DISPATCH_QUEUE_SERIAL);
	}

	return self;
}

- (void)packDownloaded: (NSNotification*)notification {
	NSDictionary* pack = notification.userInfo[@"packDict"];

	[self getStickerPacksIgnoringRecentWithType: nil completion: ^ (NSArray* stickerPacks) {
		self.stickersArray = [self processNewPack: pack withStickerPacks: stickerPacks];
	}                                   failure: nil];
}

- (void)downloadNewPack: (NSDictionary*)packDict onSuccess: (void (^)(void))success {
	NSDictionary* pack = packDict;
	[self.cacheEntity getAllPacksIgnoringRecent: ^ (NSArray* stickerPacks) {
		[self processNewPack: pack withStickerPacks: stickerPacks];

		success();
	}];
}

- (NSArray* )processNewPack: (NSDictionary*)newPack withStickerPacks: (NSArray*)stickerPacks {
	STKStickerPackObject* object = [self.serializer serializeStickerPack: newPack];
	object.order = @0;
	object.disabled = @NO;

	for (STKStickerPackObject* stickerPack in stickerPacks) {
		stickerPack.order = @(stickerPack.order.integerValue + 1);
	}

	NSArray* array = [stickerPacks arrayByAddingObject: object];
	[self saveStickerPacks: array];
	return array;
}


#pragma mark - Get sticker packs

- (void)loadStickerPacksFromCache: (NSString*)type completion: (void (^)(NSArray*))completion {
	typeof(self) __weak weakSelf = self;

	[self.cacheEntity getStickerPacks: ^ (NSArray* stickerPacks) {
		if (stickerPacks.count != 0) {
			[weakSelf loadStickersForPacks: stickerPacks completion: ^ (NSArray* stickerPacks) {
				dispatch_async(dispatch_get_main_queue(), ^ {
					completion(stickerPacks);
				});
			}];
		}
	}];
}

- (void)loadStickersForPacks: (NSArray*)packs completion: (void (^)(NSArray*))completion {
	if (packs.count > 1) {
		for (NSUInteger i = 1; i < packs.count; i++) {
			STKStickerPackObject* pack = packs[i];
			if (pack.stickers.count == 0 && ![pack.disabled boolValue]) {
				[[STKWebserviceManager sharedInstance] loadStickerPackWithName: pack.packName andPricePoint: pack.pricePoint success: ^ (id response) {
					NSDictionary* serverPack = response[@"data"];
					STKStickerPackObject* object = [self.serializer serializeStickerPack: serverPack];
					pack.stickers = object.stickers;
					[self.cacheEntity updateStickerPack: pack];
					dispatch_async(dispatch_get_main_queue(), ^ {
						completion(packs);
					});
				}                                                      failure: nil];
			}

			if (i == packs.count - 1) {
				dispatch_async(dispatch_get_main_queue(), ^ {
					[[NSNotificationCenter defaultCenter] postNotificationName: STKStickersDownloadedNotification object: self];
					completion(packs);
				});
			}
		}
	} else {
		dispatch_async(dispatch_get_main_queue(), ^ {
			completion(packs);
		});
	}
}

- (void)getStickerPacksWithType: (NSString*)type
					 completion: (void (^)(NSArray*))completion
						failure: (void (^)(NSError*))failure {
	typeof(self) __weak weakSelf = self;
//TODO: Handle error, Split this method
	NSTimeInterval lastUpdate = [self lastUpdateDate];
	NSTimeInterval timeSinceLastUpdate = [[NSDate date] timeIntervalSince1970] - lastUpdate;
	if (timeSinceLastUpdate > kUpdatesDelay) {
		[weakSelf updateStickerPacksFromServerWithType: type completion: ^ (NSError* error) {
			[weakSelf loadStickerPacksFromCache: type completion: ^ (NSArray* stickerPacks) {
				if (completion) {
					dispatch_async(dispatch_get_main_queue(), ^ {
						completion(stickerPacks);
					});
				}
			}];
		}];
	} else {
		[weakSelf loadStickerPacksFromCache: type completion: completion];
	}
}

- (void)getPackWithMessage: (NSString*)message completion: (void (^)(STKStickerPackObject*, BOOL))completion {
	NSArray* separaredStickerNames = [STKUtility trimmedPackNameAndStickerNameWithMessage: message];
	NSString* packName = [[separaredStickerNames firstObject] lowercaseString];

	STKStickerPackObject* stickerPackObject = [self.cacheEntity getStickerPackWithPackName: packName];
	if (!stickerPackObject) {
		[[STKWebserviceManager sharedInstance] getStickerPackWithName: packName success: ^ (id response) {
			NSDictionary* serverPack = response[@"data"];
			STKStickerPackObject* object = [self.serializer serializeStickerPack: serverPack];
			//TODO:Refactoring
			if (![self isPackDownloaded: object.packName]) {
				[self.cacheEntity saveDisabledStickerPack: object];
				object.disabled = @YES;
			}

			if (completion) {
				dispatch_async(dispatch_get_main_queue(), ^ {
					completion(object, NO);
				});
			}
		}                               failure: nil];
	} else {
		if (completion) {
			dispatch_async(dispatch_get_main_queue(), ^ {
				completion(stickerPackObject, YES);
			});
		}
	}
}

- (void)getPackNameForMessage: (NSString*)message completion: (void (^)(NSString*))completion {
	[[STKWebserviceManager sharedInstance] getStickerInfoWithId: [STKUtility stickerIdWithMessage: message] success: ^ (id response) {
		NSString* packname = response[@"data"][@"pack"];
		if (completion) {
			completion(packname);
		}
	}                             failure: nil];
}

- (void)getStickerPacksIgnoringRecentWithType: (NSString*)type
								   completion: (void (^)(NSArray*))completion
									  failure: (void (^)(NSError*))failre {
	[self.cacheEntity getStickerPacksIgnoringRecentForContext: self.cacheEntity.mainContext
													 response: ^ (NSArray* stickerPacks) {
														 if (completion) {
															 completion(stickerPacks);
														 }
													 }];

}

- (STKStickerPackObject*)getStickerPackWithName: (NSString*)packName {
	return [self.cacheEntity getStickerPackWithPackName: packName];
}


#pragma mark - Update sticker packs

- (void)updateStickerPacksFromServerWithType: (NSString*)type completion: (void (^)(NSError* error))completion {
	[[STKWebserviceManager sharedInstance] getStickersPacksForUserWithSuccess: ^ (id response, NSTimeInterval lastModifiedDate) {
		dispatch_async(self.queue, ^ {
			NSArray* serializedObjects = [self.serializer serializeStickerPacks: response[@"data"]];
			NSError* error = [self.cacheEntity saveStickerPacks: serializedObjects];
			if (lastModifiedDate > [self lastModifiedDate]) {
				self.hasNewModifiedPacks = YES;
				[self setLastModifiedDate: lastModifiedDate];
			} else {
				self.hasNewModifiedPacks = NO;
			}
			[self setLastUpdateDate: [[NSDate date] timeIntervalSince1970]];
			if (completion) {
				dispatch_async(dispatch_get_main_queue(), ^ {
					completion(error);
				});
			}
		});
	}                                                                 failure: ^ (NSError* error) {
		if (completion) {
			//TODO:REfactoring
			completion(error);
		}
	}];
}


#pragma mark ----------

- (void)saveStickerPacks: (NSArray*)stickerPacks {
	[self.cacheEntity saveStickerPacks: stickerPacks];
}

- (void)updateStickerPackInCache: (STKStickerPackObject*)stickerPackObject {
	[self.cacheEntity updateStickerPack: stickerPackObject];
}

- (void)incrementStickerUsedCountWithID: (NSNumber*)stickerID {
	[self.cacheEntity incrementUsedCountWithStickerID: stickerID];
}

- (void)stickerWithStickerID: (NSNumber*)stickerID completion: (void (^)(STKSticker* sticker))completion {
	[self.cacheEntity stickerWithStickerID: stickerID completion: completion];
}

- (void)togglePackDisabling: (STKStickerPackObject*)pack {
	BOOL status = pack.disabled.boolValue;
	pack.disabled = @(!status);

	[self.cacheEntity markStickerPack: pack disabled: !status];
}

- (BOOL)hasRecentStickers {
	return [[self.cacheEntity recentStickerPack].stickers count] > 0;
}

- (STKStickerPackObject*)recentPack {
	return [self.cacheEntity recentStickerPack];
}

- (NSString*)packNameForStickerId: (NSString*)stickerId {
	return [self.cacheEntity packNameForStickerId: stickerId];
}

- (BOOL)hasNewPacks {
	NSArray* arr = self.stickersArray;
	NSUInteger newsCount = 0;
	NSUInteger size = (arr.count < kFirstNewStickers + 1) ? arr.count : kFirstNewStickers + 1;
	for (NSUInteger i = 0; i < size; i++) {
		STKStickerPackObject* stickerPack = arr[i];
		if (stickerPack.isNew.boolValue) {
			newsCount++;
		}
	}
	return ![self hasRecentStickers] || newsCount > 0;
}


#pragma mark Check save delete

- (BOOL)isPackDownloaded: (NSString*)packName {

	return [self.cacheEntity isStickerPackDownloaded: packName];
}

- (void)saveStickerPack: (STKStickerPackObject*)stickerPack {
	[self.cacheEntity saveStickerPacks: @[stickerPack]];
}


#pragma mark - LastUpdateTime

- (NSTimeInterval)lastUpdateDate {
	NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
	NSTimeInterval lastUpdateDate = [defaults doubleForKey: kLastUpdateIntervalKey];
	return lastUpdateDate;
}

- (void)setLastUpdateDate: (NSTimeInterval)lastUpdateInterval {
	NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
	[defaults setDouble: lastUpdateInterval forKey: kLastUpdateIntervalKey];
}


#pragma mark - LastModifiedDate

- (NSTimeInterval)lastModifiedDate {
	NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
	NSTimeInterval timeInterval = [defaults doubleForKey: kLastModifiedDateKey];
	return timeInterval;
}

- (void)setLastModifiedDate: (NSTimeInterval)lastModifiedDate {
	NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
	[defaults setDouble: lastModifiedDate forKey: kLastModifiedDateKey];
}


#pragma mark -----

- (NSUInteger)indexOfPackWithName: (NSString*)packName {
	NSPredicate* predicate = [NSPredicate predicateWithFormat: @"%K == %@", STKStickerPackAttributes.packName, packName];
	STKStickerPackObject* stickerPack = [[self.stickersArray filteredArrayUsingPredicate: predicate] firstObject];

	NSUInteger stickerIndex = [self.stickersArray indexOfObject: stickerPack];

	return stickerIndex;
}

- (BOOL)hasPackWithName: (NSString*)packName {
	return [self.cacheEntity hasPackWithName: packName];
}

- (void)saveSticker: (STKStickerObject*)stickerObject {
	[self.cacheEntity saveSticker: stickerObject];
}

@end
