//
// Created by Vlad Hatko on 4/9/15.
// Copyright (c) 2015 Photofy. All rights reserved.
//

#import "UIView+LayoutAdditions.h"
#import "NSLayoutConstraint+Addictions.h"

@implementation UIView (LayoutAdditions)

+ (instancetype)layoutInst
{
	UIView* view = [self new];

	view.translatesAutoresizingMaskIntoConstraints = NO;

	return view;
}

- (void)attachViewsHorizontally: (NSArray<UIView*>*)subviews
{
	NSMutableString* format = [@"H:|" mutableCopy];
	NSMutableDictionary<NSString*, UIView*>* views = [NSMutableDictionary dictionaryWithCapacity: subviews.count * 2 + 1];

	[subviews enumerateObjectsUsingBlock: ^ (UIView* view, NSUInteger idx, BOOL* stop){
		view.translatesAutoresizingMaskIntoConstraints = NO;

		NSString* keyView = [NSString stringWithFormat: @"v%@", @(idx)];
		NSString* keySpacer = [NSString stringWithFormat: @"s%@", @(idx)];

		views[keyView] = view;
		views[keySpacer] = [UIView layoutInst];

		[self addSubview: views[keySpacer]];
		[self addSubview: view];

		if (idx == 0)
		{
			[format appendString: [NSString stringWithFormat: @"[%@]", keyView]];
		}
		else
		{
			[format appendString: [NSString stringWithFormat: @"[%@(s0)][%@(v0)]", keySpacer, keyView]];
		}

		if(idx == subviews.count - 1)
		{
			[format appendString: @"|"];
		}
	}];

	[NSLayoutConstraint attachToSuperviewBottomTopOfView: subviews.firstObject]; //attach one of the buttons to superview to use it in NSLayoutFormatOptions

	[self addConstraints: [NSLayoutConstraint constraintsWithVisualFormat: format
																  options: NSLayoutFormatAlignAllBottom | NSLayoutFormatAlignAllTop
																  metrics: nil
																	views: views]];
}


@end
