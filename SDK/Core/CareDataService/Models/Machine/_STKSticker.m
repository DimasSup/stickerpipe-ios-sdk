// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to STKSticker.m instead.

#import "_STKSticker.h"

const struct STKStickerAttributes STKStickerAttributes = {
		.stickerID = @"stickerID",
		.stickerMessage = @"stickerMessage",
		.stickerName = @"stickerName",
		.usedCount = @"usedCount",
		.usedDate = @"usedDate"
};

const struct STKStickerRelationships STKStickerRelationships = {
		.stickerPack = @"stickerPack",
};

@implementation STKStickerID
@end

@implementation _STKSticker

+ (id)insertInManagedObjectContext: (NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription insertNewObjectForEntityForName: @"STKSticker" inManagedObjectContext: moc_];
}

+ (NSString*)entityName {
	return @"STKSticker";
}

+ (NSEntityDescription*)entityInManagedObjectContext: (NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription entityForName: @"STKSticker" inManagedObjectContext: moc_];
}

- (STKStickerID*)objectID {
	return (STKStickerID*) [super objectID];
}

+ (NSSet*)keyPathsForValuesAffectingValueForKey: (NSString*)key {
	NSSet* keyPaths = [super keyPathsForValuesAffectingValueForKey: key];

	if ([key isEqualToString: @"stickerIDValue"]) {
		NSSet* affectingKey = [NSSet setWithObject: @"stickerID"];
		keyPaths = [keyPaths setByAddingObjectsFromSet: affectingKey];
		return keyPaths;
	}
	if ([key isEqualToString: @"usedCountValue"]) {
		NSSet* affectingKey = [NSSet setWithObject: @"usedCount"];
		keyPaths = [keyPaths setByAddingObjectsFromSet: affectingKey];
		return keyPaths;
	}

	return keyPaths;
}

@dynamic stickerID;

@dynamic stickerMessage;

@dynamic stickerName;

@dynamic usedDate;

@dynamic usedCount;

@dynamic packName;

@dynamic stickerPack;

@end

