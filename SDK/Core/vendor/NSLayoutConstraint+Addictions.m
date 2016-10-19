//
// Created by Vlad Hatko on 3/11/15.
// Copyright (c) 2015 Photofy. All rights reserved.
//

#import "NSLayoutConstraint+Addictions.h"

@implementation NSLayoutConstraint (Addictions)

+ (NSArray<NSLayoutConstraint*>*)attachToSuperviewItsSubview: (UIView*)subview
{
	NSArray* hConstraints = [self attachToSuperviewLeftRightOfView: subview];
	NSArray* vConstraints = [self attachToSuperviewBottomTopOfView: subview];

	return [hConstraints arrayByAddingObjectsFromArray: vConstraints];
}

+ (void)attachToSuperviewCenterItsSubview: (UIView*)subview
{
	[self attachToSuperviewHorizontalCenterItsSubview: subview];
	[self attachToSuperviewVerticalCenterItsSubview: subview];
}

+ (NSLayoutConstraint*)attachToSuperviewVerticalCenterItsSubview: (UIView*)subview
{
	NSLayoutConstraint *constraint = [NSLayoutConstraint constraintWithItem: subview
																  attribute: NSLayoutAttributeCenterY
																  relatedBy: NSLayoutRelationEqual
																	 toItem: subview.superview
																  attribute: NSLayoutAttributeCenterY
																 multiplier: 1
																   constant: 0];

	[subview.superview addConstraint: constraint];

	return constraint;
}

+ (NSLayoutConstraint*)attachToSuperviewHorizontalCenterItsSubview: (UIView*)subview
{
	NSLayoutConstraint *constraint = [NSLayoutConstraint constraintWithItem: subview
																  attribute: NSLayoutAttributeCenterX
																  relatedBy: NSLayoutRelationEqual
																	 toItem: subview.superview
																  attribute: NSLayoutAttributeCenterX
																 multiplier: 1
																   constant: 0];

	[subview.superview addConstraint: constraint];

	return constraint;
}

+ (NSArray<NSLayoutConstraint*>*)setConstraintsWidth: (CGFloat)width andHeight: (CGFloat)height forView: (UIView*)view
{
	return @[[self setConstraintWidth: width forView: view],
			[self setConstraintHeight: height forView: view]];
}

+ (NSLayoutConstraint*)setConstraintHeight: (CGFloat)height forView: (UIView*)view
{
	NSLayoutConstraint* constraint = [NSLayoutConstraint constraintWithItem: view
																  attribute: NSLayoutAttributeHeight
																  relatedBy: NSLayoutRelationEqual
																	 toItem: nil
																  attribute: (NSLayoutAttribute) 0
																 multiplier: 1
																   constant: height];

	[view addConstraint: constraint];

	return constraint;
}

+ (NSLayoutConstraint*)setConstraintWidth: (CGFloat)width forView: (UIView*)view
{
	NSLayoutConstraint* constraint = [NSLayoutConstraint constraintWithItem: view
																  attribute: NSLayoutAttributeWidth
																  relatedBy: NSLayoutRelationEqual
																	 toItem: nil
																  attribute: (NSLayoutAttribute) 0
																 multiplier: 1
																   constant: width];

	[view addConstraint: constraint];

	return constraint;
}

+ (NSArray*)attachToSuperviewBottomTopOfView: (UIView*)subview
{
	NSArray* constraints = [NSLayoutConstraint constraintsWithVisualFormat: @"V:|[Subview]|"
																   options: (NSLayoutFormatOptions) 0
																   metrics: nil
																	 views: @{@"Subview" : subview}];

	[subview.superview addConstraints: constraints];

	return constraints;
}

+ (NSArray*)attachToSuperviewLeftRightOfView: (UIView*)subview
{
	NSArray* constraints = [NSLayoutConstraint constraintsWithVisualFormat: @"H:|[Subview]|"
																   options: (NSLayoutFormatOptions) 0
																   metrics: nil
																	 views: @{@"Subview" : subview}];

	[subview.superview addConstraints: constraints];

	return constraints;
}

+ (NSLayoutConstraint*)attachToSuperviewBottomOfView: (UIView*)subview
{
	NSArray* constraints = [NSLayoutConstraint constraintsWithVisualFormat: @"V:[Subview]|"
																   options: (NSLayoutFormatOptions) 0
																   metrics: nil
																	 views: @{@"Subview" : subview}];

	[subview.superview addConstraints: constraints];

	return constraints.firstObject;
}

+ (NSLayoutConstraint*)attachToSuperviewTopOfView: (UIView*)subview
{
	NSLayoutConstraint *constraint = [NSLayoutConstraint constraintWithItem: subview
																  attribute: NSLayoutAttributeTop
																  relatedBy: NSLayoutRelationEqual
																	 toItem: subview.superview
																  attribute: NSLayoutAttributeTop
																 multiplier: 1
																   constant: 0];

	[subview.superview addConstraint: constraint];

	return constraint;
}

+ (NSLayoutConstraint*)attachToSuperviewLeftOfView: (UIView*)subview
{
	NSLayoutConstraint *constraint = [NSLayoutConstraint constraintWithItem: subview
																  attribute: NSLayoutAttributeLeft
																  relatedBy: NSLayoutRelationEqual
																	 toItem: subview.superview
																  attribute: NSLayoutAttributeLeft
																 multiplier: 1
																   constant: 0];

	[subview.superview addConstraint: constraint];

	return constraint;
}

+ (NSLayoutConstraint*)attachToSuperviewRightOfView: (UIView*)subview
{
	NSLayoutConstraint* constraint = [NSLayoutConstraint constraintsWithVisualFormat: @"H:[Subview]|"
																			 options: (NSLayoutFormatOptions) 0
																			 metrics: nil
																			   views: @{@"Subview" : subview}][0];

	[subview.superview addConstraint: constraint];

	return constraint;
}

+ (void)attachView: (UIView*)firstView toView: (UIView*)secondView
{
	[firstView.superview addConstraint: [NSLayoutConstraint constraintWithItem: firstView
																	 attribute: NSLayoutAttributeCenterX
																	 relatedBy: NSLayoutRelationEqual
																		toItem: secondView
																	 attribute: NSLayoutAttributeCenterX
																	multiplier: 1
																	  constant: 0]];

	[firstView.superview addConstraint: [NSLayoutConstraint constraintWithItem: firstView
																	 attribute: NSLayoutAttributeCenterY
																	 relatedBy: NSLayoutRelationEqual
																		toItem: secondView
																	 attribute: NSLayoutAttributeCenterY
																	multiplier: 1
																	  constant: 0]];

	[firstView.superview addConstraint: [NSLayoutConstraint constraintWithItem: firstView
																	 attribute: NSLayoutAttributeWidth
																	 relatedBy: NSLayoutRelationEqual
																		toItem: secondView
																	 attribute: NSLayoutAttributeWidth
																	multiplier: 1
																	  constant: 0]];

	[firstView.superview addConstraint: [NSLayoutConstraint constraintWithItem: firstView
																	 attribute: NSLayoutAttributeHeight
																	 relatedBy: NSLayoutRelationEqual
																		toItem: secondView
																	 attribute: NSLayoutAttributeHeight
																	multiplier: 1
																	  constant: 0]];
}

@end
