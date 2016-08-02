//
//  STKStickerObject.m
//  StickerFactory
//
//  Created by Vadim Degterev on 08.07.15.
//  Copyright (c) 2015 908 Inc. All rights reserved.
//

#import <SDWebImage/SDWebImageManager.h>
#import "STKStickerObject.h"
#import "STKSticker.h"
#import "STKUtility.h"

@implementation STKStickerObject

- (instancetype)initWithDictionary: (NSDictionary*)dictionary {
	if (self = [super init]) {
		self.stickerID = dictionary[@"content_id"];
		self.stickerName = dictionary[@"name"];
		self.stickerMessage = [NSString stringWithFormat: @"[[%@]]", self.stickerID];
		self.stickerURL = dictionary[@"image"][[STKUtility scaleString]];
		self.packName = self.packName;
		if (self.stickerURL) {
			[self loadStickerImage];
		}
	}

	return self;
}

- (instancetype)initWithSticker: (STKSticker*)sticker {
	if (self = [super init]) {
		self.stickerName = sticker.stickerName;
		self.stickerID = sticker.stickerID;
		self.stickerMessage = sticker.stickerMessage;
		self.usedCount = sticker.usedCount;
		self.usedDate = sticker.usedDate;
		self.packName = sticker.packName;
	}

	return self;
}

- (void)loadStickerImage {
	[[SDWebImageDownloader sharedDownloader] downloadImageWithURL: [NSURL URLWithString: self.stickerURL]
														  options: 0
														 progress: nil
														completed: ^ (UIImage* image, NSData* data, NSError* error, BOOL finished) {
															if (image && finished) {
																[[SDImageCache sharedImageCache] storeImage: image forKey: [self.stickerID stringValue]];
															}
														}];
}


#pragma mark - Description

- (NSString*)stringForDescription {
	return [NSString stringWithFormat: @"self: %@\n stickerName: %@\n, stickerID: %@\n stickerMessage: %@\n usedCount: %@\n, usedDate:%@\n", [super description], self.stickerName, self.stickerID, self.stickerMessage, self.usedCount, self.usedDate];
}

- (NSString*)description {
	return [self stringForDescription];
}

- (NSString*)debugDescription {
	return [self stringForDescription];
}

@end
