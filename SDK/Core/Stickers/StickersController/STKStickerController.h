//
//  STKStickerController.h
//  StickerPipe
//
//  Created by Vadim Degterev on 21.07.15.
//  Copyright (c) 2015 908 Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "STKStickersConstants.h"

#define STK_TEXTBUTTON_KEYBOARD @"iconChatKeyboard"
#define STK_TEXTBUTTON_STICKERS @"iconChatSmileyBtn"




@class STKStickerController;
@class STKShowStickerButton;

@protocol STKStickerControllerDelegate <NSObject>

@required

//View controller for presenting modal controllers
- (UIViewController*)stickerControllerViewControllerForPresentingModalView;

@optional

- (void)stickerController:(STKStickerController*)stickerController didSelectStickerWithMessage:(NSString*)message;

- (void)stickerControllerDidChangePackStatus:(STKStickerController*)stickerController;

- (void)stickerController:(STKStickerController*)stickerController
    willShareStickerWithMessage:(NSString *)message;

- (void)stickerController:(STKStickerController*)stickerController didSelectCustomSmile:(NSString*)smile;
- (void)stickerControllerDidRemoveSmile:(STKStickerController*)stickerController;

- (void)stickerControllerErrorHandle:(NSError *)error;

- (void)stickerControllerReloadView;

-(void)stickerController:(STKStickerController*)stickerController didSelectPack:(NSString*)packId;

@end

@interface STKStickerController : NSObject

@property (weak, nonatomic) id<STKStickerControllerDelegate> delegate;

@property (nonatomic, strong, readonly) UIView *stickersView;

@property (nonatomic, assign, readonly) BOOL isStickerViewShowed;

@property (nonatomic, strong) UIColor *headerBackgroundColor;

@property (nonatomic, weak) UITextView *textInputView;

@property (strong, nonatomic) STKShowStickerButton *keyboardButton;

@property (nonatomic) CGRect stickersViewFrame;

@property (nonatomic) BOOL showStickersOnStart;

@property (nonatomic) BOOL isNetworkReachable;
@property (nonatomic) BOOL showRecents;


//@property (nonatomic, strong) UIColor *stickersShopTintColor;

- (void)updateFrames;

- (void)reloadStickersView;

- (void)showStickersView;

- (void)hideStickersView;

- (BOOL)isStickerPackDownloaded:(NSString*)packMessage;

- (void)showPackInfoControllerWithStickerMessage:(NSString*)message;

- (void)showPackInfoControllerWithName:(NSString *)packName;

//Color settings. Default is light gray

- (void)setColorForStickersPlaceholder:(UIColor*) color;

- (void)setColorForStickersHeaderPlaceholderColor:(UIColor*) color;

- (void)textMessageSent:(NSString *)message;

- (void)handleError:(NSError *)error;

- (void)selectPack:(NSUInteger)index;

- (void)setupInternalStickersView;

- (void)showKeyboard;

@end