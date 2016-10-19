//
//  STKStickerController.m
//  StickerPipe
//
//  Created by Vadim Degterev on 21.07.15.
//  Copyright (c) 2015 908 Inc. All rights reserved.
//

#import "STKStickerController.h"
#import "STKStickerDelegateManager.h"
#import "STKStickerHeaderDelegateManager.h"
#import "STKStickerViewCell.h"
#import "STKStickersSeparator.h"
#import "STKStickerHeaderCell.h"
#import "STKUtility.h"
#import "STKStickersEntityService.h"
#import "STKEmptyRecentCell.h"
#import "STKStickersSettingsViewController.h"
#import "STKStickersShopViewController.h"
#import "STKStickerPackObject.h"
#import "STKOrientationNavigationController.h"
#import "STKShowStickerButton.h"
#import "STKAnalyticService.h"
#import "STKStickersManager.h"
#import "STKSearchModel.h"
#import "STKSearchDelegateManager.h"
#import "STKWebserviceManager.h"
#import "NSLayoutConstraint+Addictions.h"
#import "STKImageManager.h"
#import "UITextView+StickerButtonControl.h"
#import "SmilesHelper.h"
#import "StickerPipeCustomSmilesDelegateManager.h"
#import "helper.h"

@interface STKStickerController () <UITextViewDelegate, STKStickersSettingsViewControllerDelegate, STKStickersShopViewControllerDelegate>

@property (nonatomic) IBOutlet UIView* internalStickersView;
@property (nonatomic, weak) IBOutlet UICollectionView* stickersHeaderCollectionView;
@property (nonatomic, weak) IBOutlet STKShowStickerButton* stickersShopButton;
@property (nonatomic, weak) IBOutlet UIView* errorView;
@property (nonatomic, weak) IBOutlet UILabel* errorLabel;
@property (weak, nonatomic) IBOutlet UICollectionView *customSmilesCollectionView;
@property (weak, nonatomic) IBOutlet UIView *customSmilesMainView;

@property (nonatomic) StickerPipeCustomSmilesDelegateManager* customSmileDelegateManager;
@property (nonatomic) STKStickerDelegateManager* stickersDelegateManager;
@property (nonatomic) STKStickerHeaderDelegateManager* stickersHeaderDelegateManager;
@property (nonatomic) BOOL isKeyboardShowed;
@property (nonatomic) BOOL initialLoadingFinished;

@property (nonatomic) STKStickersEntityService* stickersService;

@property (nonatomic) STKStickersShopViewController* shopViewController;
@property (nonatomic) STKStickersSettingsViewController* settingsViewController;

@property (nonatomic) STKSearchDelegateManager* searchDelegateManager;


- (IBAction)collectionsButtonAction: (id)sender;
- (IBAction)stickersShopButtonAction: (id)sender;
- (IBAction)closeError: (id)sender;

@end

@implementation STKStickerController


static const CGFloat kStickersSectionPaddingTopBottom = 12.0;
static const CGFloat kKeyboardButtonHeight = 33.0;

- (instancetype)init {
	if (self = [super init]) {
		[[STKWebserviceManager sharedInstance] addObserver: self
												forKeyPath: @"networkReachable"
												   options: NSKeyValueObservingOptionNew
												   context: nil];

		[[STKWebserviceManager sharedInstance] startCheckingNetwork];

		[[NSNotificationCenter defaultCenter] addObserver: self
												 selector: @selector(willHideKeyboard:)
													 name: UIKeyboardWillHideNotification
												   object: nil];

		[[NSNotificationCenter defaultCenter] addObserver: self
												 selector: @selector(didShowKeyboard:)
													 name: UIKeyboardWillShowNotification
												   object: nil];

		[[NSNotificationCenter defaultCenter] addObserver: self
												 selector: @selector(textFieldDidChange:)
													 name: UITextViewTextDidChangeNotification
												   object: self.textInputView];

		[[NSNotificationCenter defaultCenter] addObserver: self
												 selector: @selector(storageUpdated:)
													 name: STKStickersCacheDidUpdateStickersNotification
												   object: nil];

		self.stickersService = [STKStickersEntityService new];
		self.imageManager = [STKImageManager new];

		self.stickersDelegateManager = [STKStickerDelegateManager new];
		self.stickersDelegateManager.stickersService = self.stickersService;

		self.stickersHeaderDelegateManager = [STKStickerHeaderDelegateManager new];

		self.stickersShopButton.badgeBorderColor = [STKUtility defaultGreyColor];
		self.stickersShopButton.tintColor = [STKUtility defaultBlueColor];
		self.stickersShopButton.backgroundColor = self.headerBackgroundColor ?: [STKUtility defaultGreyColor];

		[self initInternalStickerView];
		[self initStickerHeader];
		[self initStickersCollectionView];

		[self loadStickerPacksWithCompletion: ^ {
			self.initialLoadingFinished = YES;
			[self reloadStickersView];
		}];

		[self reloadRecentAtStart];

		NSUserDefaults* userDefaults = [NSUserDefaults standardUserDefaults];
		[userDefaults setObject: @"currentVC" forKey: @"viewController"];
		[userDefaults synchronize];

		self.searchDelegateManager = [STKSearchDelegateManager new];
		self.searchDelegateManager.stickerDelegateManager = self.stickersDelegateManager;
	}

	return self;
}

- (void)initInternalStickerView
{
	self.internalStickersView = [[[NSBundle mainBundle] loadNibNamed: @"STKStickersViewCustom" owner: self options: nil] firstObject];

	/**
	 *  For framework
	 */
	//    self.internalStickersView = [[[self getResourceBundle] loadNibNamed:@"STKStickersView" owner:self options:nil] firstObject];

	if (self.stickersViewFrame.size.height > 0) {
		self.internalStickersView.autoresizingMask = UIViewAutoresizingNone;
		self.internalStickersView.frame = self.stickersViewFrame;
	} else {
		self.internalStickersView.autoresizingMask = UIViewAutoresizingFlexibleHeight;
	}


	self.internalStickersView.clipsToBounds = YES;

	//iOS 7 FIX
	if (CGRectEqualToRect(self.internalStickersView.frame, CGRectZero) && [UIDevice currentDevice].systemVersion.floatValue < 8.0) {
		self.internalStickersView.frame = CGRectMake(1, 1, 1, 1);
	}
	[self reloadSmiles];
}

- (void)initStickersCollectionView {
	typeof(self) __weak weakSelf = self;

	self.stickersDelegateManager.didChangeDisplayedSection = ^ (NSInteger displayedSection) {
		[weakSelf setPackSelectedAtIndex: displayedSection];
	};

	self.stickersDelegateManager.didSelectSticker = ^ (STKStickerObject* sticker, BOOL recent) {
		[weakSelf.stickersService incrementStickerUsedCountWithID: sticker.stickerID];

		[[STKAnalyticService sharedService] sendEventWithCategory: STKAnalyticStickerCategory
														   action: recent ? STKAnalyticActionRecent : STKAnalyticActionTabs
															label: [NSString stringWithFormat: @"%@", sticker.stickerID] value: nil];

		if ([weakSelf.delegate respondsToSelector: @selector(stickerController:didSelectStickerWithMessage:)]) {
			[weakSelf.delegate stickerController: weakSelf didSelectStickerWithMessage: sticker.stickerMessage];
		}
	};

	self.stickersCollectionView.dataSource = self.stickersDelegateManager;
	self.stickersCollectionView.delegate = self.stickersDelegateManager;
	self.stickersDelegateManager.collectionView = self.stickersCollectionView;
	[self.stickersCollectionView registerClass: [STKStickerViewCell class] forCellWithReuseIdentifier: @"STKStickerViewCell"];
	[self.stickersCollectionView registerClass: [STKEmptyRecentCell class] forCellWithReuseIdentifier: @"STKEmptyRecentCell"];
	[self.stickersCollectionView registerClass: [UICollectionReusableView class] forSupplementaryViewOfKind: UICollectionElementKindSectionHeader withReuseIdentifier: @"UICollectionReusableView"];
	[self.stickersCollectionView registerClass: [STKStickersSeparator class] forSupplementaryViewOfKind: UICollectionElementKindSectionFooter withReuseIdentifier: @"STKStickerPanelSeparator"];


	self.stickersDelegateManager.collectionView = self.stickersCollectionView;

	[self.stickersDelegateManager initZoomStickerPreviewView];
}

- (void)initStickerHeader {
	typeof(self) __weak weakSelf = self;

	self.stickersHeaderDelegateManager.didSelectRow = ^ (NSIndexPath* indexPath, STKStickerPackObject* stickerPack, BOOL animated) {
		if (stickerPack.isNew.boolValue) {
			stickerPack.isNew = @NO;
			[weakSelf.stickersService updateStickerPackInCache: stickerPack];
			[weakSelf reloadHeaderItemAtIndexPath: indexPath];
		}
		[weakSelf setLastSelectedStickerPack:indexPath.row];
		
		
		if( [weakSelf.delegate respondsToSelector:@selector(stickerController:didSelectPack:)])
		{
			[weakSelf.delegate stickerController:weakSelf didSelectPack:stickerPack.packName];
		}

		NSInteger numberOfItems = [weakSelf.stickersCollectionView numberOfItemsInSection: indexPath.item];

		if (numberOfItems != 0) {
			NSIndexPath* newIndexPath = [NSIndexPath indexPathForItem: 0 inSection: indexPath.item];
			CGRect layoutRect = [weakSelf.stickersCollectionView layoutAttributesForItemAtIndexPath: newIndexPath].frame;
			if (stickerPack.stickers.count > 0 || indexPath.item == 0) {
				[weakSelf.stickersCollectionView setContentOffset: CGPointMake(weakSelf.stickersCollectionView.contentOffset.x, layoutRect.origin.y - kStickersSectionPaddingTopBottom) animated: animated];
				weakSelf.stickersDelegateManager.currentDisplayedSection = indexPath.item;
			}
		}
		[weakSelf hideCustomSmiles];
	};
	
	
	[self.stickersHeaderDelegateManager setDidSelectCustomSmilesRow:^{
		[weakSelf showCustomSmiles];
		[weakSelf setLastSelectedStickerPack:-1];
		
		if( [weakSelf.delegate respondsToSelector:@selector(stickerController:didSelectPack:)])
		{
			[weakSelf.delegate stickerController:weakSelf didSelectPack:@"custom_smiles"];
		}
	}];
	
	[self.stickersHeaderDelegateManager setDidSelectSettingsRow:^{
		[weakSelf collectionsButtonAction:nil];
	}];


	self.stickersHeaderDelegateManager.didSelectSettingsRow = ^ {
		[weakSelf collectionsButtonAction: nil];
	};

	self.stickersHeaderCollectionView.dataSource = self.stickersHeaderDelegateManager;
	self.stickersHeaderCollectionView.delegate = self.stickersHeaderDelegateManager;

	[self.stickersHeaderCollectionView registerClass: [STKStickerHeaderCell class] forCellWithReuseIdentifier: @"STKStickerPanelHeaderCell"];

	self.stickersHeaderCollectionView.backgroundColor = self.headerBackgroundColor ? self.headerBackgroundColor : [STKUtility defaultGreyColor];

	self.stickersShopButton.badgeView.hidden = !self.stickersService.hasNewModifiedPacks;
}

- (void)initKeyBoardButton {
	STKShowStickerButton* button = [STKShowStickerButton buttonWithType: UIButtonTypeSystem];
	self.keyboardButton = button;
	self.keyboardButton.translatesAutoresizingMaskIntoConstraints = NO;
	self.keyboardButton.tintColor = [UIColor grayColor];
	self.keyboardButton.badgeView.hidden = ![self.stickersService hasNewPacks];
	self.keyboardButton.stickerButtonState = STKShowStickerButtonStateStickers;
	[self.keyboardButton addTarget: self action: @selector(keyboardButtonAction:) forControlEvents: UIControlEventTouchUpInside];
	self.keyboardButton.frame = CGRectMake(self.textInputView.frame.origin.x, self.textInputView.frame.origin.y, 33, 33);
	[self.textInputView.superview addSubview: button];

	[self.textInputView.superview layoutSubviews];

}

- (void)initSuggestCollectionViewWithStickersArray: (NSArray*)stickers {
	UICollectionViewFlowLayout* aFlowLayout = [UICollectionViewFlowLayout new];
	[aFlowLayout setItemSize: CGSizeMake(320, 80)];
	[aFlowLayout setScrollDirection: UICollectionViewScrollDirectionHorizontal];

	[self.suggestCollectionView setCollectionViewLayout: aFlowLayout];
	self.suggestCollectionView.backgroundColor = [UIColor colorWithRed: 1.0f green: 1.0f blue: 1.0f alpha: 0.6];
	[self.suggestCollectionView setShowsHorizontalScrollIndicator: NO];
	[self.suggestCollectionView setShowsVerticalScrollIndicator: NO];

	[self.searchDelegateManager setStickerPacksArray: stickers];

	typeof(self) __weak weakSelf = self;

	self.searchDelegateManager.didSelectSticker = ^ (STKStickerObject* sticker) {
		[weakSelf hideSuggestCollectionView];

		[weakSelf.stickersService incrementStickerUsedCountWithID: sticker.stickerID];

		[[STKAnalyticService sharedService] sendEventWithCategory: STKAnalyticStickerCategory action: STKAnalyticActionSuggest label: [NSString stringWithFormat: @"%@", sticker.stickerID] value: nil];

		if ([weakSelf.delegate respondsToSelector: @selector(stickerController:didSelectStickerWithMessage:)]) {
			[weakSelf.delegate stickerController: weakSelf didSelectStickerWithMessage: sticker.stickerMessage];
		}
	};

	self.suggestCollectionView.dataSource = self.searchDelegateManager;
	self.suggestCollectionView.delegate = self.searchDelegateManager;
	self.searchDelegateManager.collectionView = self.suggestCollectionView;

	[self.suggestCollectionView registerClass: [STKStickerViewCell class] forCellWithReuseIdentifier: @"STKStickerViewCell"];
	[self.suggestCollectionView registerClass: [UICollectionReusableView class] forSupplementaryViewOfKind: UICollectionElementKindSectionHeader withReuseIdentifier: @"UICollectionReusableView"];

	self.searchDelegateManager.collectionView = self.suggestCollectionView;
}


#pragma mark - STKStickersSettingsViewControllerDelegate

- (void)stickersReorder: (STKStickersSettingsViewController*)stickersController packs: (NSArray*)packs {
	NSMutableArray* stickers = [packs mutableCopy];
	[stickers insertObject: self.stickersService.stickersArray[0] atIndex: 0];
	self.stickersService.stickersArray = stickers;
	self.stickersHeaderDelegateManager.stickerPacksArray = stickers;
	[self.stickersDelegateManager setStickerPacksArray: stickers];
	[self.stickersCollectionView reloadData];
	[self.stickersHeaderCollectionView reloadData];
	[self reloadRecent];

	id <STKStickerControllerDelegate> o = self.delegate;
	if ([o respondsToSelector: @selector(stickersReordered)]) {
		[o stickersReordered];
	}
}

- (void)showStickersView {
	self.keyboardButton.stickerButtonState = STKShowStickerButtonStateKeyboard;

	[self reloadStickersView];

	self.textInputView.inputView = self.stickersView;
	
	[self reloadStickersInputViews];
	
}

- (void)loadStickerPacksWithCompletion: (STSimpleBlock)completion {
	[self.stickersService getStickerPacksWithType: nil completion: ^ (NSArray* stickerPacks) {
		self.stickersService.stickersArray = stickerPacks;
		self.keyboardButton.badgeView.hidden = ![self.stickersService hasNewPacks];
		self.stickersShopButton.badgeView.hidden = !self.stickersService.hasNewModifiedPacks;
		if (completion) completion();
	}                                     failure: nil];

}


-(void)reloadSmiles
{
	self.customSmileDelegateManager = [StickerPipeCustomSmilesDelegateManager new];
	NSArray* allSmiles = [SmilesHelper newAllSmiles];
	NSMutableArray* smileIds = [NSMutableArray new];
	for (NSString* item  in allSmiles)
	{
		[smileIds addObject:[SmilesHelper smilesMappingCode][item]];
	}
	[self.customSmileDelegateManager setAllSmiles:smileIds];
	__weak typeof(self) weakSelf = self;
	
	[self.customSmileDelegateManager setDidSelectCustomSmile:^(NSString * smileId, NSIndexPath * indexPath) {
		if(weakSelf.delegate && [weakSelf.delegate respondsToSelector:@selector(stickerController:didSelectCustomSmile:)])
		{
			[weakSelf.delegate stickerController:weakSelf didSelectCustomSmile:smileId];
		}
	}];
	
	self.customSmilesCollectionView.dataSource = self.customSmileDelegateManager;
	self.customSmilesCollectionView.delegate = self.customSmileDelegateManager;
	[self.customSmilesCollectionView registerNib:[UINib nibWithNibName:@"StickerPipeCustomSmileCell" bundle:nil] forCellWithReuseIdentifier:kStickerPipeCustomSmileCell];
	[self.customSmilesCollectionView registerClass:[STKStickersSeparator class] forSupplementaryViewOfKind:UICollectionElementKindSectionFooter withReuseIdentifier:@"STKStickerPanelSeparator"];
	
}


- (void)reloadRecent {

	STKStickerPackObject* recentPack = [self.stickersService recentPack];
	NSMutableArray* stickers = [self.stickersService.stickersArray mutableCopy];
	stickers[0] = recentPack;
	self.stickersService.stickersArray = stickers;
	[self.stickersDelegateManager setStickerPacksArray: stickers];
	[self.stickersCollectionView reloadSections: [NSIndexSet indexSetWithIndex: 0]];
}

- (void)reloadRecentAtStart {
	NSMutableArray* stickers = [@[[self.stickersService recentPack]] mutableCopy];

	self.stickersService.stickersArray = stickers;
	[self.stickersDelegateManager setStickerPacksArray: stickers];
	[self.stickersCollectionView reloadSections: [NSIndexSet indexSetWithIndex: 0]];
}

- (void)showModalViewController: (UIViewController*)viewController {
	[self hideStickersView];;
	STKOrientationNavigationController* navigationController = [[STKOrientationNavigationController alloc] initWithRootViewController: viewController];

	UIViewController* presenter = [self.delegate stickerControllerViewControllerForPresentingModalView];

	NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
	NSString* vc = [defaults objectForKey: @"viewController"];
	NSString* isNotification = [defaults objectForKey: @"isNotification"];
	[defaults synchronize];

	if ([isNotification isEqualToString: @"yes"]) {
		if ([vc isEqualToString: @"shop"]) {
			[_shopViewController presentViewController: navigationController animated: YES completion: nil];
			[self setUserDefaultsValue];
		} else if ([vc isEqualToString: @"settings"]) {
			[_settingsViewController presentViewController: navigationController animated: YES completion: nil];
			[self setUserDefaultsValue];
		} else {
			[presenter presentViewController: navigationController animated: YES completion: nil];
			[self setUserDefaultsValue];
		}
	} else {
		[presenter presentViewController: navigationController animated: YES completion: nil];
	}
}

- (void)handleError: (NSError*)error {
	self.errorView.hidden = NO;
	self.errorLabel.text = (error.code == NSURLErrorNotConnectedToInternet) ? NSLocalizedString(@"No internet connection", nil) : NSLocalizedString(@"Oops... something went wrong", nil);
	if ([self.delegate respondsToSelector: @selector(stickerControllerErrorHandle:)]) {
		if ([STKWebserviceManager sharedInstance].networkReachable) {
			[self.delegate stickerControllerErrorHandle: error];
		} else {
			NSError* noInternetError = [NSError errorWithDomain: NSCocoaErrorDomain code: NSURLErrorNotConnectedToInternet userInfo: nil];
			[self.delegate stickerControllerErrorHandle: noInternetError];
		}
	}
}

- (IBAction)btnSmileBackspace:(id)sender {
	if([self.delegate respondsToSelector:@selector(stickerControllerDidRemoveSmile:)])
	{
		[self.delegate stickerControllerDidRemoveSmile:self];
	}
}
-(void)hideCustomSmiles
{
	self.customSmilesMainView.hidden = YES;
}
-(void)showCustomSmiles
{
	self.customSmilesMainView.hidden = NO;
}

#pragma mark - Actions

- (void)collectionsButtonAction: (UIButton*)collectionsButton {
	if (!_settingsViewController) {
		_settingsViewController = [[STKStickersSettingsViewController alloc] initWithNibName: @"STKStickersSettingsViewController" bundle: [NSBundle mainBundle]];

		/**
		 *  For framework
		 */
		//    _settingsViewController = [[STKStickersSettingsViewController alloc] initWithNibName:@"STKStickersSettingsViewController" bundle:[self getResourceBundle]];

		_settingsViewController.delegate = self;
	}

	[self showModalViewController: _settingsViewController];
}

- (void)stickersShopButtonAction: (id)sender {
	if (!_shopViewController) {
		_shopViewController = [[STKStickersShopViewController alloc] initWithNibName: @"STKStickersShopViewController" bundle: [NSBundle mainBundle]];

		/**
		 *  For framework
		 */
		//    _shopViewController = [[STKStickersShopViewController alloc] initWithNibName:@"STKStickersShopViewController" bundle:[self getResourceBundle]];

		_shopViewController.delegate = self;
	}

	self.stickersService.hasNewModifiedPacks = NO;
	[self showModalViewController: _shopViewController];

	id <STKStickerControllerDelegate> o = self.delegate;
	if ([o respondsToSelector: @selector(shopOpened)]) {
		[o shopOpened];
	}
	
	[[NSNotificationCenter defaultCenter] postNotificationName: STKOpenShopNotification object: self];

}

- (void)keyboardButtonAction: (UIButton*)keyboardButton {
	if (self.textInputView.inputView) {
		[self hideStickersView];

		if (self.isSuggestArrayNotEmpty && ![self.textInputView.text isEqualToString: @""]) {
			[self showSuggestCollectionView];
		}
	} else {
		[self showStickersView];

		if (self.isSuggestArrayNotEmpty) {
			[self hideSuggestCollectionView];
		}
	}
}

- (void)closeError: (id)sender {
	if ([STKWebserviceManager sharedInstance].networkReachable) {
		self.errorView.hidden = YES;
		[self loadStickerPacksWithCompletion: ^ {
			if (self.showStickersOnStart) {
				[self showStickersView];
			}
		}];
	} else {
		self.errorView.hidden = NO;
	}
}


#pragma mark - Reload

- (void)reloadStickersView {
	NSArray* stickerPacks = self.stickersService.stickersArray;
	[self.stickersDelegateManager setStickerPacksArray: stickerPacks];
	self.stickersHeaderDelegateManager.stickerPacksArray = stickerPacks;
	[self.stickersCollectionView reloadData];
	[self.stickersHeaderCollectionView reloadData];
	self.stickersCollectionView.contentOffset = CGPointZero;
	self.stickersDelegateManager.currentDisplayedSection = 0;
	int value = [self getLastSelectedStickerPack];
	[self setPackSelectedAtIndex:value>0?0:value];
	
}

- (void)reloadHeaderItemAtIndexPath: (NSIndexPath*)indexPath {
	NSArray* stickerPacks = self.stickersService.stickersArray;
	self.stickersHeaderDelegateManager.stickerPacksArray = stickerPacks;
	[self.stickersHeaderCollectionView reloadItemsAtIndexPaths: @[indexPath]];
	[self.stickersHeaderCollectionView selectItemAtIndexPath: indexPath animated: NO scrollPosition: UICollectionViewScrollPositionNone];
}
#pragma mark - save/load
-(NSIndexPath*)selectedIndexHeaderForSavedValue:(int)value
{
	if(value==-1)
	{
		return [NSIndexPath indexPathForItem:0 inSection:0];
	}
	else
	{
		return [NSIndexPath indexPathForItem:value inSection:1];
	}
}
-(int)getLastSelectedStickerPack
{
	return [[NSUserDefaults standardUserDefaults] integerForKey:@"stk_lastselected_header"];
	
}
-(void)setLastSelectedStickerPack:(int)value
{
	[[NSUserDefaults standardUserDefaults] setInteger:value forKey:@"stk_lastselected_header"];
}


#pragma mark -
- (void)reloadStickersHeader {

	NSArray* stickerPacks = self.stickersService.stickersArray;
	self.stickersHeaderDelegateManager.stickerPacksArray = stickerPacks;
	[self.stickersHeaderCollectionView reloadItemsAtIndexPaths: @[[NSIndexPath indexPathForItem: 1 inSection: 0]]];
	NSIndexPath* selectedIndexPath = [NSIndexPath indexPathForItem: self.stickersDelegateManager.currentDisplayedSection inSection: 0];
	[self.stickersHeaderCollectionView selectItemAtIndexPath: selectedIndexPath animated: NO scrollPosition: UICollectionViewScrollPositionNone];
}


#pragma mark - Selection

- (void)setPackSelectedAtIndex: (NSInteger)index {
	if(index>0)
	{
		
		if ([self.stickersHeaderCollectionView numberOfItemsInSection:1] - 1 >= index) {
			NSIndexPath *indexPath = [self selectedIndexHeaderForSavedValue:index];
			STKStickerPackObject *stickerPack = self.stickersHeaderDelegateManager.stickerPacksArray[index];
			if (stickerPack.isNew.boolValue) {
				stickerPack.isNew = @NO;
				[self.stickersService updateStickerPackInCache:stickerPack];
				[self reloadHeaderItemAtIndexPath:[NSIndexPath indexPathForItem:index inSection:1]];
			}
			[self.stickersHeaderCollectionView selectItemAtIndexPath:indexPath animated:YES scrollPosition:UICollectionViewScrollPositionCenteredHorizontally];
		}
	}
	else
	{
		NSIndexPath *indexPath = [self selectedIndexHeaderForSavedValue:index];
		[self.stickersHeaderCollectionView selectItemAtIndexPath:indexPath animated:YES scrollPosition:UICollectionViewScrollPositionCenteredHorizontally];
		[self.stickersHeaderDelegateManager collectionView:self.stickersHeaderCollectionView didSelectItemAtIndexPath:indexPath];
		
	}
}


#pragma mark - Presenting

- (void)showPackInfoControllerWithStickerMessage: (NSString*)message {
	[self hideStickersView];
	STKStickersShopViewController* vc = [[STKStickersShopViewController alloc] initWithNibName: @"STKStickersShopViewController" bundle: [NSBundle mainBundle]];

	/**
	 *  For framework
	 */
	//    STKStickersShopViewController *vc = [[STKStickersShopViewController alloc] initWithNibName:@"STKStickersShopViewController" bundle:[self getResourceBundle]];

	vc.delegate = self;
	[self showStickersView];

	if ([self isStickerPackDownloaded: message]) {
		vc.packName = [self.stickersService packNameForStickerId: [STKUtility stickerIdWithMessage: message]];
		[self showModalViewController: vc];
	} else {
		typeof(self) __weak weakSelf = self;

		[self.stickersService getPackNameForMessage: message completion: ^ (NSString* packName) {
			vc.packName = packName;
			dispatch_async(dispatch_get_main_queue(), ^ {
				[weakSelf showModalViewController: vc];
			});
		}];
	}
}

- (void)showPackInfoControllerWithName: (NSString*)packName {
	STKStickersShopViewController* vc = [[STKStickersShopViewController alloc] initWithNibName: @"STKStickersShopViewController" bundle: [NSBundle mainBundle]];

	/**
	 *  For framework
	 */
	//    STKStickersShopViewController *vc = [[STKStickersShopViewController alloc] initWithNibName:@"STKStickersShopViewController" bundle:[self getResourceBundle]];

	vc.delegate = self;
	vc.packName = packName;
	[self showStickersView];
	[self showModalViewController: vc];
}

- (void)selectPack: (NSUInteger)index {
	[self setPackSelectedAtIndex: index];
	[self.stickersHeaderDelegateManager collectionView: self.stickersHeaderCollectionView didSelectItemAtIndexPath: [NSIndexPath indexPathForRow: index inSection: 0]];
}


#pragma mark - Checks

- (BOOL)isStickerPackDownloaded: (NSString*)packMessage {
	if ([STKStickersManager isOldFormatStickerMessage: packMessage]) {
		NSArray* packNames = [STKUtility trimmedPackNameAndStickerNameWithMessage: packMessage];
		return [self.stickersService isPackDownloaded: packNames.firstObject];
	} else {
		NSString* stickerId = [STKUtility stickerIdWithMessage: packMessage];
		return [self.stickersService isPackDownloaded: [self.stickersService packNameForStickerId: stickerId]];
	}
}


#pragma mark - Colors

- (void)setColorForStickersHeaderPlaceholderColor: (UIColor*)color {
	self.stickersHeaderDelegateManager.placeholderHeaderColor = color;
}

- (void)setColorForStickersPlaceholder: (UIColor*)color {
	self.stickersDelegateManager.placeholderColor = color;
}


#pragma mark - Property

- (BOOL)isStickerViewShowed {
	return self.internalStickersView.superview != nil;
}

- (UIView*)stickersView {
	return _internalStickersView;
}

- (void)setTextInputView: (UITextView*)textInputView {
	if(_textInputView)
	{
		[_textInputView removeObserver:self forKeyPath:@"showSmileButton"];
	}
	
	_textInputView = textInputView;
	[_textInputView addObserver:self forKeyPath:@"showSmileButton" options:NSKeyValueObservingOptionNew context:NULL];

	[self initKeyBoardButton];
	_keyboardButton.hidden = !_textInputView.showSmileButton;
}

- (void)setSuggestCollectionView: (UICollectionView*)suggestCollectionView {
	_suggestCollectionView = suggestCollectionView;

	self.suggestCollectionView.alpha = 0;
	self.suggestCollectionView.hidden = YES;

}


#pragma mark - Show/hide stickers

- (void)hideStickersView {

    self.keyboardButton.stickerButtonState = STKShowStickerButtonStateStickers;

	self.textInputView.inputView = nil;
	
	[self reloadStickersInputViews];
}

- (void)showKeyboard {
	[self.textInputView becomeFirstResponder];
}

- (void)reloadStickersInputViews {
	[self.textInputView reloadInputViews];
	if (!self.isKeyboardShowed) {
		[self.textInputView becomeFirstResponder];
	}
}


#pragma mark - keyboard notifications

- (void)didShowKeyboard: (NSNotification*)notification {
	if(self.textInputView.showSmileButton)
	{
		self.isKeyboardShowed = YES;
	}
}

- (void)willHideKeyboard: (NSNotification*)notification {
	self.isKeyboardShowed = NO;
	self.textInputView.inputView = nil;
	self.keyboardButton.stickerButtonState = STKShowStickerButtonStateStickers;
}

- (void)storageUpdated: (NSNotification*)notification {
	self.keyboardButton.badgeView.hidden = ![self.stickersService hasNewPacks];
	
	id <STKStickerControllerDelegate> o = self.delegate;
	if ([o respondsToSelector: @selector(didUpdateStickerCache)]) {
		[o didUpdateStickerCache];
	}
	
}


#pragma mark - user defaults

- (void)setUserDefaultsValue {
	NSUserDefaults* userDefaults = [NSUserDefaults standardUserDefaults];
	[userDefaults setObject: @"no" forKey: @"isNotification"];
	[userDefaults synchronize];
}


#pragma mark - statistics

- (void)textMessageSendStatistic {
	[[STKAnalyticService sharedService] sendEventWithCategory: STKAnalyticMessageCategory action: STKAnalyticActionTabs label: STKMessageTextLabel value: nil];
}

- (void)stickerMessageSendStatistic {
	[[STKAnalyticService sharedService] sendEventWithCategory: STKAnalyticMessageCategory action: STKAnalyticActionTabs label: STKMessageStickerLabel value: nil];
}


#pragma mark - resource bundle

- (NSBundle*)getResourceBundle {
	NSString* bundlePath = [[NSBundle mainBundle] pathForResource: @"ResBundle" ofType: @"bundle"];
	NSBundle* bundle = [NSBundle bundleWithPath: bundlePath];

	return bundle;
}


#pragma mark - text view notification

- (void)textFieldDidChange: (NSNotification*)notification {
	UITextView* tv = notification.object;

	if (self.showSuggests && self.textInputView == tv) {
		if (tv.text.length != 0) {
			STKSearchModel* model = [STKSearchModel new];

			model.q = [self lastWordFromText: tv.text];
			model.isSuggest = YES;

			if (model.q != nil || ![model.q isEqualToString: @""]) {
				[[STKWebserviceManager sharedInstance] searchStickersWithSearchModel: model completion: ^ (NSArray* stickers) {
					BOOL stickersReceived = stickers.count != 0;

					if (stickersReceived) {
						[self initSuggestCollectionViewWithStickersArray: stickers];

						[self.suggestCollectionView scrollToItemAtIndexPath: [NSIndexPath indexPathForItem: 0 inSection: 0]
														   atScrollPosition: UICollectionViewScrollPositionLeft
																   animated: NO];

						[self.suggestCollectionView reloadData];

						[self showSuggestCollectionView];
					} else {
						[self hideSuggestCollectionView];
					}

					self.isSuggestArrayNotEmpty = stickersReceived;
				}];
			}
		}
	}
}

- (void)observeValueForKeyPath: (NSString*)keyPath
					  ofObject: (id)object
						change: (NSDictionary*)change
					   context: (void*)context {
	if (object == [STKWebserviceManager sharedInstance]) {
		if ([change[NSKeyValueChangeNewKey] boolValue]) {
			self.errorView.hidden = YES;
			if (self.initialLoadingFinished) {
				[self loadStickerPacksWithCompletion: ^ {
					if (self.showStickersOnStart) {
						[self showStickersView];
					}
				}];
			}
		} else {
			[self handleError: [NSError errorWithDomain: NSCocoaErrorDomain code: NSURLErrorNotConnectedToInternet userInfo: nil]];
		}
	}
	else if([keyPath isEqualToString:@"showSmileButton"])
	{
		_keyboardButton.hidden = !_textInputView.showSmileButton;
	}
}


#pragma mark - suggest view

- (void)showSuggestCollectionView {
	self.suggestCollectionView.hidden = NO;

	[UIView animateWithDuration: 0.3 animations: ^ {
		self.suggestCollectionView.alpha = 1.0;
	}];
}

- (void)hideSuggestCollectionView {
	[UIView animateWithDuration: 0.3 animations: ^ {
		self.suggestCollectionView.alpha = 0.0;
	}                completion: ^ (BOOL finished) {
		self.suggestCollectionView.hidden = YES;
	}];
}

- (NSString*)lastWordFromText: (NSString*)text {
	__block NSString* lastWord = nil;

	[text enumerateSubstringsInRange: NSMakeRange(0, [text length]) options: NSStringEnumerationByWords | NSStringEnumerationReverse usingBlock: ^ (NSString* substring, NSRange subrange, NSRange enclosingRange, BOOL* stop) {
		lastWord = substring;
		*stop = YES;
	}];

	return lastWord;
}


#pragma mark - STKStickersShopViewControllerDelegate

- (void)showStickersCollection {
	[self.textInputView resignFirstResponder];
	UIViewController* presentViewController = [self.delegate stickerControllerViewControllerForPresentingModalView];
	[presentViewController dismissViewControllerAnimated: YES completion: nil];

	[self collectionsButtonAction: nil];

	id <STKStickerControllerDelegate> o = self.delegate;
	if ([o respondsToSelector: @selector(showStickersCollection)]) {
		[o showStickersCollection];
	}
}

- (void)packRemoved: (STKStickerPackObject*)packObject fromController: (STKStickersShopViewController*)shopController {
	NSMutableArray* stickerPacks = [self.stickersService.stickersArray mutableCopy];

	__block NSInteger packIndex = -1;

	[stickerPacks enumerateObjectsUsingBlock: ^ (STKStickerPackObject* pack, NSUInteger idx, BOOL* stop) {
		if (pack.packID == packObject.packID) {
			packIndex = idx;
		}
	}];

	if (packIndex >= 0) {
		[stickerPacks removeObjectAtIndex: (NSUInteger) packIndex];
		self.stickersService.stickersArray = stickerPacks;
		self.stickersHeaderDelegateManager.stickerPacksArray = stickerPacks;
		[self.stickersDelegateManager setStickerPacksArray: stickerPacks];
		[self.stickersCollectionView reloadData];
		[self.stickersHeaderCollectionView reloadData];
		[self reloadRecent];
	}

	id <STKStickerControllerDelegate> o = self.delegate;
	if ([o respondsToSelector: @selector(packRemoved:)]) {
		[o packRemoved: packObject];
	}
}

- (void)hideSuggestCollectionViewIfNeeded {
	if (self.isSuggestArrayNotEmpty) {
		[self hideSuggestCollectionView];
	}
}

- (void)showPackWithName: (NSString*)name fromController: (STKStickersShopViewController*)shopController {
	[self showStickersView];
	NSUInteger stickerIndex = [self.stickersService indexOfPackWithName: name];
	[self setPackSelectedAtIndex: stickerIndex];

	[self.stickersHeaderDelegateManager collectionView:self.stickersHeaderCollectionView didSelectItemAtIndexPath:[self selectedIndexHeaderForSavedValue:stickerIndex]];
//	if ([self.stickersHeaderCollectionView numberOfItemsInSection: 1] - 1 >= stickerIndex) {
//		NSIndexPath* indexPath = [NSIndexPath indexPathForItem: stickerIndex inSection: 0];
//		[(id <STKStickerHeaderCollectionViewDelegate>) self.stickersHeaderCollectionView.delegate scrollToIndexPath: indexPath animated: NO];
//	}

	id <STKStickerControllerDelegate> o = self.delegate;
	if ([o respondsToSelector: @selector(newPackShown)]) {
		[o newPackShown];
	}

}

- (void)packWithName: (NSString*)packName downloadedFromController: (STKStickersShopViewController*)shopController {
	[self.stickersService getStickerPacksWithType: nil completion: ^ (NSArray* stickerPacks) {
		dispatch_async(dispatch_get_main_queue(), ^ {
			self.stickersService.stickersArray = stickerPacks;
			self.keyboardButton.badgeView.hidden = ![self.stickersService hasNewPacks];
			self.stickersShopButton.badgeView.hidden = !self.stickersService.hasNewModifiedPacks;
			NSUInteger stickerIndex = [self.stickersService indexOfPackWithName: packName];
			
			self.stickersHeaderDelegateManager.stickerPacksArray = self.stickersService.stickersArray;
			[self.stickersDelegateManager setStickerPacksArray: self.stickersService.stickersArray];
			
			[self.stickersHeaderCollectionView reloadData];
			[self.stickersCollectionView reloadData];
			dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
				[self showStickersView];
				[self setPackSelectedAtIndex: stickerIndex];
				[self.stickersHeaderDelegateManager collectionView:self.stickersHeaderCollectionView didSelectItemAtIndexPath:[self selectedIndexHeaderForSavedValue:stickerIndex]];
			});
		});
	}                                     failure: nil];
	
	id <STKStickerControllerDelegate> o = self.delegate;
	if ([o respondsToSelector: @selector(newPackDownloaded)]) {
		[o newPackDownloaded];
	}
}

- (void)packPurchasedWithName: (NSString*)packName price: (NSString*)packPrice fromController: (STKStickersShopViewController*)shopController {
	id <STKStickerControllerDelegate> o = self.delegate;
	if ([o respondsToSelector: @selector(packPurchasedWithName:price:)]) {
		[o packPurchasedWithName: packName price: packPrice];
	}
}

- (void)dealloc {
	[[NSNotificationCenter defaultCenter] removeObserver: self];
	[_internalStickersView removeFromSuperview];

	@try {
		
		[_textInputView removeObserver:self forKeyPath:@"showSmileButton"];
	} @catch (NSException *exception) {
		
	}
	@try {
		
		[[STKWebserviceManager sharedInstance] removeObserver: self
												   forKeyPath: @"networkReachable"
													  context: nil];
	} @catch (NSException *exception) {
		
	}
}


@end
