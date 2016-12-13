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
#import "UIView+CordsAdditions.h"
#import "NSManagedObjectContext+STKAdditions.h"
#import "STKUtility.h"
#import "STKStickersCache.h"


typedef enum {
	STKStickerPanelScrollDirectionTop,
	STKStickerPanelScrollDirectionBottom
} STKStickerPanelScrollDirection;


@interface STKStickerDelegateManager () <UIGestureRecognizerDelegate, NSFetchedResultsControllerDelegate, UICollectionViewDelegateFlowLayout>
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

@property (nonatomic) NSFetchedResultsController<STKSticker*>* frc;

@property (nonatomic, readonly) BOOL recentStickersPresented;
@end

@implementation STKStickerDelegateManager

static const CGFloat kZoomStickerImageHeight = 160.0;
static const CGFloat kStickerImageHeight = 80.0;


#pragma mark - UICollectionViewDataSource

- (instancetype)init {
	if (self = [super init]) {
		NSFetchRequest* request = [STKSticker fetchRequest];
		request.predicate = [NSPredicate predicateWithFormat: @"stickerPack.disabled = NO"];
		request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey: @"stickerPack.order" ascending: YES], [NSSortDescriptor sortDescriptorWithKey: @"order" ascending: YES]];

		self.frc = [[NSFetchedResultsController alloc] initWithFetchRequest: request
													   managedObjectContext: [NSManagedObjectContext stk_defaultContext]
														 sectionNameKeyPath: @"stickerPack.order"
																  cacheName: nil];

		self.frc.delegate = self;

		[[NSNotificationCenter defaultCenter] addObserver: self selector: @selector(packDisabled:) name: kSTKPackDisabledNotification object: nil];
	}

	return self;
}

- (void)packDisabled: (NSNotification*)packDisabled {
	[self performFetch];
	[self.collectionView reloadData];
}

- (UICollectionReusableView*)collectionView: (UICollectionView*)collectionView
		  viewForSupplementaryElementOfKind: (NSString*)kind
								atIndexPath: (NSIndexPath*)indexPath {
	if ([kind isEqualToString: UICollectionElementKindSectionFooter]) {
		STKStickersSeparator* separator = [collectionView dequeueReusableSupplementaryViewOfKind: kind withReuseIdentifier: @"STKStickerPanelSeparator" forIndexPath: indexPath];
		if ((indexPath.section == self.frc.sections.count && self.recentStickersPresented)
				|| (indexPath.section == self.frc.sections.count - 1 && !self.recentStickersPresented)) {
			separator.backgroundColor = [UIColor clearColor];
		} else {
			separator.backgroundColor = [UIColor colorWithRed: 229.0f / 255.0f green: 229.0f / 255.0f blue: 234.0f / 255.0f alpha: 1];
		}
		return separator;
	}
	return nil;
}

- (BOOL)recentStickersPresented {
	return self.recentStickers.count > 0;
}

- (NSInteger)numberOfSectionsInCollectionView: (UICollectionView*)collectionView {
	return (self.recentStickersPresented ? 1 : 0) + self.frc.sections.count;
}

- (NSInteger)collectionView: (UICollectionView*)collectionView numberOfItemsInSection: (NSInteger)section {
	if (self.recentStickersPresented) {
		if (section == 0) {
			return self.recentStickers.count;
		}

		--section;
	}

	return self.frc.sections[(NSUInteger) section].numberOfObjects;
}

- (STKSticker*)stickerForIndexPath: (NSIndexPath*)indexPath {
	if (self.recentStickersPresented) {
		if (indexPath.section == 0) {
			return self.recentStickers[(NSUInteger) indexPath.item];
		}

		indexPath = [NSIndexPath indexPathForItem: indexPath.item inSection: indexPath.section - 1];
	}

	return [self.frc objectAtIndexPath: indexPath];
}

- (UICollectionViewCell*)collectionView: (UICollectionView*)collectionView
				 cellForItemAtIndexPath: (NSIndexPath*)indexPath {
	STKStickerViewCell* cell = [collectionView dequeueReusableCellWithReuseIdentifier: @"STKStickerViewCell" forIndexPath: indexPath];
	[cell configureWithStickerMessage: [self stickerForIndexPath: indexPath].stickerMessage
						  placeholder: self.stickerPlaceholderImage
					 placeholderColor: self.placeholderColor
							isSuggest: NO];

	return cell;
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
	STKSticker* sticker = [self stickerForIndexPath: indexPath];
	self.didSelectSticker(sticker, indexPath.section == 0);
}


#pragma mark - UICollectionViewDelegateFlowLayout

- (CGSize)collectionView: (UICollectionView*)collectionView
				  layout: (UICollectionViewLayout*)collectionViewLayout
  sizeForItemAtIndexPath: (NSIndexPath*)indexPath {
	return CGSizeMake(80.0, 80.0);
}


#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidScroll: (UIScrollView*)scrollView {
	if (self.lastContentOffset > scrollView.contentOffset.y) {
		self.scrollDirection = STKStickerPanelScrollDirectionTop;
		NSArray<NSIndexPath*>* paths = [self.collectionView indexPathsForVisibleItems];
		if (paths.count == 0) {
			return;
		}

		NSInteger minSection = [[paths valueForKeyPath: @"@min.section"] integerValue];
		if (self.currentDisplayedSection > minSection) {
			self.currentDisplayedSection = minSection;
			self.didChangeDisplayedSection(minSection);
		}
	} else if (self.lastContentOffset < scrollView.contentOffset.y && self.lastContentOffset != 0) {
		self.scrollDirection = STKStickerPanelScrollDirectionBottom;
	}

	self.lastContentOffset = scrollView.contentOffset.y;
}


#pragma mark - Gesture Recognizer

- (void)initZoomStickerPreviewView {
	UILongPressGestureRecognizer* longPressGestureRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget: self action: @selector(handleLongPress:)];
	longPressGestureRecognizer.delegate = self;
	longPressGestureRecognizer.delaysTouchesBegan = YES;
	[self.collectionView addGestureRecognizer: longPressGestureRecognizer];

	[self initBlurView];

	self.blurView.hidden = YES;
}

- (void)initBlurView {
	self.blurView = [[UIView alloc] initWithFrame: CGRectMake(0, 0, [[UIScreen mainScreen] bounds].size.width, [[UIScreen mainScreen] bounds].size.height)];

	if ([self systemVersion] <= 7.0) {
		self.blurView.backgroundColor = [UIColor colorWithRed: 1.0f green: 1.0f blue: 1.0f alpha: 0.7];
	} else {
		self.blurView.backgroundColor = [UIColor clearColor];
		[self.blurView addSubview: [self addBlurEffectView]];
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

	CGPoint gestureRecognizerPoint = [gestureRecognizer locationInView: gestureRecognizer.view];
	NSIndexPath* indexPath = [self.collectionView indexPathForItemAtPoint: gestureRecognizerPoint];

	STKStickerViewCell* cell = nil;
	cell = (STKStickerViewCell*) [self.collectionView cellForItemAtIndexPath: indexPath];

	if (gestureRecognizer.state == UIGestureRecognizerStateEnded) {
		[self hideBlurView: gestureRecognizer cell: cell indexPath: indexPath];

	} else if (gestureRecognizer.state == UIGestureRecognizerStateBegan) {
		[self showBlurView: gestureRecognizer cell: cell indexPath: indexPath];

	} else {
		[self.previousCell hideStickerImage: NO];
		if (indexPath == nil) {
			return;
		} else {
			self.zoomStickerImageView.image = [cell returnStickerImage];
			[cell hideStickerImage: YES];
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

	CGPoint blurViewPoint = [gestureRecognizer.view convertPoint: [self cellPoint: indexPath] toView: self.blurView];

	self.zoomStickerImageViewTopConstraint.constant = blurViewPoint.y - kStickerImageHeight / 2;
	self.zoomStickerImageViewLeftConstraint.constant = blurViewPoint.x - kStickerImageHeight / 2;
	self.zoomStickerImageViewHeightConstraint.constant = kStickerImageHeight;
	self.zoomStickerImageViewWidthConstraint.constant = kStickerImageHeight;

	if ([self systemVersion] >= 9.0) {
		for (UIWindow* window in [[UIApplication sharedApplication] windows]) {
			if ([window isKindOfClass: NSClassFromString(@"UIRemoteKeyboardWindow")]) {
				[window addSubview: self.blurView];
				[window bringSubviewToFront: self.blurView];
			}
		}
	} else {
		UIWindow* window = [UIApplication sharedApplication].windows.lastObject;
		[window addSubview: self.blurView];
		[window bringSubviewToFront: self.blurView];
	}

	[self.blurView layoutSubviews];
	self.zoomStickerImageViewTopConstraint.constant = self.blurView.height / 2 - kStickerImageHeight * 2;
	self.zoomStickerImageViewLeftConstraint.constant = self.blurView.width / 2 - kZoomStickerImageHeight / 2;
	self.zoomStickerImageViewHeightConstraint.constant = kZoomStickerImageHeight;
	self.zoomStickerImageViewWidthConstraint.constant = kZoomStickerImageHeight;

	[cell hideStickerImage: YES];

	[UIView animateWithDuration: 0.3
						  delay: 0
		 usingSpringWithDamping: 0.7
		  initialSpringVelocity: 0.5
						options: UIViewAnimationOptionCurveEaseInOut
					 animations: ^ {
						 [self.blurEffectView setAlpha: 0.7];
						 [self.blurView layoutIfNeeded];
					 } completion: ^ (BOOL finished) {
			}];
}

- (void)hideBlurView: (UILongPressGestureRecognizer*)gestureRecognizer cell: (STKStickerViewCell*)cell indexPath: (NSIndexPath*)indexPath {
	CGPoint blurViewPoint = [gestureRecognizer.view convertPoint: [self cellPoint: indexPath] toView: self.blurView];

	self.zoomStickerImageViewTopConstraint.constant = blurViewPoint.y - kStickerImageHeight / 2;
	self.zoomStickerImageViewLeftConstraint.constant = blurViewPoint.x - kStickerImageHeight / 2;
	self.zoomStickerImageViewHeightConstraint.constant = kStickerImageHeight;
	self.zoomStickerImageViewWidthConstraint.constant = kStickerImageHeight;

	[UIView animateWithDuration: 0.3
						  delay: 0
		 usingSpringWithDamping: 0.7
		  initialSpringVelocity: 0.5
						options: UIViewAnimationOptionCurveEaseInOut
					 animations: ^ {
						 [self.blurEffectView setAlpha: 0.0];
						 [self.blurView layoutIfNeeded];
					 } completion: ^ (BOOL finished) {
				self.blurView.hidden = YES;
				[cell hideStickerImage: NO];
			}];
}

- (CGPoint)cellPoint: (NSIndexPath*)indexPath {
	UICollectionViewLayoutAttributes* attributes = [self.collectionView layoutAttributesForItemAtIndexPath: indexPath];
	CGRect cellRect = attributes.frame;
	CGPoint cellPoint = CGPointMake(cellRect.origin.x + cellRect.size.width / 2, cellRect.origin.y + cellRect.size.height / 2);
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

- (void)performFetch {
	NSError* error = nil;

	if (![self.frc performFetch: &error]) {
		STKLog(@"fetch faulted with error: %@", error.description);
	}
}


#pragma mark - NSFetchedResultsControllerDelegate

- (void)controllerDidChangeContent: (NSFetchedResultsController*)controller {
	[self.collectionView reloadData];
}


@end
