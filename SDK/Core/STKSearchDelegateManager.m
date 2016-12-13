//
//  STKSearchDelegateManager.m
//  StickerPipe
//
//  Created by Alexander908 on 7/18/16.
//  Copyright © 2016 908 Inc. All rights reserved.
//

#import "STKSearchDelegateManager.h"
#import "STKStickerViewCell.h"
#import "STKStickerDelegateManager.h"
#import "STKStickersEntityService.h"
#import "STKSticker+CoreDataProperties.h"
#import "NSManagedObject+STKAdditions.h"
#import "NSManagedObjectContext+STKAdditions.h"

@interface STKSearchDelegateManager () <UICollectionViewDelegateFlowLayout>

//Common
@property (nonatomic) NSArray* searchStickerPacks;

@property (nonatomic) UIImage* stickerPlaceholderImage;

@end


@implementation STKSearchDelegateManager

#pragma mark - UICollectionViewDataSource

- (NSInteger)numberOfSectionsInCollectionView: (UICollectionView*)collectionView {
	return 1;
}

- (NSInteger)collectionView: (UICollectionView*)collectionView numberOfItemsInSection: (NSInteger)section {
	if (self.searchStickerPacks.count > 0) {
		return self.searchStickerPacks.count;
	} else {
		return 1;
	}
}

- (UICollectionViewCell*)collectionView: (UICollectionView*)collectionView cellForItemAtIndexPath: (NSIndexPath*)indexPath {
	NSDictionary* dict = self.searchStickerPacks[(NSUInteger) indexPath.item];
	NSString* str = [NSString stringWithFormat: @"[[%@]]", dict[@"content_id"]];

	STKStickerViewCell* cell = [collectionView dequeueReusableCellWithReuseIdentifier: @"STKStickerViewCell" forIndexPath: indexPath];
	[cell configureWithStickerMessage: str placeholder: self.stickerPlaceholderImage placeholderColor: self.placeholderColor isSuggest: YES];
	cell.imageInset = 8;

	return cell;
}

#pragma mark - UICollectionViewDelegate

- (void)collectionView: (UICollectionView*)collectionView didSelectItemAtIndexPath: (NSIndexPath*)indexPath {
	if (self.searchStickerPacks.count > 0) {
		NSDictionary* dict = self.searchStickerPacks[(NSUInteger) indexPath.item];
		NSString* str = [NSString stringWithFormat: @"[[%@]]", dict[@"content_id"]];

		NSNumber *stickerID = dict[@"content_id"];

		STKSticker* stickerObject = [STKSticker stk_objectWithUniqueAttribute: @"stickerID"
																		value: stickerID
																	  context: [NSManagedObjectContext stk_defaultContext]];

		stickerObject.stickerMessage = str;
		stickerObject.stickerID = dict[@"content_id"];
		stickerObject.stickerName = [NSString stringWithFormat: @"%@", stickerObject.stickerID];
		stickerObject.usedDate = [NSDate date];
		stickerObject.packName = dict[@"pack"];

		self.didSelectSticker(stickerObject);
	}
}


#pragma mark - UICollectionViewDelegateFlowLayout

- (CGSize)collectionView: (UICollectionView*)collectionView layout: (UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath: (NSIndexPath*)indexPath {
	return CGSizeMake(80.0, 80.0);
}


#pragma mark - Properties

- (void)setStickerPlaceholder: (UIImage*)stickerPlaceholder {
	self.stickerPlaceholderImage = stickerPlaceholder;
}

- (void)setStickerPacksArray: (NSArray*)searchStickerPacks {
	self.searchStickerPacks = searchStickerPacks;
}


@end
