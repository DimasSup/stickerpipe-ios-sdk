//
//  STKImageManager.m
//  StickerPipe
//
//  Created by Olya Lutsyk on 3/1/16.
//  Copyright © 2016 908 Inc. All rights reserved.
//

#import "STKImageManager.h"
#import <objc/runtime.h>
#import <SDWebImage/SDWebImageManager.h>
#import "DFImageManagerKit.h"
#import "STKWebserviceManager.h"
#import "STKUtility.h"
#import "STKStickersManager.h"

@implementation STKImageManager

- (DFImageTask*)imageTask {
	return objc_getAssociatedObject(self, @selector(imageTask));
}

- (void)setImageTask: (DFImageTask*)imageTask {
	objc_setAssociatedObject(self, @selector(imageTask), imageTask, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (void)cancelLoading {
	[self.imageTask cancel];
}

- (void)getImageForStickerMessage: (NSString*)stickerMessage withProgress: (STKDownloadingProgressBlock)progressBlock andCompletion: (STKCompletionBlock)completion {
	NSCharacterSet* characterSet = [NSCharacterSet characterSetWithCharactersInString: @"[]"];
	NSString* stickerName = [stickerMessage stringByTrimmingCharactersInSet: characterSet];
    
    NSString* density = ([STKStickersManager downloadMaxImages]) ? [STKUtility maxDensity] : [STKUtility scaleString];

	[[SDImageCache sharedImageCache] queryDiskCacheForKey: stickerName done: ^ (UIImage* image, SDImageCacheType cacheType) {
		if (image) {
			completion(nil, image);
		} else {
			[[STKWebserviceManager sharedInstance] getStickerInfoWithId: stickerName success: ^ (id response) {
				NSString* urlString = response[@"data"][@"image"][density];

				[[SDWebImageDownloader sharedDownloader] downloadImageWithURL: [NSURL URLWithString: urlString]
																	  options: 0
																	 progress: ^ (NSInteger receivedSize, NSInteger expectedSize) {
																		 if (progressBlock) {
																			 progressBlock(receivedSize);
																		 }
																	 }
																	completed: ^ (UIImage* image, NSData* data, NSError* error, BOOL finished) {
																		if (image && finished) {
																			[[SDImageCache sharedImageCache] storeImage: image forKey: stickerName];
																			if (completion) {
																				completion(nil, image);
																			}
																		}
																	}];
			}                                         failure: nil];
		}
	}];
}

@end
