//
//  STKStickerHeaderDelegateManager.h
//  StickerPipe
//
//  Created by Vadim Degterev on 21.07.15.
//  Copyright (c) 2015 908 Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "STKStickerPack+CoreDataClass.h"

@class STKStickerPack;
@class NSFetchedResultsController;

@protocol STKStickerHeaderCollectionViewDelegate <NSObject>
- (BOOL)recentPresented;
@end

@interface STKStickerHeaderDelegateManager : NSObject <UICollectionViewDataSource, UICollectionViewDelegate>
@property (nonatomic, weak) id <STKStickerHeaderCollectionViewDelegate> delegate;

//TODO: -temp; better move it somewhere
@property (nonatomic) NSFetchedResultsController<STKStickerPack*>* frc;

@property (nonatomic, copy) void (^didSelectRow)(NSIndexPath* indexPath, STKStickerPack* stickerPackObject, BOOL animated);
@property (nonatomic) UIImage* placeholderImage;
@property (nonatomic) UIColor* placeholderHeaderColor;
@property (nonatomic, weak) UICollectionView* collectionView;

@property (nonatomic) NSUInteger selectedIdx;

- (void)performFetch;
- (STKStickerPack*)stickerPackForIndexPath: (NSIndexPath*)indexPath;
- (void)invalidateSelectionForIndexPath: (NSIndexPath*)indexPath;
- (void)scrollToIndexPath: (NSIndexPath*)indexPath animated: (BOOL)animated;
@end
