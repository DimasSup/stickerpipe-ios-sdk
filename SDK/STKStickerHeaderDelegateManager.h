//
//  STKStickerHeaderDelegateManager.h
//  StickerPipe
//
//  Created by Vadim Degterev on 21.07.15.
//  Copyright (c) 2015 908 Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@class STKStickerPackObject;

@protocol STKStickerHeaderCollectionViewDelegate <NSObject>

- (void)scrollToIndexPath:(NSIndexPath *)indexPath animated:(BOOL)animated;

@end

@interface STKStickerHeaderDelegateManager : NSObject <UICollectionViewDataSource, UICollectionViewDelegate, STKStickerHeaderCollectionViewDelegate>

@property (copy, nonatomic) void(^didSelectRow)(NSIndexPath *indexPath, STKStickerPackObject *stickerPackObject, BOOL animated);
@property (copy, nonatomic) void(^didSelectSettingsRow)(void);
@property (strong, nonatomic) UIImage *placeholderImage;
@property (strong, nonatomic) UIColor *placeholderHeadercolor;


- (void)setStickerPacks:(NSArray *)stickerPacks;
- (STKStickerPackObject*)itemAtIndexPath:(NSIndexPath*)indexPath;

@end
