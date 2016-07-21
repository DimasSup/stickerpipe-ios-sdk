//
//  STKStickerPanelCell.m
//  StickerFactory
//
//  Created by Vadim Degterev on 07.07.15.
//  Copyright (c) 2015 908 Inc. All rights reserved.
//

#import "STKStickerViewCell.h"
#import "UIImageView+Stickers.h"
#import "UIImage+Tint.h"
#import "STKUtility.h"
#import "DFImageManagerKit.h"
#import <SDWebImage/SDWebImageManager.h>
#import "STKStickerObject.h"
#import "STKImageManager.h"
#import "UIImageView+WebCache.h"
#import "STKStickersApiService.h"

#import "UIImage+CustomBundle.h"

static CGFloat imageWidth;

@interface STKStickerViewCell()

@property (strong, nonatomic) UIImageView *stickerImageView;
@property (strong, nonatomic) DFImageTask *imageTask;

@end

@implementation STKStickerViewCell

- (instancetype)initWithFrame:(CGRect)frame {
    
    self = [super initWithFrame:frame];
    if (self) {
        imageWidth = frame.size.height;
        self.stickerImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0, 0.0, imageWidth, imageWidth)];
        self.stickerImageView.center = CGPointMake(self.contentView.bounds.size.width/2,self.contentView.bounds.size.height/2);
        self.stickerImageView.contentMode = UIViewContentModeRedraw;
        [self addSubview:self.stickerImageView];
        self.backgroundColor = [UIColor clearColor];
    }
    return self;
}

- (void)setImageInset:(CGFloat)imageInset {
    _imageInset = imageInset;
    
    CGFloat imageWidthWithInset = imageWidth - imageInset * 2;
    self.stickerImageView.frame = CGRectMake(imageInset, imageInset, imageWidthWithInset, imageWidthWithInset);
    
    [self layoutSubviews];
}

- (void)layoutSubviews {
    self.stickerImageView.center = CGPointMake(self.contentView.bounds.size.width/2,self.contentView.bounds.size.height/2);
}

- (void)prepareForReuse {
    [self.imageTask cancel];
    self.imageTask = nil;
    self.stickerImageView.image = nil;
    [self.stickerImageView sd_cancelCurrentAnimationImagesLoad];
    [[SDWebImageManager sharedManager] cancelAll];
}

- (void) configureWithStickerMessage:(NSString*)stickerMessage
                         placeholder:(UIImage*)placeholder
                    placeholderColor:(UIColor*)placeholderColor
                      collectionView:(UICollectionView *)collectionView
                cellForItemAtIndexPath:(NSIndexPath *)indexPath
                           isSuggest:(BOOL)isSuggest {
    
    UIImage *resultPlaceholder = placeholder ? placeholder : [UIImage imageNamed:@"STKStickerPanelPlaceholder"];
    
    /**
     *  For framework
     */
    //    UIImage *resultPlaceholder = placeholder ? placeholder : [UIImage imageNamedInCustomBundle:@"STKStickerPanelPlaceholder"];
    
    UIColor *colorForPlaceholder = placeholderColor && !placeholder ? placeholderColor : [STKUtility defaultPlaceholderGrayColor];
    
    UIImage *coloredPlaceholder = [resultPlaceholder imageWithImageTintColor:colorForPlaceholder];
    
    [STKUtility imageUrlForStikerMessage:stickerMessage andDensity:[STKUtility scaleString]];
    
    DFImageRequestOptions *options = [DFImageRequestOptions new];
    options.priority = DFImageRequestPriorityNormal;
    
    if (isSuggest) {
        self.stickerImageView.image = [self imageWithColor:[UIColor clearColor]];
    } else {
        self.stickerImageView.image = coloredPlaceholder;
    }
    
    [self setNeedsLayout];
    
    __weak typeof(self) weakSelf = self;

    NSCharacterSet *characterSet = [NSCharacterSet characterSetWithCharactersInString:@"[]"];
    NSString *stickerName = [stickerMessage stringByTrimmingCharactersInSet:characterSet];
    
    [[SDImageCache sharedImageCache] queryDiskCacheForKey:stickerName done:^(UIImage *image, SDImageCacheType cacheType) {
        if (image) {
            weakSelf.stickerImageView.image = image;
            [weakSelf setNeedsLayout];
        }
        else {
            STKStickersApiService *stickersApiService = [STKStickersApiService new];
            [stickersApiService getStickerInfoWithId:stickerName success:^(id response) {
                
                NSString *urlString = response[@"data"][@"image"][[STKUtility scaleString]];
                
                SDWebImageDownloader *downloader = [SDWebImageDownloader sharedDownloader];
                
                [downloader downloadImageWithURL: [NSURL URLWithString:urlString]
                                         options:0
                                        progress:nil
                                       completed:^(UIImage *image, NSData *data, NSError *error, BOOL finished) {
                                           if (image && finished) {
                                               
                                               [[SDImageCache sharedImageCache] storeImage:image forKey:stickerName];
                                               dispatch_async(dispatch_get_main_queue(), ^{
                                                   
                                                   NSIndexPath *currentIndexPath = [collectionView indexPathForCell:weakSelf];
                                                   if ([currentIndexPath compare:indexPath] == NSOrderedSame) {
                                                       weakSelf.stickerImageView.image = image;
                                                       [weakSelf setNeedsLayout];
                                                   }
                                                   
                                               });
                                               
                                           }
                                       }];
            } failure:nil];
        }
        
    }];
    
    [self.imageTask resume];
    
}

- (UIImage *)imageWithColor:(UIColor *)color {
    CGRect rect = CGRectMake(0.0f, 0.0f, 64.0f, 64.0f);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}

@end
