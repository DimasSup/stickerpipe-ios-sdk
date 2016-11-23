//
// Created by vlad on 11/23/16.
// Copyright (c) 2016 908 Inc. All rights reserved.
//

#import "UIView+ActivityIndicator.h"
#import "MBProgressHUD.h"

@implementation UIView (ActivityIndicator)

- (MBProgressHUD*)showActivityIndicator {
	return [MBProgressHUD showHUDAddedTo: self animated: YES];
}

- (void)hideActivityIndicator {
	[MBProgressHUD hideHUDForView: self animated: YES];
}

@end