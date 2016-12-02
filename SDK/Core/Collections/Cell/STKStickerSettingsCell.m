//
//  STKStickerSettingsCell.m
//  StickerPipe
//
//  Created by Vadim Degterev on 05.08.15.
//  Copyright (c) 2015 908 Inc. All rights reserved.
//

#import "STKStickerSettingsCell.h"
#import "DFImageManagerKit.h"
#import "STKWebserviceManager.h"
#import "STKStickerPack+CoreDataProperties.h"


@implementation STKStickerSettingsCell

- (void)prepareForReuse {
	[self.packIconImageView df_prepareForReuse];
}

- (void)configureWithStickerPack: (STKStickerPack*)stickerPack {
	NSURL* iconUrl = [[STKWebserviceManager sharedInstance] mainImageUrlForPackName: stickerPack.packName];

	[self.packIconImageView df_setImageWithResource: iconUrl];
	self.packTitleLabel.text = stickerPack.packTitle;
	self.packDescriptionLabel.text = stickerPack.artist;
}

@end
