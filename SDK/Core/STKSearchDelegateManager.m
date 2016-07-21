//
//  STKSearchDelegateManager.m
//  StickerPipe
//
//  Created by Alexander908 on 7/18/16.
//  Copyright © 2016 908 Inc. All rights reserved.
//

#import "STKSearchDelegateManager.h"

#import "STKStickerViewCell.h"
#import "STKStickerPackObject.h"
#import "STKStickerObject.h"

#import "STKStickerDelegateManager.h"

#import "STKStickersEntityService.h"

@interface STKSearchDelegateManager()

//Common
@property (strong, nonatomic) NSArray *searchStickerPacks;

@property (strong, nonatomic) UIImage *stickerPlaceholderImage;

@end


@implementation STKSearchDelegateManager

#pragma mark - UICollectionViewDataSource

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    if (self.searchStickerPacks.count > 0) {
        return self.searchStickerPacks.count;
    } else {
        return 1;
    }
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    STKStickerViewCell *cell = nil;
    
    cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"STKStickerViewCell" forIndexPath:indexPath];
    
    NSDictionary *dict = self.searchStickerPacks[indexPath.item];
    NSString *str = [NSString stringWithFormat:@"[[%@]]", dict[@"content_id"]];
    
    [cell configureWithStickerMessage:str placeholder:self.stickerPlaceholderImage placeholderColor:self.placeholderColor collectionView:collectionView cellForItemAtIndexPath:indexPath isSuggest:YES];
    
    cell.imageInset = 8;
    
    return cell;
}

#pragma mark - UICollectionViewDelegate

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    
    if (self.searchStickerPacks.count > 0) {
        NSDictionary *dict = self.searchStickerPacks[indexPath.item];
        NSString *str = [NSString stringWithFormat:@"[[%@]]", dict[@"content_id"]];
        
        STKStickerObject *sticker = [STKStickerObject new];
        
        sticker.stickerMessage = str;
        sticker.stickerID = dict[@"content_id"];
        sticker.stickerName = [NSString stringWithFormat:@"%@",sticker.stickerID];
        
        self.didSelectSticker(sticker);
        
        [self.stickerDelegateManager setStickerPacksArray:self.stickerDelegateManager.stickersService.stickersArray];
        
        [self.stickerDelegateManager addRecentSticker:sticker forSection:1];
    }
}

#pragma mark - UICollectionViewDelegateFlowLayout

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    return CGSizeMake(80.0, 80.0);
}

#pragma mark - Properties

- (void)setStickerPlaceholder:(UIImage *)stickerPlaceholder {
    self.stickerPlaceholderImage = stickerPlaceholder;
}

- (void)setStickerPacksArray:(NSArray *)searchStickerPacks {
    self.searchStickerPacks = searchStickerPacks;
}


@end
