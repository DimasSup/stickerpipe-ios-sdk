//
//  STKStickerPanelDelegate.h
//  StickerPipe
//
//  Created by Vadim Degterev on 21.07.15.
//  Copyright (c) 2015 908 Inc. All rights reserved.
//


#import "STKStickerObject.h"

@class STKStickersEntityService;

@interface STKStickerDelegateManager : NSObject <UICollectionViewDataSource, UICollectionViewDelegate, UIScrollViewDelegate>

//Callbacks
@property (nonatomic, copy) STIntegerBlock didChangeDisplayedSection;
@property (nonatomic, copy) STKStickerObjectBlock didSelectSticker;

@property (nonatomic, weak) UICollectionView* collectionView;

@property (nonatomic) NSInteger currentDisplayedSection;

@property (nonatomic) UIColor* placeholderColor;

@property (nonatomic) STKStickersEntityService* stickersService;

- (void)setStickerPacksArray: (NSArray*)stickerPacks;

- (void)setStickerPlaceholder: (UIImage*)stickerPlaceholder;

- (void)addRecentSticker: (STKStickerObject*)sticker forSection: (NSInteger)section;

- (void)initZoomStickerPreviewView;

@end
