//
//  STKStickerPanelCell.m
//  StickerFactory
//
//  Created by Vadim Degterev on 07.07.15.
//  Copyright (c) 2015 908 Inc. All rights reserved.
//

#import <SDWebImage/SDWebImageManager.h>
#import "STKStickerViewCell.h"
#import "UIImage+Tint.h"
#import "STKUtility.h"
#import "DFImageManagerKit.h"
#import "UIImageView+WebCache.h"
#import "STKWebserviceManager.h"
#import "UIView+CordsAdditions.h"
#import "UIView+LayoutAdditions.h"
#import "NSLayoutConstraint+Addictions.h"
#import "UIImage+CustomBundle.h"
#import "helper.h"

@interface STKStickerViewCell ()

@property (nonatomic, weak) UIImageView* imageView;
@property (nonatomic) DFImageTask* imageTask;

@property (nonatomic, copy) NSArray<NSLayoutConstraint*>* sizeConstraints;
@end

@implementation STKStickerViewCell

- (instancetype)initWithFrame: (CGRect)frame {
	if (self = [super initWithFrame: frame]) {
		UIImageView* imageView = [UIImageView layoutInst];
		imageView.contentMode = UIViewContentModeRedraw;
		[self addSubview: imageView];
		[NSLayoutConstraint attachToSuperviewCenterItsSubview: imageView];
		self.sizeConstraints = [NSLayoutConstraint setConstraintsWidth: self.height andHeight: self.height forView: imageView];
		self.imageView = imageView;

		self.backgroundColor = [UIColor clearColor];
	}

	return self;
}

- (void)setImageInset: (CGFloat)imageInset {
	_imageInset = imageInset;

	self.sizeConstraints[0].constant = self.height - imageInset;
	self.sizeConstraints[1].constant = self.height - imageInset;
}

- (void)prepareForReuse {
	[self.imageTask cancel];
	self.imageTask = nil;
	self.imageView.image = nil;
	[self.imageView sd_cancelCurrentAnimationImagesLoad];
	[[SDWebImageManager sharedManager] cancelAll];
}

- (void)configureWithStickerMessage: (NSString*)stickerMessage
						placeholder: (UIImage*)placeholder
				   placeholderColor: (UIColor*)placeholderColor
					 collectionView: (UICollectionView*)collectionView
			 cellForItemAtIndexPath: (NSIndexPath*)indexPath
						  isSuggest: (BOOL)isSuggest {
	UIImage* resultPlaceholder = nil;
	if (FRAMEWORK) {
		resultPlaceholder = placeholder ? placeholder : [UIImage imageNamedInCustomBundle: @"STKStickerPanelPlaceholder"];
	} else {
		resultPlaceholder = placeholder ? placeholder : [UIImage imageNamed: @"STKStickerPanelPlaceholder"];
	}

	UIColor* colorForPlaceholder = placeholderColor && !placeholder ? placeholderColor : [STKUtility defaultPlaceholderGrayColor];

	UIImage* coloredPlaceholder = [resultPlaceholder imageWithImageTintColor: colorForPlaceholder];

	if (isSuggest) {
		self.imageView.image = [self imageWithColor: [UIColor clearColor]];
	} else {
		self.imageView.image = coloredPlaceholder;
	}

	[self setNeedsLayout];

	typeof(self) __weak weakSelf = self;

	NSCharacterSet* characterSet = [NSCharacterSet characterSetWithCharactersInString: @"[]"];
	NSString* stickerName = [stickerMessage stringByTrimmingCharactersInSet: characterSet];

	[[SDImageCache sharedImageCache] queryDiskCacheForKey: stickerName done: ^ (UIImage* image, SDImageCacheType cacheType) {
		if (image) {
			weakSelf.imageView.image = image;
			[weakSelf setNeedsLayout];
		} else {
			[[STKWebserviceManager sharedInstance] getStickerInfoWithId: stickerName success: ^ (id response) {
				NSString* urlString = response[@"data"][@"image"][[STKUtility scaleString]];

				SDWebImageDownloader* downloader = [SDWebImageDownloader sharedDownloader];

				[downloader downloadImageWithURL: [NSURL URLWithString: urlString]
										 options: 0
										progress: nil
									   completed: ^ (UIImage* image, NSData* data, NSError* error, BOOL finished) {
										   if (image && finished) {
											   [[SDImageCache sharedImageCache] storeImage: image forKey: stickerName];
											   dispatch_async(dispatch_get_main_queue(), ^ {

												   NSIndexPath* currentIndexPath = [collectionView indexPathForCell: weakSelf];
												   if ([currentIndexPath compare: indexPath] == NSOrderedSame) {
													   weakSelf.imageView.image = image;
													   [weakSelf setNeedsLayout];
												   }
											   });
										   }
									   }];
			}                                                   failure: nil];
		}
	}];

	[self.imageTask resume];

}

- (UIImage*)returnStickerImage {
	return self.imageView.image;
}

- (void)hideStickerImage: (BOOL)isHide {
	if (isHide) {
		self.imageView.alpha = 0.0;
	} else {
		self.imageView.alpha = 1.0;
	}
}

- (UIImage*)imageWithColor: (UIColor*)color {
	CGRect rect = CGRectMake(0.0f, 0.0f, 64.0f, 64.0f);
	UIGraphicsBeginImageContext(rect.size);
	CGContextRef context = UIGraphicsGetCurrentContext();

	CGContextSetFillColorWithColor(context, [color CGColor]);
	CGContextFillRect(context, rect);

	UIImage* image = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();

	return image;
}

@end
