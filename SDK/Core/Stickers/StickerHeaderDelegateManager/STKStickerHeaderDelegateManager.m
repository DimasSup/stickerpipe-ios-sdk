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
	return self.frc.sections.count;
}

- (NSInteger)collectionView: (UICollectionView*)collectionView numberOfItemsInSection: (NSInteger)section {
	return self.frc.sections[0].numberOfObjects + ([self.delegate recentPresented] ? 1 : 0);
}

- (UICollectionViewCell*)collectionView: (UICollectionView*)collectionView cellForItemAtIndexPath: (NSIndexPath*)indexPath {
	STKStickerHeaderCell* cell = [collectionView dequeueReusableCellWithReuseIdentifier: @"STKStickerPanelHeaderCell" forIndexPath: indexPath];

	cell.layer.shouldRasterize = YES;
	cell.layer.rasterizationScale = [UIScreen mainScreen].scale;

	STKStickerPack* pack = [self stickerPackForIndexPath: indexPath];

	if (pack) {
		[cell configWithStickerPack: pack
						placeholder: self.placeholderImage
			   placeholderTintColor: self.placeholderHeaderColor];
	} else {
		[cell configRecentCell];
	}

	[cell setStickerCellSelected: self.selectedIdx == indexPath.item];

	return cell;
}

- (void)collectionView: (UICollectionView*)collectionView willDisplayCell: (UICollectionViewCell*)cell forItemAtIndexPath: (NSIndexPath*)indexPath {
	[(STKStickerHeaderCell*) cell setStickerCellSelected: self.selectedIdx == indexPath.item];
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
	if (self.selectedIdx == (NSUInteger) indexPath.row) {
		return;
	}

	STKStickerHeaderCell* newCell = (STKStickerHeaderCell*) [self.collectionView cellForItemAtIndexPath: indexPath];
	[newCell setStickerCellSelected: YES];

	STKStickerHeaderCell* previousCell = (STKStickerHeaderCell*) [self.collectionView cellForItemAtIndexPath: [NSIndexPath indexPathForItem: self.selectedIdx inSection: 0]];
	[previousCell setStickerCellSelected: NO];

	self.selectedIdx = (NSUInteger) indexPath.row;
}


#pragma mark - UICollectionViewDelegate

- (void)collectionView: (UICollectionView*)collectionView didSelectItemAtIndexPath: (NSIndexPath*)indexPath {
	[self invalidateSelectionForIndexPath: indexPath];

	self.didSelectRow(indexPath, [self stickerPackForIndexPath: indexPath], YES);
}

- (void)scrollToIndexPath: (NSIndexPath*)indexPath animated: (BOOL)animated {
	[self invalidateSelectionForIndexPath: indexPath];

	self.didSelectRow(indexPath, [self stickerPackForIndexPath: indexPath], animated);
}


#pragma mark - NSFetchedResultsControllerDelegate

- (void)controllerDidChangeContent: (NSFetchedResultsController*)controller {
	[self.collectionView reloadData];
}

@end
