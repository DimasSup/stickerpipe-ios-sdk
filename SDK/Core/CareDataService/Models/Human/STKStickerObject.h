//
//  STKStickerObject.h
//  StickerFactory
//
//  Created by Vadim Degterev on 08.07.15.
//  Copyright (c) 2015 908 Inc. All rights reserved.
//

#import "STKStickerProtocol.h"

@class STKSticker, STKStickerPackObject, STKStickerObject;

typedef void(^STKStickerObjectBlock)(STKStickerObject* stickerObject);

@interface STKStickerObject : NSObject <STKStickerProtocol>

@property (nonatomic) NSString* stickerName;
@property (nonatomic) NSNumber* stickerID;
@property (nonatomic) NSString* stickerMessage;
@property (nonatomic, assign) NSNumber* usedCount;
@property (nonatomic) NSDate* usedDate;
@property (nonatomic) NSString* stickerURL;
@property (nonatomic) NSString* packName;

- (instancetype)initWithSticker: (STKSticker*)sticker;

- (instancetype)initWithDictionary: (NSDictionary*)dictionary;
- (void)loadStickerImage;

@end
