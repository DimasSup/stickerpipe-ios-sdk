//
//  STKStickerPanelCell.h
//  StickerFactory
//
//  Created by Vadim Degterev on 07.07.15.
//  Copyright (c) 2015 908 Inc. All rights reserved.
//


@interface STKStickerViewCell : UICollectionViewCell

- (void)configureWithStickerMessage: (NSString*)stickerMessage
						placeholder: (UIImage*)placeholder
				   placeholderColor: (UIColor*)placeholderColor
					 collectionView: (UICollectionView*)collectionView
			 cellForItemAtIndexPath: (NSIndexPath*)indexPath
						  isSuggest: (BOOL)isSuggest;

- (UIImage*)returnStickerImage;
- (void)hideStickerImage: (BOOL)isHide;

@property (nonatomic) CGFloat imageInset;
@end
