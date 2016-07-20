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
#import "STKStickerObject.h"
#import "STKUtility.h"
#import "STKStickersEntityService.h"
#import "STKEmptyRecentCell.h"
#import "STKStickersSettingsViewController.h"
#import "STKStickersShopViewController.h"

#import "STKStickerPackObject.h"
#import "STKOrientationNavigationController.h"
#import "STKShowStickerButton.h"
#import "STKAnalyticService.h"
#import "STKImageManager.h"
#import "STKStickersManager.h"

#import <AFNetworking/AFNetworking.h>


#import "UITextView+StickerButtonControl.h"

#import "SmilesHelper.h"
#import "StickerPipeCustomSmilesDelegateManager.h"

//SIZES

static const CGFloat kStickersSectionPaddingTopBottom = 12.0;
static const CGFloat kKeyboardButtonHeight = 33.0;

@interface STKStickerController() {
    BOOL isStartShow;
}

@property (weak, nonatomic) UIView *keyboardButtonSuperView;

@property (weak, nonatomic) IBOutlet UIView *internalStickersView;

@property (weak, nonatomic) IBOutlet UICollectionView *stickersHeaderCollectionView;

@property (weak, nonatomic) IBOutlet STKShowStickerButton *stickersShopButton;
@property (weak, nonatomic) IBOutlet UICollectionView *stickersCollectionView;
@property (weak, nonatomic) IBOutlet UICollectionView *customSmilesCollectionView;
@property (weak, nonatomic) IBOutlet UIView *customSmilesMainView;

@property (strong, nonatomic) STKStickerDelegateManager *stickersDelegateManager;
@property (strong, nonatomic) STKStickerHeaderDelegateManager *stickersHeaderDelegateManager;
@property (nonatomic,strong) StickerPipeCustomSmilesDelegateManager* customSmileDelegateManager;

@property (strong, nonatomic) UIButton *shopButton;
@property (assign, nonatomic) BOOL isKeyboardShowed;

@property (nonatomic, weak) IBOutlet UIView *errorView;
@property (nonatomic, weak) IBOutlet UILabel *errorLabel;

@property (strong, nonatomic) STKStickersEntityService *stickersService;

@property (strong, nonatomic) STKStickersShopViewController *shopViewController;
@property (strong, nonatomic) STKStickersSettingsViewController *settingsViewController;

- (IBAction)collectionsButtonAction:(id)sender;
- (IBAction)stickersShopButtonAction:(id)sender;
- (IBAction)closeError:(id)sender;

@end

@implementation STKStickerController

#pragma mark - prepare spacks
-(NSMutableArray*)prepareStickerPacks:(NSArray*)source
{
	if(self.showRecents)
	{
		return [NSMutableArray arrayWithArray:source];
	}
	else
	{
		NSMutableArray* packs = [NSMutableArray arrayWithCapacity:source.count];
		for (STKStickerPackObject* stpack in source)
		{
			if(stpack.packID)
			{
				[packs addObject:stpack];
			}
		}
		return packs;
	}
}

#pragma mark - Inits

- (void)loadStickerPacks {
    
    [self.stickersService getStickerPacksWithType:nil completion:^(NSArray *stickerPacks) {
        dispatch_async(dispatch_get_main_queue(), ^{
            
            self.stickersService.stickersArray = [self prepareStickerPacks: stickerPacks];
            self.keyboardButton.badgeView.hidden = ![self.stickersService hasNewPacks];
            self.stickersShopButton.badgeView.hidden = !self.stickersService.hasNewModifiedPacks;
            if (self.showStickersOnStart) {
                [self showStickersView];
            }
        });
        
    } failure:nil];
}

- (void)loadStartPacks {
    [self.stickersService getStickerPacksWithType:nil completion:^(NSArray *stickerPacks) {
        
        self.stickersService.stickersArray = [self prepareStickerPacks: stickerPacks];
        self.keyboardButton.badgeView.hidden = ![self.stickersService hasNewPacks];
        self.stickersShopButton.badgeView.hidden = !self.stickersService.hasNewModifiedPacks;
        
        if (!isStartShow && self.isStickerViewShowed) {
            [self showStickersView];
        } else {
            [self.stickersCollectionView reloadData];
        }
    } failure:nil];
}

- (instancetype)init {
    
    self = [super init];
    if (self) {
		self.showRecents = YES;
        self.stickersService = [STKStickersEntityService new];
        self.stickersDelegateManager = [STKStickerDelegateManager new];
        self.stickersHeaderDelegateManager = [STKStickerHeaderDelegateManager new];
        
        
        [self setupInternalStickersView];
        
        [[AFNetworkReachabilityManager sharedManager] startMonitoring];
        [self checkNetwork];
        
        //        [self loadStickerPacks];
        [self loadStartPacks];
        
        [self initStickerHeader];
        [self initStickersCollectionView];
        [self initHeaderButton:self.stickersShopButton];
        
        [self reloadStickers];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(willHideKeyboard:)
                                                     name:UIKeyboardWillHideNotification
                                                   object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(didShowKeyboard:)
                                                     name:UIKeyboardWillShowNotification
                                                   object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(storageUpdated:) name:STKStickersCacheDidUpdateStickersNotification object:nil];
        
        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(updateStickers:) name:STKStickersReorderStickersNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showCollections) name:STKShowStickersCollectionsNotification object:nil];
        
        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(showPack:) name:STKShowPackNotification object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(newPackDownloaded:) name:STKNewPackDownloadedNotification object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(removePack:) name:STKPackRemovedNotification object:nil];
        
        [self reloadRecentAtStart];
        
        [self.stickersHeaderCollectionView reloadData];
        [self.stickersCollectionView reloadData];
        
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        [userDefaults setObject:@"currentVC" forKey:@"viewController"];
        [userDefaults synchronize];
       
        
    }
    return self;
}

- (void)checkNetwork {
    
    __weak typeof(self) wself = self;
    
    [[AFNetworkReachabilityManager sharedManager]setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status){
        if ((status == AFNetworkReachabilityStatusReachableViaWWAN ||
             status ==  AFNetworkReachabilityStatusReachableViaWiFi)) {
            wself.isNetworkReachable = YES;
            wself.errorView.hidden = YES;
            [wself loadStickerPacks];
        } else {
            wself.isNetworkReachable = NO;
            [wself handleError: [NSError errorWithDomain:NSCocoaErrorDomain code:NSURLErrorNotConnectedToInternet userInfo:nil]];
        }
    }];
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
    
	STKStickerPackObject *recentPack = [self.stickersService recentPack];
	NSMutableArray *stickers = [self.stickersService.stickersArray mutableCopy];
	if(self.showRecents)
	{
		[stickers replaceObjectAtIndex:0 withObject:recentPack];
	}
	
	stickers = [self prepareStickerPacks:stickers];
	
	self.stickersService.stickersArray = stickers;
    [self.stickersDelegateManager setStickerPacksArray: stickers];
    [self.stickersCollectionView reloadSections:[NSIndexSet indexSetWithIndex:0]];
}

- (void)reloadRecentAtStart {
	return;
    STKStickerPackObject *recentPack = [self.stickersService recentPack];
    NSMutableArray *stickers = [@[recentPack] mutableCopy];
	
    self.stickersService.stickersArray = stickers;
    [self.stickersDelegateManager setStickerPacksArray: stickers];
    [self.stickersCollectionView reloadSections:[NSIndexSet indexSetWithIndex:0]];
}

- (void)updateStickers:(NSNotification *)notification {
    
    NSMutableArray *stickers = notification.userInfo[@"packs"];
	if(self.stickersService.stickersArray.count)
	{
		[stickers insertObject:self.stickersService.stickersArray[0] atIndex:0];
	}
	stickers = [self prepareStickerPacks:stickers];
    self.stickersService.stickersArray = stickers;
    [self.stickersHeaderDelegateManager setStickerPacks:stickers];
    [self.stickersDelegateManager setStickerPacksArray:stickers];
    [self.stickersCollectionView reloadData];
    [self.stickersHeaderCollectionView reloadData];
    [self reloadRecent];
}

- (void)removePack:(NSNotification *)notification {
    
    NSMutableArray *stickerPacks = [self.stickersService.stickersArray mutableCopy];
    
    STKStickerPackObject *packToDelete = notification.userInfo[@"pack"];
    BOOL hasPack = NO;
    NSInteger packIndex = 0;
    for (int i = 0; i < stickerPacks.count; i++) {
        STKStickerPackObject *pack = stickerPacks[i];
        if (pack.packID == packToDelete.packID) {
            hasPack = YES;
            packIndex = i;
        }
    }
    if (hasPack) {
        [stickerPacks removeObjectAtIndex:packIndex];
		stickerPacks = [self prepareStickerPacks:stickerPacks];
        self.stickersService.stickersArray = stickerPacks;
        [self.stickersHeaderDelegateManager setStickerPacks:stickerPacks];
        [self.stickersDelegateManager setStickerPacksArray:stickerPacks];
        [self.stickersCollectionView reloadData];
        [self.stickersHeaderCollectionView reloadData];
        [self reloadRecent];
    }
}

- (void)dealloc {
	if(_textInputView)
	{
		[_textInputView removeObserver:self forKeyPath:@"showSmileButton"];
	}
	[_internalStickersView removeFromSuperview];
	
	[[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)newPackDownloaded:(NSNotification *)notification {
    
    [self.stickersService getStickerPacksWithType:nil completion:^(NSArray *packs) {
        dispatch_async(dispatch_get_main_queue(), ^{
			NSArray* stickerPacks = [self prepareStickerPacks:packs];
			
            self.stickersService.stickersArray = stickerPacks;
            self.keyboardButton.badgeView.hidden = ![self.stickersService hasNewPacks];
            self.stickersShopButton.badgeView.hidden = !self.stickersService.hasNewModifiedPacks;
            NSString *packName = notification.userInfo[@"packName"];
            NSUInteger stickerIndex = [self.stickersService indexOfPackWithName:packName];
            
            [self.stickersHeaderDelegateManager setStickerPacks:self.stickersService.stickersArray];
            [self.stickersDelegateManager setStickerPacksArray:self.stickersService.stickersArray];
            
            [self.stickersHeaderCollectionView reloadData];
            [self.stickersCollectionView reloadData];
            
            [self setPackSelectedAtIndex:stickerIndex];
			
            [self.stickersHeaderDelegateManager collectionView:self.stickersHeaderCollectionView didSelectItemAtIndexPath:[self selectedIndexHeaderForSavedValue:stickerIndex]];
        });
    } failure:nil];
}

- (void)initStickersCollectionView {
    
    //    self.stickersDelegateManager = [STKStickerDelegateManager new];
    
    __weak typeof(self) weakSelf = self;
    [self.stickersDelegateManager setDidChangeDisplayedSection:^(NSInteger displayedSection) {
        [weakSelf setPackSelectedAtIndex:displayedSection];
    }];
    
    [self.stickersDelegateManager setDidSelectSticker:^(STKStickerObject *sticker) {
        [weakSelf.stickersService incrementStickerUsedCountWithID:sticker.stickerID];
        [[STKAnalyticService sharedService] sendEventWithCategory:STKAnalyticMessageCategory action:STKAnalyticActionSend label:STKMessageStickerLabel value:nil];
        if ([weakSelf.delegate respondsToSelector:@selector(stickerController:didSelectStickerWithMessage:)]) {
            [weakSelf.delegate stickerController:weakSelf didSelectStickerWithMessage:sticker.stickerMessage];
        }
    }];
    
    self.stickersCollectionView.dataSource = self.stickersDelegateManager;
    self.stickersCollectionView.delegate = self.stickersDelegateManager;
    self.stickersDelegateManager.collectionView = self.stickersCollectionView;
    [self.stickersCollectionView registerClass:[STKStickerViewCell class] forCellWithReuseIdentifier:@"STKStickerViewCell"];
    [self.stickersCollectionView registerClass:[STKEmptyRecentCell class] forCellWithReuseIdentifier:@"STKEmptyRecentCell"];
    [self.stickersCollectionView registerClass:[UICollectionReusableView class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"UICollectionReusableView"];
    [self.stickersCollectionView registerClass:[STKStickersSeparator class] forSupplementaryViewOfKind:UICollectionElementKindSectionFooter withReuseIdentifier:@"STKStickerPanelSeparator"];
    
    self.stickersDelegateManager.collectionView = self.stickersCollectionView;
}

- (void)initHeaderButton:(UIButton *)button {
    [button setTintColor:[STKUtility defaultBlueColor]];
    button.backgroundColor = self.headerBackgroundColor ? self.headerBackgroundColor : [STKUtility defaultGreyColor];
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

- (void) initStickerHeader {
    //    self.stickersHeaderDelegateManager = [STKStickerHeaderDelegateManager new];
    __weak typeof(self) weakSelf = self;
    [self.stickersHeaderDelegateManager setDidSelectRow:^(NSIndexPath *indexPath, STKStickerPackObject *stickerPack, BOOL animated) {
        if (stickerPack.isNew.boolValue) {
            stickerPack.isNew = @NO;
            [weakSelf.stickersService updateStickerPackInCache:stickerPack];
            [weakSelf reloadHeaderItemAtIndexPath:indexPath];
        }
		
		[weakSelf setLastSelectedStickerPack:indexPath.row];
        
		
		if( [weakSelf.delegate respondsToSelector:@selector(stickerController:didSelectPack:)])
		{
			[weakSelf.delegate stickerController:weakSelf didSelectPack:stickerPack.packName];
		}
		
        NSInteger numberOfItems = [weakSelf.stickersCollectionView numberOfItemsInSection:indexPath.item];
        
        if (numberOfItems != 0) {
            NSIndexPath *newIndexPath = [NSIndexPath indexPathForItem:0 inSection:indexPath.item];
            CGRect layoutRect = [weakSelf.stickersCollectionView layoutAttributesForItemAtIndexPath:newIndexPath].frame;
            if (stickerPack.stickers.count > 0 || indexPath.item == 0) {
                [weakSelf.stickersCollectionView setContentOffset:CGPointMake(weakSelf.stickersCollectionView.contentOffset.x, layoutRect.origin.y  - kStickersSectionPaddingTopBottom) animated:animated];
                weakSelf.stickersDelegateManager.currentDisplayedSection = indexPath.item;
            }
        }
        
		[weakSelf hideCustomSmiles];
		
	}];
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
    
    self.stickersHeaderCollectionView.dataSource = self.stickersHeaderDelegateManager;
    self.stickersHeaderCollectionView.delegate = self.stickersHeaderDelegateManager;
    
    [self.stickersHeaderCollectionView registerClass:[STKStickerHeaderCell class] forCellWithReuseIdentifier:@"STKStickerPanelHeaderCell"];
    
    self.stickersHeaderCollectionView.backgroundColor = self.headerBackgroundColor ? self.headerBackgroundColor : [STKUtility defaultGreyColor];
    
    self.stickersShopButton.badgeView.hidden = !self.stickersService.hasNewModifiedPacks;
}

- (void)setupInternalStickersView {
    
    self.stickersShopButton.badgeBorderColor = [STKUtility defaultGreyColor];
	
	self.internalStickersView = [[[NSBundle mainBundle] loadNibNamed:@"STKStickersViewCustom" owner:self options:nil] firstObject];

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
    
    [self initStickerHeader];
    [self initStickersCollectionView];
    [self initHeaderButton:self.stickersShopButton];
	
	[self reloadSmiles];
	[self hideCustomSmiles];
}

- (void)addKeyboardButtonConstraintsToView:(UIView *)view {
    
    self.keyboardButton.translatesAutoresizingMaskIntoConstraints = NO;
    
    NSLayoutConstraint *width = [NSLayoutConstraint constraintWithItem:self.keyboardButton
                                                             attribute:NSLayoutAttributeWidth
                                                             relatedBy:NSLayoutRelationEqual
                                                                toItem:nil
                                                             attribute:NSLayoutAttributeNotAnAttribute
                                                            multiplier:1
                                                              constant:kKeyboardButtonHeight];
    NSLayoutConstraint *height = [NSLayoutConstraint constraintWithItem:self.keyboardButton
                                                              attribute:NSLayoutAttributeHeight
                                                              relatedBy:NSLayoutRelationEqual
                                                                 toItem:nil
                                                              attribute:NSLayoutAttributeNotAnAttribute
                                                             multiplier:1
                                                               constant:kKeyboardButtonHeight];
    
    NSLayoutConstraint *right = [NSLayoutConstraint constraintWithItem:self.keyboardButton
                                                             attribute:NSLayoutAttributeLeft
                                                             relatedBy:NSLayoutRelationEqual
                                                                toItem:view
                                                             attribute:NSLayoutAttributeLeft
                                                            multiplier:1
                                                              constant:0];
    
    NSLayoutConstraint *top = [NSLayoutConstraint constraintWithItem:self.keyboardButton
                                                           attribute:NSLayoutAttributeTop
                                                           relatedBy:NSLayoutRelationEqual
                                                              toItem:view
                                                           attribute:NSLayoutAttributeTop
                                                          multiplier:1
                                                            constant:0];
    
    [view addConstraints:@[width, height, right,top
                           ]];
}

- (void)initKeyBoardButton {
    
    self.keyboardButton = [STKShowStickerButton buttonWithType:UIButtonTypeSystem];
    
    UIImage *buttonImage = [UIImage imageNamed:STK_TEXTBUTTON_STICKERS];
    [self.keyboardButton setImage:buttonImage forState:UIControlStateNormal];
	[self.keyboardButton.imageView setContentMode:UIViewContentModeScaleAspectFit];
    [self.keyboardButton addTarget:self action:@selector(keyboardButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    self.keyboardButton.tintColor = [UIColor grayColor];
    self.keyboardButton.badgeView.hidden = ![self.stickersService hasNewPacks];
	self.keyboardButton.frame = CGRectMake(self.textInputView.frame.origin.x, self.textInputView.frame.origin.y, 33, 33);
	
	
    [self.textInputView.superview addSubview:self.keyboardButton];

}

- (void)updateFrames {

}


- (void)textResizeForButton {
    CGRect viewFrame = self.keyboardButtonSuperView.frame;
    viewFrame.size.height = CGFLOAT_MAX;
    UIBezierPath *exclusivePath = [UIBezierPath bezierPathWithRect:viewFrame];
    self.textInputView.textContainer.exclusionPaths = @[exclusivePath];
}

- (void)showModalViewController:(UIViewController *)viewController {
    
    //    [self hideStickersView];
    
    STKOrientationNavigationController *navigationController = [[STKOrientationNavigationController alloc] initWithRootViewController:viewController];
    
    UIViewController *presenter = [self.delegate stickerControllerViewControllerForPresentingModalView];
    
    NSUserDefaults *defaults=[NSUserDefaults standardUserDefaults];
    NSString *vc = [defaults objectForKey:@"viewController"];
    NSString *isNotification = [defaults objectForKey:@"isNotification"];
    [defaults synchronize];
    
    if ([isNotification isEqualToString:@"yes"]) {
        if ([vc isEqualToString:@"shop"]) {
            [_shopViewController presentViewController:navigationController animated:YES completion:nil];
            [self setUserDefaultsValue];
            
        } else if ([vc isEqualToString:@"settings"]) {
            [_settingsViewController presentViewController:navigationController animated:YES completion:nil];
            [self setUserDefaultsValue];
            
        } else {
            [presenter presentViewController:navigationController animated:YES completion:nil];
            [self setUserDefaultsValue];
        }
    } else {
        [presenter presentViewController:navigationController animated:YES completion:nil];
    }
}

- (void)handleError:(NSError *)error {
    
    self.errorView.hidden = NO;
    self.errorLabel.text = (error.code == NSURLErrorNotConnectedToInternet) ? NSLocalizedString(@"No internet connection", nil) : NSLocalizedString(@"Oops... something went wrong", nil);
    if ([self.delegate respondsToSelector:@selector(stickerControllerErrorHandle:)]) {
        if (self.isNetworkReachable) {
            [self.delegate stickerControllerErrorHandle:error];
        } else {
            NSError *noInternetError = [NSError errorWithDomain:NSCocoaErrorDomain code:NSURLErrorNotConnectedToInternet userInfo:nil];
            [self.delegate stickerControllerErrorHandle:noInternetError];
        }
    }
}

#pragma mark - Actions

- (void)collectionsButtonAction:(UIButton*)collectionsButton {
    
    _settingsViewController = [[STKStickersSettingsViewController alloc] initWithNibName:@"STKStickersSettingsViewController" bundle:[NSBundle mainBundle]];
    _settingsViewController.stickerController = self;
    [self showModalViewController:_settingsViewController];
}

- (void)stickersShopButtonAction:(id)sender {
    
    _shopViewController = [[STKStickersShopViewController alloc] initWithNibName:@"STKStickersShopViewController" bundle:[NSBundle mainBundle]];
    _shopViewController.stickerController = self;
    self.stickersService.hasNewModifiedPacks = NO;
    [self showModalViewController:_shopViewController];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:STKOpenShopNotification object:self];
}

- (void)keyboardButtonAction:(UIButton *)keyboardButton {
    if (self.textInputView.inputView) {
        [self hideStickersView];
        
    } else {
        [self showStickersView];
    }
}

- (void)closeError:(id)sender {
    if (self.isNetworkReachable) {
        self.errorView.hidden = YES;
        [self loadStickerPacks];
    } else {
        self.errorView.hidden = NO;
    }
}

#pragma mark - Reload

- (void)reloadStickersView {
    
    [self reloadStickers];
}

- (void)reloadHeaderItemAtIndexPath:(NSIndexPath*)indexPath {
    
    NSArray *stickerPacks = self.stickersService.stickersArray;
    [self.stickersHeaderDelegateManager setStickerPacks:stickerPacks];
    [self.stickersHeaderCollectionView reloadItemsAtIndexPaths:@[indexPath]];
    [self.stickersHeaderCollectionView selectItemAtIndexPath:indexPath animated:NO scrollPosition:UICollectionViewScrollPositionNone];
}

- (void)reloadStickersHeader {
    
    NSArray *stickerPacks = self.stickersService.stickersArray;
    [self.stickersHeaderDelegateManager setStickerPacks:stickerPacks];
    [self.stickersHeaderCollectionView reloadItemsAtIndexPaths:@[[NSIndexPath indexPathForItem:1 inSection:1]]];
    NSIndexPath *selectedIndexPath = [NSIndexPath indexPathForItem:self.stickersDelegateManager.currentDisplayedSection inSection:1];
    [self.stickersHeaderCollectionView selectItemAtIndexPath:selectedIndexPath animated:NO scrollPosition:UICollectionViewScrollPositionNone];
}

- (void)reloadStickers { //17
    [self setupInternalStickersView];
    
    NSArray *stickerPacks = self.stickersService.stickersArray;
    [self.stickersDelegateManager setStickerPacksArray:stickerPacks];
    [self.stickersHeaderDelegateManager setStickerPacks:stickerPacks];
    [self.stickersCollectionView reloadData];
    [self.stickersHeaderCollectionView reloadData];
    self.stickersCollectionView.contentOffset = CGPointZero;
    self.stickersDelegateManager.currentDisplayedSection = 0;
	int value = [self getLastSelectedStickerPack];
	[self setPackSelectedAtIndex:value>0?0:value];
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
#pragma mark - Selection

- (void)setPackSelectedAtIndex:(NSInteger)index {
	if(index>0)
	{
		
		if ([self.stickersHeaderCollectionView numberOfItemsInSection:1] - 1 >= index) {
			NSIndexPath *indexPath = [self selectedIndexHeaderForSavedValue:index];
			
			STKStickerPackObject *stickerPack = [self.stickersHeaderDelegateManager itemAtIndexPath:indexPath];
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

- (void)showPackInfoControllerWithStickerMessage:(NSString*)message {
    
    [self hideStickersView];
    STKStickersShopViewController *vc = [[STKStickersShopViewController alloc] initWithNibName:@"STKStickersShopViewController" bundle:[NSBundle mainBundle]];
    
    if ([self isStickerPackDownloaded:message]) {
        vc.packName = [self.stickersService packNameForStickerId:[STKUtility stickerIdWithMessage:message]];
        [self showModalViewController:vc];
        
    } else {
        __weak typeof(self) weakSelf = self;
        
        [self.stickersService getPackNameForMessage:message
                                         completion:^(NSString *packName) {
                                             vc.packName = packName;
                                             dispatch_async(dispatch_get_main_queue(), ^{
                                                 [weakSelf showModalViewController:vc];
                                             });
                                         }];
    }
}

- (void)showPackInfoControllerWithName:(NSString *)packName {
    STKStickersShopViewController *vc = [[STKStickersShopViewController alloc] initWithNibName:@"STKStickersShopViewController" bundle:[NSBundle mainBundle]];
    vc.stickerController = self;
    vc.packName = packName;
    [vc.stickerController showStickersView];
    [self showModalViewController:vc];
}

- (void)showCollections {
    [self hideStickersView];
    [self collectionsButtonAction:nil];
}

- (void)showPack:(NSNotification *)notification {
    NSString *packName = notification.userInfo[@"packName"];
    NSUInteger stickerIndex = [self.stickersService indexOfPackWithName:packName];
    [self showStickersView];
    [self setPackSelectedAtIndex:stickerIndex];
}

- (void)selectPack:(NSUInteger)index {
    [self setPackSelectedAtIndex:index];
    [self.stickersHeaderDelegateManager collectionView:self.stickersHeaderCollectionView didSelectItemAtIndexPath:[self selectedIndexHeaderForSavedValue:index]];
}

#pragma mark - Checks

-(BOOL)isStickerPackDownloaded:(NSString *)packMessage {
    NSString *packName = [NSString new];
    if ([STKStickersManager isOldFormatStickerMessage:packMessage]) {
        NSArray *packNames = [STKUtility trimmedPackNameAndStickerNameWithMessage:packMessage];
        packName = packNames.firstObject;
    } else {
        NSString *stickerId = [STKUtility stickerIdWithMessage:packMessage];
        packName = [self.stickersService packNameForStickerId:stickerId];
    }
    return [self.stickersService isPackDownloaded:packName];
}

#pragma mark - Colors

-(void)setColorForStickersHeaderPlaceholderColor:(UIColor *)color {
    self.stickersHeaderDelegateManager.placeholderHeadercolor = color;
}

-(void)setColorForStickersPlaceholder:(UIColor *)color {
    self.stickersDelegateManager.placeholderColor = color;
}

#pragma mark - Property

- (BOOL)isStickerViewShowed {
    
    BOOL isShowed = self.internalStickersView.superview != nil;
    
    isStartShow = YES;
    
    return isShowed;
}

- (UIView *)stickersView {
    
    [self reloadStickers];
    
    return _internalStickersView;
}

- (void)setTextInputView:(UITextView *)textInputView {
	if(_textInputView)
	{
		[_textInputView removeObserver:self forKeyPath:@"showSmileButton"];
	}
	
    _textInputView = textInputView;
	[_textInputView addObserver:self forKeyPath:@"showSmileButton" options:NSKeyValueObservingOptionNew context:NULL];
	[self initKeyBoardButton];
	_keyboardButton.hidden = !_textInputView.showSmileButton;
}

#pragma mark - 
-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context
{
	if([keyPath isEqualToString:@"showSmileButton"])
	{
		_keyboardButton.hidden = !_textInputView.showSmileButton;
	}
}
#pragma mark - Show/hide stickers

- (void)showStickersView {
    UIImage *buttonImage = [UIImage imageNamed:STK_TEXTBUTTON_KEYBOARD];
    
    [self.keyboardButton setImage:buttonImage forState:UIControlStateNormal];
    [self.keyboardButton setImage:buttonImage forState:UIControlStateHighlighted];
    
    self.textInputView.inputView = self.stickersView;
    [self reloadStickersInputViews];
}

- (void)showKeyboard {
    
    [self.textInputView becomeFirstResponder];

}

- (void)hideStickersView {
    
    UIImage *buttonImage = [UIImage imageNamed:STK_TEXTBUTTON_STICKERS];
    
    [self.keyboardButton setImage:buttonImage forState:UIControlStateNormal];
    [self.keyboardButton setImage:buttonImage forState:UIControlStateHighlighted];
    
    self.textInputView.inputView = nil;
    
    [self reloadStickersInputViews];
}

- (void)reloadStickersInputViews {
    [self.textInputView reloadInputViews];
    if (!self.isKeyboardShowed) {
        [self.textInputView becomeFirstResponder];
    }
}

#pragma mark - keyboard notifications

- (void) didShowKeyboard:(NSNotification*)notification {
	if(self.textInputView.showSmileButton)
	{
		self.isKeyboardShowed = YES;
	}
}

- (void)willHideKeyboard:(NSNotification*)notification {
    self.isKeyboardShowed = NO;
	
	UIImage *buttonImage = [UIImage imageNamed:STK_TEXTBUTTON_STICKERS];
	
	[self.keyboardButton setImage:buttonImage forState:UIControlStateNormal];
	[self.keyboardButton setImage:buttonImage forState:UIControlStateHighlighted];
	
	self.textInputView.inputView = nil;
	
	
	
}

- (void)storageUpdated:(NSNotification*)notification {
    self.keyboardButton.badgeView.hidden = ![self.stickersService hasNewPacks];
}

#pragma mark - user defaults
- (void)setUserDefaultsValue {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setObject:@"no" forKey:@"isNotification"];
    [userDefaults synchronize];
}

#pragma mark -------

- (void)textMessageSent:(NSString *)message {
    [[STKAnalyticService sharedService] sendEventWithCategory:STKAnalyticMessageCategory action:STKAnalyticActionSend label:STKMessageTextLabel value:nil];
    
}

@end
