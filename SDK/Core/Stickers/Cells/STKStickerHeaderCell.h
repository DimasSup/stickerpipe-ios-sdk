//
//  STKStickerPanelHeaderCell.h
//  StickerFactory
//
//  Created by Vadim Degterev on 08.07.15.
//  Copyright (c) 2015 908 Inc. All rights reserved.
//


@class STKStickerPackObject;

@interface STKStickerHeaderCell : UICollectionViewCell

@property (nonatomic) UIColor* selectionColor;

- (void)configWithStickerPack: (STKStickerPackObject*)stickerPack placeholder: (UIImage*)placeholder placeholderTintColor: (UIColor*)placeholderTintColor collectionView: (UICollectionView*)collectionView cellForItemAtIndexPath: (NSIndexPath*)indexPath;

- (void)configureSettingsCell;
- (void)configureSmileCell;

@end
