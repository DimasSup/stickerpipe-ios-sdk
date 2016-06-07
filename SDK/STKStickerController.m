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

#import "UIImage+CustomBundle.h"


//SIZES

static const CGFloat kStickersSectionPaddingTopBottom = 12.0;

@interface STKStickerController()

@property (strong, nonatomic) UIView *keyboardButtonSuperView;

@property (weak, nonatomic) IBOutlet UIView *internalStickersView;

@property (weak, nonatomic) IBOutlet UICollectionView *stickersHeaderCollectionView;

@property (weak, nonatomic) IBOutlet STKShowStickerButton *stickersShopButton;
@property (weak, nonatomic) IBOutlet UICollectionView *stickersCollectionView;

@property (strong, nonatomic) STKStickerDelegateManager *stickersDelegateManager;
@property (strong, nonatomic) STKStickerHeaderDelegateManager *stickersHeaderDelegateManager;
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

#pragma mark - Inits

- (void)loadStickerPacks {
    
    [self.stickersService getStickerPacksWithType:nil completion:^(NSArray *stickerPacks) {
        dispatch_async(dispatch_get_main_queue(), ^{
            
            self.stickersService.stickersArray = stickerPacks;
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
        
        self.stickersService.stickersArray = stickerPacks;
        self.keyboardButton.badgeView.hidden = ![self.stickersService hasNewPacks];
        self.stickersShopButton.badgeView.hidden = !self.stickersService.hasNewModifiedPacks;
        if (self.isStickerViewShowed) {
            [self showStickersView];
        }
    } failure:nil];
}


- (instancetype)init {
    
    self = [super init];
    if (self) {
        
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
        
        [self.stickersHeaderCollectionView reloadData];
        [self.stickersCollectionView reloadData];
        
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

- (void)reloadRecent {
    
    STKStickerPackObject *recentPack = [self.stickersService recentPack];
    NSMutableArray *stickers = [self.stickersService.stickersArray mutableCopy];
    [stickers replaceObjectAtIndex:0 withObject:recentPack];
    self.stickersService.stickersArray = stickers;
    [self.stickersDelegateManager setStickerPacksArray: stickers];
    [self.stickersCollectionView reloadSections:[NSIndexSet indexSetWithIndex:0]];
}

- (void)updateStickers:(NSNotification *)notification {
    
    NSMutableArray *stickers = notification.userInfo[@"packs"];
    [stickers insertObject:self.stickersService.stickersArray[0] atIndex:0];
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
        self.stickersService.stickersArray = stickerPacks;
        [self.stickersHeaderDelegateManager setStickerPacks:stickerPacks];
        [self.stickersDelegateManager setStickerPacksArray:stickerPacks];
        [self.stickersCollectionView reloadData];
        [self.stickersHeaderCollectionView reloadData];
        [self reloadRecent];
    }
    
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)newPackDownloaded:(NSNotification *)notification {
    
    [self.stickersService getStickerPacksWithType:nil completion:^(NSArray *stickerPacks) {
        dispatch_async(dispatch_get_main_queue(), ^{
            
            
            self.stickersService.stickersArray = stickerPacks;
            self.keyboardButton.badgeView.hidden = ![self.stickersService hasNewPacks];
            self.stickersShopButton.badgeView.hidden = !self.stickersService.hasNewModifiedPacks;
            NSString *packName = notification.userInfo[@"packName"];
            NSUInteger stickerIndex = [self.stickersService indexOfPackWithName:packName];
            
            [self.stickersHeaderDelegateManager setStickerPacks:self.stickersService.stickersArray];
            [self.stickersDelegateManager setStickerPacksArray:self.stickersService.stickersArray];
            
            [self.stickersHeaderCollectionView reloadData];
            [self.stickersCollectionView reloadData];
            
            [self showStickersView];
            [self setPackSelectedAtIndex:stickerIndex];
            [self.stickersHeaderDelegateManager collectionView:self.stickersHeaderCollectionView didSelectItemAtIndexPath:[NSIndexPath indexPathForRow:stickerIndex inSection:0]];
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
    UIRefreshControl *refreshControl = [[UIRefreshControl alloc] init];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [refreshControl addTarget:self action:@selector(handleRefresh:) forControlEvents:UIControlEventValueChanged];
        [self.stickersCollectionView addSubview:refreshControl];
        self.stickersCollectionView.alwaysBounceVertical = YES;
    });
}

- (void)initHeaderButton:(UIButton *)button {
    [button setTintColor:[STKUtility defaultBlueColor]];
    button.backgroundColor = self.headerBackgroundColor ? self.headerBackgroundColor : [STKUtility defaultGreyColor];
}


- (void) initStickerHeader {
    //    self.stickersHeaderDelegateManager = [STKStickerHeaderDelegateManager new];
    __weak typeof(self) weakSelf = self;
    [self.stickersHeaderDelegateManager setDidSelectRow:^(NSIndexPath *indexPath, STKStickerPackObject *stickerPack) {
        if (stickerPack.isNew.boolValue) {
            stickerPack.isNew = @NO;
            [weakSelf.stickersService updateStickerPackInCache:stickerPack];
            [weakSelf reloadHeaderItemAtIndexPath:indexPath];
        }
        NSIndexPath *newIndexPath = [NSIndexPath indexPathForItem:0 inSection:indexPath.item];
        CGRect layoutRect = [weakSelf.stickersCollectionView layoutAttributesForItemAtIndexPath:newIndexPath].frame;
        if (stickerPack.stickers.count > 0 || indexPath.item == 0) {
            [weakSelf.stickersCollectionView setContentOffset:CGPointMake(weakSelf.stickersCollectionView.contentOffset.x, layoutRect.origin.y  - kStickersSectionPaddingTopBottom) animated:YES];
            weakSelf.stickersDelegateManager.currentDisplayedSection = indexPath.item;
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
    
    self.internalStickersView = [[[self getResourceBundle] loadNibNamed:@"STKStickersView" owner:self options:nil] firstObject];
    
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
}

- (void)addKeyboardButtonConstraintsToView:(UIView *)view {
    
    self.keyboardButton.translatesAutoresizingMaskIntoConstraints = NO;
    
    NSLayoutConstraint *width = [NSLayoutConstraint constraintWithItem:self.keyboardButton
                                                             attribute:NSLayoutAttributeWidth
                                                             relatedBy:NSLayoutRelationEqual
                                                                toItem:nil
                                                             attribute:NSLayoutAttributeNotAnAttribute
                                                            multiplier:1
                                                              constant:33];
    NSLayoutConstraint *height = [NSLayoutConstraint constraintWithItem:self.keyboardButton
                                                              attribute:NSLayoutAttributeHeight
                                                              relatedBy:NSLayoutRelationEqual
                                                                 toItem:nil
                                                              attribute:NSLayoutAttributeNotAnAttribute
                                                             multiplier:1
                                                               constant:33];
    
    NSLayoutConstraint *right = [NSLayoutConstraint constraintWithItem:self.keyboardButton
                                                             attribute:NSLayoutAttributeRight
                                                             relatedBy:NSLayoutRelationEqual
                                                                toItem:view
                                                             attribute:NSLayoutAttributeRight
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
    
    UIImage *buttonImage = [UIImage imageNamedInCustomBundle:@"STKShowStickersIcon"];
    [self.keyboardButton setImage:buttonImage forState:UIControlStateNormal];
    [self.keyboardButton addTarget:self action:@selector(keyboardButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    self.keyboardButton.tintColor = [UIColor grayColor];
    self.keyboardButton.badgeView.hidden = ![self.stickersService hasNewPacks];
    
    CGRect frame = CGRectMake(0, 0, self.textInputView.contentSize.width, 33);
    UIView *view = [[UIView alloc]initWithFrame:frame];
    [view addSubview:self.keyboardButton];
    [self.textInputView addSubview:view];
    [self addKeyboardButtonConstraintsToView:view];
    self.keyboardButtonSuperView = view;
}

- (void)updateFrames {
    CGRect frame = CGRectMake(0, 0, self.textInputView.frame.size.width, 33);
    self.keyboardButtonSuperView.frame = frame;
    [self.keyboardButton layoutIfNeeded];
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


- (void)handleRefresh:(UIRefreshControl *)refresh {
    if (self.isNetworkReachable) {
        [self loadStickerPacks];
        self.errorView.hidden = YES;
    }
    [refresh endRefreshing];
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
    
    _settingsViewController = [[STKStickersSettingsViewController alloc] initWithNibName:@"STKStickersSettingsViewController" bundle:[self getResourceBundle]];
    [self showModalViewController:_settingsViewController];
}

- (void)stickersShopButtonAction:(id)sender {
    
    _shopViewController = [[STKStickersShopViewController alloc] initWithNibName:@"STKStickersShopViewController" bundle:[self getResourceBundle]];
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
    [self.stickersHeaderCollectionView reloadItemsAtIndexPaths:@[[NSIndexPath indexPathForItem:1 inSection:0]]];
    NSIndexPath *selectedIndexPath = [NSIndexPath indexPathForItem:self.stickersDelegateManager.currentDisplayedSection inSection:0];
    [self.stickersHeaderCollectionView selectItemAtIndexPath:selectedIndexPath animated:NO scrollPosition:UICollectionViewScrollPositionNone];
}

- (void)reloadStickers {
    [self setupInternalStickersView];
    
    NSArray *stickerPacks = self.stickersService.stickersArray;
    [self.stickersDelegateManager setStickerPacksArray:stickerPacks];
    [self.stickersHeaderDelegateManager setStickerPacks:stickerPacks];
    [self.stickersCollectionView reloadData];
    [self.stickersHeaderCollectionView reloadData];
    self.stickersCollectionView.contentOffset = CGPointZero;
    self.stickersDelegateManager.currentDisplayedSection = 0;
    
    [self setPackSelectedAtIndex:0];
}

#pragma mark - Selection

- (void)setPackSelectedAtIndex:(NSInteger)index {
    
    if ([self.stickersHeaderCollectionView numberOfItemsInSection:0] - 1 >= index) {
        NSIndexPath *indexPath = [NSIndexPath indexPathForItem:index inSection:0];
        
        STKStickerPackObject *stickerPack = [self.stickersHeaderDelegateManager itemAtIndexPath:indexPath];
        if (stickerPack.isNew.boolValue) {
            stickerPack.isNew = @NO;
            [self.stickersService updateStickerPackInCache:stickerPack];
            [self reloadHeaderItemAtIndexPath:[NSIndexPath indexPathForItem:index inSection:0]];
        }
        [self.stickersHeaderCollectionView selectItemAtIndexPath:indexPath animated:YES scrollPosition:UICollectionViewScrollPositionCenteredHorizontally];
    }
}

#pragma mark - Presenting

- (void)showPackInfoControllerWithStickerMessage:(NSString*)message {
    
    [self hideStickersView];
    STKStickersShopViewController *vc = [[STKStickersShopViewController alloc] initWithNibName:@"STKStickersShopViewController" bundle:[self getResourceBundle]];
    
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
    STKStickersShopViewController *vc = [[STKStickersShopViewController alloc] initWithNibName:@"STKStickersShopViewController" bundle:[self getResourceBundle]];
    vc.packName = packName;
    [self showModalViewController:vc];
}

- (void)showCollections {
    [self hideStickersView];
    UIViewController *presentViewController = [self.delegate stickerControllerViewControllerForPresentingModalView];
    [presentViewController dismissViewControllerAnimated:YES completion:nil];
    
    [self collectionsButtonAction:nil];
}

- (void)showPack:(NSNotification *)notification {
    NSString *packName = notification.userInfo[@"packName"];
    NSUInteger stickerIndex = [self.stickersService indexOfPackWithName:packName];
    //[self showStickersView];
    [self setPackSelectedAtIndex:stickerIndex];
}

- (void)selectPack:(NSUInteger)index {
    [self setPackSelectedAtIndex:index];
    [self.stickersHeaderDelegateManager collectionView:self.stickersHeaderCollectionView didSelectItemAtIndexPath:[NSIndexPath indexPathForRow:index inSection:0]];
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
    
    return isShowed;
}

-(UIView *)stickersView {
    
    [self reloadStickers];
    
    return _internalStickersView;
}

- (void)setTextInputView:(UITextView *)textInputView {
    _textInputView = textInputView;
    [self initKeyBoardButton];
}

#pragma mark - Show/hide stickers

- (void)showStickersView {
    UIImage *buttonImage = [UIImage imageNamedInCustomBundle:@"STKShowKeyboadIcon"];
    
    [self.keyboardButton setImage:buttonImage forState:UIControlStateNormal];
    [self.keyboardButton setImage:buttonImage forState:UIControlStateHighlighted];
    
    self.textInputView.inputView = self.stickersView;
    [self reloadStickersInputViews];
}

- (void)hideStickersView {
    
    UIImage *buttonImage = [UIImage imageNamedInCustomBundle:@"STKShowStickersIcon"];
    
    [self.keyboardButton setImage:buttonImage forState:UIControlStateNormal];
    [self.keyboardButton setImage:buttonImage forState:UIControlStateHighlighted];
    
    self.textInputView.inputView = nil;
    
    [self reloadStickersInputViews];
}


- (void) reloadStickersInputViews {
    [self.textInputView reloadInputViews];
    if (!self.isKeyboardShowed) {
        [self.textInputView becomeFirstResponder];
    }
}

#pragma mark - keyboard notifications

- (void) didShowKeyboard:(NSNotification*)notification {
    self.isKeyboardShowed = YES;
}

- (void)willHideKeyboard:(NSNotification*)notification {
    self.isKeyboardShowed = NO;
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

- (NSBundle *)getResourceBundle {
    NSString *bundlePath = [[NSBundle mainBundle] pathForResource:@"ResBundle" ofType:@"bundle"];
    NSBundle *bundle = [NSBundle bundleWithPath:bundlePath];
    
    return bundle;
}

@end
