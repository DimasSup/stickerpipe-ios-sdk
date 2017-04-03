//
//  UITextView+StickerButtonControl.m
//  Little Pal
//
//  Created by admin on 15.06.16.
//  Copyright © 2016 BrillKids. All rights reserved.
//

#import "UITextView+StickerButtonControl.h"

#import <objc/runtime.h>

static char* SMILE_BUTTON_KEY = "SMILE_BUTTON";
static char* STICKER_BUTTON_KEY = "STICKER_BUTTON";


@implementation UITextView (StickerButtonControl)
-(void)setShowSmileButton:(BOOL)showSmileButton
{
	objc_setAssociatedObject(self, SMILE_BUTTON_KEY, [NSNumber numberWithBool:showSmileButton], OBJC_ASSOCIATION_RETAIN);
}
-(BOOL)showSmileButton
{
	return [objc_getAssociatedObject(self, SMILE_BUTTON_KEY) boolValue];
}

-(void)setHideStickerButton:(BOOL)showSmileButton
{
	objc_setAssociatedObject(self, STICKER_BUTTON_KEY, [NSNumber numberWithBool:showSmileButton], OBJC_ASSOCIATION_RETAIN);
}
-(BOOL)hideStickerButton
{
	return [objc_getAssociatedObject(self, STICKER_BUTTON_KEY) boolValue];
}
@end
