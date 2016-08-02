//
//  STKStickerPackObject.h
//  StickerFactory
//
//  Created by Vadim Degterev on 08.07.15.
//  Copyright (c) 2015 908 Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "STKStickerPackProtocol.h"

@class STKStickerPack;

@interface STKStickerPackObject : NSObject <STKStickerPackProtocol>

@property (nonatomic) NSString* artist;
@property (nonatomic) NSString* packName;
@property (nonatomic) NSString* packTitle;
@property (nonatomic) NSNumber* packID;
@property (nonatomic) NSString* pricePoint;
@property (nonatomic) NSNumber* price;
@property (nonatomic) NSMutableArray* stickers;
@property (nonatomic) NSNumber* disabled;
@property (nonatomic) NSNumber* order;
@property (nonatomic) NSString* packDescription;
@property (nonatomic) NSNumber* isNew;
@property (nonatomic) NSString* bannerUrl;
@property (nonatomic) NSString* productID;

- (instancetype)initWithServerResponse: (NSDictionary*)serverResponse;
- (instancetype)initWithStickerPack: (STKStickerPack*)stickerPack;

@end
