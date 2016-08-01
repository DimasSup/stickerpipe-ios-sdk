//
//  STKStickersMapper.m
//  StickerFactory
//
//  Created by Vadim Degterev on 07.07.15.
//  Copyright (c) 2015 908 Inc. All rights reserved.
//

#import <CoreData/CoreData.h>
#import "STKStickersSerializer.h"
#import "STKStickerPack.h"
#import "STKStickerPackObject.h"


@implementation STKStickersSerializer

- (NSArray*)serializeStickerPacks: (NSArray*)stickerPacks {
	NSMutableArray* packObjects = [NSMutableArray new];

	[stickerPacks enumerateObjectsUsingBlock: ^ (NSDictionary* object, NSUInteger idx, BOOL* stop) {
		STKStickerPackObject* stickerPack = [self serializeStickerPack: object];
		stickerPack.order = @(idx);
		[packObjects addObject: stickerPack];
	}];

	return [NSArray arrayWithArray: packObjects];
}

- (STKStickerPackObject*)serializeStickerPack: (NSDictionary*)stickerPackResponse {
	return [[STKStickerPackObject alloc] initWithServerResponse: stickerPackResponse];
}

@end
