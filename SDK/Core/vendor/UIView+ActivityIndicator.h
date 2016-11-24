//
// Created by vlad on 11/23/16.
// Copyright (c) 2016 908 Inc. All rights reserved.
//

@class MBProgressHUD;

@interface UIView (ActivityIndicator)
- (MBProgressHUD*)showActivityIndicator;
- (void)hideActivityIndicator;
@end