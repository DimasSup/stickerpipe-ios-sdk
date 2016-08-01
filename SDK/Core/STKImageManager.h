//
//  STKImageManager.h
//  StickerPipe
//
//  Created by Olya Lutsyk on 3/1/16.
//  Copyright © 2016 908 Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@class DFImageTask;

typedef void(^ STKCompletionBlock)(NSError* error, UIImage* stickerImage);
typedef void(^ STKDownloadingProgressBlock)(NSTimeInterval progress);

@interface STKImageManager : NSObject

@property (nonatomic) DFImageTask* imageTask;

- (void)getImageForStickerMessage: (NSString*)stickerMessage withProgress: (STKDownloadingProgressBlock)progressBlock andCompletion: (STKCompletionBlock)completion;

- (void)cancelLoading;

@end
