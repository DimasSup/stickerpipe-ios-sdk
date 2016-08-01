//
//  STKStickerPackObject.m
//  StickerFactory
//
//  Created by Vadim Degterev on 08.07.15.
//  Copyright (c) 2015 908 Inc. All rights reserved.
//

#import "STKStickerPackObject.h"
#import "STKSticker.h"
#import "STKStickerPack.h"
#import "STKStickerObject.h"
#import "STKUtility.h"

@implementation STKStickerPackObject

- (instancetype)initWithServerResponse: (NSDictionary*)serverResponse {
	if (self = [super init]) {
		self.artist = serverResponse[@"artist"];
		self.bannerUrl = serverResponse[@"banners"][[STKUtility scaleString]];
		self.packName = serverResponse[@"pack_name"];
		self.packTitle = serverResponse[@"title"];
		self.packID = serverResponse[@"pack_id"];
		self.pricePoint = serverResponse[@"pricepoint"];
		self.disabled = ([serverResponse[@"user_status"] isEqualToString: @"active"]) ? @NO : @YES;
		self.price = serverResponse[@"price"];
		self.packDescription = serverResponse[@"description"];
		self.productID = serverResponse[@"product_id"];

		NSMutableArray* stickersArray = [NSMutableArray array];
		for (NSDictionary* dictionary in serverResponse[@"stickers"]) {
			[stickersArray addObject: [[STKStickerObject alloc] initWithDictionary: dictionary]];
		}

		self.stickers = stickersArray;
	}

	return self;
}

- (instancetype)initWithStickerPack: (STKStickerPack*)stickerPack {
	if (self = [super init]) {
		self.artist = stickerPack.artist;
		self.packName = stickerPack.packName;
		self.packTitle = stickerPack.packTitle;
		self.packID = stickerPack.packID;
		self.pricePoint = stickerPack.pricePoint;
		self.price = stickerPack.price;
		self.packDescription = stickerPack.packDescription;
		self.disabled = stickerPack.disabled;
		self.order = stickerPack.order;
		self.isNew = stickerPack.isNew;
		self.bannerUrl = stickerPack.bannerUrl;
		self.productID = stickerPack.productID;

		NSMutableArray* stickersArray = [NSMutableArray array];
		@autoreleasepool{
			for (STKSticker* sticker in stickerPack.stickers) {
				STKStickerObject* stickerObject = [[STKStickerObject alloc] initWithSticker: sticker];
				[stickersArray addObject: stickerObject];
			}
		}

		self.stickers = stickersArray;
	}

	return self;
}


#pragma mark - Description

- (NSString*)stringForDescription {
	return [NSString stringWithFormat: @"%@\n Artist: %@\n packName: %@\n Pack title: %@\n packID: %@\n price: %@\n Disabled: %@\n Order: %@", [super description], self.artist, self.packName, self.packTitle, self.packID, self.price, self.disabled, self.order];
}

- (NSString*)description {
	return [self stringForDescription];
}

- (NSString*)debugDescription {
	return [self stringForDescription];
}

@end
