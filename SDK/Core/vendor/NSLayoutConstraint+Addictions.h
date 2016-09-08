//
// Created by Vlad Hatko on 3/11/15.
// Copyright (c) 2015 Photofy. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

@interface NSLayoutConstraint (Addictions)

+ (NSArray<NSLayoutConstraint*>*)attachToSuperviewItsSubview: (UIView*)subview;
+ (void)attachToSuperviewCenterItsSubview: (UIView*)subview;

+ (NSLayoutConstraint*)attachToSuperviewVerticalCenterItsSubview: (UIView*)subview;
+ (NSLayoutConstraint*)attachToSuperviewHorizontalCenterItsSubview: (UIView*)subview;

+ (NSArray<NSLayoutConstraint*>*)setConstraintsWidth: (CGFloat)width andHeight: (CGFloat)height forView: (UIView*)view;

+ (NSLayoutConstraint*)setConstraintHeight: (CGFloat)height forView: (UIView*)view;
+ (NSLayoutConstraint*)setConstraintWidth: (CGFloat)width forView: (UIView*)view;

+ (NSArray*)attachToSuperviewBottomTopOfView: (UIView*)subview;
+ (NSArray*)attachToSuperviewLeftRightOfView: (UIView*)subview;

+(NSLayoutConstraint*)attachToSuperviewBottomOfView:(UIView*)subview;
+(NSLayoutConstraint*)attachToSuperviewTopOfView:(UIView*)subview;
+(NSLayoutConstraint*)attachToSuperviewLeftOfView:(UIView*)subview;
+(NSLayoutConstraint*)attachToSuperviewRightOfView:(UIView*)subview;

+ (void)attachView: (UIView*)firstView toView: (UIView*)secondView;

@end
