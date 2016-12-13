//
//  STKSticker+CoreDataClass.m
//  
//
//  Created by vlad on 11/24/16.
//
//

#import "STKSticker+CoreDataClass.h"
#import "NSManagedObject+STKAdditions.h"
#import "NSManagedObjectContext+STKAdditions.h"
#import "STKUtility.h"
#import "SDWebImageDownloader.h"
#import "SDImageCache.h"

@implementation STKSticker

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

+ (instancetype)stickerWithDictionary: (NSDictionary*)dictionary {
	NSNumber* stickerID = dictionary[@"content_id"];

	STKSticker* sticker = [STKSticker stk_objectWithUniqueAttribute: @"stickerID"
															  value: stickerID
															context: [NSManagedObjectContext stk_defaultContext]];

	sticker.stickerID = stickerID;
	sticker.stickerName = dictionary[@"name"];
	sticker.stickerMessage = [NSString stringWithFormat: @"[[%@]]", sticker.stickerID];
	sticker.stickerURL = dictionary[@"image"][[STKUtility scaleString]];
	sticker.packName = sticker.packName;
	sticker.usedCount = @0;
	if (sticker.stickerURL) {
		[sticker loadStickerImage];
	}
	return sticker;
}

@end
