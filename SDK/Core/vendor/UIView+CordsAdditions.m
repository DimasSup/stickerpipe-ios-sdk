//
// Created by Vlad Hatko on 2/10/15.
// Copyright (c) 2015 Photofy. All rights reserved.
//

#import "UIView+CordsAdditions.h"

@implementation UIView (CordsAdditions)

- (CGFloat)top
{
	return self.frame.origin.y;
}

- (void)setTop: (CGFloat)top
{
	self.frame = CGRectMake(self.left, top, self.width, self.height);
}

- (CGFloat)left
{
	return self.frame.origin.x;
}

- (void)setLeft: (CGFloat)left
{
	self.frame = CGRectMake(left, self.top, self.width, self.height);
}

- (CGFloat)right
{
	return CGRectGetMaxX(self.frame);
}

- (void)setRight: (CGFloat)right
{
	CGFloat difference = self.right - right;

	self.left -= difference;
}

- (CGFloat)width
{
	return self.frame.size.width;
}

- (void)setWidth: (CGFloat)width
{
	self.frame = CGRectMake(self.left, self.top, width, self.height);
}

- (CGFloat)height
{
	return self.frame.size.height;
}

- (void)setHeight: (CGFloat)height
{
	self.frame = CGRectMake(self.left, self.top, self.width, height);
}

- (CGFloat)bottom
{
	return CGRectGetMaxY(self.frame);
}

- (void)setBottom: (CGFloat)bottom
{
	CGFloat difference = self.bottom - bottom;

	self.top -= difference;
}

- (CGFloat)centerX
{
	return self.center.x;
}

- (void)setCenterX: (CGFloat)centerX
{
	self.center = CGPointMake(centerX, self.centerY);
}

- (CGFloat)centerY
{
	return self.center.y;
}

- (void)setCenterY: (CGFloat)centerY
{
	self.center = CGPointMake(self.centerX, centerY);
}

- (CGPoint)origin
{
	return self.frame.origin;
}

- (void)setOrigin: (CGPoint)origin
{
	self.left = origin.x;
	self.top = origin.y;
}

- (CGSize)size
{
	return self.frame.size;
}

- (void)setSize: (CGSize)size
{
	self.width = size.width;
	self.height = size.height;
}

@end
