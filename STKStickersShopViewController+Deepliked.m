//
//  STKStickersShopViewController+Deepliked.m
//  Little Pal
//
//  Created by admin on 04.11.16.
//  Copyright © 2016 BrillKids. All rights reserved.
//

#import "STKStickersShopViewController+Deepliked.h"
#import "DeeplinkedViewController.h"

@implementation STKStickersShopViewController (Deepliked)
-(void)setDeeplinkParameters:(DeeplinkedViewControllerParameters *)deeplinkParameters
{
	if(deeplinkParameters.navigationParameters[@"stickerpack"])
	{
		NSArray* arr = deeplinkParameters.navigationParameters[@"stickerpack"];
		NSString* val = [arr lastObject];
		if(val)
		{
			self.packName = val;
		}
		
	}
	[super setDeeplinkParameters:deeplinkParameters];
}
@end
