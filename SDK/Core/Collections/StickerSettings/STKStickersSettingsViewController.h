//
//  STKStickersSettingsViewController.h
//  StickerPipe
//
//  Created by Vadim Degterev on 05.08.15.
//  Copyright (c) 2015 908 Inc. All rights reserved.
//


@class STKStickersSettingsViewController;
@protocol STKStickersShopViewControllerDelegate;

@protocol STKStickersSettingsViewControllerDelegate<NSObject>
- (void)showStickersView;
- (void)stickersReorder: (STKStickersSettingsViewController*)stickersController packs:(NSArray* )packs;
@end

@interface STKStickersSettingsViewController : UIViewController
@property (nonatomic, weak) id <STKStickersSettingsViewControllerDelegate, STKStickersShopViewControllerDelegate> delegate;
@end
