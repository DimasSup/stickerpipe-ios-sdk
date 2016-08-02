//
//  STKStickerHeaderDelegateManager.m
//  StickerPipe
//
//  Created by Vadim Degterev on 21.07.15.
//  Copyright (c) 2015 908 Inc. All rights reserved.
//

#import "STKStickerHeaderDelegateManager.h"
#import "STKStickerHeaderCell.h"
#import "STKStickerPackObject.h"


@implementation STKStickerHeaderDelegateManager

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return (self.stickerPacksArray.count > 0) ? 3 : 2;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
	if(section==0)
	{
		return 1;
	}
	else if (section == 1 && self.stickerPacksArray.count > 0) {
		return self.stickerPacksArray.count;
	} else {
		return 1;
	}
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    STKStickerHeaderCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"STKStickerPanelHeaderCell" forIndexPath:indexPath];
    
	cell.layer.shouldRasterize = YES;
    cell.layer.rasterizationScale = [UIScreen mainScreen].scale;

	if (indexPath.section == 1 && self.stickerPacksArray.count > 0) {
		STKStickerPackObject* stickerPack = self.stickerPacksArray[(NSUInteger) indexPath.item];
		
		[cell configWithStickerPack: stickerPack placeholder: self.placeholderImage placeholderTintColor: self.placeholderHeaderColor collectionView: collectionView cellForItemAtIndexPath: indexPath];
	} else if(indexPath.section == 0)
	{
		[cell configureSmileCell];
	} else {
		[cell configureSettingsCell];
	}
	
	return cell;
}

#pragma mark - UICollectionViewDelegate

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
	if (indexPath.section == 1 && self.stickerPacksArray.count > 0) {
		STKStickerPackObject *stickerPackObject = self.stickerPacksArray[indexPath.item];
		self.didSelectRow(indexPath, stickerPackObject, YES);
	}
	else if(indexPath.section>0) {
		self.didSelectSettingsRow();
	}
	else
	{
		if(self.didSelectCustomSmilesRow)
		{
			self.didSelectCustomSmilesRow();
		};
	}
}

- (void)scrollToIndexPath:(NSIndexPath *)indexPath animated:(BOOL)animated {
    if (indexPath.section == 1 && self.stickerPacksArray.count > 0) {
        STKStickerPackObject *stickerPackObject = self.stickerPacksArray[indexPath.item];
        self.didSelectRow(indexPath, stickerPackObject, animated);
    } else {
        self.didSelectSettingsRow();
    }
}




@end
