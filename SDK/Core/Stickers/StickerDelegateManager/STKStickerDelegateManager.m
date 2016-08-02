//
//  STKStickerPanelDelegate.m
//  StickerPipe
//
//  Created by Vadim Degterev on 21.07.15.
//  Copyright (c) 2015 908 Inc. All rights reserved.
//

#import "STKStickerDelegateManager.h"
#import "STKStickerViewCell.h"
#import "STKStickersSeparator.h"
#import "STKStickerPackObject.h"
#import "STKEmptyRecentCell.h"
#import "UIView+CordsAdditions.h"


typedef enum {
	STKStickerPanelScrollDirectionTop,
	STKStickerPanelScrollDirectionBottom
} STKStickerPanelScrollDirection;


@interface STKStickerDelegateManager () <UIGestureRecognizerDelegate>
@property (nonatomic) CGFloat lastContentOffset;
@property (nonatomic) STKStickerPanelScrollDirection scrollDirection;

@property (nonatomic) UIView* blurView;
@property (nonatomic) UIVisualEffectView* blurEffectView;
@property (nonatomic) UIImageView* zoomStickerImageView;
@property (nonatomic) STKStickerViewCell* previousCell;
@property (nonatomic) NSLayoutConstraint* zoomStickerImageViewWidthConstraint;
@property (nonatomic) NSLayoutConstraint* zoomStickerImageViewHeightConstraint;
@property (nonatomic) NSLayoutConstraint* zoomStickerImageViewTopConstraint;
@property (nonatomic) NSLayoutConstraint* zoomStickerImageViewLeftConstraint;

//Common
@property (nonatomic) NSArray* stickerPacks;
@property (nonatomic) UIImage* stickerPlaceholderImage;
@end

@implementation STKStickerDelegateManager

static const CGFloat kZoomStickerImageHeight = 160.0;
static const CGFloat kStickerImageHeight = 80.0;

#pragma mark - UICollectionViewDataSource

- (UICollectionReusableView*)collectionView: (UICollectionView*)collectionView viewForSupplementaryElementOfKind: (NSString*)kind atIndexPath: (NSIndexPath*)indexPath {
	if ([kind isEqualToString: UICollectionElementKindSectionFooter]) {
		STKStickersSeparator* separator = [collectionView dequeueReusableSupplementaryViewOfKind: kind withReuseIdentifier: @"STKStickerPanelSeparator" forIndexPath: indexPath];
		//if last section
		if (indexPath.section == self.stickerPacks.count - 1) {
			separator.backgroundColor = [UIColor clearColor];
		} else {
			separator.backgroundColor = [UIColor colorWithRed: 229.0f / 255.0f green: 229.0f / 255.0f blue: 234.0f / 255.0f alpha: 1];
		}
		return separator;
	}
	return nil;
}

- (NSInteger)numberOfSectionsInCollectionView: (UICollectionView*)collectionView {
	return self.stickerPacks.count;
}

- (NSInteger)collectionView: (UICollectionView*)collectionView numberOfItemsInSection: (NSInteger)section {
	STKStickerPackObject* stickerPack = self.stickerPacks[(NSUInteger) section];
	if (stickerPack.stickers.count == 0 && [stickerPack.packName isEqualToString: @"Recent"]) {
		//Empty cell
		return 1;
	}

	return stickerPack.stickers.count;
}

- (UICollectionViewCell*)collectionView: (UICollectionView*)collectionView cellForItemAtIndexPath: (NSIndexPath*)indexPath {
	STKStickerPackObject* stickerPack = self.stickerPacks[(NSUInteger) indexPath.section];
	if (stickerPack.stickers.count == 0 && [stickerPack.packName isEqualToString: @"Recent"]) {
		STKEmptyRecentCell* cell = [collectionView dequeueReusableCellWithReuseIdentifier: @"STKEmptyRecentCell" forIndexPath: indexPath];
		NSString* textForResentCell;
		if (self.stickerPacks.count > 1) {
			textForResentCell = NSLocalizedString(@"Send emotions with Stickers", nil);
		} else {
			textForResentCell = NSLocalizedString(@"LOADING...", nil);
		}

		[cell configureWithText: textForResentCell];
		return cell;
	} else {
		STKStickerViewCell* cell = [collectionView dequeueReusableCellWithReuseIdentifier: @"STKStickerViewCell" forIndexPath: indexPath];

		STKStickerObject* sticker = stickerPack.stickers[(NSUInteger) indexPath.item];
		[cell configureWithStickerMessage: sticker.stickerMessage placeholder: self.stickerPlaceholderImage placeholderColor: self.placeholderColor collectionView: collectionView cellForItemAtIndexPath: indexPath isSuggest: NO];
		return cell;
	}
}


#pragma mark - UICollectionViewDelegate

- (void)collectionView: (UICollectionView*)collectionView didEndDisplayingCell: (UICollectionViewCell*)cell forItemAtIndexPath: (NSIndexPath*)indexPath {
	if (self.currentDisplayedSection == indexPath.section) {
		NSInteger itemsCount = [collectionView numberOfItemsInSection: indexPath.section];
		if (indexPath.item == itemsCount - 1 && self.scrollDirection == STKStickerPanelScrollDirectionBottom) {
			self.didChangeDisplayedSection(indexPath.section + 1);

			self.currentDisplayedSection = indexPath.section + 1;
		}
	}
}

- (void)collectionView: (UICollectionView*)collectionView didSelectItemAtIndexPath: (NSIndexPath*)indexPath {
	STKStickerPackObject* stickerPack = self.stickerPacks[(NSUInteger) indexPath.section];
	if (stickerPack.stickers.count > 0) {
		STKStickerObject* sticker = stickerPack.stickers[(NSUInteger) indexPath.item];
		if (sticker) {
			[self addRecentSticker: sticker forSection: indexPath.section];
			self.didSelectSticker(sticker);
		}
	}
}

- (void)addRecentSticker: (STKStickerObject*)sticker forSection: (NSInteger)section {
	if (section > 0) {
		sticker.usedCount = @(sticker.usedCount.integerValue + 1);
		STKStickerPackObject* recentPack = self.stickerPacks[0];

		__block NSInteger stickerIndex = -1;
		[recentPack.stickers enumerateObjectsUsingBlock: ^ (STKStickerObject* st, NSUInteger idx, BOOL* stop) {
			if (st.stickerID == sticker.stickerID) {
				stickerIndex = idx;
			}
		}];

		if (stickerIndex >= 0) {
			[recentPack.stickers removeObjectAtIndex: (NSUInteger) stickerIndex];
		}

		[recentPack.stickers insertObject: sticker atIndex: 0];
		[recentPack.stickers sortedArrayUsingDescriptors: @[[NSSortDescriptor sortDescriptorWithKey: @"usedCount" ascending: NO]]];

		if (recentPack.stickers.count > 12) {
			[recentPack.stickers removeObjectAtIndex: 12];
		}

		[self.collectionView reloadData];
	}
}


#pragma mark - UICollectionViewDelegateFlowLayout

- (CGSize)collectionView: (UICollectionView*)collectionView layout: (UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath: (NSIndexPath*)indexPath {
	STKStickerPackObject* pack = self.stickerPacks[(NSUInteger) indexPath.section];
	if ([pack.packName isEqualToString: @"Recent"] && pack.stickers.count == 0) {
		UICollectionViewFlowLayout* layout = (UICollectionViewFlowLayout*) collectionViewLayout;

		return CGSizeMake(self.collectionView.width - (layout.sectionInset.left + layout.sectionInset.right), 100.0);
	} else {
		return CGSizeMake(80.0, 80.0);
	}
}


#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidScroll: (UIScrollView*)scrollView {
	if (self.lastContentOffset > scrollView.contentOffset.y) {
		self.scrollDirection = STKStickerPanelScrollDirectionTop;
		NSInteger minSection = [[[self.collectionView indexPathsForVisibleItems] valueForKeyPath: @"@min.section"] integerValue];
		if (self.currentDisplayedSection > minSection) {
			self.currentDisplayedSection = minSection;
			self.didChangeDisplayedSection(minSection);
		}
	} else if (self.lastContentOffset < scrollView.contentOffset.y && self.lastContentOffset != 0) {
		self.scrollDirection = STKStickerPanelScrollDirectionBottom;
	}

	self.lastContentOffset = scrollView.contentOffset.y;
}


#pragma mark - Properties

- (void)setStickerPlaceholder: (UIImage*)stickerPlaceholder {
	self.stickerPlaceholderImage = stickerPlaceholder;
}

- (void)setStickerPacksArray: (NSArray*)stickerPacks {
	self.stickerPacks = stickerPacks;
}

#pragma mark - Gesture Recognizer

- (void)initZoomStickerPreviewView {
    UILongPressGestureRecognizer* longPressGestureRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action: @selector(handleLongPress:)];
    longPressGestureRecognizer.delegate = self;
    longPressGestureRecognizer.delaysTouchesBegan = YES;
    [self.collectionView addGestureRecognizer: longPressGestureRecognizer];
    
    [self initBlurView];
    
    self.blurView.hidden = YES;
}

- (void)initBlurView {
    self.blurView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, [[UIScreen mainScreen] bounds].size.width, [[UIScreen mainScreen] bounds].size.height)];
    
    if([self systemVersion] <= 7.0) {
         self.blurView.backgroundColor = [UIColor colorWithRed: 1.0f green: 1.0f blue: 1.0f alpha: 0.7];
    } else {
        self.blurView.backgroundColor = [UIColor clearColor];
        [self.blurView addSubview:[self addBlurEffectView]];
    }
       
    self.zoomStickerImageView = [UIImageView new];
    self.zoomStickerImageView.backgroundColor = [UIColor clearColor];
    
    [self.blurView addSubview: self.zoomStickerImageView];
    
    self.zoomStickerImageView.translatesAutoresizingMaskIntoConstraints = NO;
    
    self.zoomStickerImageViewWidthConstraint = [NSLayoutConstraint constraintWithItem: self.zoomStickerImageView
                                                                            attribute: NSLayoutAttributeWidth
                                                                            relatedBy: NSLayoutRelationEqual
                                                                               toItem: nil
                                                                            attribute: NSLayoutAttributeNotAnAttribute
                                                                           multiplier: 1
                                                                             constant: kZoomStickerImageHeight];
    
    self.zoomStickerImageViewHeightConstraint = [NSLayoutConstraint constraintWithItem: self.zoomStickerImageView
                                                                             attribute: NSLayoutAttributeHeight
                                                                             relatedBy: NSLayoutRelationEqual
                                                                                toItem: nil
                                                                             attribute: NSLayoutAttributeNotAnAttribute
                                                                            multiplier: 1
                                                                              constant: kZoomStickerImageHeight];
    
    self.zoomStickerImageViewTopConstraint = [NSLayoutConstraint constraintWithItem: self.zoomStickerImageView
                                                                          attribute: NSLayoutAttributeTop
                                                                          relatedBy: NSLayoutRelationEqual
                                                                             toItem: self.blurView
                                                                          attribute: NSLayoutAttributeTop
                                                                         multiplier: 1
                                                                           constant: 0];
    
    self.zoomStickerImageViewLeftConstraint = [NSLayoutConstraint constraintWithItem: self.zoomStickerImageView
                                                                           attribute: NSLayoutAttributeLeft
                                                                           relatedBy: NSLayoutRelationEqual
                                                                              toItem: self.blurView
                                                                           attribute: NSLayoutAttributeLeft
                                                                          multiplier: 1
                                                                            constant: 0];
    
    [self.blurView addConstraints: @[self.zoomStickerImageViewTopConstraint, self.zoomStickerImageViewLeftConstraint]];
    [self.zoomStickerImageView addConstraints: @[self.zoomStickerImageViewWidthConstraint, self.zoomStickerImageViewHeightConstraint]];
    
    [self.blurView.superview layoutSubviews];
}

- (void)handleLongPress: (UILongPressGestureRecognizer*)gestureRecognizer {
    
    CGPoint gestureRecognizerPoint = [gestureRecognizer locationInView:gestureRecognizer.view];
    NSIndexPath* indexPath = [self.collectionView indexPathForItemAtPoint: gestureRecognizerPoint];
    
    STKStickerViewCell* cell = nil;
    cell = (STKStickerViewCell*)[self.collectionView cellForItemAtIndexPath: indexPath];
    
    if (gestureRecognizer.state == UIGestureRecognizerStateEnded) {
        [self hideBlurView: gestureRecognizer cell:cell indexPath: indexPath];
        
    } else if (gestureRecognizer.state == UIGestureRecognizerStateBegan) {
        [self showBlurView:gestureRecognizer cell:cell indexPath:indexPath];
        
    } else {
        [self.previousCell hideStickerImage:NO];
        if (indexPath == nil) {
            return;
        } else {
            self.zoomStickerImageView.image = [cell returnStickerImage];
            [cell hideStickerImage:YES];
            self.previousCell = cell;
        }
    }
}

- (void)showBlurView: (UILongPressGestureRecognizer*)gestureRecognizer cell: (STKStickerViewCell*)cell indexPath: (NSIndexPath*)indexPath {
    
    if (indexPath == nil) {
        return;
    } else {
        self.zoomStickerImageView.image = [cell returnStickerImage];
    }
    
    self.blurView.hidden = NO;
    
    CGPoint blurViewPoint = [gestureRecognizer.view convertPoint:[self cellPoint:indexPath] toView:self.blurView];
    
    self.zoomStickerImageViewTopConstraint.constant = blurViewPoint.y - kStickerImageHeight/2;
    self.zoomStickerImageViewLeftConstraint.constant = blurViewPoint.x - kStickerImageHeight/2;
    self.zoomStickerImageViewHeightConstraint.constant = kStickerImageHeight;
    self.zoomStickerImageViewWidthConstraint.constant = kStickerImageHeight;
    
    if([self systemVersion] >= 9.0) {
        for(UIWindow* window in [[UIApplication sharedApplication] windows]) {
            if([window isKindOfClass: NSClassFromString(@"UIRemoteKeyboardWindow")]) {
                [window addSubview:self.blurView];
                [window bringSubviewToFront:self.blurView];
            }
        }
    } else {
        UIWindow* window = [UIApplication sharedApplication].windows.lastObject;
        [window addSubview: self.blurView];
        [window bringSubviewToFront: self.blurView];
    }
    
    [self.blurView layoutSubviews];
    self.zoomStickerImageViewTopConstraint.constant = self.blurView.height/2 - kStickerImageHeight*2;
    self.zoomStickerImageViewLeftConstraint.constant = self.blurView.width/2 - kZoomStickerImageHeight/2;
    self.zoomStickerImageViewHeightConstraint.constant = kZoomStickerImageHeight;
    self.zoomStickerImageViewWidthConstraint.constant = kZoomStickerImageHeight;
    
    [cell hideStickerImage:YES];
    
    [UIView animateWithDuration: 0.3
                          delay: 0
         usingSpringWithDamping: 0.7
          initialSpringVelocity: 0.5
                        options: UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         [self.blurEffectView setAlpha: 0.7];
                         [self.blurView layoutIfNeeded];
                     } completion:^(BOOL finished) { }];
}

- (void)hideBlurView: (UILongPressGestureRecognizer*)gestureRecognizer cell: (STKStickerViewCell*)cell indexPath: (NSIndexPath*)indexPath {
    
    CGPoint blurViewPoint = [gestureRecognizer.view convertPoint:[self cellPoint:indexPath] toView:self.blurView];
    
    self.zoomStickerImageViewTopConstraint.constant = blurViewPoint.y - kStickerImageHeight/2;
    self.zoomStickerImageViewLeftConstraint.constant = blurViewPoint.x - kStickerImageHeight/2;
    self.zoomStickerImageViewHeightConstraint.constant = kStickerImageHeight;
    self.zoomStickerImageViewWidthConstraint.constant = kStickerImageHeight;
    
    [UIView animateWithDuration: 0.3
                          delay: 0
         usingSpringWithDamping: 0.7
          initialSpringVelocity: 0.5
                        options: UIViewAnimationOptionCurveEaseInOut
                     animations: ^{
                         [self.blurEffectView setAlpha: 0.0];
                         [self.blurView layoutIfNeeded];
                     } completion:^(BOOL finished) {
                         self.blurView.hidden = YES;
                         [cell hideStickerImage:NO];
                     }];
}

- (CGPoint)cellPoint: (NSIndexPath*)indexPath {
    UICollectionViewLayoutAttributes* attributes = [self.collectionView layoutAttributesForItemAtIndexPath:indexPath];
    CGRect cellRect = attributes.frame;
    CGPoint cellPoint = CGPointMake(cellRect.origin.x + cellRect.size.width/2, cellRect.origin.y + cellRect.size.height/2);
    return cellPoint;
}

- (UIVisualEffectView*)addBlurEffectView {
    UIBlurEffect* blurEffect = [UIBlurEffect effectWithStyle: UIBlurEffectStyleExtraLight];
    self.blurEffectView = [[UIVisualEffectView alloc] initWithEffect: blurEffect];
    self.blurEffectView.frame = self.blurView.bounds;
    self.blurEffectView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self.blurEffectView setAlpha: 0.1];
    return self.blurEffectView;
}


- (CGFloat)systemVersion {
    return [[UIDevice currentDevice].systemVersion floatValue];
}

@end
