//
//  STKStickerController.h
//  StickerPipe
//
//  Created by Vadim Degterev on 21.07.15.
//  Copyright (c) 2015 908 Inc. All rights reserved.
//

#import "STKStickersConstants.h"





@class STKStickerController;
@class STKShowStickerButton;
@class STKStickerController, STKShowStickerButton, STKStickerPackObject, STKImageManager;

@protocol STKStickerControllerDelegate <NSObject>

@required

//View controller for presenting modal controllers
- (UIViewController*)stickerControllerViewControllerForPresentingModalView;

@optional

- (void)stickerController: (STKStickerController*)stickerController didSelectStickerWithMessage: (NSString*)message;

- (void)didUpdateStickerCache;
-(void)stickerController:(STKStickerController *)stickerController didSelectPack:(NSString *)packId;
- (void)stickerController:(STKStickerController*)stickerController didSelectCustomSmile:(NSString*)smile;
- (void)stickerControllerDidRemoveSmile:(STKStickerController*)stickerController;

- (void)stickerControllerErrorHandle: (NSError*)error;

- (void)packRemoved: (STKStickerPackObject*)packObject;

- (void)stickersReordered;

- (void)showStickersCollection;

- (void)newPackShown;

- (void)newPackDownloaded;

- (void)packPurchasedWithName: (NSString*)packName price: (NSString*)packPrice;

- (void)shopOpened;
@end

@interface STKStickerController : NSObject
@property (nonatomic, weak) id <STKStickerControllerDelegate> delegate;

@property (nonatomic, readonly) UIView* stickersView;

@property (nonatomic, readonly) BOOL isStickerViewShowed;

@property (nonatomic) UIColor* headerBackgroundColor;

@property (nonatomic, weak) UITextView* textInputView;

@property (nonatomic,weak) STKShowStickerButton* keyboardButton;

@property (nonatomic) CGRect stickersViewFrame;

@property (nonatomic) BOOL showStickersOnStart;

@property (nonatomic) BOOL isNetworkReachable;
@property (nonatomic) BOOL showRecents;

@property (nonatomic, weak) IBOutlet UICollectionView* stickersCollectionView;

@property (nonatomic) STKImageManager* imageManager;

@property (nonatomic) UICollectionView* suggestCollectionView;
@property (nonatomic) BOOL isSuggestArrayNotEmpty;

- (void)reloadStickersView;

- (void)showStickersView;

- (void)hideStickersView;

- (BOOL)isStickerPackDownloaded: (NSString*)packMessage;

- (void)showPackInfoControllerWithStickerMessage: (NSString*)message;

- (void)showPackInfoControllerWithName: (NSString*)packName;

//Color settings. Default is light gray

- (void)setColorForStickersPlaceholder: (UIColor*)color;

- (void)setColorForStickersHeaderPlaceholderColor: (UIColor*)color;

- (void)textMessageSendStatistic;
- (void)stickerMessageSendStatistic;

- (void)handleError: (NSError*)error;

- (void)selectPack: (NSUInteger)index;

- (void)setupInternalStickersView;

- (void)showKeyboard;

- (void)showSuggestCollectionView;
- (void)hideSuggestCollectionView;

@end
