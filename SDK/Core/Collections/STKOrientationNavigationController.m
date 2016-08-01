//
//  STKOrientationNavigationController.m
//  StickerPipe
//
//  Created by Vadim Degterev on 19.08.15.
//  Copyright (c) 2015 908 Inc. All rights reserved.
//

#import "STKOrientationNavigationController.h"

@implementation STKOrientationNavigationController

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
	return [self.topViewController supportedInterfaceOrientations];
}

@end
