//
//  STKStickerPack+CoreDataClass.m
//  
//
//  Created by vlad on 11/24/16.
//
//

#import "STKStickerPack+CoreDataClass.h"
#import "STKSticker+CoreDataProperties.h"
#import "STKUtility.h"
#import "NSManagedObject+STKAdditions.h"
#import "NSManagedObjectContext+STKAdditions.h"

@implementation STKStickerPack

+ (instancetype)stickerPackWithDict: (NSDictionary*)dict {
	NSNumber* packID = dict[@"pack_id"];

	STKStickerPack* stickerPack = [STKStickerPack stk_objectWithUniqueAttribute: @"packID"
																		  value: packID
																		context: [NSManagedObjectContext stk_defaultContext]];

	stickerPack.packID = packID;
	[stickerPack fillWithDict: dict];

	return stickerPack;
}

+ (NSArray*)serializeStickerPacks: (NSArray<NSDictionary*>*)stickerPacks {
	NSMutableArray* packObjects = [NSMutableArray new];

	[stickerPacks enumerateObjectsUsingBlock: ^ (NSDictionary* dict, NSUInteger idx, BOOL* stop) {
		STKStickerPack* stickerPack = [STKStickerPack stickerPackWithDict: dict];
		if (!stickerPack.order) {
			stickerPack.order = @(idx);
		}
		[packObjects addObject: stickerPack];
	}];

	return packObjects;
}

- (void)fillWithDict: (NSDictionary*)dict {
	self.updatedDate = [NSDate dateWithTimeIntervalSince1970: [dict[@"updated_at"] doubleValue]];
	self.artist = dict[@"artist"];
	self.bannerUrl = dict[@"banners"][[STKUtility scaleString]];
	self.packName = dict[@"pack_name"];
	self.packTitle = dict[@"title"];
	self.pricePoint = dict[@"pricepoint"];
	self.disabled = @(![dict[@"user_status"] isEqualToString: @"active"]);
	self.price = dict[@"price"];
	self.packDescription = dict[@"description"];
	self.productID = dict[@"product_id"];


//TODO:  -temp
	if (!self.isNew) {
		self.isNew = @YES;
	}

	[dict[@"stickers"] enumerateObjectsUsingBlock: ^ (NSDictionary* dictionary, NSUInteger idx, BOOL* stop) {
		STKSticker* sticker = [STKSticker stickerWithDictionary: dictionary];
		sticker.order = @(idx);
		[self addStickersObject: sticker];
	}];
}


@end
