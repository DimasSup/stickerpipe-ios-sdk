//
//  STKStickersDataModel.h
//  StickerFactory
//
//  Created by Vadim Degterev on 08.07.15.
//  Copyright (c) 2015 908 Inc. All rights reserved.
//

#import "helper.h"

extern NSString* const kSTKPackDisabledNotification;

@class STKSticker;
@class STKStickerPack;

@interface STKStickersCache : NSObject

@property (nonatomic) NSManagedObjectContext* mainContext;

- (NSError*)saveStickerPacks: (NSArray*)stickerPacks;

- (STKStickerPack*)getStickerPackWithPackName: (NSString*)packName;

- (NSArray<STKStickerPack*>*)getAllEnabledPacks;

- (NSString*)packNameForStickerId: (NSString*)stickerId;

- (BOOL)isStickerPackDownloaded: (NSString*)packName;

- (void)markStickerPack: (STKStickerPack*)pack disabled: (BOOL)disabled;

- (BOOL)hasPackWithName: (NSString*)packName;

- (void)incrementStickerUsedCount: (STKSticker*)sticker;

- (BOOL)hasRecents;
- (NSArray<STKSticker*>*)getRecentStickers;
- (NSError*)saveChangesIfNeeded;
@end
