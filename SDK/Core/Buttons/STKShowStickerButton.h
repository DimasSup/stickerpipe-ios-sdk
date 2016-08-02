//
// Created by Vadim Degterev on 12.08.15.
// Copyright (c) 2015 908 Inc. All rights reserved.
//

#import "STKBadgeView.h"


#define STK_TEXTBUTTON_KEYBOARD @"iconChatKeyboard"
#define STK_TEXTBUTTON_STICKERS @"iconChatSmileyBtn"

typedef NS_ENUM(ushort, STKShowStickerButtonState)
{
	STKShowStickerButtonStateStickers,
	STKShowStickerButtonStateKeyboard,
};

@interface STKShowStickerButton : UIButton
@property (nonatomic) STKBadgeView* badgeView;
@property (nonatomic) IBInspectable UIColor* badgeBorderColor;

@property (nonatomic) STKShowStickerButtonState stickerButtonState;
@end