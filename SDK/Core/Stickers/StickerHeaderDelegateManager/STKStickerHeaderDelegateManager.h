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
- (void)scrollToIndexPath: (NSIndexPath*)indexPath animated: (BOOL)animated;
@end

@interface STKStickerHeaderDelegateManager : NSObject <UICollectionViewDataSource, UICollectionViewDelegate, STKStickerHeaderCollectionViewDelegate>

@property (nonatomic, copy) void (^didSelectRow)(NSIndexPath* indexPath, STKStickerPackObject* stickerPackObject, BOOL animated);
@property (nonatomic, copy) void (^didSelectSettingsRow)(void);
@property (nonatomic) UIImage* placeholderImage;
@property (nonatomic) UIColor* placeholderHeaderColor;
@property (nonatomic) NSArray<STKStickerPackObject*>* stickerPacksArray;

#warning -add deprecated later; use stickerPacksArray directly instead
- (STKStickerPackObject*)itemAtIndexPath: (NSIndexPath*)indexPath;
- (void)setStickerPacks: (NSArray*)stickerPacks;

@end
