//
//  STKStickerPack+CoreDataProperties.m
//  
//
//  Created by vlad on 11/24/16.
//
//

#import "STKStickerPack+CoreDataProperties.h"

@implementation STKStickerPack (CoreDataProperties)

+ (NSFetchRequest<STKStickerPack *> *)fetchRequest {
	return [[NSFetchRequest alloc] initWithEntityName:@"STKStickerPack"];
}

@dynamic artist;
@dynamic bannerUrl;
@dynamic disabled;
@dynamic isNew;
@dynamic order;
@dynamic packDescription;
@dynamic packID;
@dynamic packName;
@dynamic packTitle;
@dynamic price;
@dynamic pricePoint;
@dynamic productID;
@dynamic stickers;
- (void)addStickersObject:(STKSticker *)value {
	NSMutableOrderedSet* tempSet = [NSMutableOrderedSet orderedSetWithOrderedSet:self.stickers];
	[tempSet addObject:value];
	self.stickers = tempSet;
}
@end
