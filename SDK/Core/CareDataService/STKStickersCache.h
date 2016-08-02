//
//  STKStickersDataModel.h
//  StickerFactory
//
//  Created by Vadim Degterev on 08.07.15.
//  Copyright (c) 2015 908 Inc. All rights reserved.
//


@class STKStickerObject, STKStickerPackObject, STKSticker;

@interface STKStickersCache : NSObject

@property (nonatomic) NSManagedObjectContext* backgroundContext;
@property (nonatomic) NSManagedObjectContext* mainContext;

- (NSError*)saveStickerPacks: (NSArray*)stickerPacks;

- (void)saveStickerPack: (STKStickerPackObject*)stickerPack;

- (void)saveDisabledStickerPack: (STKStickerPackObject*)stickerPack;

- (void)updateStickerPack: (STKStickerPackObject*)stickerPackObject;

- (STKStickerPackObject*)getStickerPackWithPackName: (NSString*)packName;

- (void)getStickerPacksIgnoringRecentForContext: (NSManagedObjectContext*)context
									   response: (void (^)(NSArray*))response;

- (void)getAllPacksIgnoringRecent: (void (^)(NSArray* stickerPacks))response;

- (void)getStickerPacks: (void (^)(NSArray* stickerPacks))response;

- (STKStickerPackObject*)recentStickerPack;

- (NSString*)packNameForStickerId: (NSString*)stickerId;

- (BOOL)isStickerPackDownloaded: (NSString*)packName;

- (BOOL)hasNewStickerPacks;

- (void)incrementUsedCountWithStickerID: (NSNumber*)stickerID;

- (void)markStickerPack: (STKStickerPackObject*)pack disabled: (BOOL)disabled;

- (BOOL)hasPackWithName: (NSString*)packName;

- (void)stickerWithStickerID: (NSNumber*)stickerID completion: (void (^)(STKSticker* sticker))completion;
- (void)saveSticker: (STKStickerObject*)stickerObject;

@end
