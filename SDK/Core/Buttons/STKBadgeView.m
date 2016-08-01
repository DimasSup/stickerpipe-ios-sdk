//
//  STKBadgeVIew.m
//  StickerPipe
//
//  Created by Vadim Degterev on 13.08.15.
//  Copyright (c) 2015 908 Inc. All rights reserved.
//

#import "STKBadgeView.h"

@interface STKBadgeView ()

@property (nonatomic) CGSize dotSize;
@property (nonatomic) CGFloat lineWidth;
@property (nonatomic) UIColor* borderColor;

@end


@implementation STKBadgeView

- (instancetype)initWithFrame: (CGRect)frame lineWidth: (CGFloat)lineWidth dotSize: (CGSize)dotSize andBorderColor: (UIColor*)borderColor {
	if (self = [super initWithFrame: frame]) {
		self.backgroundColor = [UIColor clearColor];
		self.userInteractionEnabled = NO;
		self.lineWidth = lineWidth;
		self.dotSize = dotSize;
		self.borderColor = borderColor;
	}

	return self;
}

- (instancetype)initWithFrame: (CGRect)frame {
	if (self = [super initWithFrame: frame]) {
		[[NSException exceptionWithName: @"Init exception" reason: @"Use initWithFrame:lineWidth:" userInfo: nil] raise];
	}
	return self;
}

- (void)drawRect: (CGRect)rect {
	// Drawing code
	CGFloat lineWidth = self.lineWidth;
	CGRect rectInsets = CGRectInset(rect, lineWidth, lineWidth);
	UIBezierPath* path = [UIBezierPath bezierPathWithRoundedRect: rectInsets cornerRadius: CGRectGetHeight(rectInsets) / 2.0f];
	[[UIColor redColor] setFill];
	[path fill];
	path.lineWidth = lineWidth;
	[self.borderColor setStroke];
	[path stroke];

	CGFloat whiteDotWight = self.dotSize.width;
	CGFloat whiteDotHeight = self.dotSize.height;
	CGFloat whiteDotY = CGRectGetMidY(rectInsets) - (whiteDotHeight / 2.0f);
	CGFloat whiteDotX = CGRectGetMidX(rectInsets) - (whiteDotWight / 2.0f);

	UIBezierPath* whiteDot = [UIBezierPath bezierPathWithRoundedRect: CGRectMake(whiteDotX, whiteDotY, whiteDotWight, whiteDotHeight) cornerRadius: whiteDotHeight / 2.0];
	[[UIColor whiteColor] setFill];
	[whiteDot fill];
	[path appendPath: whiteDot];
}


@end
