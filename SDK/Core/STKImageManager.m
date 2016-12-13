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
#import "STKWebserviceManager.h"
#import "STKUtility.h"
#import "STKStickersManager.h"

@implementation STKImageManager

- (id <SDWebImageOperation>)imageTask {
	return objc_getAssociatedObject(self, @selector(imageTask));
}

- (void)setImageTask: (id <SDWebImageOperation>)imageTask {
	objc_setAssociatedObject(self, @selector(imageTask), imageTask, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (void)cancelLoading {
	[self.imageTask cancel];
}

- (void)getImageForStickerMessage: (NSString*)stickerMessage withProgress: (STKDownloadingProgressBlock)progressBlock andCompletion: (STKCompletionBlock)completion {
	NSCharacterSet* characterSet = [NSCharacterSet characterSetWithCharactersInString: @"[]"];
	NSString* stickerName = [stickerMessage stringByTrimmingCharactersInSet: characterSet];
    
    NSString* density = [STKStickersManager downloadMaxImages] ? [STKUtility maxDensity] : [STKUtility scaleString];

	[[SDImageCache sharedImageCache] queryDiskCacheForKey: stickerName done: ^ (UIImage* image, SDImageCacheType cacheType) {
		if (image) {
			completion(nil, image);
		} else {
			[[STKWebserviceManager sharedInstance] getStickerInfoWithId: stickerName success: ^ (id response) {
				NSURL* urlString = [NSURL URLWithString: response[@"data"][@"image"][density]];
				self.imageTask = [[STKWebserviceManager sharedInstance] downloadImageWithURL: urlString
																				  completion: ^ (UIImage* downloadedImage, NSData* data, NSError* error, BOOL finished) {
																					  if (downloadedImage && finished) {
																						  [[SDImageCache sharedImageCache] storeImage: downloadedImage forKey: stickerName];
																						  if (completion) {
																							  completion(nil, downloadedImage);
																						  }
																					  }
																				  }];
			}                                                   failure: nil];
		}
	}];
}

@end
