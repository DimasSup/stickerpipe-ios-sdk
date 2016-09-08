//
//  STKStickersDataModel.m
//  StickerFactory
//
//  Created by Vadim Degterev on 08.07.15.
//  Copyright (c) 2015 908 Inc. All rights reserved.
//

#import "STKStickersCache.h"
#import "NSManagedObjectContext+STKAdditions.h"
#import "NSManagedObject+STKAdditions.h"
#import "STKStickerPack.h"
#import "STKStickerObject.h"
#import "STKStickerPackObject.h"
#import "STKSticker.h"
#import "STKStickersConstants.h"
#import "STKUtility.h"


@implementation STKStickersCache

NSString *const kRecentName = @"Recent";

- (instancetype)init {
	if (self = [super init]) {
		[[NSNotificationCenter defaultCenter] addObserver: self selector: @selector(didUpdateStorage:) name: NSManagedObjectContextDidSaveNotification object: nil];
	}

	return self;
}

- (void)dealloc {
	[[NSNotificationCenter defaultCenter] removeObserver: self];
}

- (void)didUpdateStorage: (NSNotification*)notification {
	dispatch_async(dispatch_get_main_queue(), ^ {
		[[NSNotificationCenter defaultCenter] postNotificationName: STKStickersCacheDidUpdateStickersNotification object: nil];
	});
}


#pragma mark - Saving

- (NSError*)saveStickerPacks: (NSArray*)stickerPacks {
	__block NSError* error;
	[self.backgroundContext performBlockAndWait: ^ {
		[self removeAbsentPacksWithCurrentPacks: stickerPacks];

		NSUInteger __block shift = 0;

		[stickerPacks enumerateObjectsUsingBlock: ^ (STKStickerPackObject* object, NSUInteger idx, BOOL* stop) {
			STKStickerPack* stickerPack = [self stickerPackModelWithID: object.packID context: self.backgroundContext];
			if (!stickerPack.order) {
				stickerPack.order = @(idx);
				++shift;
			} else {
				stickerPack.order = @([stickerPack.order integerValue] + shift);
			}
			[self fillStickerPack: stickerPack withObject: object];
		}];

		[self.backgroundContext save: &error];
	}];
	return error;
}

- (void)removeAbsentPacksWithCurrentPacks: (NSArray<STKStickerPackObject*>*)stickerPacks {
	NSArray* packIDs = [stickerPacks valueForKeyPath: @"@unionOfObjects.packID"];

	NSFetchRequest* requestForDelete = [NSFetchRequest fetchRequestWithEntityName: [STKStickerPack entityName]];
	requestForDelete.predicate = [NSPredicate predicateWithFormat: @"NOT (%K in %@)", STKStickerPackAttributes.packID, packIDs];

	NSArray* objectsForDelete = [self.backgroundContext executeFetchRequest: requestForDelete error: nil];

	for (STKStickerPack* pack in objectsForDelete) {
		[self.backgroundContext deleteObject: pack];
	}
}

- (void)saveStickerPack: (STKStickerPackObject*)stickerPack {
	STKStickerPack* stickerModel = [self stickerModelFormStickerObject: stickerPack context: self.backgroundContext];
	stickerModel.isNew = @YES;
	for (STKStickerObject* stickerObject in stickerPack.stickers) {
		STKSticker* sticker = [self stickerModelWithID: stickerObject.stickerID context: self.backgroundContext];
		sticker.stickerName = stickerObject.stickerName;
		sticker.stickerID = stickerObject.stickerID;
		sticker.stickerMessage = stickerObject.stickerMessage;
		sticker.usedCount = stickerObject.usedCount;
		sticker.usedDate = stickerObject.usedDate;
		if (sticker) {
			[stickerModel addStickersObject: sticker];
		}
	}

	[self.backgroundContext save: nil];
}

- (void)saveSticker: (STKStickerObject*)stickerObject {
	if (stickerObject) {
		STKSticker* sticker = [self stickerModelWithID: stickerObject.stickerID context: self.backgroundContext];
		sticker.stickerName = stickerObject.stickerName;
		sticker.stickerID = stickerObject.stickerID;
		sticker.stickerMessage = stickerObject.stickerMessage;
		sticker.usedCount = stickerObject.usedCount;
		sticker.usedDate = stickerObject.usedDate;

		[self.backgroundContext save: nil];
	}
}

- (void)saveDisabledStickerPack: (STKStickerPackObject*)stickerPack {
	STKStickerPack* stickerModel = [self stickerModelFormStickerObject: stickerPack context: self.backgroundContext];
	stickerModel.disabled = @YES;

	for (STKStickerObject* stickerObject in stickerPack.stickers) {
		STKSticker* sticker = [self stickerModelWithID: stickerObject.stickerID context: self.backgroundContext];
		sticker.stickerName = stickerObject.stickerName;
		sticker.stickerID = stickerObject.stickerID;
		sticker.stickerMessage = stickerObject.stickerMessage;
		sticker.usedCount = stickerObject.usedCount;
		sticker.usedDate = stickerObject.usedDate;
		sticker.packName = stickerObject.packName;
		if (sticker) {
			[stickerModel addStickersObject: sticker];
		}
	}

	[self.backgroundContext save: nil];
}


#pragma mark - Update

- (void)updateStickerPack: (STKStickerPackObject*)stickerPackObject {
	typeof(self) __weak weakSelf = self;

	[self.backgroundContext performBlock: ^ {
		NSPredicate* predicate = [NSPredicate predicateWithFormat: @"%K == %@", STKStickerPackAttributes.packID, stickerPackObject.packID];
		NSArray* packs = [STKStickerPack stk_findWithPredicate: predicate sortDescriptors: nil fetchLimit: 1 context: weakSelf.backgroundContext];
		STKStickerPack* stickerPack = packs.firstObject;
		if (stickerPack) {
			[weakSelf fillStickerPack: stickerPack withObject: stickerPackObject];

			NSError* error = nil;
			[weakSelf.backgroundContext save: &error];
			if (error) {
				STKLog(@"Saving context error: %@", error.localizedDescription);
			}
		}
	}];
}


#pragma mark - FillItems

- (STKStickerPack*)fillStickerPack: (STKStickerPack*)stickerPack withObject: (STKStickerPackObject*)stickerPackObject {
	stickerPack.artist = stickerPackObject.artist;
	stickerPack.packName = stickerPackObject.packName;
	stickerPack.packID = stickerPackObject.packID;
	stickerPack.price = stickerPackObject.price;
	stickerPack.pricePoint = stickerPackObject.pricePoint;
	stickerPack.packTitle = stickerPackObject.packTitle;
	stickerPack.packDescription = stickerPackObject.packDescription;
	stickerPack.bannerUrl = stickerPackObject.bannerUrl;
	stickerPack.productID = stickerPackObject.productID;
	stickerPack.disabled = stickerPackObject.disabled;

	if (stickerPack.isNew.boolValue) {
		if (stickerPackObject.isNew) {
			stickerPack.isNew = stickerPackObject.isNew;
		}
	} else if (!stickerPack.isNew) {
		stickerPack.isNew = @YES;
	}

	if (stickerPackObject.order) {
		stickerPack.order = stickerPackObject.order;
	}

	for (STKStickerObject* stickerObject in stickerPackObject.stickers) {
		STKSticker* sticker = [self stickerModelWithID: stickerObject.stickerID context: self.backgroundContext];
		sticker.stickerName = stickerObject.stickerName;
		sticker.stickerID = stickerObject.stickerID;
		sticker.stickerMessage = stickerObject.stickerMessage;
		sticker.usedCount = stickerObject.usedCount;
		sticker.usedDate = stickerObject.usedDate;
		sticker.packName = stickerObject.packName;
		if (sticker) {
			[stickerPack addStickersObject: sticker];
		}
	}
	return stickerPack;
}


#pragma mark - NewItems

- (STKStickerPack*)stickerModelFormStickerObject: (STKStickerPackObject*)stickerPackObject
										 context: (NSManagedObjectContext*)context {
	STKStickerPack* stickerPack = [self stickerPackModelWithID: stickerPackObject.packID context: context];
	stickerPack.artist = stickerPackObject.artist;
	stickerPack.packName = stickerPackObject.packName;
	stickerPack.packID = stickerPackObject.packID;
	stickerPack.price = stickerPackObject.price;
	stickerPack.pricePoint = stickerPackObject.pricePoint;
	stickerPack.packTitle = stickerPackObject.packTitle;
	stickerPack.packDescription = stickerPackObject.packDescription;
	stickerPack.disabled = stickerPackObject.disabled;
	stickerPack.isNew = stickerPackObject.isNew;
	stickerPack.bannerUrl = stickerPackObject.bannerUrl;
	stickerPack.productID = stickerPackObject.productID;
	stickerPack.order = stickerPackObject.order;
	return stickerPack;
}

- (STKSticker*)stickerModelWithID: (NSNumber*)stickerID context: (NSManagedObjectContext*)context {
	return [STKSticker stk_objectWithUniqueAttribute: STKStickerAttributes.stickerID value: stickerID context: context];
}

- (STKStickerPack*)stickerPackModelWithID: (NSNumber*)packID context: (NSManagedObjectContext*)context {
	return [STKStickerPack stk_objectWithUniqueAttribute: STKStickerPackAttributes.packID value: packID context: context];
}


#pragma mark - Getters

- (void)getStickerPacksIgnoringRecentForContext: (NSManagedObjectContext*)context
									   response: (void (^)(NSArray*))response {
	if (context) {
		NSPredicate* predicate = [NSPredicate predicateWithFormat: @"%K == %@ OR %K == nil", STKStickerPackAttributes.disabled, @NO, STKStickerPackAttributes.disabled];
		NSSortDescriptor* sortDescriptor = [NSSortDescriptor sortDescriptorWithKey: STKStickerPackAttributes.order ascending: YES];
		NSArray* stickerPacks = [STKStickerPack stk_findWithPredicate: predicate sortDescriptors: @[sortDescriptor] context: context];

		NSMutableArray* result = [NSMutableArray array];

		for (STKStickerPack* pack in stickerPacks) {
			STKStickerPackObject* stickerPackObject = [[STKStickerPackObject alloc] initWithStickerPack: pack];
			if (stickerPackObject) {
				[result addObject: stickerPackObject];
			}
		}
		if (response) {
			dispatch_async(dispatch_get_main_queue(), ^ {
				response(result);
			});
		}
	}
}

- (void)getAllPacksIgnoringRecent: (void (^)(NSArray*))response {
	NSPredicate* predicate = [NSPredicate predicateWithFormat: @"%K != nil", STKStickerPackAttributes.disabled];

	NSArray* stickerPacks = [STKStickerPack stk_findWithPredicate: predicate sortDescriptors: nil context: self.mainContext];
	NSMutableArray* result = [NSMutableArray array];

	for (STKStickerPack* pack in stickerPacks) {
		STKStickerPackObject* stickerPackObject = [[STKStickerPackObject alloc] initWithStickerPack: pack];
		if (stickerPackObject) {
			[result addObject: stickerPackObject];
		}
	}
	if (response) {
		dispatch_async(dispatch_get_main_queue(), ^ {
			response(result);
		});
	}
}

- (void)getStickerPacks: (void (^)(NSArray* stickerPacks))response {
	STKStickerPackObject* recentPack = [self recentStickerPack];
	NSMutableArray* result = [NSMutableArray array];

//TODO: Check recent stickers
	[self getStickerPacksIgnoringRecentForContext: self.mainContext response: ^ (NSArray* stickerPacks) {
		if (recentPack) {
			[result insertObject: recentPack atIndex: 0];
			[result addObjectsFromArray: stickerPacks];
		}
		if (response) {
			response(result);
		}
	}];
}

- (STKStickerPackObject*)getStickerPackWithPackName: (NSString*)packName {
	NSPredicate* predicate = [NSPredicate predicateWithFormat: @"%K == %@", STKStickerPackAttributes.packName, packName];
	STKStickerPack* stickerPack = [[STKStickerPack stk_findWithPredicate: predicate sortDescriptors: nil fetchLimit: 1 context: self.mainContext] firstObject];

	if (stickerPack) {
		return [[STKStickerPackObject alloc] initWithStickerPack: stickerPack];
	} else {
		return nil;
	}
}

- (STKStickerPackObject*)recentStickerPack {
	STKStickerPackObject* recentPack = [STKStickerPackObject new];
	recentPack.packName = kRecentName;
	recentPack.packTitle = kRecentName;
	recentPack.isNew = @NO;

	NSPredicate* predicate = [NSPredicate predicateWithFormat: @"%K > 0 AND (%K.%K == NO OR %K.%K == nil)", STKStickerAttributes.usedCount, STKStickerRelationships.stickerPack, STKStickerPackAttributes.disabled, STKStickerRelationships.stickerPack, STKStickerPackAttributes.disabled];
	NSSortDescriptor* sortDescriptor = [NSSortDescriptor sortDescriptorWithKey: STKStickerAttributes.usedDate
																	 ascending: NO];

	NSArray* stickers = [STKSticker stk_findWithPredicate: predicate
										  sortDescriptors: @[sortDescriptor]
											   fetchLimit: 12
												  context: self.mainContext];

	NSMutableArray* stickerObjects = [NSMutableArray new];
	for (STKSticker* sticker in stickers) {
		STKStickerObject* stickerObject = [[STKStickerObject alloc] initWithSticker: sticker];
		if (stickerObject) {
			[stickerObjects addObject: stickerObject];
		}
	}

	NSArray* sortedRecentStickers = [stickerObjects sortedArrayUsingDescriptors: @[[NSSortDescriptor sortDescriptorWithKey: STKStickerAttributes.usedDate ascending: NO]]];

	recentPack.stickers = [NSMutableArray arrayWithArray: sortedRecentStickers];

	return recentPack;
}

- (NSString*)packNameForStickerId: (NSString*)stickerId {
	NSPredicate* predicate = [NSPredicate predicateWithFormat: @"%K == %@", STKStickerAttributes.stickerID, stickerId];
	STKSticker* sticker = [[STKSticker stk_findWithPredicate: predicate sortDescriptors: nil fetchLimit: 1 context: self.mainContext] firstObject];

	return sticker.packName;
}

#pragma mark - Change

- (void)markStickerPack: (STKStickerPackObject*)pack disabled: (BOOL)disabled {
	NSPredicate* predicate = [NSPredicate predicateWithFormat: @"%K == %@", STKStickerPackAttributes.packID, pack.packID];
	STKStickerPack* stickerPack = [STKStickerPack stk_findWithPredicate: predicate sortDescriptors: nil fetchLimit: 1 context: self.mainContext].firstObject;

	stickerPack.disabled = @(disabled);

	[self.mainContext save: nil];
}

- (void)incrementUsedCountWithStickerID: (NSNumber*)stickerID {
	typeof(self) __weak weakSelf = self;

	[self.backgroundContext performBlock: ^ {
		NSPredicate* predicate = [NSPredicate predicateWithFormat: @"%K == %@", STKStickerAttributes.stickerID, stickerID];
		NSArray* stickers = [STKSticker stk_findWithPredicate: predicate sortDescriptors: nil fetchLimit: 1 context: self.backgroundContext];

		STKSticker* sticker = stickers.firstObject;
		sticker.usedCount = @([sticker.usedCount integerValue] + 1);
		sticker.usedDate = [NSDate date];

		[weakSelf.backgroundContext save: nil];
	}];
}

- (void)stickerWithStickerID: (NSNumber*)stickerID completion: (void (^)(STKSticker* sticker))completion {
	[self.backgroundContext performBlock: ^ {
		NSPredicate* predicate = [NSPredicate predicateWithFormat: @"%K == %@", STKStickerAttributes.stickerID, stickerID];
		NSArray* stickers = [STKSticker stk_findWithPredicate: predicate sortDescriptors: nil fetchLimit: 1 context: self.backgroundContext];
		STKSticker* sticker = stickers.firstObject;

		if (completion) {
			completion(sticker);
		}
	}];
}


#pragma mark - Check

- (BOOL)hasNewStickerPacks {
	NSFetchRequest* request = [NSFetchRequest fetchRequestWithEntityName: [STKStickerPack entityName]];
	request.predicate = [NSPredicate predicateWithFormat: @"%K == %@", STKStickerPackAttributes.isNew, @YES];
	request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey: STKStickerPackAttributes.order ascending: NO]];
	request.fetchOffset = [[NSManagedObjectContext stk_defaultContext] countForFetchRequest: request error: nil] - 3;
	request.fetchLimit = 3;
	NSUInteger count = [[NSManagedObjectContext stk_defaultContext] countForFetchRequest: request error: nil];
	return count > 0 || ([self recentStickerPack].stickers.count == 0);
}

- (BOOL)isStickerPackDownloaded: (NSString*)packName {
	NSFetchRequest* request = [[NSFetchRequest alloc] initWithEntityName: [STKStickerPack entityName]];
	request.predicate = [NSPredicate predicateWithFormat: @"%K == %@ AND (%K == NO OR %K == nil)", STKStickerPackAttributes.packName, packName, STKStickerPackAttributes.disabled, STKStickerPackAttributes.disabled];
	request.fetchLimit = 1;
	return [self.mainContext countForFetchRequest: request error: nil] > 0;
}

- (BOOL)hasPackWithName: (NSString*)packName {
	NSFetchRequest* request = [NSFetchRequest fetchRequestWithEntityName: [STKStickerPack entityName]];
	request.predicate = [NSPredicate predicateWithFormat: @"%K == %@", STKStickerPackAttributes.packName, packName];
	return [self.mainContext countForFetchRequest: request error: nil] > 0;
}


#pragma mark - Properties

- (NSManagedObjectContext*)mainContext {
	if (!_mainContext) {
		_mainContext = [NSManagedObjectContext stk_defaultContext];
	}
	return _mainContext;
}

- (NSManagedObjectContext*)backgroundContext {
	if (!_backgroundContext) {
		_backgroundContext = [NSManagedObjectContext stk_backgroundContext];
	}
	return _backgroundContext;
}

@end
