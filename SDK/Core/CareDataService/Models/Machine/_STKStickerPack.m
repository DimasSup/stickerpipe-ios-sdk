// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to STKStickerPack.m instead.

#import "_STKStickerPack.h"

const struct STKStickerPackAttributes STKStickerPackAttributes = {
		.artist = @"artist",
		.bannerUrl = @"bannerUrl",
		.disabled = @"disabled",
		.isNew = @"isNew",
		.order = @"order",
		.packDescription = @"packDescription",
		.packID = @"packID",
		.packName = @"packName",
		.packTitle = @"packTitle",
		.price = @"price",
		.pricePoint = @"pricePoint",
		.productID = @"productID",
};

const struct STKStickerPackRelationships STKStickerPackRelationships = {
		.stickers = @"stickers",
};

@implementation STKStickerPackID
@end

@implementation _STKStickerPack

+ (id)insertInManagedObjectContext: (NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription insertNewObjectForEntityForName: @"STKStickerPack" inManagedObjectContext: moc_];
}

+ (NSString*)entityName {
	return @"STKStickerPack";
}

+ (NSEntityDescription*)entityInManagedObjectContext: (NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription entityForName: @"STKStickerPack" inManagedObjectContext: moc_];
}

- (STKStickerPackID*)objectID {
	return (STKStickerPackID*) [super objectID];
}

+ (NSSet*)keyPathsForValuesAffectingValueForKey: (NSString*)key {
	NSSet* keyPaths = [super keyPathsForValuesAffectingValueForKey: key];

	if ([key isEqualToString: @"disabledValue"]) {
		NSSet* affectingKey = [NSSet setWithObject: @"disabled"];
		keyPaths = [keyPaths setByAddingObjectsFromSet: affectingKey];
		return keyPaths;
	}
	if ([key isEqualToString: @"isNewValue"]) {
		NSSet* affectingKey = [NSSet setWithObject: @"isNew"];
		keyPaths = [keyPaths setByAddingObjectsFromSet: affectingKey];
		return keyPaths;
	}
	if ([key isEqualToString: @"orderValue"]) {
		NSSet* affectingKey = [NSSet setWithObject: @"order"];
		keyPaths = [keyPaths setByAddingObjectsFromSet: affectingKey];
		return keyPaths;
	}
	if ([key isEqualToString: @"packIDValue"]) {
		NSSet* affectingKey = [NSSet setWithObject: @"packID"];
		keyPaths = [keyPaths setByAddingObjectsFromSet: affectingKey];
		return keyPaths;
	}
	if ([key isEqualToString: @"priceValue"]) {
		NSSet* affectingKey = [NSSet setWithObject: @"price"];
		keyPaths = [keyPaths setByAddingObjectsFromSet: affectingKey];
		return keyPaths;
	}

	return keyPaths;
}

- (NSMutableOrderedSet*)stickersSet {
	[self willAccessValueForKey: @"stickers"];

	NSMutableOrderedSet* result = [self mutableOrderedSetValueForKey: @"stickers"];

	[self didAccessValueForKey: @"stickers"];
	return result;
}

@dynamic artist;

@dynamic bannerUrl;

@dynamic disabled;

@dynamic isNew;

@dynamic order;

@dynamic packDescription;

@dynamic packID;

@dynamic packName;

@dynamic pricePoint;

@dynamic packTitle;

@dynamic price;

@dynamic productID;

@dynamic stickers;

@end
