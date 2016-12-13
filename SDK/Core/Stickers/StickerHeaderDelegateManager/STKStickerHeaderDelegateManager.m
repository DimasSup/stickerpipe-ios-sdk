//
//  STKStickerHeaderDelegateManager.m
//  StickerPipe
//
//  Created by Vadim Degterev on 21.07.15.
//  Copyright (c) 2015 908 Inc. All rights reserved.
//

#import <CoreData/CoreData.h>
#import "STKStickerHeaderDelegateManager.h"
#import "STKStickerHeaderCell.h"
#import "NSManagedObjectContext+STKAdditions.h"
#import "STKUtility.h"


@interface STKStickerHeaderDelegateManager () <NSFetchedResultsControllerDelegate>
@end

@implementation STKStickerHeaderDelegateManager

- (instancetype)init {
	if (self = [super init]) {
		
		NSFetchRequest* request = [STKStickerPack fetchRequest];
		request.predicate = [NSPredicate predicateWithFormat: @"disabled = NO"];
		request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey: @"order" ascending: YES]];

		self.frc = [[NSFetchedResultsController alloc] initWithFetchRequest: request
													   managedObjectContext: [NSManagedObjectContext stk_defaultContext]
														 sectionNameKeyPath: nil
																  cacheName: nil];

		self.frc.delegate = self;
	}

	return self;
}

- (void)performFetch {
	NSError* error = nil;

	if (![self.frc performFetch: &error]) {
		STKLog(@"fetch faulted with error: %@", error.description);
	}
}


#pragma mark - UICollectionViewDelegate

- (NSInteger)numberOfSectionsInCollectionView: (UICollectionView*)collectionView {
	return self.frc.sections.count + 1;
}

- (NSInteger)collectionView: (UICollectionView*)collectionView numberOfItemsInSection: (NSInteger)section {
	if(section == 0)
	{
		return 1;
	}
	else{
		return self.frc.sections[0].numberOfObjects + ([self.delegate recentPresented] ? 1 : 0);
	}
}

- (UICollectionViewCell*)collectionView: (UICollectionView*)collectionView cellForItemAtIndexPath: (NSIndexPath*)indexPath {
	
	NSIndexPath* real = indexPath;
	
	STKStickerHeaderCell* cell = [collectionView dequeueReusableCellWithReuseIdentifier: @"STKStickerPanelHeaderCell" forIndexPath: indexPath];
	
	cell.layer.shouldRasterize = YES;
	cell.layer.rasterizationScale = [UIScreen mainScreen].scale;
	
	if(indexPath.section == 0)
	{
		[cell configureSmileCell];
	}
	else
	{
		indexPath = [NSIndexPath indexPathForItem:indexPath.item inSection:indexPath.section  -1];
		STKStickerPack* pack = [self stickerPackForIndexPath: indexPath];
		
		if (pack) {
			[cell configWithStickerPack: pack
							placeholder: self.placeholderImage
				   placeholderTintColor: self.placeholderHeaderColor];
		} else {
			[cell configRecentCell];
		}
		
		
	}
	if(self.selectedIdx)
	{
		[cell setStickerCellSelected: (self.selectedIdx.item == real.item) && (self.selectedIdx.section ==real.section)];
	}
	else
	{
		[cell setStickerCellSelected:NO];
	}
	return cell;
}

- (void)collectionView: (UICollectionView*)collectionView willDisplayCell: (UICollectionViewCell*)cell forItemAtIndexPath: (NSIndexPath*)indexPath {
	
	if(self.selectedIdx !=nil && (self.selectedIdx.item == indexPath.item) && (self.selectedIdx.section ==indexPath.section))
	{
		[(STKStickerHeaderCell*) cell setStickerCellSelected: YES];
	}
	else
	{
		[(STKStickerHeaderCell*)cell setStickerCellSelected:NO];
	}
	
}

- (STKStickerPack*)stickerPackForIndexPath: (NSIndexPath*)indexPath {
	
	if ([self.delegate recentPresented]) {
		if (indexPath.item == 0) {
			return nil;
		}

		indexPath = [NSIndexPath indexPathForItem: indexPath.item - 1 inSection: indexPath.section];
	}

	return [self.frc objectAtIndexPath: indexPath];
}

- (void)invalidateSelectionForIndexPath: (NSIndexPath*)indexPath {
	if(self.selectedIdx)
	{
		if ((self.selectedIdx.item == indexPath.item) && (self.selectedIdx.section ==indexPath.section))
		{
			return;
		}
	}
	
	STKStickerHeaderCell* newCell = (STKStickerHeaderCell*) [self.collectionView cellForItemAtIndexPath: indexPath];
	[newCell setStickerCellSelected: YES];

	STKStickerHeaderCell* previousCell = (STKStickerHeaderCell*) [self.collectionView cellForItemAtIndexPath:self.selectedIdx];
	[previousCell setStickerCellSelected: NO];

	self.selectedIdx = indexPath;
}


#pragma mark - UICollectionViewDelegate
-(void)makeSelected:(NSIndexPath*)indexPath
{
	[self invalidateSelectionForIndexPath: indexPath];
	
}
- (void)collectionView: (UICollectionView*)collectionView didSelectItemAtIndexPath: (NSIndexPath*)indexPath
{
	[self collectionView:collectionView didSelectItemAtIndexPath:indexPath animated:YES];
}
- (void)collectionView: (UICollectionView*)collectionView didSelectItemAtIndexPath: (NSIndexPath*)indexPath animated:(BOOL)animated{
	[self invalidateSelectionForIndexPath: indexPath];
	if(indexPath.section == 0)
	{
		self.didSelectCustomSmilesRow();
		return;
	}
	indexPath = [NSIndexPath indexPathForRow:indexPath.row inSection:indexPath.section - 1];
	
	self.didSelectRow(indexPath, [self stickerPackForIndexPath: indexPath], animated);
}

- (void)scrollToIndexPath: (NSIndexPath*)indexPath animated: (BOOL)animated {
	[self.collectionView scrollToItemAtIndexPath:indexPath atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally animated:animated];
	[self invalidateSelectionForIndexPath: indexPath];
		
	
}


#pragma mark - NSFetchedResultsControllerDelegate

- (void)controllerDidChangeContent: (NSFetchedResultsController*)controller {
	[self.collectionView reloadData];
}

@end
