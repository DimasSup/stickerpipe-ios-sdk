//
//  STKStickersEntityService.h
//  StickerPipe
//
//  Created by Vadim Degterev on 27.07.15.
//  Copyright (c) 2015 908 Inc. All rights reserved.
//


@class STKStickerPackObject, STKSticker, STKStickerObject;

@interface STKStickersEntityService : NSObject

@property (nonatomic) NSArray* stickersArray;

@property BOOL hasNewModifiedPacks;

- (void)getStickerPacksWithType: (NSString*)type
					 completion: (void (^)(NSArray* stickerPacks))completion
						failure: (void (^)(NSError* error))failure;

- (void)incrementStickerUsedCountWithID: (NSNumber*)stickerID;

- (void)getStickerPacksIgnoringRecentWithType: (NSString*)type
								   completion: (void (^)(NSArray* stickerPacks))completion
									  failure: (void (^)(NSError* error))failre;

- (void)getPackWithMessage: (NSString*)message completion: (void (^)(STKStickerPackObject* stickerPack, BOOL isDownloaded))completion;

- (void)getPackNameForMessage: (NSString*)message completion: (void (^)(NSString* packName))completion;

- (void)downloadNewPack: (NSDictionary*)packDict onSuccess: (void (^)(void))success;

- (STKStickerPackObject*)getStickerPackWithName: (NSString*)packName;

- (STKStickerPackObject*)recentPack;

- (NSString*)packNameForStickerId: (NSString*)stickerId;

- (BOOL)isPackDownloaded: (NSString*)packName;

- (void)saveStickerPack: (STKStickerPackObject*)stickerPack;

- (void)saveStickerPacks: (NSArray*)stickerPacks;

- (void)updateStickerPackInCache: (STKStickerPackObject*)stickerPackObject;

- (void)togglePackDisabling: (STKStickerPackObject*)pack;

- (BOOL)hasRecentStickers;

- (BOOL)hasNewPacks;

- (BOOL)hasPackWithName: (NSString*)packName;
- (NSUInteger)indexOfPackWithName: (NSString*)packName;

- (void)stickerWithStickerID: (NSNumber*)stickerID completion: (void (^)(STKSticker* sticker))completion;

- (void)saveSticker: (STKStickerObject*)stickerObject;

@end
