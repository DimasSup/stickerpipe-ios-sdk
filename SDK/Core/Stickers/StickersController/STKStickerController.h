//
//  STKStickerController.h
//  StickerPipe
//
//  Created by Vadim Degterev on 21.07.15.
//  Copyright (c) 2015 908 Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "STKStickersConstants.h"

@class STKStickerController, STKShowStickerButton, STKStickerPackObject, STKImageManager;

@protocol STKStickerControllerDelegate <NSObject>
/**
 View controller for presenting modal controllers
*/
- (UIViewController*)stickerControllerViewControllerForPresentingModalView;

@optional

/**
 Sticker selected; you can use @message to get image from @imageManager property
*/
- (void)  stickerController: (STKStickerController*)stickerController
didSelectStickerWithMessage: (NSString*)message;


/**
 Sticker packs info in local store updated
*/
- (void)didUpdateStickerCache;


/**
 Respond to StickerController error in your code
*/
- (void)stickerControllerErrorHandle: (NSError*)error;


/**
 Pack removed from settings
*/
- (void)packRemoved: (STKStickerPackObject*)packObject;

/**
 Sticker packs reordered from settings
*/
- (void)stickersReordered;


/**
 Stickers view presented; called after moving from other controllers - settings / shop
*/
- (void)showStickersCollection;

/**
 Called, when new pack was downloaded and shown
*/
- (void)newPackShown;

/**
 Called, when new pack was downloaded from store
*/
- (void)newPackDownloaded;

/**
 Called, when user purchases new pack
*/
- (void)packPurchasedWithName: (NSString*)packName
						price: (NSString*)packPrice;

/**
 Called, when shop controller presented
*/
- (void)shopOpened;
@end


/***
 *
 *
 *
 */


@interface STKStickerController : NSObject
@property (nonatomic, weak) id <STKStickerControllerDelegate> delegate;

/**
 Pass error here to process it by StickerController and act properly;
 calls stickerControllerErrorHandle: method, if implemented
*/
- (void)handleError: (NSError*)error;


/**
 Use this object to get image for sticker message, received from delegate method
*/
@property (nonatomic) STKImageManager* imageManager;

/**
 Check if sticker pack already downloaded for current user
*/
- (BOOL)isStickerPackDownloaded: (NSString*)packMessage;


/**
 Set this textView to your message input
*/
@property (nonatomic) UITextView* textInputView;


/**
 Container for all Stickers views
*/
@property (nonatomic, readonly) UIView* stickersView;

/**
 Button for changing keyboard / stickers presentation
*/
@property (nonatomic) STKShowStickerButton* keyboardButton;

/**
 CollectionView with stickers
*/
@property (nonatomic, weak) IBOutlet UICollectionView* stickersCollectionView;

/**
 If true, stickers will be shown right after they will be loaded; default is NO
*/
@property (nonatomic) BOOL showStickersOnStart;

/**
 Reload sticker view with stored stickers
*/
- (void)reloadStickersView;

/**
 Stickers / keyboard presenting
*/
- (void)showStickersView;
- (void)hideStickersView;
- (void)showKeyboard;
- (BOOL)isStickerViewShowed;

/**
 Select pack with index
*/
- (void)selectPack: (NSUInteger)index;


/**
 Show sticker pack info
*/
- (void)showPackInfoControllerWithStickerMessage: (NSString*)message;
- (void)showPackInfoControllerWithName: (NSString*)packName;


/**
 Send statistic
*/
- (void)textMessageSendStatistic;
- (void)stickerMessageSendStatistic;


/**
 Background color for header, containing packs
*/
@property (nonatomic) UIColor* headerBackgroundColor;

/**
 Methods for customization placeholders
*/
- (void)setColorForStickersPlaceholder: (UIColor*)color;
- (void)setColorForStickersHeaderPlaceholderColor: (UIColor*)color;


/**
 Collection view to present suggested stickers
*/
@property (nonatomic) UICollectionView* suggestCollectionView;

/**
 Check, if there are suggests to present
*/
@property (nonatomic) BOOL isSuggestArrayNotEmpty;

/**
 Indicates if suggests should be presented; default is NO
*/
@property (nonatomic) BOOL showSuggests;

- (void)showSuggestCollectionView;
- (void)hideSuggestCollectionView;
@end
