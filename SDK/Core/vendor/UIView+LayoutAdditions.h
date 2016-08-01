//
// Created by Vlad Hatko on 4/9/15.
// Copyright (c) 2015 Photofy. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

@interface UIView (LayoutAdditions)
+ (instancetype)layoutInst;

- (void)attachViewsHorizontally: (NSArray<UIView*>*)subviews;
@end
