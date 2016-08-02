//
// Created by Vadim Degterev on 12.08.15.
// Copyright (c) 2015 908 Inc. All rights reserved.
//

#import "STKShowStickerButton.h"

@implementation STKShowStickerButton

static const CGFloat kBadgeViewPadding = 4.0;

- (void)awakeFromNib {
	[self initBadgeView];
}

- (instancetype)initWithFrame: (CGRect)frame {
	if (self = [super initWithFrame: frame]) {
		[self initBadgeView];
	}

	return self;
}

- (void)initBadgeView {
	self.imageView.contentMode = UIViewContentModeScaleAspectFit;

	UIColor* color = (self.badgeBorderColor) ? self.badgeBorderColor : [UIColor whiteColor];

	self.badgeView = [[STKBadgeView alloc] initWithFrame: CGRectMake(0, 0, 16.0, 16.0) lineWidth: 2.0 dotSize: CGSizeZero andBorderColor: color];
	self.badgeView.center = CGPointMake(CGRectGetMaxX(self.imageView.frame) - kBadgeViewPadding, CGRectGetMinY(self.imageView.frame) + kBadgeViewPadding);
	[self addSubview: self.badgeView];
}

- (void)layoutSubviews {
	[super layoutSubviews];
	self.badgeView.center = CGPointMake(CGRectGetMaxX(self.imageView.frame) - 2.0f, CGRectGetMinY(self.imageView.frame) + kBadgeViewPadding);
}

- (void)setStickerButtonState: (STKShowStickerButtonState)showStickerButtonState {
	_stickerButtonState = showStickerButtonState;

	if (showStickerButtonState == STKShowStickerButtonStateStickers) {
		UIImage* buttonImage = [UIImage imageNamed: STK_TEXTBUTTON_STICKERS];

		/**
		 *  For framework
		 */
		//UIImage *buttonImage = [UIImage imageNamedInCustomBundle:@"STKShowStickersIcon"];

		[self setImage: buttonImage forState: UIControlStateNormal];
		[self setImage: buttonImage forState: UIControlStateHighlighted];
	} else {
		UIImage* buttonImage = [UIImage imageNamed: STK_TEXTBUTTON_KEYBOARD];

		/**
		 *  For framework
		 */
		//UIImage *buttonImage = [UIImage imageNamedInCustomBundle:@"STKShowKeyboadIcon"];

		[self setImage: buttonImage forState: UIControlStateNormal];
		[self setImage: buttonImage forState: UIControlStateHighlighted];
	}
}


@end