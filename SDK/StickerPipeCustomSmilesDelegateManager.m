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
#import "UserSettingsService.h"

@interface StickerPipeCustomSmilesDelegateManager()
@property(nonatomic,strong)NSArray* smiles;
@property(nonatomic,strong)NSArray* recentSmiles;
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
	
	return self.recentSmiles.count>0?2: 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView
	 numberOfItemsInSection:(NSInteger)section
{
	if(self.recentSmiles.count)
	{
		if(section==0)
		{
			UICollectionViewFlowLayout* layout = collectionView.collectionViewLayout;
			int c = (collectionView.frame.size.width - collectionView.layoutMargins.left-collectionView.layoutMargins.right)/([self collectionView:collectionView layout:nil sizeForItemAtIndexPath:nil].width+layout.minimumInteritemSpacing);
			
			c = c*2;
			
			return MIN(c,self.recentSmiles.count);
		}
		else{
			return self.smiles.count;
		}
	}
	return self.smiles.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView
				  cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
	StickerPipeCustomSmileCell* cell = [collectionView dequeueReusableCellWithReuseIdentifier:kStickerPipeCustomSmileCell forIndexPath:indexPath];
	
	NSString* itm = nil;
	
	if(self.recentSmiles.count)
	{
		if(indexPath.section==0)
		{
			itm = self.recentSmiles[indexPath.row];
		}
		else
		{
			itm = self.smiles[indexPath.row];
		}
	}
	else{
		itm = self.smiles[indexPath.row];
	}
	
	[cell reinitializeWithSmile:itm];
	
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
		NSString* itm = nil;
		
		if(self.recentSmiles.count)
		{
			if(indexPath.section==0)
			{
				itm = self.recentSmiles[indexPath.row];
			}
			else
			{
				itm = self.smiles[indexPath.row];
			}
		}
		else{
			itm = self.smiles[indexPath.row];
		}

		
		self.didSelectCustomSmile(itm,indexPath);
	}
}

-(void)setAllSmiles:(NSArray *)smiles
{
	self.smiles =  smiles;
}
-(void)setAllRecentSmiles:(NSArray *)smiles
{
	self.recentSmiles = smiles;
}

@end
