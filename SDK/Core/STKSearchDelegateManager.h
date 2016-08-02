//
//  STKSearchDelegateManager.h
//  StickerPipe
//
//  Created by Alexander908 on 7/18/16.
//  Copyright © 2016 908 Inc. All rights reserved.
//


@class STKStickerObject;
@class STKStickerDelegateManager;

@interface STKSearchDelegateManager : NSObject <UICollectionViewDataSource, UICollectionViewDelegate, UIScrollViewDelegate>

@property (nonatomic, copy) void (^didSelectSticker)(STKStickerObject* sticker);

@property (nonatomic, weak) UICollectionView* collectionView;

@property (nonatomic) UIColor* placeholderColor;

- (void)setStickerPacksArray: (NSArray*)searchStickerPacks;

- (void)setStickerPlaceholder: (UIImage*)stickerPlaceholder;

@property (nonatomic) STKStickerDelegateManager* stickerDelegateManager;

@end
