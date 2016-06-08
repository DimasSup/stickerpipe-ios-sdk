//
//  StickerPipeCustomSmilesDelegateManager.m
//  Little Pal
//
//  Created by admin on 26.05.16.
//  Copyright © 2016 BrillKids. All rights reserved.
//

#import "StickerPipeCustomSmilesDelegateManager.h"
#import "STKStickersSeparator.h"
#import "StickerPipeCustomSmileCell.h"

@interface StickerPipeCustomSmilesDelegateManager()
@property(nonatomic,strong)NSArray* smiles;

@end

@implementation StickerPipeCustomSmilesDelegateManager


#pragma mark -



#pragma mark - UICollectionViewDataSource

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
	
	if ([kind isEqualToString:UICollectionElementKindSectionFooter]) {
		STKStickersSeparator *separator = [collectionView dequeueReusableSupplementaryViewOfKind:kind withReuseIdentifier:@"STKStickerPanelSeparator" forIndexPath:indexPath];
		//if last section
		separator.backgroundColor = [UIColor colorWithRed:229.0/255.0 green:229.0/255.0 blue:234.0/255.0 alpha:1];
		return separator;
	}
	return nil;
}


- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
	
	return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView
	 numberOfItemsInSection:(NSInteger)section
{
	return self.smiles.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView
				  cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
	StickerPipeCustomSmileCell* cell = [collectionView dequeueReusableCellWithReuseIdentifier:kStickerPipeCustomSmileCell forIndexPath:indexPath];
	
	[cell reinitializeWithSmile:self.smiles[indexPath.row]];
	
	
	
	
	return cell;
}

#pragma mark - UICollectionViewDelegate

- (void)collectionView:(UICollectionView *)collectionView didEndDisplayingCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath {
	
	
}



#pragma mark - UICollectionViewDelegateFlowLayout

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
	
	return CGSizeMake(35.0, 35.0);
}


#pragma mark - UICollectionViewDelegate

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
	if(self.didSelectCustomSmile)
	{
		self.didSelectCustomSmile(_smiles[indexPath.row],indexPath);
	}
}

-(void)setAllSmiles:(NSArray *)smiles
{
	self.smiles =  smiles;
}


@end
