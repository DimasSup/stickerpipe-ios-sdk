//
// Created by Vlad Hatko on 11/6/15.
// Copyright (c) 2015 Photofy. All rights reserved.
//

#import <objc/runtime.h>
#import "UIAlertController+ShortMessage.h"

@interface UIAlertController ()
@property (nonatomic, strong) UIWindow* alertWindow;
@end

@implementation UIAlertController (ShortMessage)

- (void)setAlertWindow: (UIWindow*)alertWindow
{
	objc_setAssociatedObject(self, @selector(alertWindow), alertWindow, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (UIWindow*)alertWindow
{
	return objc_getAssociatedObject(self, @selector(alertWindow));
}

+ (UIAlertController*)showShortMessage: (NSString*)message fromController: (UIViewController*)controller
{
	return [self showAlertWithTitle: nil shortMessage: message fromController: controller];
}

+ (UIAlertController*)showAlertWithTitle: (NSString*)title shortMessage: (NSString*)message fromController: (UIViewController*)controller
{
	return [self showAlertWithTitle: title shortMessage: message actions: @[[UIAlertAction actionWithTitle: @"Ok" style: UIAlertActionStyleDefault handler: nil]] fromController: controller];
}

+ (UIAlertController*)showAlertWithTitle: (NSString*)title shortMessage: (NSString*)message actions: (NSArray<UIAlertAction*>*)actions fromController: (UIViewController*)controller
{
	UIAlertController* alert = [UIAlertController alertControllerWithTitle: title
													message: message
											 preferredStyle: UIAlertControllerStyleAlert];

	for (UIAlertAction* action in actions)
	{
		[alert addAction: action];
	}

	if (controller)
	{
		[controller presentViewController: alert animated: YES completion: nil];
	}
	else
	{
		[alert show];
	}

	return alert;
}

+ (UIAlertController*)showAlertWithMessage: (NSString*)message actions: (NSArray<UIAlertAction*>*)actions fromController: (UIViewController*)controller
{
	return [self showAlertWithTitle: @"" shortMessage: message actions: actions fromController: controller];
}

- (void)show
{
	self.alertWindow = [[UIWindow alloc] initWithFrame: [UIScreen mainScreen].bounds];
	self.alertWindow.rootViewController = [UIViewController new];
	self.alertWindow.windowLevel = UIWindowLevelAlert + 1;
	[self.alertWindow makeKeyAndVisible];
	[self.alertWindow.rootViewController presentViewController: self animated: YES completion: nil];
}

@end
