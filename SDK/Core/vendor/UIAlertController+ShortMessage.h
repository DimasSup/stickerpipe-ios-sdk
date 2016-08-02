//
// Created by Vlad Hatko on 11/6/15.
// Copyright (c) 2015 Photofy. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

@interface UIAlertController (ShortMessage)

+ (UIAlertController*)showShortMessage: (NSString*)message fromController: (UIViewController*)controller;

+ (UIAlertController*)showAlertWithTitle: (NSString*)title
							shortMessage: (NSString*)message
						  fromController: (UIViewController*)controller;

+ (UIAlertController*)showAlertWithTitle: (NSString*)title
							shortMessage: (NSString*)message
								 actions: (NSArray<UIAlertAction*>*)actions
						  fromController: (UIViewController*)controller;

+ (UIAlertController*)showAlertWithMessage: (NSString*)message
								   actions: (NSArray<UIAlertAction*>*)actions
							fromController: (UIViewController*)controller;

- (void)show;

@end
